--
-- MCI plan to limit users on default db service
--
-- if query consumes more than 5 seconds of CPU
--  - switched to the group QUERY_LOW
--  - limit CPU
--  - limit PQ do degree <PARALLEL_LIMIT>
--
-- Version: 0.1
--
-- Change History:
-- 2014/04/14	Jiri Srba	created
--
set echo on
SET VERIFY OFF

DEFINE RSRC_PLAN=MCI_PLAN

-- limit PQ after 5 sec switch
DEFINE PARALLEL_LIMIT=2

DEFINE DEFAULT_SVC=MCISTB
DEFINE ADHOC_SVC=MCIST2
DEFINE CICDTP_SVC=CICST2_DTP
DEFINE CIC_SVC=CICST2
DEFINE INETEXT_SVC=INETEXT
DEFINE INETINT_SVC=INETINT
DEFINE JOBS_SVC=MCIST2_JOBS

DEFINE GRP_APP=MCI_APPL
DEFINE GRP_HIGH=MCI_HIGH
DEFINE GRP_LOW=MCI_LOW


-- DROP old MCI planu
prompt DROP old MCI planu
ALTER SYSTEM SET RESOURCE_MANAGER_PLAN ='';

BEGIN
  DBMS_RESOURCE_MANAGER.CREATE_PENDING_AREA();
  dbms_resource_manager.DELETE_PLAN_CASCADE ('&RSRC_PLAN'); 
  dbms_resource_manager.DELETE_CONSUMER_GROUP('&GRP_HIGH');
  dbms_resource_manager.DELETE_CONSUMER_GROUP('&GRP_LOW');
  dbms_resource_manager.DELETE_CONSUMER_GROUP('&GRP_APP');
exception when OTHERS then null;
END;
/

BEGIN  
  dbms_resource_manager.validate_pending_area();
  dbms_resource_manager.submit_pending_area();
END;
/

-- CREATE Groups
prompt Create resource manager consumer groups
BEGIN
DBMS_RESOURCE_MANAGER.CREATE_PENDING_AREA();
-- consumer groups
  dbms_resource_manager.create_consumer_group (
	consumer_group => '&GRP_HIGH',
	comment => 'MCI: Short, well-tuned queries'
  );
--
  dbms_resource_manager.create_consumer_group (
	consumer_group => '&GRP_LOW',
	comment => 'MCI: switching group'
  );
--
  dbms_resource_manager.create_consumer_group (
	consumer_group => '&GRP_APP',
	comment => 'MCI: application group'
  );
--
  dbms_resource_manager.validate_pending_area();
  dbms_resource_manager.submit_pending_area();
END;
/  

-- Create plan  
prompt Create resource manager plans and directives.
BEGIN
DBMS_RESOURCE_MANAGER.CREATE_PENDING_AREA();

-- resource plan
DBMS_RESOURCE_MANAGER.CREATE_PLAN(
  PLAN => '&RSRC_PLAN'
  , COMMENT => '&RSRC_PLAN.: limit 5 seconds on CPU to non-application users'
  );

-- session start in GRP_HIGH consumer group
-- switch after 5 sec to GRP_LOW
dbms_resource_manager.create_plan_directive(
		plan => '&RSRC_PLAN'
		, group_or_subplan => '&GRP_HIGH'
		, comment => 'Max 5 seconds on CPU before switch'
		, mgmt_p3 => 40
		, switch_estimate => true
		, switch_group => '&GRP_LOW'
		, switch_time => 5
    , switch_for_call => FALSE
);

dbms_resource_manager.create_plan_directive(
		plan => '&RSRC_PLAN'
		, group_or_subplan => '&GRP_LOW'
		, comment => 'Switching group for &GRP_HIGH..'
		, mgmt_p3 => 10
		, parallel_degree_limit_p1 => &PARALLEL_LIMIT
		--, parallel_target_percentage => 25
		, active_sess_pool_p1 => &PARALLEL_LIMIT
);

dbms_resource_manager.create_plan_directive(
	  plan => '&RSRC_PLAN'
	  , group_or_subplan => '&GRP_APP' 
	  , comment => 'Directive for &GRP_APP..'
	  , mgmt_p2 => 75
);

dbms_resource_manager.create_plan_directive(
	  plan => '&RSRC_PLAN'
	  , group_or_subplan => 'SYS_GROUP' 
	  , comment => 'Directive for SYS_GROUP.'
	  , mgmt_p1 => 75
);

-- Other Groups
-- to prevent ORA-29377: consumer group OTHER_GROUPS is not part of top-plan LIMIT_EXEC_TIME
DBMS_RESOURCE_MANAGER.CREATE_PLAN_DIRECTIVE('&RSRC_PLAN','OTHER_GROUPS','OTHER_GROUPS',
     MGMT_P3 => 5);

DBMS_RESOURCE_MANAGER.VALIDATE_PENDING_AREA();
DBMS_RESOURCE_MANAGER.SUBMIT_PENDING_AREA();
dbms_resource_manager.clear_pending_area();

END;
/

-- Resource manager groups mappings
begin
  dbms_resource_manager.create_pending_area();

  -- Mapping priorities
dbms_resource_manager.set_consumer_group_mapping_pri(
	explicit => 1
	, service_module_action => 2
	, service_module => 3
	, module_name_action => 4
	, module_name => 5
	, oracle_user => 6
	, service_name => 7
	, client_program => 8
	, client_os_user => 9
	, client_machine => 10
);

-- default service and ADHOC SQL service -> GRP HIGH
dbms_resource_manager.set_consumer_group_mapping(
	dbms_resource_manager.service_name, '&DEFAULT_SVC', '&GRP_HIGH'
  );
dbms_resource_manager.set_consumer_group_mapping(
	dbms_resource_manager.service_name, '&ADHOC_SVC', '&GRP_HIGH'
  );
-- other APP services mapped into GRP APP  
dbms_resource_manager.set_consumer_group_mapping(
	dbms_resource_manager.service_name, '&CICDTP_SVC', '&GRP_APP'
  );
dbms_resource_manager.set_consumer_group_mapping(
	dbms_resource_manager.service_name, '&CIC_SVC', '&GRP_APP'
  );
dbms_resource_manager.set_consumer_group_mapping(
	dbms_resource_manager.service_name, '&INETEXT_SVC', '&GRP_APP'
  );
dbms_resource_manager.set_consumer_group_mapping(
	dbms_resource_manager.service_name, '&INETINT_SVC', '&GRP_APP'
  );
dbms_resource_manager.set_consumer_group_mapping(
	dbms_resource_manager.service_name, '&JOBS_SVC', '&GRP_APP'
  );
  
dbms_resource_manager.validate_pending_area();
dbms_resource_manager.submit_pending_area();
end;
/

-- grant switch to PUBLIC
prompt Resource manager consumer group privileges
BEGIN
DBMS_RESOURCE_MANAGER_PRIVS.GRANT_SWITCH_CONSUMER_GROUP('PUBLIC','&GRP_HIGH',FALSE);
DBMS_RESOURCE_MANAGER_PRIVS.GRANT_SWITCH_CONSUMER_GROUP('PUBLIC','&GRP_LOW',FALSE);
DBMS_RESOURCE_MANAGER_PRIVS.GRANT_SWITCH_CONSUMER_GROUP('PUBLIC','&GRP_APP',FALSE);
END;
/

alter system set resource_manager_plan = '&RSRC_PLAN';

select name from v$rsrc_plan where cpu_managed='ON' and is_top_plan='TRUE';