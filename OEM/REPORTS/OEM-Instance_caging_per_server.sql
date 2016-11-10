SELECT   
    p.target_name,
    p.value "#CPU"
  FROM MGMT$DB_INIT_PARAMS p
  WHERE p.host_name like 'dordb01.vs.csin.cz'
    AND p.name = 'cpu_count'
  ORDER BY p.target_name

-- /*  
BarChart  
SQL
Right
Value 200x150  
*/ --

-- kontrola zapnutí Instance cagingu a hodnoty cpu count > 24
-- odkomenovat první, zakomenotvat druhý a obráceně
SELECT
  TARGET_NAME, HOST_NAME,
  name, value
FROM
  MGMT$DB_INIT_PARAMS_ALL
WHERE
  REGEXP_LIKE(host_name, '(d|t|zp|p)ordb0[0-4].vs.csin.cz')
--   AND name = 'resource_limit' and value not like 'TRUE'
  AND name = 'cpu_count' and value > 24
ORDER BY
  target_name, name;