--
-- create appl user
--

define user=&1
define default_tablespace=&2

create user &user identified by "abcd1234" profile PROF_APPL
  default tablespace &default_tablespace quota unlimited on &default_tablespace
  PASSWORD EXPIRE;

BEGIN EXECUTE IMMEDIATE 'create role CS_APPL_ACCOUNTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

GRANT CSCONNECT, CS_APPL_ACCOUNTS TO "&user";

exit
