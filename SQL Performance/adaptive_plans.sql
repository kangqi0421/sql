--
-- Sql Plan Directives used for this statement
--

set lin 180
select * from table(dbms_xplan.display_cursor('4u47qgjtaz316', NULL, '+ALLSTATS +ADAPTIVE'));

EXEC DBMS_SPD.flush_sql_plan_directive;

SELECT TO_CHAR(d.directive_id) dir_id, o.owner, o.object_name, 
       o.subobject_name col_name, o.object_type, d.type, d.state, d.reason
FROM   dba_sql_plan_directives d, dba_sql_plan_dir_objects o
WHERE  d.directive_id=o.directive_id
AND    o.owner = 'PDB'
  and o.object_name  in ('PRODUCTCHARGE','ALTERNATIVECHARGES')
  and state = 'USABLE'
ORDER BY 1,2,3,4,5;

-- SQL patch plan
