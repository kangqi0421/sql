column spoolname new_value spoolname noprint;
select name ||'_'||to_char(sysdate, 'yyyyddmm_hh24miss') spoolname from v$database;

SET LINES 32767 trims ON pages 9999 echo ON

spool &spoolname._db_info.txt

-- datafiles pouze umisteni
select name from v$datafile;

-- tempfiles vcetne size
SELECT d.file_name, d.bytes/1048576 MB, d.autoextensible EXT,
       decode(d.autoextensible, 'YES', round(d.maxbytes/1048576), null) MAXSIZE 
 from dba_temp_files d;

-- undo vcetne size
SELECT t.tablespace_name, d.file_name, d.bytes/1048576 MB, 
       autoextensible EXT,decode(autoextensible, 'YES', round(maxbytes/1048576), null) MAXSIZE
  FROM    dba_tablespaces t
       INNER JOIN
          dba_data_files d
       ON (t.tablespace_name = d.tablespace_name)
 WHERE t.contents = 'UNDO';

-- logfile a controlfile
select member from v$logfile;
select name from v$controlfile;

-- block change tracking a flashback
select status from v$block_change_tracking;
select FLASHBACK_ON from v$database;

-- spfile
select value from v$parameter where name = 'spfile';

