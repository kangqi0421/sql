alter system set resource_manager_plan = DEFAULT_PLAN;
ALTER SYSTEM SET cpu_count = &1 ;
select instance_caging from v$rsrc_plan where cpu_managed='ON' and is_top_plan='TRUE';
select value from v$parameter where name ='cpu_count'
  and (isdefault='FALSE' or ismodified != 'FALSE');
