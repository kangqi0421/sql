--
-- ASM přidání disků
--

-- migrace disků
nahraženo postupem na wiki
https://foton.vs.csin.cz/dbawiki/playground:jirka:asm_migrate_disks

-- select PER DB
SET echo off heading off verify off feed off trims on pages 0 lines 32767

spool asm_disks_DATA.sql

-- MIGRATE DATA
SELECT  'ALTER DISKGROUP '||name||CHR(10)
  || ' ADD DISK'||CHR(10)
  || add_disk || CHR(10)
  || 'DROP DISK'||CHR(10)
  || drop_disk || CHR(10)
  || '/'||CHR(10)|| 'exit' || CHR(10)
FROM (
with dg as
(
select
    dg.name,
    regexp_substr(p.value, '[A-Z]+', 1, 1) dg_short,
    dg.group_number
  from V$ASM_DISKGROUP_STAT dg,
       V$PARAMETER p
 where dg.name = ltrim(p.value, '+')
       and p.name = 'db_create_file_dest'
)
select
  add_disk, drop_disk, dg.name
 from (
   -- add disk
   SELECT
     LISTAGG(''''||a.path||'''', ','||chr(10)) WITHIN GROUP (ORDER BY a.path) AS add_disk
    from
       V$ASM_DISK a,
       dg
 WHERE a.header_status = 'CANDIDATE'
   AND REGEXP_LIKE (a.path, dg.dg_short||'_'||'(DATA|D01)', 'i')
   ),
  (
  -- drop disk
  SELECT
     LISTAGG(d.name, ','||chr(10)) WITHIN GROUP (ORDER BY d.name) AS drop_disk
    from
       V$ASM_DISK_STAT d,
       dg
   WHERE d.header_status = 'MEMBER'
   AND d.group_number = dg.group_number
  ),
  dg
)
/

-- migrate FRA
SELECT  'ALTER DISKGROUP '||name||CHR(10)
  || ' ADD DISK'||CHR(10)
  || add_disk || CHR(10)
  || 'DROP DISK'||CHR(10)
  || drop_disk || CHR(10)
  || '/'||CHR(10)|| 'exit' || CHR(10)
FROM (
with dg as
(
select
    dg.name,
    regexp_substr(p.value, '[A-Z]+', 1, 1) dg_short,
    dg.group_number
  from V$ASM_DISKGROUP_STAT dg,
       V$PARAMETER p
 where dg.name = ltrim(p.value, '+')
       and p.name = 'db_recovery_file_dest'
)
select
  add_disk, drop_disk, dg.name
 from (
   -- add disk
   SELECT
     LISTAGG(''''||a.path||'''', ','||chr(10)) WITHIN GROUP (ORDER BY a.path) AS add_disk
    from
       V$ASM_DISK a,
       dg
 WHERE a.header_status = 'CANDIDATE'
   AND REGEXP_LIKE (a.path, dg.dg_short||'_'||'FRA', 'i')
   ),
  (
  -- drop disk
  SELECT
     LISTAGG(d.name, ','||chr(10)) WITHIN GROUP (ORDER BY d.name) AS drop_disk
    from
       V$ASM_DISK_STAT d,
       dg
   WHERE d.header_status = 'MEMBER'
   AND d.group_number = dg.group_number
  ),
  dg
)
/

-- nové disky
asmcmd lsdsk --candidate --suppressheader

-- migrované asm dg
asmcmd lsdsk --candidate --suppressheader | grep -Poi '([A-Z]+)_(D01|DATA|FRA)' | uniq

([A-Z]+)_(D01|FRA)p1

sqlplus / as sysasm

set lines 32767 trims on
column cmd for a32767

select 'ALTER DISKGROUP ' ||dg||
         ' ADD DISK ' ||
          listagg(''''||path||'''',',') within group (order by path) ||
          ';' as cmd
from (
select regexp_replace(path,
          '^/dev/(mapper/(\w+_){3}|rlvo)([a-zA-Z]+)[_]?(D01|d01|FRA|fra)(p1|\d+)',
          '\3_\4',1,0,'i') as dg,
       path
    from v$asm_disk
  where header_status in ('CANDIDATE','FORMER')
  )
group by dg
;


asmcmd lsdsk -k  --candidate

select path, header_status from v$asm_disk
  where header_status not in ('MEMBER')
;


---
alter diskgroup CMTD_D01 add disk '/dev/mapper/asm_449_003*_CMTD_D01p1';

alter diskgroup RDBPKA_D01
  drop disk RDBPKA_D01_0004,RDBPKA_D01_0008,RDBPKA_D01_0017,RDBPKA_D01_0024;




-- kontrolni info
select NAME, GROUP_NUMBER, state from v$asm_diskgroup;

-- pridani DM multipath disks
show parameter spfile
show parameter asm_diskstring
ALTER SYSTEM SET asm_diskstring = '/dev/oracleasm/disks/*','/dev/mapper/asm_449*p1';


-- DROP disks
set trims on pages 0 lines 32767
select 'DROP DISK'||CHR(10) from dual;

select LISTAGG(name, ','||chr(10)) WITHIN GROUP (ORDER BY name)
  from v$asm_disk
 where 1 = 1
   and header_status = 'MEMBER' -- pouze jiz existujici
   and GROUP_NUMBER in (
		select GROUP_NUMBER from v$asm_diskgroup where name like 'CLMT_D01'
		)
   --and OS_MB = 111653               -- a velikost 55GB
   and path like '/dev/mapper/asm_210873%'
;


-- funguje pouze z ASM instance
select * from v$asm_operation;


set lines 180 pages 999
col name for a14
col type for a6
col COMPATIBILITY for a15
col DATABASE_COMPATIBILITY for a15
col path format a40

select name, TYPE, TOTAL_MB, FREE_MB, COMPATIBILITY, DATABASE_COMPATIBILITY from v$asm_diskgroup;

select name, header_status,state, path, total_mb, free_mb,disk_number
  from v$asm_disk
order by NAME;


--
alter diskgroup CLMT_D01 drop disk
CLMT_D01_0020,
CLMT_D01_0021,
CLMT_D01_0022,
CLMT_D01_0023,
CLMT_D01_0024,
CLMT_D01_0025,
CLMT_D01_0026,
CLMT_D01_0027,
CLMT_D01_0028,
CLMT_D01_0029,
CLMT_D01_0030,
CLMT_D01_0031,
CLMT_D01_0032,
CLMT_D01_0033,
CLMT_D01_0034;
