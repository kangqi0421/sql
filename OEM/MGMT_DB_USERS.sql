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
