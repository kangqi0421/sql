--
-- backup validate check logical database
--

-- ARCHVIELOG
cat > validate.rman <<EOD
set echo on;
connect target /;
run {
allocate channel d1 type disk;
allocate channel d2 type disk;
allocate channel d3 type disk;
allocate channel d4 type disk;
backup validate check logical database;
}
EOD
echo "rman cmdfile validate.rman > validate.${ORACLE_SID}.log 2>&1" | at now


-- NOARCHIVELOG

at now <<EAT
{
sqlplus -S / as sysdba <<ESQL | rman target /
set pages 0 verify off feed off
select 'backup validate check logical datafile '|| FILE# ||';'
  from v\\\$datafile;
exit
ESQL
} > ${ORACLE_SID%%[1-9]}_backup_validate2.log 2>&1
EAT
