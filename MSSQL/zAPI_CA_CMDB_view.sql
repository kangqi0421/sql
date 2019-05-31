CREATE VIEW [dbo].[zAPI_Oracle_licence_apps]
AS
SELECT COALESCE([ci].[host_name],[ci].[resource_name]) AS [APP_NAME],
        [kind].[sym] AS APP_KIND,
        dbo.hex([ci].[own_resource_uuid]) AS CMDB_CI_ID,
        [stat].[name] AS [STATUS],
        [ci].[inactive] AS INACTIVE,
        [ci].[resource_name] AS RESOURCE_NAME,
        [ci].[resource_tag] AS RESOURCE_ALT_NAME,
        CONCAT([va].[last_name],' '+[va].[first_name]) AS va,
        va.[email_address] AS va_email,
        CONCAT([som].[last_name],' '+[som].[first_name]) AS som,
        som.[email_address] AS som_email,
        CONCAT([as].[last_name],' '+[as].[first_name]) AS [as],
        [as].[email_address] AS as_email,
        [serv_mode].[sym] AS [serv_mode]
FROM [dbo].[ca_owned_resource] AS ci
    JOIN [dbo].[usp_owned_resource] AS ci_ext
        ON [ci].[own_resource_uuid] = [ci_ext].[owned_resource_uuid]
    JOIN [dbo].[zapmx] AS ci_att
        ON ci_att.[own_resource_uuid] = [ci].[own_resource_uuid]
    LEFT OUTER JOIN [dbo].[zcodes] AS kind
        ON kind.[id] = [ci_att].[kind]
    LEFT OUTER JOIN [dbo].[ca_resource_status] AS stat
        ON stat.[id] = [ci].[resource_status]
    LEFT OUTER JOIN [dbo].[ca_contact] AS va
        ON va.[contact_uuid] = ci_ext.nr_nx_ref_1
    LEFT OUTER JOIN [dbo].[ca_contact] AS som
        ON som.[contact_uuid] = [ci].[resource_contact_uuid]
    LEFT OUTER JOIN [dbo].[ca_contact] AS [as]
        ON [as].[contact_uuid] = [ci_att].[administrator]
    LEFT OUTER JOIN [dbo].[zcodes] AS serv_mode
        ON serv_mode.[id] = [ci_att].[service_mode]
WHERE [ci_ext].[zcountry] = 3000000
         AND [ci].[resource_class] != 10000001

UNION ALL

SELECT COALESCE([ci].[host_name],[ci].[resource_name]) AS [APP_NAME],
        null AS APP_KIND,
        dbo.hex([ci].[own_resource_uuid]) AS CMDB_CI_ID,
        [stat].[name] AS [STATUS],
        [ci].[inactive] AS INACTIVE,
        [ci].[resource_name] AS RESOURCE_NAME,
        [ci].[resource_tag] AS RESOURCE_ALT_NAME,
        null AS va,
        null AS va_email,
        CONCAT([som].[last_name],' '+[som].[first_name]) AS som,
        som.[email_address] AS som_email,
        null AS [as],
        null AS as_email,
        null AS [serv_mode]
FROM [dbo].[ca_owned_resource] AS ci
    JOIN [dbo].[usp_owned_resource] AS ci_ext
        ON [ci].[own_resource_uuid] = [ci_ext].[owned_resource_uuid]
    LEFT OUTER JOIN [dbo].[ca_resource_status] AS stat
        ON stat.[id] = [ci].[resource_status]
    LEFT OUTER JOIN [dbo].[ca_contact] AS som
        ON som.[contact_uuid] = [ci].[resource_contact_uuid]
WHERE [ci_ext].[zcountry] = 3000000
    AND [ci].[resource_class] = 10000001


/* 20151209, by PV, rq Ales Zeleny */
CREATE VIEW [dbo].[zAPI_Oracle_Databases]
AS
    SELECT
        dbo.hex(CI.own_resource_uuid) as CMDB_CI_ID,
        CI.resource_name as DBNAME,
        --COALESCE(e.db_id,'') COLLATE SQL_Latin1_General_CP1250_CI_AS AS RAC,
        e.db_id AS RAC_ID,
        zuse.sym AS ENV_STATUS,
        --COALESCE(e.version,'') COLLATE SQL_Latin1_General_CP1250_CI_AS AS DBVERSION,
        e.version AS DBVERSION,
        adm.last_name + COALESCE(' '+adm.first_name,'') AS ADMINISTRATOR,
        CI.resource_tag AS OLI_LICDB_ID,
        [e].[zlb_method] AS RAC
    FROM ca_owned_resource AS CI
        JOIN usp_owned_resource CIb ON CI.own_resource_uuid = CIb.owned_resource_uuid
            LEFT JOIN ca_contact adm ON adm.contact_uuid=CIb.nr_nx_ref_1
            LEFT JOIN zuse ON CIb.zuse = zuse.id
        JOIN ci_database e ON CI.own_resource_uuid = e.own_resource_uuid
    WHERE CI.inactive=0 AND CI.resource_class=400115 /*Oracle*/ AND CIb.zcountry=3000000 /*CZ*/ --AND COALESCE(CI.resource_tag,'')<>'' AND CIb.nr_nx_string1='OLI_DB'

