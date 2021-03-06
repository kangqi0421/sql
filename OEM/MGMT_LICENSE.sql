--
-- Licence usage
--
-- MGMT$DB_FEATUREUSAGE
--

-- enable
Enterprise Manager 12c For Oracle Database: How to Enable the Metric "Feature Usage" to Get Data from the Repository View SYSMAN.MGMT$DB_FEATUREUSAGE (Doc ID 1970236.1)

Database > Monitoring > Metric and Collections Settings

The 4 following metrics are retrieved (They are all disabled by default).

Database Feature Usage
Database Usage Tracking DBA Feature Usage Statistics
Database Usage Tracking DBA Feature Usage Statistics Feature Info
Feature Usage


select count(*) from dashboard.MGMT$DB_FEATUREUSAGE;

  COUNT(*)
----------
      7855
    167476
    199343
    199708

19.09.2019 76453

- kontrola na urovni EM agenta na serveru

${AGENT_INST}/bin/emctl status agent scheduler | grep feature


-- OEM rozdíl proti OLI
select distinct
    host,
    database_name,
    NAME,
    currently_used, last_usage_date, last_sample_date,
    APP_NAME
  FROM MGMT$DB_FEATUREUSAGE u
       LEFT JOIN OLI_DATABASE d
         ON (u.database_name = d.dbname)
 WHERE 1=1
--    AND database_name = 'KNXTA'
    AND (
        name like '%Compression%'
--     OR name like '%Datapump%'
        )
     AND name not in  ('Backup BASIC Compression')
    and currently_used='TRUE'
    and last_usage_date > sysdate - interval '2' month
    and host not in (
        select hostname||'.'||domain as server
          from OLI_OWNER.OLAPI_LICENCE_USAGE_SUMMARY
         where current_prod_id = 3)
    -- vyjimky
    --and host not in ('avlog.vs.csin.cz')
order by database_name;



-- Advanced Compression
-- porovnat s OLI_OWNER tabulkou
select distinct
    host,
    database_name,
    NAME,
    currently_used, last_usage_date, last_sample_date
  FROM MGMT$DB_FEATUREUSAGE
 WHERE 1=1
--    AND database_name = 'KNXTA'
    AND (
        name like '%Compression%'
--     OR name like '%Datapump%'
        )
     AND name not in  ('Backup BASIC Compression')
    and currently_used='TRUE'
    and last_usage_date > sysdate - interval '3' month
order by database_name;




select
    host
    -- max(last_usage_date), max(last_sample_date)
  FROM MGMT$DB_FEATUREUSAGE
 WHERE 1=1
--   and database_name = 'CPTINT'
 -- AND name like '%Compression%'
    AND name in ('Hybrid Columnar Compression',
                 'SecureFile Compression (user)',
                 'Backup LOW Compression')
    and currently_used='TRUE'
group by host
order by 1;


-- data z OLI
select hostname||'.'||domain as server
    from OLI_OWNER.OLAPI_LICENCE_USAGE_SUMMARY
  where current_prod_id = 3
 order by 1
;

-- Compression
select
    host,
    database_name,
    NAME,
    currently_used, last_usage_date, last_sample_date
  FROM MGMT$DB_FEATUREUSAGE
 WHERE 1=1
   and database_name = 'WDNZ'
    AND name like '%Compression%'
    AND name in ('Hybrid Columnar Compression',
                  'SecureFile Compression (user)',
                  'Backup LOW Compression')
    and currently_used='TRUE'
;


-- Advanced Security
select database_name, NAME AS advsec, currently_used
  FROM MGMT$DB_FEATUREUSAGE
 where NAME = 'Advanced Security'
--    and currently_used='TRUE'
;

select distinct main_mdf.database_name, adv_sec.advsec "Advanced Security",
rac_info.racid "RAC Used", hcc_info.hcc "Advanced Compression Used",
tune_pk.tune_usr "Tuning Pack Used",
DIAG_PK.diag "Diagnostic Pack Used", part_used.part_usr "Partitioning in Use"
FROM
(select database_name, NAME AS advsec, currently_used
FROM MGMT$DB_FEATUREUSAGE
where NAME = 'Advanced Security'
and currently_used='TRUE') ADV_SEC,
(select database_name, NAME AS racid, currently_used
FROM MGMT$DB_FEATUREUSAGE
where NAME = 'Real Application Clusters (RAC)'
and currently_used='TRUE') RAC_INFO,
(select database_name, NAME AS hcc, currently_used
FROM MGMT$DB_FEATUREUSAGE
where NAME = 'Hybrid Columnar Compression'
and currently_used='TRUE') HCC_INFO,
(select database_name, NAME AS diag, currently_used
FROM MGMT$DB_FEATUREUSAGE
where NAME = 'Diagnostic Pack'
and currently_used='TRUE') DIAG_PK,
(select database_name, NAME AS part_usr, currently_used
FROM MGMT$DB_FEATUREUSAGE
where NAME = 'Partitioning (user)'
and currently_used='TRUE') PART_USED,
(select database_name, NAME AS tune_usr, currently_used
FROM MGMT$DB_FEATUREUSAGE
where NAME = 'Tuning Pack'
and currently_used='TRUE') TUNE_PK,
MGMT$DB_FEATUREUSAGE MAIN_MDF
where MAIN_MDF.database_name=ADV_SEC.database_name(+)
and MAIN_MDF.database_name=RAC_INFO.database_name(+)
and MAIN_MDF.database_name=HCC_INFO.database_name(+)
and MAIN_MDF.database_name=DIAG_PK.database_name(+)
and MAIN_MDF.database_name=PART_USED.database_name(+)
and MAIN_MDF.database_name=TUNE_PK.database_name(+)
order by 1;
