# ASM disk groups

```
asmcmd dsget

asmcmd dsset '/dev/mapper/asm_250FX_*_OCR','/dev/mapper/asm*p1'
```


## list new asm diskgroups
sqlplus / as sysasm <<ESQL
select unique
        regexp_replace(path,
          '^/dev/mapper/asm.*_([A-Z]+)_(D01|DATA|FRA)(p1|\d+)?',
          '\1_\2',
          1,0,'i') AS dg
  from v\$asm_disk
 where header_status in ('CANDIDATE','FORMER')
order by 1;
exit
ESQL

## vyzkouset vytvoreni ASM diskgroupy pres asmca -silent
asmcmd lsdsk --suppressheader --candidate

asmcmd lsdsk --suppressheader --candidate | \
  grep -Poi '([A-Z]+)_(D0\d|DATA|FRA)' | uniq

for db in BRATB BRATC CPSTSYS CPSTINT CPSTPRS
do

dg=${db}_DATA
au_size=64
##au_size=8
DB_COMPATIBLE="12.1"
ASM_COMPATIBLE="12.2"
echo "dg: $dg"
asmca -silent -createDiskGroup \
  -diskGroupName $dg \
    -diskList "'/dev/mapper/asm_*${dg}" \
  -redundancy EXTERNAL -au_size ${au_size} \
  -compatible.asm ${ASM_COMPATIBLE} -compatible.rdbms ${DB_COMPATIBLE} -compatible.advm ${ASM_COMPATIBLE}

done

DG=${db}_FRA
au_size=8
DB_COMPATIBLE="12.1"
ASM_COMPATIBLE="12.2"
asmca -silent -createDiskGroup \
  -diskGroupName $DG \
    -diskList "'/dev/mapper/asm_*${DG}1" \
  -redundancy EXTERNAL -au_size ${au_size} \
  -compatible.asm ${ASM_COMPATIBLE} -compatible.rdbms ${DB_COMPATIBLE} -compatible.advm ${ASM_COMPATIBLE}


### DWH PoC

asmca -silent -createDiskGroup -diskGroupName DWHDD18Z_DATA -diskList '/dev/mapper/asm_*DATA1' -redundancy EXTERNAL -au_size 64 -compatible.asm '12.2' -compatible.advm '12.2' -compatible.rdbms '12.2'


## asmcmd compatible

compatible.asm
compatible.rdbms

vypis lsdg:
`asmcmd lsdg`

dg=JIRKA_DATA

for dg in JIRKA_DATA
do
  asmcmd lsattr -l -G $dg
  asmcmd setattr -G $dg compatible.asm 19.0
  asmcmd setattr -G $dg compatible.rdbms 12.1
  asmcmd lsattr -l -G $dg
  # asmcmd mount $dg
done


select name from v$asm_diskgroup;


## upgrade na 12.2, pokud je compatible men�� nez 10.0
for each in ECRST_FRA ESPE_D01 ECRSTB_FRA ECRSTB_D01 ECRSTC_D01 ESPT_FRA ECRSTC_FRA ESPE_FRA ECRST_D01
do
sqlplus / as sysasm <<ESQL
alter diskgroup $each mount restricted;
alter diskgroup $each set attribute 'compatible.asm'='11.2.0.2.0';
alter diskgroup $each dismount;
alter diskgroup $each mount;
ESQL
done


## mount ALL - v novejsich verzich ...
asmcmd mount -a


## asmcmd dropdg

asmcmd mount DLKZ_FRA
asmcmd dropdg -r DLKZ_FRA


## asmcmd mkdg
AU_SIZE=4M
COMPATIBLE="12.1"

cat >
<dg name="data" redundancy="normal">
     <fg name="fg1">
          <dsk string="/dev/disk1"/>
          <dsk string="/dev/disk2"/>
     </fg>
     <fg name="fg2">
          <dsk string="/dev/disk3"/>
          <dsk string="/dev/disk4"/>
     </fg>

     <a name="compatible.asm" value="11.2" />
     <a name="compatible.rdbms" value="11.2" />
     <a name="compatible.advm" value="11.2" />
</dg>


## create ASM diskgroup
AU_SIZE=4M
COMPATIBLE="12.1"
sqlplus -s / as sysasm <<ESQL
SET heading off verify off feed off trims on pages 0 lines 32767
define au_size=${AU_SIZE}
define compatible=${COMPATIBLE}
spool asm_create_dg.sql
-- nazev DG je vytvo�en p�es regexp
-- '^/dev/(mapper/(\w+_){3}|rlvo)([a-zA-Z]+)[_]?(D01|d01|DATA|data|FRA|fra)(p1|\d+)','\3_\4'
-- AIX /dev/rlvo
-- Linux /dev/mapper
-- /dev/mapper/asm_srdf-metro_01CA_RTOZA_D01p1
SELECT
  'CREATE DISKGROUP ' || dg
    ||' EXTERNAL REDUNDANCY '||chr(10)|| 'DISK'||CHR(10)
    || disk||chr(10)
    || 'ATTRIBUTE ''AU_SIZE''=''&au_size'', ''compatible.asm''=''&compatible'',''compatible.rdbms''=''&compatible'';'
  as cmd
FROM
   (
    SELECT
      regexp_replace(path,
        '^/dev/mapper/asm.*_([A-Z]+)_(D0\d|DATA|FRA)(p1|\d)?',
        '\1_\2',
        1,0,'i') AS dg,
      LISTAGG(''''||path||'''', ','||chr(10)) WITHIN GROUP (ORDER BY path) disk
    FROM V\$ASM_DISK
    WHERE
      header_status in ('CANDIDATE','FORMER')
      --and path like '%CLMT%'
    GROUP BY
       regexp_replace(path,
        '^/dev/mapper/asm.*_([A-Z]+)_(D0\d|DATA|FRA)(p1|\d)?',
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


## RAC: mount asm dg na v�ech nodech
for dg in $(asmcmd lsdg --suppressheader | awk '{print $NF}' | tr -d '/')
do
  srvctl start diskgroup -diskgroup $dg
done

crs

## get ASM diskgroups


```sql          select
             '[' ||
              LISTAGG(dbms_assert.enquote_name(dg.name), ',')
                  WITHIN GROUP (order by dg.name) ||
              ']' as json_array
            from V\$ASM_DISKGROUP_STAT dg,
                 V\$PARAMETER p
          where dg.name = ltrim(p.value, '+')
                and p.name in
                  ('db_create_file_dest', 'db_recovery_file_dest')
          /
```