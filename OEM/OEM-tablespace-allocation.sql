SELECT /* OEM metric daily */  
   to_char(m.rollup_timestamp,'dd.mm.yyyy') "date",  
   m.key_value,
   round(m.average,1) "Allocated Space [MB]" 
FROM 
  MGMT$METRIC_DAILY m 
WHERE  1 = 1 
  AND m.target_name like :db
  AND m.metric_name = 'tbspAllocation' 
  AND m.metric_column = 'spaceAllocated' 
  AND m.metric_label like 'Tablespace Allocation' 
  AND m.key_value like :tablespace
AND m.rollup_timestamp > sysdate - 14 
  order by m.rollup_timestamp asc