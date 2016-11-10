-- Average Active Sessions per server
SELECT /*+ MATERIALIZE */
    TRUNC(m.rollup_timestamp) "DT",
--    t.host_name, 
    m.target_name,
    ROUND(m.average,2) "Avg Active Sessions"
  FROM MGMT$METRIC_DAILY m join mgmt$target t on (M.target_GUID = t.TARGET_GUID)
  WHERE 1 = 1
    AND T.HOST_NAME like 'pordb04.vs.csin.cz'
--    AND m.target_name LIKE 'MATP_MATP1%'
    AND m.metric_name   = 'instance_throughput'
    AND m.metric_column = 'avg_active_sessions'
    AND m.column_label LIKE 'Average Active Sessions'
    AND m.rollup_timestamp > TRUNC(sysdate-7)
  ORDER BY m.rollup_timestamp
  ;

-- Instance caging - ne/využití CPU a omezení pøes instance caging
col host_name for a20
col target_name for a15
col "#avg_active_sess" for 99.90
col "#CPU limit" for 99

with metric_daily as (     
SELECT
    /* OEM metric daily average over last 7 days */
    m.TARGET_GUID,
    AVG(m.average) avg_act_sess
  FROM MGMT$METRIC_DAILY m
  WHERE 
    m.metric_name   = 'instance_throughput'
    AND m.metric_column = 'avg_active_sessions'
    AND column_label LIKE 'Average Active Sessions'
    AND m.rollup_timestamp > sysdate - 7
  GROUP BY m.TARGET_GUID )
SELECT  
    t.host_name,
    t.target_name,
    round(s.avg_act_sess, 2) "#avg_active_sess",  -- stavajici spotreba CPU v metrice average active sessions
    p.value "#CPU limit"                          -- CPU limit nastaveny pres instance caging
--    ,round(sum(s.avg_act_sess) over (partition by t.host_name), 2) "sum #sess per hostname"
  FROM mgmt$target t join MGMT$DB_INIT_PARAMS p on (t.TARGET_GUID = p.TARGET_GUID)
       join metric_daily s on (t.TARGET_GUID = s.TARGET_GUID)
  WHERE 
    -- Linux Oracle Cloud bez [b]ackup serveru
    REGEXP_LIKE(t.host_name, '(d|t|zp|p)ordb0[0-4].vs.csin.cz')
    AND t.target_type LIKE '%database'
    AND p.name = 'cpu_count'
  ORDER by host_name, target_name;
    
    
/*
SELECT
    p.TARGET_GUID,
    p.target_name,
    p.value "#CPU"
  FROM MGMT$DB_INIT_PARAMS p
  WHERE p.host_name LIKE 'zpordb0_.vs.csin.cz'
    AND p.name = 'cpu_count'
  ORDER BY p.host_name,
    p.target_name;
    
SELECT
    m.TARGET_GUID,
    AVG(m.average) avg_act_sess
  FROM MGMT$METRIC_DAILY m
  WHERE 
    m.target_name  IN ('CASEZA_CASEZA1')
    AND m.metric_name   = 'instance_throughput'
    AND m.metric_column = 'avg_active_sessions'
    AND column_label LIKE 'Average Active Sessions'
    AND m.rollup_timestamp > sysdate - 7
  GROUP BY m.TARGET_GUID
  ;

*/