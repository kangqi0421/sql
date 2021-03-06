connect / as sysdba

spool Create_IPX.log

CREATE ROLE IPX_ROLE;

GRANT CREATE TABLE TO IPX_ROLE;
GRANT CREATE SEQUENCE TO IPX_ROLE;
GRANT CREATE SYNONYM TO IPX_ROLE;
GRANT SELECT ON SYS.V_$INSTANCE TO IPX_ROLE;
GRANT SELECT ON SYS.V_$DATABASE TO IPX_ROLE;
GRANT SELECT ON SYS.V_$DATABASE_INCARNATION TO IPX_ROLE;
GRANT SELECT ON SYS.DBA_LOG_GROUPS TO IPX_ROLE;
GRANT SELECT ON SYS.DBA_LOG_GROUP_COLUMNS TO IPX_ROLE;
GRANT SELECT ON SYS.V_$TRANSACTION TO IPX_ROLE;
GRANT SELECT ON SYS.V_$ARCHIVED_LOG TO IPX_ROLE;
GRANT SELECT ON SYS.V_$LOGMNR_CONTENTS TO IPX_ROLE;
GRANT SELECT ON SYS.V_$PARAMETER TO IPX_ROLE;
GRANT SELECT ON SYS.V_$SPPARAMETER TO IPX_ROLE;
GRANT SELECT ON SYS.V_$NLS_PARAMETERS TO IPX_ROLE;
GRANT SELECT ANY TRANSACTION TO IPX_ROLE;
GRANT EXECUTE ON SYS.DBMS_FLASHBACK TO IPX_ROLE;
GRANT EXECUTE ON SYS.DBMS_LOGMNR_D TO IPX_ROLE;
GRANT EXECUTE ON SYS.DBMS_LOGMNR TO IPX_ROLE;
GRANT SELECT ON SYS.V_$ARCHIVED_LOG TO IPX_ROLE;
GRANT SELECT ON SYS.V_$LOG TO IPX_ROLE;
GRANT SELECT ON SYS.V_$LOGFILE TO IPX_ROLE;
GRANT SELECT ON SYS.V_$TRANSPORTABLE_PLATFORM TO IPX_ROLE;
GRANT SELECT ON SYS.V_$THREAD TO IPX_ROLE;
GRANT SELECT ON SYS.ALL_TABLES TO IPX_ROLE;
GRANT SELECT ON SYS.ALL_TAB_PARTITIONS TO IPX_ROLE;
GRANT SELECT ON SYS.DBA_LOG_GROUPS TO IPX_ROLE;
GRANT SELECT ON SYS.DBA_LOG_GROUP_COLUMNS TO IPX_ROLE;
GRANT SELECT ON SYS.DBA_TABLESPACES TO IPX_ROLE;
GRANT SELECT ON SYS.DBA_USERS TO IPX_ROLE;
GRANT SELECT ON SYS.USER$ TO IPX_ROLE;
GRANT SELECT ON SYS.OBJ$ TO IPX_ROLE;
GRANT SELECT ON SYS.TAB$ TO IPX_ROLE;
GRANT SELECT ON SYS.COL$ TO IPX_ROLE;
GRANT SELECT ON SYS.PARTOBJ$ TO IPX_ROLE;
GRANT SELECT ON SYS.TABPART$ TO IPX_ROLE;
GRANT SELECT ON SYS.TABCOMPART$ TO IPX_ROLE;
GRANT SELECT ON SYS.TABSUBPART$ TO IPX_ROLE;

CREATE USER IPX IDENTIFIED BY "He02sL.o" PROFILE PROF_APPL DEFAULT TABLESPACE USERS TEMPORARY TABLESPACE TEMP PASSWORD EXPIRE;
ALTER USER IPX QUOTA 10M ON USERS;
GRANT CSCONNECT TO IPX;
GRANT IPX_ROLE TO IPX;
GRANT CS_APPL_ACCOUNTS TO IPX;
GRANT CREATE JOB TO IPX;
GRANT CREATE TRIGGER TO IPX;
