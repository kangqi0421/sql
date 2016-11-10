set newpage none 
set linesize 100
spool /tmp/asmdebug.out
--
-- Get a timestamp
select rpad('>', 10, '>'), to_char(sysdate, 'MON DD HH24:MM:SS') from dual;
--
-- Diskgroup information
set head off
select 'Diskgroup Information' from dual;
set head on
column name format a15
column DG# format 99
select group_number DG#, name, state, type, total_mb, free_mb from
v$asm_diskgroup;
--
-- Get the # of Allocation Units  per DG
set head off
select 'Number of AUs per diskgroup' from dual;
set head on
select count(number_kfdat) AU_count, group_kfdat DG# from x$kfdat
group by group_kfdat;
--
-- Get the # of Allocation Units  per DiskGroup and Disk
set head off
select 'Number of AUs per Diskgroup,Disk' from dual;
col "group#,disk#" for a30
set head on
select count(*)AU_count, GROUP_KFDAT||','||number_kfdat "group#,disk#" from x$kfdat group by GROUP_KFDAT,number_kfdat;
--
-- Get the # of allocated (V) and free (F) Allocation Units
set head off
select 'Number of allocated (V) and free (F) Allocation Units' from dual;
col "VF" for a2
set head on
select GROUP_KFDAT "group#", number_kfdat "disk#", v_kfdat "VF", count(*)
from x$kfdat
group by GROUP_KFDAT, number_kfdat, v_kfdat;


--
-- Get the # of Allocation Units per ASM file
set head off
select 'Number of AUs per ASM file ordered by AU count for metadata only'
from dual;
set head on
select count(XNUM_KFFXP) AU_count,  NUMBER_KFFXP file#, GROUP_KFFXP DG# from x$kffxp where NUMBER_KFFXP < 256
group by NUMBER_KFFXP, GROUP_KFFXP
order by count(XNUM_KFFXP) ;
--
-- Get the # of Allocation Units per ASM file by file alias.  Change the
-- system_created Y|N depending if you want the short or long ASM name
set head off
select 'Number of AUs per ASM file ordered by AU count.  This is for non
metadata' from dual;
col name format a60
set head on
select GROUP_KFFXP, NUMBER_KFFXP, name, count(*)
from x$kffxp, v$asm_alias
where GROUP_KFFXP=GROUP_NUMBER and NUMBER_KFFXP=FILE_NUMBER and
system_created='Y'
     group by GROUP_KFFXP, NUMBER_KFFXP, name
     order by GROUP_KFFXP, NUMBER_KFFXP;
--
-- Get partner information.  This is really only useful if redundancy is other than
-- external.
set head off
select 'The following shows the disk to partner relationship.  This is really only
useful if using normal or high redundancy.' from dual;
set head on
select grp DG#, disk, NUMBER_KFDPARTNER partner, PARITY_KFDPARTNER parity, ACTIVE_KFDPARTNER active
from x$kfdpartner;
--
-- Another look at file utilization.
set head off
set linesize 132
select 'bytes is the sum of AUs with data in them * 1024^2
space is the sum of all AUs allocated for this file * 1024^2'
from dual;
set head on
col Name format a60
select f.group_number, f.file_number, bytes, space, space/(1024*1024) "InMB", a.name "Name"
from v$asm_file f, v$asm_alias a
where f.group_number=a.group_number and f.file_number=a.file_number
    and system_created='Y'
    order by f.group_number, f.file_number;
--
-- Get robust disk information
set linesize 400
col failgroup format a20
col label format a20
col name format a40
col path format a40
set head off
select 'Robust disk information' from dual;
set head on
select GROUP_NUMBER, DISK_NUMBER, INCARNATION, MOUNT_STATUS, HEADER_STATUS, MODE_STATUS, STATE, LIBRARY, TOTAL_MB, FREE_MB,
NAME, FAILGROUP, LABEL, PATH, CREATE_DATE, MOUNT_DATE, READS,
WRITES, READ_ERRS, WRITE_ERRS, READ_TIME, WRITE_TIME, BYTES_READ, BYTES_WRITTEN
from v$asm_disk;
--
spool off
