# Migrace OWF_MGR

## pre-import
```sql
connect sys

create or replace type system.ecxevtmsg as object
	(
   	document_number   varchar2(2000),
   	party_id          varchar2(2000),
   	transaction_type  varchar2(2000),
   	payload           clob,
   	event_type        varchar2(2000),
   	event_code        varchar2(2000),
   	event_details1    varchar2(2000),
   	event_details2    varchar2(2000),
   	event_details3    varchar2(2000),
   	event_details4    varchar2(2000)
	);
/
create or replace type system.wf_message_payload_t as object (message CLOB);
/

CREATE OR REPLACE FORCE NONEDITIONABLE VIEW "SYS"."WF_ALL_JOBS" (
  "JOB",
  "LOG_USER",
  "PRIV_USER",
  "SCHEMA_USER",
  "LAST_DATE",
  "LAST_SEC",
  "THIS_DATE",
  "THIS_SEC",
  "NEXT_DATE",
  "NEXT_SEC",
  "TOTAL_TIME",
  "BROKEN",
  "INTERVAL",
  "FAILURES",
  "WHAT",
  "NLS_ENV",
  "MISC_ENV",
  "INSTANCE") AS 
select
  j."JOB",
  j."LOG_USER",
  j."PRIV_USER",
  j."SCHEMA_USER",
  j."LAST_DATE",
  j."LAST_SEC",
  j."THIS_DATE",
  j."THIS_SEC",
  j."NEXT_DATE",
  j."NEXT_SEC",
  j."TOTAL_TIME",
  j."BROKEN",
  j."INTERVAL",
  j."FAILURES",
  j."WHAT",
  j."NLS_ENV",
  j."MISC_ENV",
  j."INSTANCE"
from SYS.dba_jobs j
where j.priv_user = sys_context('USERENV', 'CURRENT_SCHEMA');

grant select on "SYS"."WF_ALL_JOBS" to public;
create public synonym WF_ALL_JOBS for SYS.WF_ALL_JOBS;
```

## impdp metadata
```shell
impdp \
  system \
  directory=data_pump_dir \
  dumpfile=owf_mgr_%u.dwhz.dmp \
  logfile=owf_mgr.dwhz.metadata.log \
  schemas=owf_mgr \
  content=metadata_only \
  include=user,system_grant,role_grant,tablespace_quota,default_role
```

## grant
```sql
-- source database
select 'grant '||privilege||' on '||owner||'.'||table_name||' to '||grantee||decode(grantable,'YES',' with grant option','')||';'
from dba_tab_privs
where grantee = 'OWF_MGR'
  and owner in ('SYS','SYSTEM')
  and privilege not in ('READ','WRITE')
  and table_name not like 'QT%BUFFER';

-- target database
grant SELECT on SYS.V_$PARAMETER to OWF_MGR;
grant SELECT on SYS.V_$DATABASE to OWF_MGR;
grant SELECT on SYS.V_$INSTANCE to OWF_MGR;
grant SELECT on SYS.V_$TIMER to OWF_MGR;
grant SELECT on SYS.GV_$SESSION to OWF_MGR;
grant SELECT on SYS.DBA_ROLES to OWF_MGR;
grant SELECT on SYS.DBA_ROLE_PRIVS to OWF_MGR with grant option;
grant SELECT on SYS.DBA_USERS to OWF_MGR with grant option;
grant SELECT on SYS.DBA_JOBS_RUNNING to OWF_MGR;
grant SELECT on SYS.DBA_JOBS to OWF_MGR;
grant EXECUTE on SYS.AQ$_AGENT to OWF_MGR with grant option;
grant EXECUTE on SYS.AQ$_DEQUEUE_HISTORY to OWF_MGR with grant option;
grant EXECUTE on SYS.AQ$_SUBSCRIBERS to OWF_MGR with grant option;
grant EXECUTE on SYS.AQ$_RECIPIENTS to OWF_MGR with grant option;
grant EXECUTE on SYS.AQ$_HISTORY to OWF_MGR with grant option;
grant EXECUTE on SYS.AQ$_DEQUEUE_HISTORY_T to OWF_MGR with grant option;
grant EXECUTE on SYS.AQ$_NOTIFY_MSG to OWF_MGR with grant option;
grant SELECT on SYS.DBA_QUEUE_SCHEDULES to OWF_MGR;
grant SELECT on SYS.GV_$AQ to OWF_MGR;
grant EXECUTE on SYS.DBMS_AQ to OWF_MGR;
grant EXECUTE on SYS.DBMS_AQADM to OWF_MGR;
grant EXECUTE on SYSTEM.WF_MESSAGE_PAYLOAD_T to OWF_MGR;
grant EXECUTE on SYSTEM.ECXEVTMSG to OWF_MGR with grant option;
grant EXECUTE on SYS.DBMS_AQ_BQVIEW to OWF_MGR;
grant EXECUTE on SYS.APPL_BATCH_RG to OWF_MGR;
grant SELECT on SYS.USER$ to OWF_MGR;

-- source database
select 'grant '||privilege||' on directory '||table_name||' to '||grantee||decode(grantable,'YES',' with grant option','')||';'
from dba_tab_privs
where grantee = 'OWF_MGR'
  and owner in ('SYS','SYSTEM')
  and privilege in ('READ','WRITE');

-- target database
grant READ on directory TMP to OWF_MGR;
grant READ on directory IMPORT to OWF_MGR;
grant WRITE on directory TMP to OWF_MGR;
grant WRITE on directory IMPORT to OWF_MGR;
```

## impdp data
```shell
impdp \
  system \
  directory=data_pump_dir \
  dumpfile=owf_mgr_%u.dwhz.dmp \
  logfile=owf_mgr.dwhz.data.log \
  schemas=owf_mgr \
  exclude=user,system_grant,role_grant,tablespace_quota,default_role \
  parallel=4
```
