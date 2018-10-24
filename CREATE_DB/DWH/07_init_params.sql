--
-- DWH change init params
--

alter system set pga_aggregate_target = 8G;
alter system set sga_target = 16G scope=spfile;

alter system set db_files = 4000 scope=spfile;

-- disable recycle
alter system set recyclebin = OFF scope=spfile;

-- disable force logging
alter database no force logging;
