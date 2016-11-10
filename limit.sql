-- limits
col resource_name for a10

select *
  from gv$resource_limit
 where 1=1
   -- AND LIMIT_VALUE > 0
   and resource_name in ('processes','sessions')
  order by resource_name, inst_id;