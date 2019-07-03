--
-- Sql Plan Directives used for this statement
--

set lin 180
select * from table(dbms_xplan.display_cursor('4u47qgjtaz316', NULL, '+ALLSTATS +ADAPTIVE'));

--
-- SPD
--

-- vypnutí SPD 12.1.0.2

alter system set "_optimizer_dsdir_usage_control"=0  comment='disable use of directives' scope=both ;
alter system set "_sql_plan_directive_mgmt_control"=0  comment='disable creation of directives' scope=both;

-- to Write last directives from memory to SYSAUX
EXEC DBMS_SPD.flush_sql_plan_directive;

--  to drop existing directives
begin
  for i in (select directive_id from dba_sql_plan_directives where type ='DYNAMIC_SAMPLING')
  LOOP
  dbms_spd.drop_sql_plan_directive(i.directive_id);
  END LOOP;
END;
/

--


-- dba_sql_plan_directives

SELECT TO_CHAR(d.directive_id) dir_id, o.owner, o.object_name,
       o.subobject_name col_name, o.object_type, d.type, d.state, d.reason
FROM   dba_sql_plan_directives d, dba_sql_plan_dir_objects o
WHERE  d.directive_id=o.directive_id
AND    o.owner = 'PDB'
  and o.object_name  in ('PRODUCTCHARGE','ALTERNATIVECHARGES')
  and state = 'USABLE'
ORDER BY 1,2,3,4,5;

-- SPD directive
SELECT directive_id,
       state,
       last_used,
       auto_drop,
       enabled,
       extract(notes,'/spd_note/spd_text/text()')spd_text,
       extract(notes,'/spd_note/internal_state/text()')internal_state
FROM dba_sql_plan_directives
WHERE directive_id IN(
  SELECT directive_id
  FROM dba_sql_plan_dir_objects
  WHERE owner like 'DRDM%'
);
