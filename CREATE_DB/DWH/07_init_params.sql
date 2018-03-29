--
-- change init params
--

alter system set pga_aggregate_target = 16G;
alter system set sga_target = 64G scope=spfile;

-- tohle nefunguje
alter system set NLS_LENGTH_SEMANTICS=CHAR scope=spfile;

-- import dblink
alter system reset cpu_count;
alter system set resource_manager_plan = '';

ALTER DATABASE NO FORCE LOGGING;

-- ORA-02049: timeout: distributed transaction waiting for lock
alter system set distributed_lock_timeout = 1000000 scope=spfile;

alter system set COMMIT_LOGGING = BATCH;
alter system set COMMIT_WAIT = NOWAIT;

alter system set DB_BLOCK_CHECKSUM=FALSE scope=spfile;

ALTER SYSTEM SET "_OPTIMIZER_GATHER_STATS_ON_LOAD"=FALSE;


