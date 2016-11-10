-- všechny servery tady v Praze
define server=%

-- IOPS per db on server
SELECT
   m.target_name,
   round(max(m.maximum)) max_IOPS,
   round(avg(m.average)) avg_IOPS
FROM
  MGMT$METRIC_DAILY m
WHERE   m.metric_name = 'DiskActivitySummary' 
    AND m.metric_column = 'totiosmade' AND column_label like 'Total Disk I/O made across all disks (per second)'
  AND m.rollup_timestamp > sysdate - interval '2' DAY
  AND m.target_name like '&server'
group by m.target_name 
order by 2 desc;
