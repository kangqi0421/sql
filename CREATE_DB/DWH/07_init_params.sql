--
-- change init params
--

alter system set pga_aggregate_target = 16G;
alter system set sga_target = 64G scope=spfile;

alter system set db_files = 4000 scope=spfile;
