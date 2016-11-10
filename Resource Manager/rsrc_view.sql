-- active plan
select * from v$rsrc_plan 
  --where cpu_managed='ON' and is_top_plan='TRUE'
;

define plan = DWH_PLAN_PROD

-- všechny dostupné RM plány
select * from dba_rsrc_plans;

select 
    *
--    GROUP_OR_SUBPLAN, SWITCH_GROUP, switch_time
  from dba_rsrc_plan_directives
 where plan like '&plan'
--  and GROUP_OR_SUBPLAN like 'GRP%'
 order by plan, GROUP_OR_SUBPLAN
;

select *
  from dba_rsrc_consumer_groups
-- where CONSUMER_GROUP like 'GRP_%'
 ;

select * from dba_rsrc_group_mappings;

-- default group DEFAULT_CONSUMER_GROUP
select username, initial_rsrc_consumer_group from dba_users;

-- mapovani session to consumer groups
select username, resource_consumer_group from gv$session
  where username = 'SRBA';

select username,resource_CONSUMER_GROUP,count(*) 
  from gv$session
 group by username,resource_CONSUMER_GROUP
 order by 2,1;
 
select username, osuser, machine, program, module, service_name, resource_CONSUMER_GROUP
  from gv$session
where resource_consumer_group = 'MCI_HIGH'
  --and NOT REGEXP_LIKE(username, '^(EXT|CEN|ITA|SOL)[^_].*')
order by 1;    
  
-- Performance stats statistiky 
select * from v$rsrc_consumer_group;  

-- SID state and consumer groups
SELECT se.sid, co.name consumer_group, se.state, se.consumed_cpu_time cpu_time, 
       se.cpu_wait_time, se.queued_time, se.PQ_ACTIVE_TIME, se.PQ_ACTIVE, se.sql_canceled
  FROM v$rsrc_session_info se, v$rsrc_consumer_group co
 WHERE se.current_consumer_group_id = co.id
--  and co.name = 'MCI_HIGH'
--  and se.sql_canceled > 0
  ;
  
select * 
  from V$RSRC_CONS_GROUP_HISTORY
 ORDER BY sequence;  
  
-- SQL cancel stats
SELECT  b.start_time, b.name,  a.name, a.requests, consumed_cpu_time,
    sql_canceled
  FROM v$rsrc_cons_group_history a
  INNER JOIN V$RSRC_PLAN_HISTORY b
  ON (a.sequence#    = b.sequence#)
--  WHERE sql_canceled > 0
  ORDER BY b.start_time desc;
  
-- CPU usage history
select m.begin_time, m.consumer_group_name, m.cpu_consumed_time / 60000 avg_running_sessions, m.cpu_wait_time / 60000 avg_waiting_sessions, d.mgmt_p1*(select value from v$parameter where name = 'cpu_count')/100 allocation 
from v$rsrcmgrmetric_history m, dba_rsrc_plan_directives d, v$rsrc_plan p 
where m.consumer_group_name = d.group_or_subplan and p.name = d.plan 
order by m.begin_time, m.consumer_group_name;

-- DBA_HIST
SELECT  
      r.*
--        end_interval_time, consumer_group_name, consumed_cpu_time, CPU_WAIT_TIME, yields
  FROM DBA_HIST_RSRC_CONSUMER_GROUP r JOIN dba_hist_snapshot s on (r.snap_id = s.snap_id)
  WHERE  r.consumer_group_name in ('OTHER_GROUPS')
    AND r.instance_number = 1
  ORDER BY s.end_interval_time desc;  


