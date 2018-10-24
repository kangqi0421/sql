--
-- init parametry
--
http://jbaskar.blogspot.cz/2011/08/oms-grid-console-exploring-using-sql.html

https://docs.oracle.com/cd/E73210_01/EMVWS/lot.htm

-- init OER view
MGMT$DB_INIT_PARAMS
MGMT$DB_INIT_PARAMS_ALL
CM$MGMT_DB_INIT_PARAMS_ECM


-- init parametry produkce
SELECT
    TARGET_NAME, host_name, isdefault,
    VALUE
    -- round(value/1048576) "MB"
  FROM MGMT$DB_INIT_PARAMS
  WHERE name                 = 'db_file_multiblock_read_count'
  and target_name in ('DMTA2','DWHTA2','ODSTA2','RTOP', 'ODSP', 'DWHP', 'DWMP')
    --like '%TA2%'
ORDER BY TARGET_NAME;

-- memory_target - overeni, ze se nepouziva na produkci
SELECT
   host_name, target_name, round(value/1048576/1024)
 FROM MGMT$DB_INIT_PARAMS
 where
  REGEXP_LIKE(host_name, '^[p]ordb0[0-5].vs.csin.cz')
--  REGEXP_LIKE(host_name, 'z?(t|d|p|b)ordb0[0-5].vs.csin.cz')
 and name = 'memory_target' and value > 0
 order by host_name, target_name;

-- init parametry produkce
SELECT *
--    TARGET_NAME,
--    VALUE
  FROM MGMT$DB_INIT_PARAMS
  INNER JOIN MGMT$TARGET_FLAT_MEMBERS
  ON (MEMBER_TARGET_GUID = TARGET_GUID)
  WHERE name                 = 'cursor_sharing'
  --AND AGGREGATE_TARGET_NAME IN ('PRODUKCE')
  AND AGGREGATE_TARGET_TYPE = 'composite'
  and target_name like 'EPM%'
ORDER BY TARGET_NAME;

-- cpu_count - instance caging
SELECT
  host_name, target_name, value
 FROM SYSMAN.MGMT$DB_INIT_PARAMS
 where name = 'cpu_count'
--    AND REGEXP_LIKE(host_name, 'z?(t|d|p|b)ordb0[0-5].vs.csin.cz')
    and REGEXP_LIKE(host_name, '[p]ordb02.vs.csin.cz')
 order by target_name;

-- db_recovery_file_dest_size
SELECT --*
--  host_name,
   target_name, round(value/1048576/1024)
 FROM MGMT$DB_INIT_PARAMS
 where name = 'db_recovery_file_dest_size'
 and target_name in ('BRAP_BRAP1','CPSP_CPSP1','CRMP','CSPO','MCIP_MCIP1','DMSLAPP')
-- and  target_name like 'BRAP%'
 order by target_name;
