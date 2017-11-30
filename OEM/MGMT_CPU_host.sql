--
-- OEM: max CPU utilization per host
--
-- OEM Repository query for getting the max number of CPUs used:
select
   c.hostname,
   ceil(max((a.maximum*c.cpu_count)/100)) MAX_CPU,
   round(avg((a.average*c.cpu_count)/100),1) AVG_CPU
 FROM
   mgmt$metric_daily a
     join sysman.MGMT_ECM_HW c on (a.target_name = c.hostname||'.'||c.domain)
 where a.metric_name = 'Load'
 and a.column_label = 'CPU Utilization (%)'
 AND a.target_name = 'pgrtodb.cc.csin.cz'
  --AND REGEXP_LIKE(a.target_name, 'z?[pbdt]ordb0[0-9].vs.csin.cz')
  --AND a.rollup_timestamp > systimestamp - interval '1' day
  and a.rollup_timestamp between date'2016-12-29' and date'2016-12-30'
group by c.hostname
;

-- DETAIL CPU metrics
select /*CSV*/
   a.collection_timestamp,
   --c.hostname,
   round(sum(a.value*c.cpu_count/100),2) AVG_CPU
 FROM
   MGMT$METRIC_DETAILS a
     join sysman.MGMT_ECM_HW c on (a.target_name = c.hostname||'.'||c.domain)
 where a.metric_name = 'Load'
 and a.column_label = 'CPU Utilization (%)'
-- AND a.target_name = 'pgrtodb.cc.csin.cz'
  AND a.target_name in ('bordb06.vs.csin.cz')
  --AND REGEXP_LIKE(a.target_name, 'z?[pbdt]ordb0[0-9].vs.csin.cz')
  --AND a.rollup_timestamp > systimestamp - interval '1' day
  and a.collection_timestamp between date'2016-12-28' and date'2016-12-29'
GROUP BY a.collection_timestamp
ORDER BY a.collection_timestamp;


-- SQL developer graph
with cpu_util as
(
select
   substr(c.hostname, -1, 2)||substr(c.hostname, 1, 5) hostname,
   ceil(max((a.maximum*c.cpu_count)/100)) MAX_CPU,
   round(avg((a.average*c.cpu_count)/100),1) AVG_CPU
 FROM
   mgmt$metric_daily a
     join sysman.MGMT_ECM_HW c on (a.target_name = c.hostname||'.'||c.domain)
 where a.metric_name = 'Load'
 and a.column_label = 'CPU Utilization (%)'
 AND a.rollup_timestamp > systimestamp - NUMTOYMINTERVAL( :MONTHS, 'MONTH' )
 AND REGEXP_LIKE(a.target_name, '^[pb]ordb0[0-9].vs.csin.cz')
group by c.hostname)
-- decode column to second column
select hostname, 'Average CPU', AVG_CPU
  from cpu_util
union all
select hostname, 'Max. CPU', MAX_CPU
  from cpu_util
order by 1
;

