--
-- recreate spfile do umisteni v ASM ve formatu spfile<DBNAME>.ora
--
-- bez restartu
--

column db_name new_value db_name print
SELECT SYS_CONTEXT ('USERENV', 'DB_NAME') as db_name from dual;

column spfile new_value spfile
select regexp_replace(name, '/datafile/.*$', '/spfile&db_name..ora', 1, 1, 'i') as spfile
  from v$datafile where file# = 1;

create pfile from spfile;
create spfile = '&spfile' from pfile;
host echo "spfile='&spfile'" > $ORACLE_HOME/dbs/init$ORACLE_SID.ora
host srvctl modify database -db &db_name -spfile &spfile

-- whenever sqlerror continue none
-- shutdown immediate
-- whenever sqlerror exit 2 rollback

host if [ -f "$ORACLE_HOME/dbs/spfile$ORACLE_SID.ora" ]; then cp -p "$ORACLE_HOME/dbs/spfile$ORACLE_SID.ora" spfile$ORACLE_SID.ora.`date +%Y%m%d_%H%M%S` ; fi
host rm -f $ORACLE_HOME/dbs/spfile$ORACLE_SID.ora

-- startup
-- show parameter spfile


