-- IOPS - Total Disk I/O Made Across All Disks
SELECT   TO_CHAR(m.rollup_timestamp,'dd.mm.yyyy hh24:mi:ss') "DT",
    target_name "server",
    ROUND(average,0) "IOPS"
  FROM MGMT$METRIC_HOURLY m
  WHERE 1 = 1
    -- OEM Linux Oracle Farma PREPROD/PROD
    AND REGEXP_LIKE(m.target_name, 'z?(p|b)ordb0[0-4].vs.csin.cz')
    -- AND REGEXP_LIKE(m.target_name, 'z?(p|b)ordb0[0-4].vs.csin.cz')
    -- OEM Linux Oracle Farma test
    --    AND REGEXP_LIKE(m.target_name, '(d|t)ordb0[0-4].vs.csin.cz')
    AND m.target_type  IN ( 'host')
    AND m.metric_name   = 'DiskActivitySummary'
    AND m.metric_column = 'totiosmade'
    AND column_label LIKE 'Total Disk I/O made across all disks (per second)'
--    AND m.rollup_timestamp > TRUNC(sysdate - 7)
    AND m.rollup_timestamp BETWEEN TIMESTAMP'2015-02-27 00:00:00' AND TIMESTAMP'2015-02-28 00:00:00'
  ORDER BY m.rollup_timestamp, m.target_name ;


-- Max Average Disk I/O Service Time (ms) Among All Disks
SELECT   TO_CHAR(m.rollup_timestamp,'dd.mm.yyyy hh24:mi:ss') "DT",
    target_name "server",
    ROUND(average,1) "max avgsvc [ms]"
  FROM MGMT$METRIC_HOURLY m
  WHERE 1 = 1
    -- OEM Linux Oracle Farma PREPROD/PROD
    AND REGEXP_LIKE(m.target_name, 'z?(p|b)ordb0[0-4].vs.csin.cz')
    -- AND REGEXP_LIKE(m.target_name, 'z?(p|b)ordb0[0-4].vs.csin.cz')
    -- OEM LOF test
    --    AND REGEXP_LIKE(m.target_name, '(d|t)ordb0[0-4].vs.csin.cz')
    AND m.target_type  IN ( 'host')
    AND m.metric_name   = 'DiskActivitySummary'
    AND m.metric_column = 'maxavserv'
    AND column_label like 'Max Average Disk I/O Service Time (ms) amongst all disks'--    AND m.rollup_timestamp > TRUNC(sysdate - 7)
    AND m.rollup_timestamp BETWEEN TIMESTAMP'2015-02-27 00:00:00' AND TIMESTAMP'2015-02-28 00:00:00'
  ORDER BY m.rollup_timestamp, m.target_name ;