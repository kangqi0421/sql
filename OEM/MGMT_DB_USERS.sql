--
-- MGMT$DB_USERS
--

-- target_guid vede na db instance, nikoliv rac db !
select DISTINCT database_name as DBNAME,
       -- u.host_name,
       p.PROPERTY_VALUE ENV_STATUS,
       u.username
       -- profile
  from MGMT$DB_USERS u
    JOIN MGMT$DB_DBNINSTANCEINFO d
      ON (u.target_guid = d.target_guid)
    JOIN sysman.mgmt_target_properties p
      ON (p.target_guid = u.target_guid)
where  p.property_name = 'orcl_gtp_lifecycle_status'
   AND database_name = 'MCIZ'
   AND username = 'ARM_CLIENT';


-- REDIM db
select DISTINCT r.database_name as DBNAME,
       -- u.host_name,
       u.username
       -- profile
  from MGMT$DB_USERS u
    JOIN MGMT$DB_DBNINSTANCEINFO d
      ON (u.target_guid = d.target_guid)
    JOIN REDIM_DATABASES r
      ON (r.database = d.database_name)
where  1=1
   AND database_name = 'MCIZ'
   AND username = 'ARM_CLIENT';
