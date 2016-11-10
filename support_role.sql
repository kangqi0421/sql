--
-- support role
--

define role=SUPPORT_ROLE
--define role=EXT90032

-- dbms_xplan
GRANT select on sys.v_$session  to &role;
GRANT select on sys.v_$sql  to &&role;
GRANT select on sys.v_$sql_plan  to &&role;
GRANT select on sys.v_$sql_plan_statistics_all to &&role;

-- AWR report
GRANT SELECT ON SYS.V_$DATABASE TO &&role;
GRANT SELECT ON SYS.V_$INSTANCE TO &&role;
GRANT EXECUTE ON SYS.DBMS_WORKLOAD_REPOSITORY TO &&role;
GRANT SELECT ON SYS.DBA_HIST_DATABASE_INSTANCE TO &&role;
GRANT SELECT ON SYS.DBA_HIST_SNAPSHOT TO &&role;
GRANT ADVISOR TO &&role;

-- SQLDeveloper Manage Database
-- namísto
GRANT select on dba_tablespaces to &&role;
GRANT select on dba_free_space to &&role;
GRANT select on dba_data_files to &&role;
-- volá SQL developer při kontrole select 'YES'
GRANT select on dba_tables to &&role;

GRANT select on sys.v_$parameter to &&role;
GRANT select on sys.v_$sga to &&role;
GRANT select on sys.v_$pgastat to &&role;

-- definovat další v$view

-- nejčastěji volané view dle auditu Starbanku
-- V$SESSION
-- DBA_OBJECTS
-- V$ENABLEDPRIVS
-- V$DBFILE