--------------------------------------------------------
--  DDL for View EM_INSTANCE
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "DASHBOARD"."EM_INSTANCE" ("EM_GUID", "DBNAME", "INSTANCE_NAME", "CPU", "SGA_SIZE_MB") AS
  SELECT
    d.target_guid em_guid,
    d.database_name dbname,
    d.instance_name,
    cpu_count cpu,
    m.sgasize sga_size_mb   -- SGA size
FROM
    MGMT$DB_CPU_USAGE c
    JOIN CM$MGMT_DB_SGA_ECM m ON (c.target_guid = m.cm_target_guid)
    JOIN mgmt$db_dbninstanceinfo d ON (m.cm_target_guid = d.target_guid)
WHERE m.sganame = 'Total SGA (MB)'
;
