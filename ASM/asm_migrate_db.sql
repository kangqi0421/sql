--
-- ASM migrate disks per database
--

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

spool off

spool asm_disks_FRA.sql


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

spool off

exit
