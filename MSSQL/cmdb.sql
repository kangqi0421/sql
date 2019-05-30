--
-- CMDB
--


cadb.csin.cz,1441

use RecoHUB

Description=CA Servicedesk database
Trace=No
Server=cadb.csin.cz,1441
Database=mdb

-- Test CMDB
Server=cadb.csint.cz,1441
Database=mdb

runas /netonly /noprofile /user:XTC\sol60210 "C:\Program Files (x86)\Microsoft SQL Server\140\Tools\Binn\ManagementStudio\Ssms.exe"

--
-- definovaná view pro OLI
--

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

-- SQL Developer

select * FROM "dbo"."zAPI_Oracle_licence_servers"@"CASDGW";


