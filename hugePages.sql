--
-- hugepages | reset memory_target to sga/pga size
--

-- memory target na SGA a PGA
SELECT component, round(current_size/1048576/1024) "current [GB]" FROM v$memory_dynamic_components
   WHERE component LIKE '%Target';

-- OEM
SELECT
   host_name,
   target_name,  name, --value,
   round(value/1048576/1024) "GB",
   ROUND(sum(value/1048576/1024) over ()) "SUM GB"
--   ROUND(sum(value/1048576/1024) over (PARTITION BY target_name)) "SUM GB"
 FROM MGMT$DB_INIT_PARAMS
 where
    name in ('memory_target','sga_target','pga_aggregate_target')
--    AND (target_name like 'PDBD%'
--      or target_name like 'SYMDA%'
--      )
    and host_name like '&server%'
--    AND REGEXP_LIKE(host_name, '^(p|b)ordb05.vs.csin.cz')
--     AND REGEXP_LIKE(host_name, '^z(p|b)ordb\d+.vs.csin.cz')
--     and target_name not like '%2'
    and value > 0
order by target_name, name;

-- Linux
define sga=12G
define pga=6G

alter system reset sga_max_size;
alter system reset memory_target;
alter system reset pga_aggregate_limit;
alter system set sga_target = &sga comment='HugePages enabled' scope=spfile;
alter system set pga_aggregate_target = &pga scope=spfile;


srvctl stop db -d ${ORACLE_SID%%[12]} && srvctl start db -d ${ORACLE_SID%%[1-9]}
