--
-- CMDB
--


-- RecoHUB
cadb.csin.cz,1441

TEST:
cadb.csint.cz,5441

username: zAPI_Oracle_licence
password: 7osEqq6N50pbBo0zVriF

ALTER LOGIN zAPI_Oracle_licence WITH DEFAULT_DATABASE=RecoHUB
GO

use RecoHUB

-- view od Šavel

[RecoHUB].[dbo].[viwSN_BS_for_OracleOLI] - application -
[RecoHUB].[dbo].[viwSN_serverCI_for_OracleOLI] - duplicity v cluster_name
  --> [RecoHUB].[dbo].[tblSN_server_extract]
[RecoHUB].[dbo].[viwSN_DBCI_for_OracleOLI]
  [sys_id],
  [name]

[dbo].[tblSN_cmdb_ci_server] <- servery
[dbo].[tblSN_cmdb_ci_service] <- aplikace ?

SELECT
       [sys_id]
      ,[u_system_name]
      ,[serial_number]
      ,[u_app_short_name]
      ,[name]
      ,[short_description]
      ,[service_classification]
      ,[busines_criticality]
      ,[schedule]
      ,[u_application_analyst]
      ,[used_for]
  FROM [viwSN_BS_for_OracleOLI]  WITH (NOLOCK)
  ;

HSL_oem.vs.csin.cz

select [sys_id]
      ,[sys_class_name]
      ,[name]
      ,[serial_number]
      ,[u_hostname]
      ,[fqdn]
      ,[cpu_core_count]
      -- ,[cpu_core_thread]
      ,[cpu_count]
      ,[cpu_speed]
      ,[cpu_type]
      ,[os]
      ,[ram]
      ,[used_for]
      ,[virtual]
   from [dbo].[tblSN_server_extract]  WITH (NOLOCK)
  WHERE [u_hostname] like 'oem'


-- viwSN_DBCI_for_OracleOLI
create view [dbo].[viwSN_DBCI_for_OracleOLI] as
SELECT [correlation_id]
      ,[sys_id]
      ,[u_ci_legacy_id]
      ,[name]
      ,[sys_class_name]
      ,[install_status]
 FROM [RecoHUB].[dbo].[tblSN_endpoint]
 where name like 'DBO%'
UNION ALL
SELECT [correlation_id]
      ,[sys_id]
      ,[u_ci_legacy_id]
      ,[name]
      ,[sys_class_name]
      ,[install_status]
 FROM [RecoHUB].[dbo].[tblSN_DBOI_extract]


-- viwSN_serverCI_for_OracleOLI
create view [dbo].[viwSN_serverCI_for_OracleOLI] as
SELECT clu.name as cluster_name
..
  FROM [RecoHUB].[dbo].[tblSN_server_extract] srv
  left join [RecoHUB].[dbo].[tblSN_rel] rel on srv.sys_id = rel.parent
  left join [RecoHUB].[dbo].[tblSN_vcenter_cluster_extract] clu on rel.child = clu.sys_id

SELECT TOP (1000)
      [sys_id]
      ,[name]
  FROM [RecoHUB].[dbo].[tblSN_vcenter_cluster_extract]

-- vazba mezi clustery
SELECT
       [child]
      ,[parent]
      ,[sys_id]
  FROM [RecoHUB].[dbo].[tblSN_rel]

-- CA CMDB

Description=CA Servicedesk database
Trace=No
Server=cadb.csin.cz,1441
Database=mdb




-- Test CMDB
Server=cadb.csint.cz,1441
Database=mdb

runas /netonly /noprofile /user:XTC\sol60210 "C:\Program Files (x86)\Microsoft SQL Server\140\Tools\Binn\ManagementStudio\Ssms.exe"


isql casd zAPI_Oracle_licence Heslo123.

--
-- CA definovaná view pro OLI
--

[dbo].[zAPI_Oracle_licence_apps]
[dbo].[zAPI_Oracle_Databases]
[dbo].[zAPI_Oracle_DBInstances]
[dbo].[zAPI_OLI_relations]
[dbo].[zAPI_OLI_servers]
[dbo].[zAPI_OLI_virtual_platforms]


use mdb;

-- dotaz na CMDB CA Servers
select hostname, domain
   from [dbo].[zAPI_OLI_servers]  WITH (NOLOCK)
  WHERE DOMAIN like 'dppardb01.vs.csin.cz%'

-- dotaz na licence WITH NOLOCK

USE mdb;

SELECT APP_NAME, APP_KIND, CMDB_CI_ID, STATUS, INACTIVE, RESOURCE_NAME, RESOURCE_ALT_NAME,
       va, va_email, som, som_email, [as], as_email, serv_mode
FROM     zAPI_Oracle_licence_apps WITH (NOLOCK)  -- bez zamykani radek
WHERE  (STATUS = 'Alive')
  AND APP_KIND like 'Infrastructure'
  AND resource_name like 'SAS_MN%'
ORDER BY RESOURCE_NAME

GO
