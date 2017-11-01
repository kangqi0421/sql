--
-- create users
--

WHENEVER SQLERROR CONTINUE

CREATE USER "DBEIM" identified by "DBEIMABCD1234" profile PROF_APPL_UNLIMITED  default tablespace MDW_DATA_TS quota unlimited on MDW_DATA_TS;
CREATE USER "DBMAIN" identified by "DBMAINABCD1234" profile PROF_APPL_UNLIMITED  default tablespace MDW_DATA_TS quota unlimited on MDW_DATA_TS;
CREATE USER "MW" identified by "MWABCD1234" profile PROF_APPL_UNLIMITED  default tablespace MDW_DATA_TS quota unlimited on MDW_DATA_TS;
CREATE USER "MWAPP" identified by "MWAPPABCD1234" profile PROF_APPL_UNLIMITED  default tablespace MDW_DATA_TS quota unlimited on MDW_DATA_TS;
CREATE USER "MWSTAT" identified by "MWSTATABCD1234" profile PROF_APPL_UNLIMITED  default tablespace MDW_DATA_TS quota unlimited on MDW_DATA_TS;
