--// memory parameters //--

with pivot_data as
(
select sys_context('USERENV', 'INSTANCE_NAME') as inst, name, ceil(value/1048576) as mb from v$parameter
 )
SELECT *
FROM pivot_data PIVOT (max(mb) for name in ('memory_target', 'sga_target', 'pga_aggregate_target') )
order by 1
/


--// spec utilization //--

WITH pivot_data
     AS (SELECT substr(hostname,1,INSTR (hostname, '.', 1)-1) hostname,
             datetime_hourly, spec_util
           FROM ovo_hourly
          WHERE datetime_hourly BETWEEN DATE '2011-12-01'
                                    AND DATE '2012-01-01')
  SELECT *
    FROM pivot_data PIVOT (MAX (spec_util)
                    FOR hostname
                    IN ('amldb1', 'apscdbp1', 'rdbp1', 'apscdbp2'))
ORDER BY 1