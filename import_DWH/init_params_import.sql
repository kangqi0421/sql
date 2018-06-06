--
-- set init params before import
--

-- zvednout PGA pro create indexu
alter system set pga_aggregate_target = 40G;

-- force no logging
ALTER DATABASE NO FORCE LOGGING;

-- import dblink
alter system reset cpu_count;
alter system set resource_manager_plan = '';


-- ORA-02049: timeout: distributed transaction waiting for lock
alter system set distributed_lock_timeout = 1000000 scope=spfile;

alter system set COMMIT_LOGGING = BATCH;
alter system set COMMIT_WAIT = NOWAIT;

alter system set DB_BLOCK_CHECKSUM=FALSE scope=spfile;

ALTER SYSTEM SET "_OPTIMIZER_GATHER_STATS_ON_LOAD"=FALSE;
