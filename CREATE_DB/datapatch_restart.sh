#/bin/sh

# apply datapatch in UPGRADE mode and restart db

sqlplus -s / as sysdba <<ESQL
set lines 80 pages 0 trims on head off feed off
-- uchovani puvodni hodnoty cluster_database do tempu
SPOOL /tmp/cd.sql
SELECT 'alter system set cluster_database = '||value||' scope=spfile;'
  FROM sys.v_\$parameter WHERE name = 'cluster_database' AND value = 'TRUE';
prompt EXIT
SPOOL OFF
-- cluster na false
BEGIN
for rec in (select 1 FROM sys.v_\$parameter WHERE name = 'cluster_database' AND value = 'TRUE')
LOOP
  execute immediate 'alter system set cluster_database = false scope=spfile';
END LOOP;
END;
/
ESQL
srvctl stop db -d ${ORACLE_SID%%[1-9]}
echo "STARTUP UPGRADE" | sqlplus -s / as sysdba
$ORACLE_HOME/OPatch/datapatch -verbose
sqlplus / as sysdba @/tmp/cd.sql
srvctl stop db -d ${ORACLE_SID%%[1-9]} && srvctl start db -d ${ORACLE_SID%%[1-9]}
