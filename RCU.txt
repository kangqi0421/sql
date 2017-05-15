--
-- RCU.sql
--
-- Doc ID 2064677.1
--

create user RCU IDENTIFIED BY rcu;

grant select_catalog_role to RCU;
grant select any dictionary to RCU;
grant create session to RCU;
grant select on schema_version_registry to RCU;