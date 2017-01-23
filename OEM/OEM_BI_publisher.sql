
-- CPU nebo MEM
   AND metric_column = 'memUsedPct'
   AND  metric_column = 'cpuUtil'

-- CPU, MEM utilization
select
   to_char(m.rollup_timestamp,'yyyy-mm-dd') timestamp,
   substr(m.target_name, 1, instr(m.target_name, '.')-1) target_name,
   ROUND(m.maximum) util
 FROM
   mgmt$metric_daily m join MGMT$OS_HW_SUMMARY h
    on (m.target_name = h.host_name)
 where metric_name = 'Load'
   AND metric_column = :metric
   AND REGEXP_LIKE(m.target_name, :hostname)
   AND m.rollup_timestamp > systimestamp - NUMTOYMINTERVAL( :MONTHS, 'MONTH' )
ORDER by m.rollup_timestamp, target_name
