--
-- mgmt_targets
-- mgmt_target_properties
--

-- ALL targets
SELECT
--  t.*
  t.target_name
  ||':'|| t.target_type
--  ,t.category_prop_1
  ,T.Host_Name
FROM
  MGMT_TARGETS t
 WHERE
   t.target_type IN ('oracle_database','rac_database')
--   t.target_type IN ('host')
   AND t.target_name like 'APS%'
--   AND category_prop_1 in ('HP-UX','AIX')
--    AND category_prop_1 in ('Linux','HP-UX','AIX')
   -- filtr na produkci
   --AND target_guid IN (SELECT TARGET_GUID FROM SYSMAN.MGMT$GROUP_MEMBERS WHERE group_name = 'PRODUKCE')
   -- bez Postgresu
   --and NOT (host_name like 'ppg%' or host_name like 'lintr%' or host_name like '%avlog%')
   --
ORDER BY t.target_name;

-- DB targets - pouze single DB a RAC DB
-- MGMT$DB_DBNINSTANCEINFO
select
--   *
    database_name, dbversion
  FROM MGMT$DB_DBNINSTANCEINFO d
    JOIN MGMT$TARGET t ON d.target_guid = t.target_guid
  WHERE t.TYPE_QUALIFIER3 = 'DB'
    and database_name like 'CPS%'
ORDER by d.target_name;

-- RAC targets
select * from MGMT$RAC_TOPOLOGY t
  where cluster_name = 'ordb02-cluster'
    and db_instance_name like 'DLKP%';


-- Database Info
select t.target_guid, t.target_name,
       database_name dbname,
       oracle_home,
       log_mode,
       characterset,
       substr(d.supplemental_log_data_min, 1, 1) SL_MIN,
       dbversion, env_status,
       substr(is_rac, 1,1) is_rac,
       -- servername
       -- pokud je db v clsteru, vrat scanName, jinak server name
       NVL2(cluster_name, scanName, server_name) server_name,
       port
  FROM
    MGMT$DB_DBNINSTANCEINFO d
    JOIN MGMT$TARGET_PROPERTIES
      PIVOT (MIN(PROPERTY_VALUE) FOR PROPERTY_NAME IN (
        'orcl_gtp_lifecycle_status' as env_status,
        'OracleHome' as oracle_home,
        'RACOption' as is_rac,
        'ClusterName' as cluster_name,
        'MachineName' as server_name,
        'Port' as port
        )) p ON (d.target_guid = p.target_guid)
  -- pouze DB bez RAC instance
  JOIN MGMT$TARGET t on (p.target_guid = t.target_guid)
  -- join scanName dle clusterName
  LEFT JOIN (select target_name, property_value scanName
         from MGMT$TARGET_PROPERTIES
        where property_name = 'scanName') s
    ON p.cluster_name = s.target_name
  -- pouze DB bez RAC instance
WHERE t.TYPE_QUALIFIER3 = 'DB'
ORDER BY dbname
;


-- DB verze a Oracle Home
select 'emcli modify_target -name="'|| t.target_name
     ||'" -type="'|| t.target_type
     ||'" -properties="OracleHome:/oracle/product/db/12.1.0.2"'
  FROM
  ...
WHERE 1=1
--t.TYPE_QUALIFIER3 = 'DB'
        and dbversion = '12.1.0.2.0'
        and oracle_home <> '/oracle/product/db/12.1.0.2'



-- OEM Groups and members
SELECT
    AGGREGATE_TARGET_NAME "GROUP",
    member_target_name "SERVER"
    --member_target_type
  FROM
    MGMT$TARGET_FLAT_MEMBERS
  WHERE
    MEMBER_TARGET_TYPE  IN ('host')
    --AND AGGREGATE_TARGET_NAME IN ('PRODUKCE')
    AND MEMBER_TARGET_NAME like 'dordb04%'
;


-- OS info/HW info short AIX/Linux/Win ..
select * from MGMT$OS_HW_SUMMARY  ;
select * from sysman.MGMT_ECM_HW;

-- OS info - replacement for short info version
select target_name,
       case
         when category_prop_1 like 'AIX' then category_prop_1||' '||substr(category_prop_2,1,3)
         when category_prop_1 like 'HP-UX' then category_prop_1||' '||substr(category_prop_2,3)
         when category_prop_1 like 'Linux' then replace(category_prop_2, 'Red Hat Enterprise Linux Server release','RHEL')
         when category_prop_1 like 'Windows' then category_prop_2
         else category_prop_1||' '||category_prop_2
       end  "OS"
  from SYSMAN.MGMT_TARGETS
 where target_type = 'host'
-- and target_name like 'aspspkidb1%'
-- and target_name <> host_name
 order by target_name
;

-- Platforms
select
  category_prop_1, count(*)
  from SYSMAN.MGMT_TARGETS
   where target_type IN ('oracle_database','rac_database')
group by CATEGORY_PROP_1 order by 2 desc;

-- Versions
select
  category_prop_1, count(*)
  from SYSMAN.MGMT_TARGETS
--   where target_type = 'host'
group by CATEGORY_PROP_1 order by 2 desc;


-- OS info MEM AIX
with db_count as (
select host_name, count(*) cnt
  from MGMT_TARGETS t
 where category_prop_3 = 'DB'
 group by host_name
 )
select d.host_name, mem, cnt "#db", 16384*cnt
  from db_count d
    join MGMT$OS_HW_SUMMARY h on (d.host_name = h.host_name)
where h.MA like 'PowerPC%'
 and 16384*cnt > mem
 order by host_name
 ;

-- Contacts / LifeCycle status
-- Kontakty per Linux DB farma
select --p.*,
  --p.target_name, p.property_value "Contact"
  p.target_name||': '||p.property_value
 from mgmt$target_properties p
where 1=1
  and p.target_type in ('rac_database','oracle_database')
  and p.property_name = 'orcl_gtp_contact'  -- Contact
  --and property_name = 'orcl_gtp_lifecycle_status' -- Lifecycle status
  -- and property_name = 'OracleHome'  -- OracleHome
  and p.target_guid in (
  SELECT TARGET_GUID
    FROM MGMT_TARGETS
    WHERE target_type LIKE '%database'
      AND host_name LIKE 'pordb02.vs.csin.cz'
  )
order by upper(p.target_name);

--// pouze DB vèetnì RAC, ale bez RAC instancí //--
SELECT target_name,
	   case when emd_url like '%cc.csin.cz%' then 'VIE' else 'PRG' end DC
  FROM SYSMAN.mgmt_targets
 WHERE category_prop_3 = 'DB'
order by 1;

-- pouze produkce
SELECT count(*)
    --member_target_name,
    --member_target_type
  FROM
    MGMT$TARGET_FLAT_MEMBERS
  WHERE
    AGGREGATE_TARGET_NAME IN ('PRODUKCE')
  AND MEMBER_TARGET_TYPE  IN ('oracle_database','rac_database')
  --ORDER BY  member_target_name
  ;
