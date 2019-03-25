--
-- Create APP user
--

@/dba/sql/CREATE_DB/create_appl_user.sql DLKREPTC_E ODI_DATA

select * from dba_users;

pošlete prosím přesně, jaké schema chcete vytvořit a jaké parametry:
- profile PROF_APPL
- default tablespace ?
- quoty na nějaké další tablespaces ?
- create role ?

define user=ACSSLSPAXX
define default_tablespace=ACS
define owner_role=PAD_OWNER

--
-- APP user
--

BEGIN EXECUTE IMMEDIATE 'CREATE ROLE &owner_role';
EXCEPTION WHEN OTHERS THEN IF sqlcode != -1921 THEN RAISE; END IF; END;
/


create user &user identified by "abcd1234" profile DEFAULT
  default tablespace &default_tablespace quota unlimited on &default_tablespace
  PASSWORD EXPIRE;

alter user  &user profile PROF_APPL;

BEGIN EXECUTE IMMEDIATE 'CREATE ROLE CS_APPL_ACCOUNTS';
EXCEPTION WHEN OTHERS THEN IF sqlcode != -1921 THEN RAISE; END IF; END;
/

GRANT CSCONNECT, CS_APPL_ACCOUNTS TO "&user";

GRANT &owner_role TO "&user";


-- další role
GRANT CBL_DB_SERVER to &user ;

-- dalsi prava
GRANT CREATE SESSION, CREATE TABLE, CREATE SYNONYM TO "&user";

--
alter user &user quota 10G on &default_tablespace;

--
-- list appl ucet
--
select *
  from dba_users
 where 1 = 1
    and oracle_maintained = 'N'
    and username like '%'
    and not REGEXP_LIKE(username, '^[A-Z]{1,3}\d{4,}$')
--    and account_status = 'OPEN'
    AND username IN (select grantee from dba_role_privs where granted_role = 'CS_APPL_ACCOUNTS')
order by 1
/


--
emcli:

TARGETS="RTOEA:oracle_database;RTOTF:oracle_database;RTOZA_RTOZA1:oracle_database;RTODI:oracle_database;RTOTI_RTOTI1:oracle_database;RTOTP:oracle_database;"

emcli execute_sql -sql="FILE" -input_file="FILE:$PWD/create_RTODS_MON_DYNA.sql" -targets="$TARGETS"  -credential_set_name="DBCredsSYSDBA"

--
-- rename user - Oracle 11.2.0.2.0 ongoing
--

alter session set "_enable_rename_user"=true;
alter system enable restricted session;

alter user PDBPDB10 rename to PDB10 identified by "pdb10abcd1234";

alter system disable restricted session;


-- MCI user

-- I*NET user

define user=INETLAFWEBAPILOCKERDEVB
define default_tablespace=INET_APL_TS

create user &user identified by "abcd1234" profile PROF_APPL
  default tablespace &default_tablespace quota unlimited on &default_tablespace
  PASSWORD EXPIRE;

BEGIN EXECUTE IMMEDIATE 'create role CS_APPL_ACCOUNTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

GRANT CSCONNECT, CS_APPL_ACCOUNTS TO "&user";




--
Pro každého zakládaného uživatele je potřeba vyplněný zaváděcí list - viz příloha - a souhlas odboru bezpečnost IS/IT.
--
Zadání práva stejná jako xyz budí dojem neexistence správy způsobu řízení přístupových oprávnění v aplikaci, to je špatné zadání, definujte prosím jaké role požadujete, ne předlohu.
--

--CTLR
grant select on COST_OWNER.V_IMP_ABC_DRIVERS to &user;
grant select on COST_OWNER.V_IMP_ABC_MAPS to &user;

-- JAVA permission
exec dbms_java.grant_permission( 'OUT_OWNER', 'SYS:java.io.FilePermission',
'/srv/data/prod/csops/csopsd/remote/csopsd/export/CCDPP1/*', 'read,write');
exec dbms_java.grant_permission( 'OUT_OWNER', 'SYS:java.io.FilePermission','/srv/data/tst/csops/csopsd/remote/csopsd/export/CCDIN1/*', 'read,write');

--create role SODS_REP_USER_ROLE;
grant csconnect to &&user;
grant INET_INETRISKCARD_RO to &&user;


alter user &&user quota 50M on USERS;

@privs &&user

-- GRANT db_developer_role TO cen32740;
--grant select any table, select any dictionary, select any transaction to cen32740;

-- SELECT on schema SODS_REPORT_OWN to role SODS_REP_USER_ROLE
BEGIN
  FOR rec IN
  (
    SELECT   owner, table_name
      FROM dba_tables
     WHERE owner = 'SODS_REPORT_OWN'
  )
  LOOP
    EXECUTE immediate 'grant SELECT on '||rec.owner||'.'||rec.table_name||
    ' to SODS_REP_USER_ROLE';
  END LOOP;
END;
/

-- ODI
-- grant select on all relevant schemas
begin
  for s in (select 'grant select on '||t.owner||'.'||t.table_name || ' to rmd_ro_role' stmt from dba_tables t where t.owner in ('RMDREPPA_E', 'RMDREPZA_E') order by owner, table_name) loop
    dbms_output.put_line(s.stmt);
    execute immediate s.stmt;
  end loop;
end;
/


-- Collections ECCC role
create tablespace ECCC datafile size 512M autoextend on next 512M maxsize 32767M;
create role ECCC_ROLE;

create user ECCC identified by "abcd1234" profile PROF_APPL
  default tablespace ECCC quota UNLIMITED on ECCC;
grant CSCONNECT,ECCC_ROLE to ECCC;

GRANT CREATE TABLE TO &user;
GRANT CREATE VIEW TO &user;
GRANT CREATE SYNONYM TO &user;
GRANT CREATE SEQUENCE TO &user;
GRANT CREATE PROCEDURE TO &user;
GRANT CREATE SNAPSHOT TO &user;
GRANT CREATE TRIGGER TO &user;
GRANT CREATE TYPE TO &user;

-- Personalni ucet

--create user &user identified by "abcd1234" password expire profile PROF_USER
  --default tablespace USERS quota 50M on USERS;

-- Personalni ucet bez quoty
create user &user identified by "abcd1234" password expire profile PROF_USER;
grant csconnect, DBA to &user;

-- Kerberos user
create user CEN32740 identified externally as 'cen32740@CEN.CSIN.CZ' profile PROF_SUPP;
grant csconnect to CEN32740;
grant RTODS_APPL_ANALYST, RTODS_APPL_HOTFIX to CEN32740;

-- Kerberos zpět
alter user EXT94623 identified by "abcd1234" password expire;
alter user EXT94210 identified by "abcd1234" password expire;
alter user EXT93159 identified by "abcd1234" password expire;

-- CRM user
define user=EXT95392S
create user &user identified by "abcd1234" password expire profile PROF_USER
  default tablespace SIEBELS_USERS;
GRANT CSCONNECT,CSRESOURCE,SSE_LOADY TO &user ;

