ALTER SESSION SET nls_date_format = 'dd.mm.yyyy hh24:mi';
ALTER SESSION SET NLS_TERRITORY = "CZECH REPUBLIC";

* Physical read IO requests – “Number of read requests for application activity (mainly buffer cache and direct load operation) which read one or more database blocks per request. This is a subset of "physical read total IO requests" statistic.”

* Physical read total IO requests – “Number of read requests which read one or more database blocks for all instance activity including application, backup and recovery, and other utilities.”

* Physical write IO requests – “Number of write requests for application activity (mainly buffer cache and direct load operation) which wrote one or more database blocks per request.”

* Physical write total IO requests – “Number of write requests which wrote one or more database blocks from all instance activity including application activity, backup and recovery, and other utilities.”


--// physical reads/writes --//
--// average lze nahradit za maxval
SELECT
  a.end_time "time",
  ROUND(a.maxval) "read [IORS]",
  ROUND(b.maxval) "write [IOWS]",
  ROUND(a.maxval +b.maxval) "IOPS",
  ROUND(c.maxval / 1048576) "read [MB/s]",
  ROUND(d.maxval / 1048576) "write [MB/s]",
  ROUND((c.maxval+d.maxval)/ 1048576) "read+write [MB/s]"
FROM dba_hist_sysmetric_summary a
INNER JOIN dba_hist_sysmetric_summary b ON (a.snap_id = b.snap_id AND a.instance_number = b.instance_number)
INNER JOIN dba_hist_sysmetric_summary c ON (b.snap_id = c.snap_id AND b.instance_number = c.instance_number)
INNER JOIN dba_hist_sysmetric_summary d ON (c.snap_id = d.snap_id AND c.instance_number = d.instance_number)
WHERE a.instance_number = 1
AND (TO_CHAR (a.END_TIME, 'MI') > '55' OR TO_CHAR (a.END_TIME, 'MI') < '05')   --<< pouze cela hodina
AND a.metric_name = 'Physical Read Total IO Requests Per Sec'
AND b.metric_name = 'Physical Write Total IO Requests Per Sec'
AND c.metric_name = 'Physical Read Total Bytes Per Sec'
AND d.metric_name = 'Physical Write Total Bytes Per Sec'
ORDER BY a.begin_time;

-- avg a max IOPS value
select avg(iops), max(iops)
from (
SELECT
  a.end_time "time",
--  ROUND(a.maxval) "read [IORS]",
--  ROUND(b.maxval) "write [IOWS]",
  ROUND(a.maxval +b.maxval) "IOPS"
--  ROUND(c.maxval / 1048576) "read [MB/s]",
--  ROUND(d.maxval / 1048576) "write [MB/s]",
--  ROUND((c.maxval+d.maxval)/ 1048576) "read+write [MB/s]"
FROM dba_hist_sysmetric_summary a
INNER JOIN dba_hist_sysmetric_summary b ON (a.snap_id = b.snap_id AND a.instance_number = b.instance_number)
INNER JOIN dba_hist_sysmetric_summary c ON (b.snap_id = c.snap_id AND b.instance_number = c.instance_number)
INNER JOIN dba_hist_sysmetric_summary d ON (c.snap_id = d.snap_id AND c.instance_number = d.instance_number)
WHERE a.instance_number = 1
AND (TO_CHAR (a.END_TIME, 'hh24')) between 07 and 18
AND a.metric_name = 'Physical Read Total IO Requests Per Sec'
AND b.metric_name = 'Physical Write Total IO Requests Per Sec'
AND c.metric_name = 'Physical Read Total Bytes Per Sec'
AND d.metric_name = 'Physical Write Total Bytes Per Sec'
ORDER BY a.begin_time
);

-- Small/Large read
Physical read total IO requests
physical read total multi block requests

Small Reads  = Total Reads - Large Reads
Small Writes = Total Writes - Large Writes

-- procento SMALL reads vs Total Reads
select round(sum(SMALL_READ_REQS)/(sum(SMALL_READ_REQS) +  sum(LARGE_READ_REQS))*100)
 from gv$iostat_function ;

-- IO per function
select inst_id,function_name,
sum(small_read_megabytes+large_read_megabytes) as read_mb,
sum(small_write_megabytes+large_write_megabytes) as write_mb
from gv$iostat_function
group by cube (inst_id,function_name)
order by inst_id,function_name;


--// aktuální požadavky na datafiles //--
SELECT FILE_NO,
  SMALL_READ_MEGABYTES,
  LARGE_READ_MEGABYTES,
  SMALL_READ_REQS,
  LARGE_READ_REQS
FROM v$iostat_file
WHERE FILETYPE_NAME = 'Data File';
