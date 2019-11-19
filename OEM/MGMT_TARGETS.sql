--
-- mgmt_targets
-- mgmt_target_properties

-- SYSMAN views
select * from dba_objects
  where object_name like '%NET%'
--  where object_name like 'MGMT%CLUSTER%'
 and owner = 'SYSMAN'
;

DB target:
  - MGMT$DB_DBNINSTANCEINFO
  - SYSMAN.EM_MANAGEABLE_ENTITIES WHERE d.category_prop_3 = 'DB'
- 12.2 - filtr upraven na
where TARGET_TYPE in ('rac_database', 'oracle_database')
  and TYPE_QUALIFIER3 != 'RACINST'


HOST target
  - MGMT$OS_HW_SUMMARY
  - MGMT_ECM_HW
  - CM$MGMT_ECM_HW_VIRTUAL

LifeCycle:
       p.PROPERTY_VALUE ENV_STATUS,
..
    JOIN sysman.mgmt_target_properties p
      ON (p.target_guid = d.entity_guid)
 where p.property_name = 'orcl_gtp_lifecycle_status'

-- ALL targets
SELECT
--  t.*
  t.target_name
  ||':'|| t.target_type
--  ,t.category_prop_1
  ,T.Host_Name
FROM
  sysman.MGMT$TARGET t
 WHERE
   t.target_type IN ('oracle_database','rac_database')
   -- t.TYPE_QUALIFIER3 = 'DB'
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
-- vyber target_name dle database_name
select
--   *
    database_name, dbversion
  FROM sysman.MGMT$DB_DBNINSTANCEINFO d
    JOIN sysman.MGMT$TARGET t ON d.target_guid = t.target_guid
  WHERE t.TYPE_QUALIFIER3 = 'DB'
    and (
           database_name like 'TS0O%'
        OR database_name like 'TS1O%'
        OR database_name like 'SK2O%'
        OR database_name like 'TS3O%'
        OR database_name like 'BRATB%'
     )
ORDER by d.target_name;

-- RAC targets
-- RACOneNode - pozor, ukazuje pouze jeden node, nikoliv vsechny uzly v clusteru
select * from MGMT$RAC_TOPOLOGY t
  where cluster_name = 'ordb02-cluster'
    and db_instance_name like 'DLKP%';

-- RAC clusters and nodes
select * FROM MGMT_CLUSTER_CONFIG;

-- MGMT_CLUSTER_CONFIG - join na poslední dostupný snapshot
select s.*
  from sysman.MGMT_CLUSTER_CONFIG c
    join MGMT$ECM_VISIBLE_SNAPSHOTS s on (c.ECM_SNAPSHOT_ID = s.ECM_SNAPSHOT_ID)
 where
    cluster_name like 'zr01db%'
  order by s.saved_timestamp
 FETCH  first 1 rows only;


select * FROM MGMT_CLUSTER_CSS_NODES_ECM;

ECM_SNAPSHOT_ID


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

--
-- Target Properties
--
https://blogs.oracle.com/oem/leveraging-target-properties-to-enhance-enterprise-manager-capabilities-v2

select *  from sysman.mgmt$all_target_prop_defs;

select * from sysman.MGMT_ALL_TARGET_PROPS;

select * from sysman.mgmt$target_properties
  where property_name like 'udtp%';



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
;

--
-- OS info/HW info short AIX/Linux/Win ..
--

select * from SYSMAN.MGMT$OS_HW_SUMMARY;

select * from SYSMAN.MGMT_ECM_HW;

select * from CM$MGMT_ECM_HW_VIRTUAL;

-- VMWare DEV/TEST
-- seznam
  SELECT
--    *
         host_name "hostname",
         os_vendor,
         CPU_COUNT "CPUs",
         mem
    FROM SYSMAN.MGMT$OS_HW_SUMMARY
   WHERE    -- host_name like 'dp%db%'
     REGEXP_LIKE(host_name, '^[dt][pb][a-z]{3}db\d{2}.vs.csin.cz')
         and VIRTUAL like 'Yes'
         AND system_config = 'x86_64'
ORDER BY host_name
;

