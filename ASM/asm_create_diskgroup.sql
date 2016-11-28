# ASM disk groups

## list new asm diskgroups
sqlplus / as sysasm <<ESQL
select unique
        regexp_replace(path,
          '^/dev/mapper/asm.*_([A-Z]+)_(D01|FRA)p1',
          '\1_\2',
          1,0,'i') AS dg
  from v\$asm_disk
 where header_status in ('CANDIDATE','FORMER')
order by 1;
exit
ESQL

## create
AU_SIZE=4M
sqlplus -s / as sysasm <<ESQL
SET heading off verify off feed off trims on pages 0 lines 32767
define au_size=$AU_SIZE
spool asm_create_dg.sql
-- nazev DG je vytvoøen pøes regexp
-- '^/dev/(mapper/(\w+_){3}|rlvo)([a-zA-Z]+)[_]?(D01|d01|DATA|data|FRA|fra)(p1|\d+)','\3_\4'
-- AIX /dev/rlvo
-- Linux /dev/mapper
-- /dev/mapper/asm_srdf-metro_01CA_RTOZA_D01p1
SELECT
  'CREATE DISKGROUP ' || dg
    ||' EXTERNAL REDUNDANCY '||chr(10)|| 'DISK'||CHR(10)
    || disk||chr(10)
    || 'ATTRIBUTE ''AU_SIZE''=''&au_size'', ''compatible.asm''=''12.1'',''compatible.rdbms''=''12.1'';'
  as cmd
FROM
   (
    SELECT
      regexp_replace(path,
        '^/dev/mapper/asm.*_([A-Z]+)_(D01|DATA|FRA)p1',
        '\1_\2',
        1,0,'i') AS dg,
      LISTAGG(''''||path||'''', ','||chr(10)) WITHIN GROUP (ORDER BY path) disk
    FROM V\$ASM_DISK
    WHERE
      header_status in ('CANDIDATE','FORMER')
    GROUP BY
       regexp_replace(path,
        '^/dev/mapper/asm.*_([A-Z]+)_(D01|DATA|FRA)p1',
        '\1_\2',
        1,0,'i')
  )
/

prompt exit

spool off;
ESQL

sqlplus / as sysasm @asm_create_dg.sql

## list ASM diskgroups and compatibility
sqlplus / as sysasm <<ESQL
set lines 180
col name for a10
col type for a6
col COMPATIBILITY for a15
col DATABASE_COMPATIBILITY for a15
select name, TYPE, TOTAL_MB, FREE_MB, ALLOCATION_UNIT_SIZE/1048576 AU_SIZE, COMPATIBILITY, DATABASE_COMPATIBILITY
  from v\$asm_diskgroup
ORDER by NAME;
ESQL


## RAC: mount asm dg na všech nodech
for dg in $(asmcmd lsdg --suppressheader | awk '{print $NF}' | tr -d '/')
do
  srvctl start diskgroup -diskgroup $dg
done

crs
