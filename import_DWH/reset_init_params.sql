--
-- reset init params after import
--

-- import dblink
alter system reset cpu_count;
alter system reset resource_manager_plan;

alter system reset distributed_lock_timeout;

alter system reset COMMIT_LOGGING;
alter system reset COMMIT_WAIT;

alter system reset DB_BLOCK_CHECKSUM;

ALTER SYSTEM RESET "_OPTIMIZER_GATHER_STATS_ON_LOAD";