/* 20151209, by PV, rq Ales Zeleny */
CREATE VIEW [dbo].[zAPI_Oracle_DBInstances]
AS
    SELECT
        dbo.hex(CI.own_resource_uuid) as DBINST_CMDB_CI_ID,
        CI.resource_name as INST_NAME,
        e.type AS INST_ROLE,
        e.zprocessor_count AS PERCENT_ON_SERVER,
        CI.resource_tag AS OLI_DBINST_ID,
        CIsrv.HOSTNAME,
        CIsrv.SERVER_CMDB_CI_ID,
        CIdb.DBNAME,
        CIdb.DB_CMDB_CI_ID
    FROM ca_owned_resource AS CI
        JOIN usp_owned_resource CIb ON CI.own_resource_uuid = CIb.owned_resource_uuid
            LEFT JOIN ca_contact adm ON adm.contact_uuid=CIb.nr_nx_ref_1
            LEFT JOIN zuse ON CIb.zuse = zuse.id
        JOIN ci_database e ON CI.own_resource_uuid = e.own_resource_uuid
        OUTER APPLY
                (SELECT
                    CIsrv.dns_name AS HOSTNAME,
                    dbo.hex(CIsrv.own_resource_uuid) AS SERVER_CMDB_CI_ID
                FROM busmgt AS rs
                    JOIN ca_owned_resource AS CIsrv ON CIsrv.own_resource_uuid = rs.hier_parent AND CIsrv.inactive=0
                    JOIN ci_hardware_server es ON  CIsrv.own_resource_uuid = es.own_resource_uuid AND rs.del=0
                WHERE rs.hier_child = CI.own_resource_uuid
                ) AS CIsrv
        OUTER APPLY
                (SELECT
                    CIdb.resource_name AS DBNAME,
                    dbo.hex(CIdb.own_resource_uuid) AS DB_CMDB_CI_ID
                FROM busmgt AS rd
                    JOIN ca_owned_resource AS CIdb ON CIdb.own_resource_uuid = rd.hier_child AND CIdb.resource_class=400115 /*Oracle*/ AND rd.del=0 AND CIdb.inactive=0
                WHERE rd.hier_parent = CI.own_resource_uuid
                ) AS CIdb
    WHERE CI.inactive=0 AND CI.resource_class=10004403 /*Oracle Instance*/ AND CIb.zcountry=3000000 /*CZ*/ --AND COALESCE(CI.resource_tag,'')<>'' AND CIb.nr_nx_string1='OLI_DB'


CREATE VIEW [dbo].[zAPI_OLI_relations]
/*18.4.2016 RQ R.Jirik*/

AS

select
  rel.id as 'rel_id'
, type as 'rel_type'
, parent.name as 'p_name'
, child.name as 'c_name'
, parent.model as 'p_model'
, child.model as 'c_model'
, parent_id
, child_id
, parent_id_bin
, child_id_bin


FROM "mdb"."dbo"."zSyncUMOrelAll" as rel
LEFT JOIN "mdb"."dbo"."zSyncUMOciAll" as parent ON rel.parent_id_bin = parent.id_bin
LEFT JOIN "mdb"."dbo"."zSyncUMOciAll" as child ON rel.child_id_bin = child.id_bin

where delete_flag=0 and (parent.class ='virtual-platform' or child.class ='virtual-platform')


CREATE VIEW [dbo].[zAPI_OLI_servers]
/*18.4.2016 RQ R.Jirik*/

AS

SELECT
       [system_name] as HOSTNAME
      ,[dns_name] as DOMAIN
      ,NULL as DR_HW
      ,case when srv_os like '%AIX%' and class like '%virtual%' then [number_proc_inst] when srv_os not like '%AIX%' and class like '%virtual%' then processor_count  else NULL end as LOGICAL_CPU
      ,NULL as SPARE
      ,NULL as HYPERTHREADING
      ,NULL as SERVER_PARTITIONING
      ,NULL as CPU_CHIPS
      ,NULL as CPU_SOCKETS
      --,case when srv_os like '%AIX%' and ISNUMERIC(processor_count)=1 then cast(processor_count as float)/100   else processor_count end as CPU_CORES
      ,[zcores] as CPU_CORES
      ,[proc_type] as CPU_TYPE
      ,case when ISNUMERIC(proc_speed)=1 then cast(proc_speed as float)/1000 end as CPU_FREQ_GHZ
      ,case when right(phys_mem,3)= ' MB' then left(phys_mem, LEN(phys_mem)-3) when right(phys_mem,3)= ' GB' and ISNUMERIC(left(phys_mem, LEN(phys_mem)-3))=1 then cast(left(phys_mem, LEN(phys_mem)-3) as float)*1024 else phys_mem end as RAM_MB
      ,[class] as CLASS
      ,[family] as FAMILY
      ,[serial_number] as SN
      ,[status] as 'STATUS'
      ,[inactive] as INACTIVE
      ,[zuse] as USE_ROLE
      ,[model] as HW_MODEL
      ,[location] as DATACENTER_NAME
      ,[srv_os] as OS
      ,ci.id as CMDB_CI_ID
      ,ci.id_bin as CMDB_CI_ID_BIN
      ,[name] as RESOURCE_NAME
      ,[last_update_date] as last_mod_date
  FROM [mdb].[dbo].[zSyncUMOciAll] as ci

where  class like 'server%' and inactive = 0 and status='alive'

  --GRANT SELECT,VIEW DEFINITION ON dbo.zAPI_OLI_servers TO zCMDB_ConfigMgr



CREATE VIEW [dbo].[zAPI_OLI_virtual_platforms]
/* 20.4.2016 RQ R.Jirik*/
AS

SELECT
       [system_name] as DISPLAY_NAME
      ,[zsap_id_no]  as CPU_CORES
      ,[model] as HW_MODEL
      ,[class] as CLASS
      ,[name] as RESOURCE_NAME
      ,[serial_number] as SN
      ,ci.id as CMDB_CI_ID
      ,ci.id_bin as CMDB_CI_ID_BIN
      ,[last_update_date] as last_mod_date
FROM [mdb].[dbo].[zSyncUMOciAll] as ci

WHERE class = 'virtual-platform' and inactive = 0 and status='alive'
