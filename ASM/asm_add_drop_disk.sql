--
-- ASM přidání disků

asmcmd lsdsk -k --candidate

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



-- migrace disků

nahraženo postupem na wiki
https://foton.vs.csin.cz/dbawiki/playground:jirka:asm_migrate_disks

-- kontrolni info
select NAME, GROUP_NUMBER, state from v$asm_diskgroup;

-- pridani DM multipath disks
show parameter spfile
show parameter asm_diskstring
ALTER SYSTEM SET asm_diskstring = '/dev/oracleasm/disks/*','/dev/mapper/asm_449*p1';

--//  START script  //--

-- definice diskgroup D01/FRA
def dg="D01"
--def dg="FRA"

SET heading off verify off feed off trims on pages 0 lines 4000

spool asm_disks_&dg..sql


-- ALTER diskgroup
select 'ALTER DISKGROUP '||name||' ADD DISK'||CHR(10)
  from v$asm_diskgroup
 where name
    like '%&dg'
--	in (select ltrim(value, '+') from v$parameter where name = 'db_create_file_dest')
/

--ADD candidate disks
select LISTAGG(''''||path||'''', ','||chr(10)) WITHIN GROUP (ORDER BY path)  -- path do uvozovek, kazdy disk na samostatny radek
  from v$asm_disk
 where header_status = 'CANDIDATE'
       and lower(path) like lower('%&dg%')
order by disk_number
;

-- DROP disks
select 'DROP DISK'||CHR(10) from dual;

select LISTAGG(name, ','||chr(10)) WITHIN GROUP (ORDER BY name)
  from v$asm_disk
 where 1 = 1
   and header_status = 'MEMBER' -- pouze jiz existujici
   and GROUP_NUMBER in (
		select GROUP_NUMBER from v$asm_diskgroup where name like 'ESPZA_D01'
		)
   and OS_MB = 111653               -- a velikost 55GB
   --and substr(path, 6, 5) in ('vgr02')
;


select '/'||CHR(10) from dual;

spool off;

--
-- End Of Scipt
--


-- add drop disk - old version
SET heading off verify off feed off trims on pages 0 lines 4000

spool asm_migration_disks.sql

select 'ALTER DISKGROUP '||name||' ADD DISK'||CHR(10) from v$asm_diskgroup where name like '%D01';

select LISTAGG(''''||path||'''', ','||chr(10)) WITHIN GROUP (ORDER BY path)  -- path do uvozovek, kazdy disk na samostatny radek
  from v$asm_disk
 where header_status = 'CANDIDATE'
and path like '%D01%';

select 'DROP DISK'||CHR(10) from dual;

select LISTAGG(name, ','||chr(10)) WITHIN GROUP (ORDER BY name)
  from v$asm_disk
 where GROUP_NUMBER = 1         -- pouze disky GRP#1
   and header_status = 'MEMBER' -- pouze jiz existujici
and OS_MB = 55808               -- a velikost 55GB
and substr(path, 6, 5) in ('vgr02')  ;

select '/'||CHR(10) from dual;

spool off;


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
