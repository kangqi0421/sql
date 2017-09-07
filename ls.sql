--------------------------------------------------------------------------------
--
-- File name:   ls.sql
-- Purpose:     List datafiles of given &1 TABLESPACE
--
-- Changes:     - added support for ASM and Filesystems
--              - ASM files are sorted by file id, filesystem is sorted by suffix number at file name
--
--------------------------------------------------------------------------------

--set define off  -- pro SQLdeveloper, at se nezasekne
set lines 180 pages 999 verify off feedback off

/* SQLDeveloper does not handle noprint very nice */
define noprint=""
col sqlplus_sqld noprint new_value noprint
select decode(substr(program,1,7),'sqlplus','noprint','') sqlplus_sqld
from v$session where sid = (select sid from v$mystat where rownum = 1);


--// formatovani sloupcu //--
col tablespace_name for a30
col file_name for a65

--// dynamicky generovane SQL //--
set termout off

define _IF_ASM="--"
define _IF_FS="--"

define AUTOEXTEND="autoextend on next 512m maxsize "

col if_asm	&noprint new_value _IF_ASM
col if_fs	&noprint new_value _IF_FS
col dfSize	&noprint new_value  dfSize

--// detekce ASM dle db_create_file_dest //--
select decode(substr(value,1,1),'+','',NULL,'--') if_asm from v$parameter where name = 'db_create_file_dest';
select decode(substr(value,1,1),'+','--',NULL,'') if_fs  from v$parameter where name = 'db_create_file_dest';

--// detekce velikosti souboru dfSize, pro 8k block pouze 32767, jinak 32G //--
--
-- 8k block -> 32 767M
-- 16k+     -> 32 768M
--
select decode(value, 8192, 32767, 65535) dfSize from v$parameter where name = 'db_block_size';

set termout on

--// aktualni velikosti datafiles //--
SELECT
    tablespace_name
	, file_id
	, file_name
	, round(bytes/1048576, 2) "MB"
	, autoextensible
  , (INCREMENT_BY * (select value from v$parameter where name = 'db_block_size'))/1048576 "inc MB"
  , round(maxbytes/1048576, 2) "max MB"
 FROM (select tablespace_name, file_id, file_name, autoextensible, bytes, maxbytes, increment_by from dba_data_files
       union all
       select tablespace_name, file_id, file_name, autoextensible, bytes, maxbytes, increment_by from dba_temp_files
      )
     WHERE upper(tablespace_name) like upper('&1')
   ORDER BY tablespace_name
&_IF_ASM , file_id  -- pro ASM setrid dle file_id
&_IF_FS  , SUBSTR (file_name, INSTR (file_name, '/', -1, 1) + 1) -- pro filesystem setrid dle cisla koncovky file_name
;

prompt
prompt DB: dba_data_files JOIN dba_free_space:
SELECT   f.tablespace_name,
    f.total_max_size                                  "max size [MB]",
    f.total_size                                      "alloc space [MB]",
    -- f.total_size - NVL (s.free_space, 0)           "alloc space [MB]",
	 (f.total_max_size - f.total_size) + NVL (s.free_space, 0) "free space [MB]",
    round((f.total_size - NVL (s.free_space, 0))/f.total_max_size*100) "Space Used (%)"
  FROM
    (
      SELECT   tablespace_name,
               round(SUM (bytes/1048576)) total_size,
               round(SUM (bytes_total/1048576)) total_max_size
        FROM
          (
            SELECT   tablespace_name, BYTES,
                CASE
                  WHEN autoextensible = 'NO'    THEN BYTES
                  WHEN autoextensible = 'YES'   THEN maxbytes
                END bytes_total
              FROM dba_data_files
          )
        GROUP BY tablespace_name
    ) f
  INNER JOIN
    (
      SELECT   tablespace_name,
          round(SUM (BYTES/1048576)) free_space
        FROM dba_free_space
        GROUP BY tablespace_name
    ) s
  ON (s.tablespace_name   = f.tablespace_name)
  WHERE upper(s.tablespace_name) like upper('&1')
 ORDER BY tablespace_name
  ;

prompt
prompt ASM: dg info:
SELECT name, round(total_mb/1024) "Total GB", round(free_mb/1024) "Free GB" FROM v$asm_diskgroup
  WHERE name in (select ltrim(value,'+') from v$parameter where name = 'db_create_file_dest');

prompt
prompt ASM: free for autoextend:
SELECT ROUND( (SELECT TOTAL_MB / 1024 GB
         FROM V$ASM_DISKGROUP
        WHERE name in (select ltrim(value,'+') from v$parameter where name = 'db_create_file_dest'))
-
(SELECT (        a.data_size
               + b.temp_size
               + c.redo_size
               + d.cf_size
               + e.bct_size) /1024/1024/1024  GB
  FROM
       (SELECT SUM (DECODE (autoextensible, 'YES', maxbytes, bytes)) data_size FROM dba_data_files) a,
       (SELECT NVL (SUM (DECODE (autoextensible, 'YES', maxbytes, bytes)) , 0) temp_size FROM dba_temp_files) b,
       (SELECT SUM (bytes) redo_size FROM v$log) c,
       (SELECT SUM (block_size * file_size_blks) cf_size FROM v$controlfile)   d,
       (SELECT NVL (bytes, 0) bct_size FROM v$block_change_tracking) e
       )) "free [GB]"
FROM DUAL;

prompt
prompt Resize: prvni datafile dle bytes ASC
prompt ======

set head off

-- debug
-- set termout on echo on

WITH file_id_row as (
SELECT file_id
  FROM (  SELECT file_id,
                 bytes
            FROM (
			    SELECT   file_id, file_name,
			        CASE
					  WHEN autoextensible = 'NO'  THEN bytes
					  WHEN autoextensible = 'YES' THEN maxbytes
					END bytes
				FROM dba_data_files
                 WHERE UPPER (tablespace_name) LIKE UPPER ('&&1')
									)
			WHERE	1=1
            -- AND bytes < &dfSize * 1048576
        ORDER BY bytes
        )
 WHERE ROWNUM = 1
)
SELECT 'alter database datafile ' || file_id || ' resize &dfSize.m;' from file_id_row
UNION ALL
SELECT 'alter database datafile ' || file_id || ' &AUTOEXTEND &dfSize.m;' from file_id_row
/


prompt
prompt Add datafile:
prompt =============

WITH tablespace_row AS (
SELECT TABLESPACE_NAME
  FROM dba_tablespaces
           WHERE  UPPER (tablespace_name) LIKE UPPER ('&&1')
)
SELECT 'alter tablespace '||TABLESPACE_NAME||' add datafile '||
&_IF_FS    '''  ''' ||
        ' size &dfSize.m;'
  FROM tablespace_row
UNION ALL
SELECT 'alter tablespace '||TABLESPACE_NAME||' add datafile '||
&_IF_FS    '''  ''' ||
        ' size 512m &AUTOEXTEND &dfSize.m;'
  FROM tablespace_row;

prompt

set head on feedback on verify on