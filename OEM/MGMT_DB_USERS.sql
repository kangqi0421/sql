--
-- MGMT$DB_USERS
--

-- target_guid vede na db instance, nikoliv rac db !
select DISTINCT
      database_name as DBNAME,
      u.host_name,
      u.username
      -- profile
  from MGMT$DB_USERS u
    JOIN MGMT$DB_DBNINSTANCEINFO d
      ON (u.target_guid = d.target_guid)
where  1=1
   AND database_name = 'MCIZ'
   AND username = 'ARM_CLIENT';


-- INFP - vcetne SAS aplikace
select DISTINCT
      u.username,
      database_name,
      app_name
  from MGMT$DB_USERS u
    JOIN MGMT$DB_DBNINSTANCEINFO d
      ON (u.target_guid = d.target_guid)
    JOIN OLI_DATABASE o
      ON (o.dbname = d.database_name)
where  1=1
   AND NOT REGEXP_LIKE(username, '^[A-Z]+\d{4,}$')
   AND username not in (
      select username from dba_users where oracle_maintained = 'Y')
   AND username not in ('ARM_CLIENT', 'ARM_CLSYS')
   -- pouze CRM a RTODS
   AND (database_name like 'CRM%' or database_name like 'RTO%' )
order by 1, 2;
