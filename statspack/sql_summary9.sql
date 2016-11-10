/* Formatted on 2004/11/04 16:05 (Formatter Plus v4.8.0) */
SELECT   s.hash_value, SUM (s.buffer_gets)"buffer gets", SUM (s.disk_reads)"disk reads", sum(s.CPU_TIME)/1000000 "CPU [s]", sum(s.elapsed_time)/1000000 "time [s]",
         SUM (s.executions) "executions"
    FROM sql s
	 where s.snap_id > 11136
GROUP BY s.hash_value
	  having sum(s.elapsed_time)/1000000 > 300
ORDER BY 5 DESC

select hash_value, snap_id, disk_reads, buffer_gets, executions, cpu_time, elapsed_time 
from stats$sql_summary where hash_value in (953041270, 1454785879, 841110954, 2366233413)
 order by hash_value, snap_id	  

select distinct snap_id from stats$sql_summary