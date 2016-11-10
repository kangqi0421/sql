-- http://www.pythian.com/blog/oracle-limiting-query-runtime-without-killing-the-session/

-- CANCEL_SQL does not stops the SQL execution based on SWITCH_TIME following the upgrade from 11.1.0.7 to 11.2.0.2.
-- Workaround:
-- Use active session limits but don't use switch_time

-- SRBA TEST RG
BEGIN
  DBMS_RESOURCE_MANAGER.CLEAR_PENDING_AREA();
  DBMS_RESOURCE_MANAGER.CREATE_PENDING_AREA();

  DBMS_RESOURCE_MANAGER.CREATE_CONSUMER_GROUP ('GRP_SRBA', 'Group pro users, limited SQL query time');
  dbms_resource_manager.set_consumer_group_mapping('ORACLE_USER','SRBA','GRP_SRBA');

  DBMS_RESOURCE_MANAGER.CREATE_PLAN_DIRECTIVE('CRM_PLAN','GRP_SRBA','GRP_SRBA: limited SQL query execution time',
	switch_group => 'CANCEL_SQL', switch_elapsed_time => 5, switch_for_call => true);
  
  dbms_resource_manager.validate_pending_area();
  dbms_resource_manager.submit_pending_area();
END;
/

exec DBMS_RESOURCE_MANAGER_PRIVS.GRANT_SWITCH_CONSUMER_GROUP('PUBLIC','GRP_SRBA',FALSE);

-- switch to group CRM
select SID,serial# from v$session where AUDSID = USERENV('SESSIONID');
exec DBMS_RESOURCE_MANAGER.SWITCH_CONSUMER_GROUP_FOR_SESS(10029,38251,'CRM_LIMIT_QUERY'); 
select resource_consumer_group from v$session where AUDSID = USERENV('SESSIONID');


-- CPU load
set autotrace trace
set timing on
define rows=1000000000000
select
    /*+ ordered use_nl(b) use_nl(c) use_nl(d) full(a) full(b) full(c) full(d) */
    count(*)
from
    sys.obj$ a, sys.obj$ b, sys.obj$ c, sys.obj$ d
where
    a.owner# = b.owner# and b.owner# = c.owner#
and c.owner# = d.owner# and rownum <= &rows
/


 
-- state
SELECT se.sid sess_id, co.name consumer_group,
 se.state, se.consumed_cpu_time cpu_time, se.cpu_wait_time, se.queued_time
 FROM v$rsrc_session_info se, v$rsrc_consumer_group co
 WHERE se.current_consumer_group_id = co.id
 and co.name = 'CRM_LIMIT_QUERY';
