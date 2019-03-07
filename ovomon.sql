--
-- OVOMON
--

-- oem12:
@/dba/local/sql/ovomon.sql
--

BEGIN
  EXECUTE IMMEDIATE 'create user OVOMON identified by "abcd1234" '
    ||'profile DEFAULT default tablespace USERS';
  EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN EXECUTE IMMEDIATE 'create role CS_APPL_ACCOUNTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

alter user OVOMON profile DEFAULT;
alter user OVOMON identified by "abcd1234";
alter user OVOMON profile PROF_APPL;


GRANT CSCONNECT, CS_APPL_ACCOUNTS TO OVOMON;

GRANT select on sys.v_$session  to OVOMON;
GRANT select on sys.gv_$session to OVOMON;
GRANT select on sys.v_$sysmetric to OVOMON;
GRANT select on sys.gv_$sysmetric to OVOMON;
GRANT SELECT ON sys.dba_scheduler_jobs TO OVOMON;
GRANT SELECT ON sys.dba_blockers TO OVOMON;
GRANT SELECT ON sys.dba_role_privs TO OVOMON;

select inst_id, begin_time, metric_name, value, metric_unit
  from gv$sysmetric
   where metric_name like 'SQL Service Response Time';


-- přepsat - běží dlouho
-- COST 40
select
(select count(*)
from v$session
where sid in
(select holding_session
from dba_blockers) and event='SQL*Net message
from client' and type!='BACKGROUND' and username not in
(select grantee
from dba_role_privs
where granted_role='DBA')) as Blockers
from Dual

>>
SELECT count(*)
  FROM gv$session
 WHERE  BLOCKING_SESSION_STATUS = 'VALID'
   AND  event = 'SQL*Net message from client'
   AND  type = 'USER'
;
