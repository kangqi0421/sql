-- reset memory_target to sga/pga size

-- memory target na SGA a PGA
SELECT component, round(current_size/1048576/1024) "current [GB]" FROM v$memory_dynamic_components
   WHERE component LIKE '%Target';

-- OEM
SELECT
   host_name, target_name, round(value/1048576/1024)
 FROM MGMT$DB_INIT_PARAMS
 where
  REGEXP_LIKE(host_name, '^[p]ordb0[0-5].vs.csin.cz')
--  REGEXP_LIKE(host_name, 'z?(t|d|p|b)ordb0[0-5].vs.csin.cz')
 and name = 'memory_target' and value > 0
 order by host_name, target_name;

-- Linux
define sga=12G
define pga=6G

alter system reset sga_max_size;
alter system reset memory_target;
alter system reset pga_aggregate_limit;
alter system set sga_target = &sga comment='HugePages enabled' scope=spfile;
alter system set pga_aggregate_target = &pga scope=spfile;


srvctl stop db -d ${ORACLE_SID%%[12]} && srvctl start db -d ${ORACLE_SID%%[1-9]}