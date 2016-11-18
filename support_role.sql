--
-- support role
--

define role=AWR_SUPPORT_ROLE
--define role=EXT90032

create role &role;

grant &role to ESPIS;

-- SQL exec plan dbms_xplan
GRANT select on sys.v_$session  to &role;
GRANT select on sys.v_$sql  to &&role;
GRANT select on SYS.V_$SQL_PLAN  to &&role;
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

-- TOAD session browser
GRANT SELECT ON GV_$SESSION TO &&role;
GRANT SELECT ON GV_$PROCESS TO &&role;
GRANT SELECT ON GV_$SESS_IO TO &&role;
GRANT SELECT ON GV_$SESSION_WAIT TO &&role;
GRANT SELECT ON GV_$SESSION_EVENT TO &&role;
GRANT SELECT ON GV_$ACCESS TO &&role;
GRANT SELECT ON GV_$SESSTAT TO &&role;
GRANT SELECT ON GV_$SQL_PLAN TO &&role;
GRANT SELECT ON GV_$SQLTEXT_WITH_NEWLINES TO &&role;

-- definovat další v$view

-- nejčastěji volané view dle auditu Starbanku
-- V$SESSION
-- DBA_OBJECTS
-- V$ENABLEDPRIVS
-- V$DBFILE