-- AIX pool info Shared Pool ID
SELECT * FROM (
        SELECT
        s1.TARGET_NAME,
        s2.NAME        ,
        s2.VALUE
FROM
        CM$MGMT_ECM_HW_VIRTUAL s2        ,
        MGMT$ECM_CURRENT_SNAPSHOTS s1gen1,
        MGMT$TARGET s1
WHERE
        (
                s1gen1.TARGET_GUID     = s1.TARGET_GUID
            AND s1gen1.ECM_SNAPSHOT_ID = s2.ECM_SNAPSHOT_ID (+)
            AND s1.TARGET_TYPE         = 'host'
            AND s1gen1.SNAPSHOT_TYPE   = 'll_host_config'
        )
    AND name in
    ('Active CPUs in Pool','Shared Pool ID','Online Virtual CPUs','Active Physical CPUs in system')
)
;


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
 from sysman.mgmt$target_properties p
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

--// pouze DB v�etn� RAC, ale bez RAC instanc� //--
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

-- cluster target
select
  'add_target -name="' || ManagementEntityEO.ENTITY_NAME
  || '" -type="cluster" -host="' ||ManagementEntityEO.HOST_NAME
  || '" -monitor_mode="1" -properties="OracleHome:' ||
  (SELECT PROPERTY_VALUE FROM SYSMAN.MGMT_TARGET_PROPERTIES WHERE TARGET_GUID =
  ManagementEntityEO.ENTITY_GUID AND
  (UPPER(PROPERTY_NAME) LIKE '%HOME' AND UPPER(PROPERTY_NAME)!='MW_HOME' OR PROPERTY_NAME ='INSTALL_LOCATION') AND ROWNUM = 1)
  || ';eonsPort:' ||
  (SELECT PROPERTY_VALUE FROM SYSMAN.MGMT_TARGET_PROPERTIES WHERE TARGET_GUID = ManagementEntityEO.ENTITY_GUID AND
  (UPPER(PROPERTY_NAME) LIKE 'EONSPORT%'))
  || ';scanName:' ||
  (SELECT PROPERTY_VALUE FROM SYSMAN.MGMT_TARGET_PROPERTIES WHERE TARGET_GUID = ManagementEntityEO.ENTITY_GUID AND
  (UPPER(PROPERTY_NAME) LIKE 'SCANNAME%'))
  || ';scanPort:' ||
  (SELECT PROPERTY_VALUE FROM SYSMAN.MGMT_TARGET_PROPERTIES WHERE TARGET_GUID = ManagementEntityEO.ENTITY_GUID AND
  (UPPER(PROPERTY_NAME) LIKE 'SCANPORT%'))
  || '" -instances="'||
  /*(select listagg(sub.entity_name,':host;') within group (order by sub.entity_name) FROM GC_MANAGEABLE_ENTITIES sub
  where sub.ENTITY_TYPE='host' and sub.entity_name like ManagementEntityEO.ENTITY_NAME||'%')*/
  (select listagg(d.entity_name,':host;') within group (order by d.entity_name) FROM GC_MANAGEABLE_ENTITIES sub, mgmt_assoc_instances a, em_manageable_entities d
  where
  a.source_me_guid = HEXTORAW(sub.entity_guid)
  and sub.entity_guid= a.SOURCE_ME_GUID
  AND a.dest_me_guid = d.entity_guid
  AND d.manage_status != 1
  and d.ENTITY_TYPE='host'
  and a.ASSOC_TYPE = 'cluster_contains'
  and sub.entity_name like '%'||ManagementEntityEO.ENTITY_NAME||'%')
  ||':host"'
  FROM GC_MANAGEABLE_ENTITIES ManagementEntityEO,MGMT_TARGET_TYPES ManagementEntityTypeEO
  WHERE ManagementEntityEO.PROMOTE_STATUS=1
  AND ManagementEntityEO.MANAGE_STATUS=1
  AND ManagementEntityEO.ENTITY_TYPE!= 'host'
  AND ManagementEntityEO.ENTITY_TYPE='cluster'
  AND ManagementEntityEO.ENTITY_TYPE= ManagementEntityTypeEO.TARGET_TYPE
  AND (NOT EXISTS(SELECT 1 FROM
  mgmt_type_properties mtp WHERE mtp.target_type= ManagementEntityEO.entity_type AND mtp.property_name ='DISCOVERY_FWK_OPTOUT'AND
  mtp.property_value='1'))
  AND ManagementEntityEO.HOST_NAME ='&hostname';
