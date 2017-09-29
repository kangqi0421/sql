Description=CA Servicedesk database
Trace=No
Server=cadb.csin.cz,1441
Database=mdb


--
-- definovaná view pro OLI
--

[dbo].[zAPI_OLI_relations]
[dbo].[zAPI_OLI_servers]
[dbo].[zAPI_OLI_virtual_platforms]

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

