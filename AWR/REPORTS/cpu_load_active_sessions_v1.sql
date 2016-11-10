WITH cpu AS
  (
  SELECT to_number(value) cpus FROM v$parameter  WHERE name='cpu_count'
  ),
     sysmetric AS
  ( 
  SELECT   to_char(end_time,'dd.mm.yyyy hh24:mi:ss') end_time,
           metric_name,
           to_number(average) AS value
    FROM dba_hist_sysmetric_summary
      where metric_name IN ( 
            'Average Active Sessions',
            'Host CPU Utilization (%)',
            'Current OS Load'
            )
        AND end_time > TRUNC(sysdate - 3)
        AND instance_number = sys_context('USERENV', 'INSTANCE')
  )
  SELECT  to_char(end_time,'dd.mm.yyyy hh24:mi:ss') end_time, 
          decode(metric_name,'Host CPU Utilization (%)', 'CPU util*#cpu', metric_name),
          case metric_name 
             when 'Average Active Sessions' then value
             when 'Current OS Load' then value
             -- CPU util*#cpu/100
             when 'Host CPU Utilization (%)' then value*cpus/100
          end value   
    from sysmetric, cpu
  UNION ALL
  SELECT   to_char(end_time,'dd.mm.yyyy hh24:mi:ss') end_time, 'CPU COUNT', cpus
    FROM cpu, sysmetric
  ORDER BY end_time