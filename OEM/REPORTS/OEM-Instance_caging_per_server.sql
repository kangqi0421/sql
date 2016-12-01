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

-- kontrola zapnutí Instance cagingu
SELECT
  --db.host_name,
  db.target_name "db",
  db.value "cpu"
  --hw.logical_cpu_count
 FROM SYSMAN.MGMT$DB_INIT_PARAMS_ALL db
   join SYSMAN.MGMT$OS_HW_SUMMARY hw on (db.host_name = hw.host_name)
 where REGEXP_LIKE(db.host_name, 'z?(t|d|p|b)ordb[[:digit:]]+.vs.csin.cz')
   and db.name = 'cpu_count'
   and db.isdefault = 'TRUE'
   and db.value = hw.logical_cpu_count
 order by db.target_name;