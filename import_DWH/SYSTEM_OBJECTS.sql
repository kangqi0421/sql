--------------------------------------------------------
--  DDL for Trigger OWF_LOGON_TRIG
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "SYSTEM"."OWF_LOGON_TRIG" AFTER LOGON
ON database
declare
  ls_user varchar2(40) := 'OWF_MGR';       -- OWF_MGR
  ls_program varchar2(40) := 'WFBLDR.EXE';  -- WFBLDR.EXE

  ln_sid number;
  ls_conflict_osuser varchar2(40);
  ls_current_program varchar2(40);
  l_cnt integer;

BEGIN
  if user = ls_user then

    select USERENV('SID') into ln_sid from dual;

    select ses_sid.program into ls_current_program
      from
        v$session ses_sid
     where ses_sid.sid = ln_sid;

    select count(1) into l_cnt
      from
        v$session ses_sid,
        owf_mgr.owf_logon_trig_usr_groups usrgrp_sid
     where ses_sid.sid = ln_sid
       and ses_sid.program = ls_program
       and upper(ses_sid.osuser) = upper(usrgrp_sid.osuser_id);

    if l_cnt = 0 and upper(ls_current_program) = upper(ls_program)
      then RAISE_APPLICATION_ERROR(-20001, 'Current osuser not enabled for WF changes (OWF_MGR.OWF_LOGON_TRIG_USR_GROUPS).');
     end if;


    select ses_oth.osuser into ls_conflict_osuser
      from
        v$session ses_sid,
        v$session ses_oth,
        owf_mgr.owf_logon_trig_usr_groups usrgrp_sid,
        owf_mgr.owf_logon_trig_usr_groups usrgrp_oth
     where ses_sid.sid = ln_sid
       and ses_sid.program = ls_program
       and ses_oth.program = ses_sid.program
       and ses_oth.username = user
       and ses_oth.status in ('ACTIVE', 'INACTIVE')
       and upper(ses_sid.osuser) = upper(usrgrp_sid.osuser_id)
       and upper(ses_oth.osuser) = upper(usrgrp_oth.osuser_id)
       and ses_sid.osuser <> ses_oth.osuser
       and upper(usrgrp_sid.wf_user_group) = upper(usrgrp_oth.wf_user_group)
       and rownum < 2;

    RAISE_APPLICATION_ERROR(-20001, 'Access Denied, user '||ls_conflict_osuser||' is using Oracle Workflow Builder.');

  end if;
EXCEPTION when no_data_found then
  null;
END;
/
ALTER TRIGGER "SYSTEM"."OWF_LOGON_TRIG" ENABLE;
--------------------------------------------------------
--  DDL for Trigger TR_DB_LOGON
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "SYSTEM"."TR_DB_LOGON"
/* ===================================================
/* Module:             TR_DB_LOGON
/* Purpose:            Logon trigger for user authorization
/* Created By:         Robert Mackovik
/* Created Date:       1.3.2009
/* Last Updated By:    RJasa
/* Last Updated Date:  08.09.2016
/*
/* Change History:
/* Date        Author          Change
/* 09.10.2009  Martin Matejka  Session number control disabled
/* 15.10.2009  Rudolf Kopriva  Added exception for server DBlinks (#Incident 782261)
/* 23.10.2009  Filip Oliva     Added exception for DBA users (#change 76719)
/* 23.07.2015  Jan Blazek      C925334 - remove substring started by @ from V_OS_USER
/* 08.09.2016  RJasa           C1129617 - added dependecy on db_user in db_logon_os_user_permanent
/*
/* Description: Access control trigger
/*
/* =================================================== */
after logon on database
declare
  V_DB_USER system.db_logon_access.DB_USER_NAME%type := 'N/A';
  V_OS_USER system.db_logon_access.OS_USER_NAME%type := 'N/A';
  V_HOST     varchar2(100);
  V_MODULE   varchar2(100);
  C_DELETED_FLAG_NO VARCHAR2(1) := 'N';
  V_LOGON_GRANTED PLS_INTEGER := 0;
  V_LOGON_ROLE PLS_INTEGER;
  V_DBA_ROLE PLS_INTEGER;
  V_MAX_USER_SESSIONS PLS_INTEGER := null;
  V_COUNT_USER_SESSIONS PLS_INTEGER := null;
  V_LOGON_USER_ROLE PLS_INTEGER;
begin
  -- Get USERENV session settings
  select
    REGEXP_REPLACE(UPPER(SYS_CONTEXT('USERENV', 'OS_USER')), '(@.+)', '' ),
    UPPER(USER),
    UPPER(SYS_CONTEXT('USERENV', 'HOST')),
    UPPER(SYS_CONTEXT('USERENV', 'MODULE'))
  into
    V_OS_USER,
    V_DB_USER,
    V_HOST,
    V_MODULE
  from dual;

  -- Get logon role
  select count(1) into V_LOGON_ROLE
  from DBA_ROLE_PRIVS
  where GRANTED_ROLE in ('DB_LOGON_CONTROL','DB_LOGON_CONTROL_APPL')
  and GRANTEE = V_DB_USER;

  -- Get DBA role
  select count(1) into V_DBA_ROLE
    from DBA_ROLE_PRIVS
  where GRANTED_ROLE ='DBA'
    and GRANTEE = V_DB_USER;

  -- Check if user has logon_role
  if V_LOGON_ROLE > 0 AND  V_DB_USER <> V_OS_USER then
    V_LOGON_GRANTED := 0;
  else
    V_LOGON_GRANTED := 1;
  end if;

  -- Check if user has DBA role
  if V_DBA_ROLE > 0 then --C 76719 begin
    V_LOGON_GRANTED := 1;
  end if; --C 76719 end

  -- Check NULL OS user
  if V_OS_USER is NULL then
    V_LOGON_GRANTED := 1;
  end if;

  -- Check permanent OS users
  if V_LOGON_GRANTED = 0 then
    begin
      select 1
        into V_LOGON_GRANTED
        from system.db_logon_os_user_permanent
       where upper(OS_USER_NAME) = upper(V_OS_USER)
         and (DB_USER_NAME = 'XNA' or upper(DB_USER_NAME) = upper(V_DB_USER))
         and OS_USER_DELETED_FLAG = C_DELETED_FLAG_NO;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
    end;
  end if;

  -- Check host and module variables (for using DB Links)
  if V_LOGON_GRANTED = 0 then -- I782261 begin
     if (V_HOST like 'DWH%') and (V_MODULE like 'ORACLE@%') then
         V_LOGON_GRANTED := 1;
     end if;
  end if; --I782261 end

  -- Check db_logon_access permissions
  if V_LOGON_GRANTED = 0 then
    begin
      select 1
      into V_LOGON_GRANTED
      from system.db_logon_access
      where DB_USER_NAME = V_DB_USER and
            OS_USER_NAME = V_OS_USER and
            DB_LOGON_DATE = TRUNC(sysdate);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN RAISE_APPLICATION_ERROR(-20999, 'Not authorized to logon with OS_USER = ' || V_OS_USER || ' and DB_USER = ' || V_DB_USER || ' - rejected by TR_DB_LOGON.');
    end;
  end if;

end;
/
ALTER TRIGGER "SYSTEM"."TR_DB_LOGON" ENABLE;
--------------------------------------------------------
--  DDL for Trigger TR_DB_LOGON_ACCESS
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "SYSTEM"."TR_DB_LOGON_ACCESS"
before insert on system.db_logon_access
for each row
begin
  select UPPER(:NEW.DB_USER_NAME),
         UPPER(:NEW.OS_USER_NAME),
         TRUNC(:NEW.DB_LOGON_DATE),
         user
  into :NEW.DB_USER_NAME,
       :NEW.OS_USER_NAME,
       :NEW.DB_LOGON_DATE,
       :NEW.INSERTED_BY
  from dual;

  if :NEW.DB_LOGON_DATE < TRUNC(sysdate) then
    RAISE_APPLICATION_ERROR(NUM => -20000, MSG => 'DB_LOGON_DATE Cannot be in the past.');
  end if;
end;
/
ALTER TRIGGER "SYSTEM"."TR_DB_LOGON_ACCESS" ENABLE;
--------------------------------------------------------
--  DDL for Trigger TR_DB_LOGON_AUDIT_CONFIG
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "SYSTEM"."TR_DB_LOGON_AUDIT_CONFIG"
BEFORE INSERT OR UPDATE ON SYSTEM.DB_LOGON_AUDIT_CONFIG FOR EACH ROW
begin

  select
     upper(:new.username),
     decode(upper(nvl(:new.noaudit_permanent, 'N')), 'Y', 'Y', 'N'),
     decode(upper(nvl(:new.noaudit_appl_user, 'N')), 'Y', 'Y', 'N'),
     nvl(:new.updated_by, user),
     sysdate
   into
     :new.username,
     :new.noaudit_permanent,
     :new.noaudit_appl_user,
     :new.updated_by,
     :new.updated_datetime
   from dual;

  if inserting then
    :new.inserted_by := nvl(:new.inserted_by, user);
    :new.inserted_datetime := sysdate;
  end if;

end;
/
ALTER TRIGGER "SYSTEM"."TR_DB_LOGON_AUDIT_CONFIG" ENABLE;
--------------------------------------------------------
--  DDL for Trigger TR_DB_LOGON_OS_USER_PERMANENT
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "SYSTEM"."TR_DB_LOGON_OS_USER_PERMANENT"
before insert or update on system.db_logon_os_user_permanent
for each row
begin
  select UPPER(:NEW.OS_USER_NAME),
         UPPER(:NEW.OS_USER_DELETED_FLAG)
  into :NEW.OS_USER_NAME,
       :NEW.OS_USER_DELETED_FLAG
  from dual;
end;
/
ALTER TRIGGER "SYSTEM"."TR_DB_LOGON_OS_USER_PERMANENT" ENABLE;
--------------------------------------------------------
--  DDL for Trigger TR_DB_TRACED_USERS
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "SYSTEM"."TR_DB_TRACED_USERS"
BEFORE INSERT ON DB_TRACED_USERS FOR EACH ROW
declare
  l_tmp number;
begin

  select 1 into l_tmp
    from ALL_USERS
  where upper(username) = upper(:new.db_user_name);

  select
     upper(:new.db_user_name),
     user,
     decode(upper(nvl(:new.waits, 'Y')), 'Y', 'Y', 'N'),
     decode(upper(nvl(:new.binds, 'N')), 'Y', 'Y', 'N')
   into
     :new.db_user_name,
     :new.inserted_by,
     :new.waits,
     :new.binds
   from dual;

exception
   when no_data_found then
     raise_application_error(-20001, 'User '||upper(:new.db_user_name)||' doesn''t exist');
end;
/
ALTER TRIGGER "SYSTEM"."TR_DB_TRACED_USERS" ENABLE;
--------------------------------------------------------
--  DDL for Trigger TR_LOGON_AUDIT
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "SYSTEM"."TR_LOGON_AUDIT"
/* ===================================================
/* Module:             TR_LOGON_AUDIT
/* Purpose:            Logon trigger for auditing
/* Created By:         Filip Cech
/* Created Date:       24.05.2012
/* Last Updated By:    Filip Cech
/* Last Updated Date:  24.05.2012
/*
/* Change History:
/* Date        Author          Change
/* 24.05.2012  Filip Cech      C279137 - New version
/*
/* Description: Access control trigger
/*
/* =================================================== */
after logon on database
begin

  audit_ctx_pkg.audit_session;

end;
/
ALTER TRIGGER "SYSTEM"."TR_LOGON_AUDIT" ENABLE;
--------------------------------------------------------
--  DDL for Trigger TR_LOGON_TRACE
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "SYSTEM"."TR_LOGON_TRACE"
AFTER LOGON ON DATABASE
declare
  l_user varchar2(32);
  l_waits char(1);
  l_binds char(1);

  b_waits boolean := false;
  b_binds boolean := false;

begin

 select upper(db_user_name), waits, binds
   into l_user, l_waits, l_binds
   from DB_TRACED_USERS
  where upper(db_user_name) = upper(USER)
    and rownum < 2;

 if l_waits = 'Y' then b_waits := true; end if;
 if l_binds = 'Y' then b_binds := true; end if;

 dbms_session.session_trace_enable(b_waits, b_binds);

 -- special behaviour for user TUXCRM
 if upper(USER) = 'TUXCRM' then
   execute immediate 'begin etl_owner.tx_sync.g_tuxcrm_trace := ''Y''; end;';
 end if;

exception
when no_data_found then
  -- do not trace
  null;
when others then
  null;
end;
/
ALTER TRIGGER "SYSTEM"."TR_LOGON_TRACE" ENABLE;
--------------------------------------------------------
--  DDL for Procedure GRANT_LOGON_ACCESS_1DAY
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "SYSTEM"."GRANT_LOGON_ACCESS_1DAY" (P_DB_USER_NAME IN VARCHAR2, P_OS_USER_NAME IN VARCHAR2, P_DB_LOGON_DATE IN DATE, P_DB_LOGON_REASON IN VARCHAR2) as
begin
  insert into system.db_logon_access(DB_USER_NAME, OS_USER_NAME, DB_LOGON_DATE, DB_LOGON_REASON)
  values(P_DB_USER_NAME, P_OS_USER_NAME, P_DB_LOGON_DATE, P_DB_LOGON_REASON);

  commit;

exception
   when others then
     rollback;
     raise_application_error(-20401, DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);

end;

/

  GRANT EXECUTE ON "SYSTEM"."GRANT_LOGON_ACCESS_1DAY" TO "DWH_CS_ADMIN";
--------------------------------------------------------
--  DDL for Procedure SET_USER_TRACE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "SYSTEM"."SET_USER_TRACE" (
  p_db_user_name in varchar2,
  p_trace boolean,
  p_waits boolean default true,
  p_binds boolean default false
  )
as
 l_waits char(1) := 'N';
 l_binds char(1) := 'N';
begin

  if p_trace then

    if p_waits then l_waits := 'Y'; end if;
    if p_binds then l_binds := 'Y'; end if;

    begin

      insert into DB_TRACED_USERS (db_user_name, waits, binds)
        values
          (upper(p_db_user_name), l_waits, l_binds);

    exception
      when dup_val_on_index then

      update DB_TRACED_USERS
         set waits = l_waits,
             binds = l_binds
       where db_user_name = upper(p_db_user_name);

    end;

  else

    delete from DB_TRACED_USERS
      where db_user_name = upper(p_db_user_name);

  end if;

  commit;

exception
   when others then
     rollback;
     raise_application_error(-20401, DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);

end;

/

  GRANT EXECUTE ON "SYSTEM"."SET_USER_TRACE" TO "DWH_CS_ADMIN";
--------------------------------------------------------
--  DDL for Package ADMIN_DB_USERS
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE PACKAGE "SYSTEM"."ADMIN_DB_USERS" authid
    definer IS
/* ===================================================
/* Module:                   ADMIN_DB_USERS
/* Purpose:                  Change users
/* Created By:               Vladimir Horak
/* Created Date:             11.12.2002
/* Last Updated By:          jjalovec
/* Last Updated Date:        07.02.2017
/* Version:                  2.8
/*
/* Change History:
/* Date           Author            Change
/* 11.12.2002     V.Horak           New package
/* 10.11.2004     J.Rozsival        Change Password procedure corrections
/* 02.04.2009     Robert Mackovik   C42593: Added audit to ADMIN_DB_USERS_LOG table
/* 09.06.2009     Radek Hula        I5d[PROD] C8130 Added grant on DB_LOGON_CONTROL to CEN and EXT users
/* 10.08.2011     Filip Cech        C279137 - commented SET_DWH_DATABASE_AUDIT, SET_ODS_DATABASE_AUDIT
/* 29.03.2016     Jan Blazek        C1033987 - added procedure SET_RESOURCE_CONSUMER_GROUP; added resource group ANALYST_USER_GRP_2 to newly created users in Create_CEN_user, Create_EXT_user and Create_ADMIN_User
/* 28.07.2016     Jan Blazek        C1109505 - removed SET_DWH_DATABASE_AUDIT, SET_ODS_DATABASE_AUDIT, SET_USER_AUDIT
/* 20.12.2016     Jan Blazek        16ZDM75881 - renamed ALL _ODSDWH_ROLES to ALL_DWH_ROLES
/* 25.01.2017     Jan Blazek        C1200246 - added locks while creating user (because only one instance of SET_RESOURCE_CONSUMER_GROUP can be run in the whole DB in the same time)
/* 07.02.2017     jjalovec          A85526 - changes beacause of new REDIM_AREAS table
/* 24.10.2017     Pavel Tomasek    C1379532 - add default roles CSCONNECT a DB_LOGON_CONTROL
/*
/* Description: Administrations of database users
/*
/* =================================================== */

--role for controling user behaviour (limited sessions and logging)
C_ROLE_LOG_CON constant varchar2(30) := 'DB_LOGON_CONTROL';
l_lock boolean := false;
C_LOCK_NAME constant varchar2(30) := 'ADMIN_DB_USERS_LOCK';
C_LOCK_TIMEOUT     constant integer:= 10;          -- Lock timeout (seconds)
C_LOCK_LOOP_CNT    constant integer:= 20;         -- Maximum count of loops
C_LOCK_LOOP_WAIT   constant integer:= 10;         -- Waiting time (sec) for 1 loop



   PROCEDURE CREATE_CEN_USER ( user_name in varchar2, user_pswd varchar2 );
   PROCEDURE CREATE_AUDIT_USER ( user_name in varchar2, user_pswd varchar2 );
   PROCEDURE CREATE_EXT_USER ( user_name in varchar2, user_pswd varchar2 );
   PROCEDURE CREATE_ADMIN_USER ( user_name in varchar2, user_pswd varchar2 );
--   PROCEDURE DROP_DB_USER ( user_name in varchar2 );
   PROCEDURE CHANGE_USER_PASSWORD (user_name in varchar2, user_password in varchar2);
   PROCEDURE LOCK_DB_USER ( user_name in varchar2 );
   PROCEDURE UNLOCK_DB_USER ( user_name in varchar2 );
   PROCEDURE GRANT_ROLE_TO_USER ( user_name in varchar2, role_name varchar2 );
   PROCEDURE REVOKE_ROLE_FROM_USER ( user_name in varchar2, role_name varchar2 );
--   PROCEDURE DELETE_AUDIT_RECORDS ( days number );
END ADMIN_DB_USERS;

/

  GRANT EXECUTE ON "SYSTEM"."ADMIN_DB_USERS" TO "REDIM_OWNER";
  GRANT EXECUTE ON "SYSTEM"."ADMIN_DB_USERS" TO "USER_ADMINISTRATOR";
--------------------------------------------------------
--  DDL for Package AUDIT_CTX_PKG
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE PACKAGE "SYSTEM"."AUDIT_CTX_PKG"
is

/* ===================================================
/* Module:             AUDIT_CTX_PKG
/* Purpose:            Package used to set user audit context on logon
/* Created By:         FCech
/* Created Date:       29.5.2012
/* Last Updated By:    MHmaouz
/* Last Updated Date:  30.9.2015
/* Version:            1.1
/*
/* Change History:
/* Date       Author      Change
/* 29.5.2012  FCech       C279137 - New module
/* 30.9.2015  MHamouz     15P DM-33892 - unified auditing 12c - changed audit control by context, changed host names
/*
/* =================================================== */

/* procedure set_detail_audit
- set detail audit for current session
*/
  procedure set_detail_audit;

/* procedure audit_session
- decide abount current session detail audit and set it
*/
  procedure audit_session;

end;

/
--------------------------------------------------------
--  DDL for Package Body ADMIN_DB_USERS
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE PACKAGE BODY "SYSTEM"."ADMIN_DB_USERS" AS

PROCEDURE SET_AUDIT_LOG(P_PROCEDURE_NAME IN VARCHAR2, P_PARAMETERS IN VARCHAR2, P_RESULT IN VARCHAR2, P_ERRM IN VARCHAR2) IS
BEGIN
  insert into system.admin_db_users_log(EXECUTION_DATE, EXECUTED_BY, PROCEDURE_NAME, PARAMETERS, RESULT, ERROR_MESSAGE)
  values(sysdate, user, P_PROCEDURE_NAME, P_PARAMETERS, P_RESULT, P_ERRM);

  commit;
END SET_AUDIT_LOG;

  procedure makeLock (user_name in varchar2) is
  begin
    if etl_owner.etl_lock_util.waitlock(C_LOCK_NAME, C_LOCK_LOOP_CNT, C_LOCK_LOOP_WAIT, C_LOCK_TIMEOUT) then
      l_lock := true;
    else
      raise_application_error(-20112, 'Cannot set lock while creating database user ' ||user_name|| chr(10)|| sqlerrm);
    end if;

  exception
   when others then
     if l_lock then
       etl_owner.etl_lock_util.releaselock(C_LOCK_NAME);
     end if;
     raise_application_error(-20113,'Error while creating lock for database user ' ||user_name|| chr(10)|| sqlerrm);
  end;

   FUNCTION CREATE_DATABASE_USER( user_name in varchar2, user_pswd varchar2 ) Return Number
   /*** pouze create user ***/
   is
   v_sql varchar2(500);
   v_parameters varchar2(256):= 'USER_NAME = ' || user_name;
   begin

     v_sql := 'create user '||user_name||' PROFILE CS_DEFAULT ' ||
              ' IDENTIFIED BY "'||user_pswd || '" PASSWORD EXPIRE ' ||
              ' DEFAULT TABLESPACE "USERS" '||
              ' ACCOUNT UNLOCK ';
     execute immediate v_sql;

     return 0;

      exception
       when others then
         begin
           raise_application_error(-20111,'Cannot create database user '||user_name||
                                    chr(10)||sqlerrm);
           return -1;
         end;

   end Create_database_user;

  PROCEDURE SET_RESOURCE_CONSUMER_GROUP(user_name in varchar2, resource_group in varchar2)
  is
  begin
    sys.dbms_resource_manager.clear_pending_area();
    sys.dbms_resource_manager.create_pending_area();
    sys.dbms_resource_manager_privs.grant_switch_consumer_group(user_name, resource_group, false);
    sys.dbms_resource_manager.set_consumer_group_mapping(dbms_resource_manager.oracle_user, user_name, resource_group);
    sys.dbms_resource_manager.submit_pending_area();

    exception
     when others then
        begin
         raise_application_error(-20111,'Cannot set resource consumer group for user '||user_name||
                                  chr(10)||sqlerrm);
        end;

  end SET_RESOURCE_CONSUMER_GROUP;

   PROCEDURE Create_CEN_user ( user_name in varchar2, user_pswd varchar2 )
   is
   r number;
   v_sql varchar2 (500);
   v_parameters varchar2(256):= 'USER_NAME = ' || user_name;
   V_ROLE_LOG_CON PLS_INTEGER := 0;
   begin

     makeLock(user_name);

     v_sql :='d';

     r:=create_database_user(user_name,user_pswd );

     SET_AUDIT_LOG('CREATE_CEN_USER', v_parameters, 'OK', NULL);

     --C8130
     select count(1) into V_ROLE_LOG_CON from dba_roles where role = C_ROLE_LOG_CON;
     if V_ROLE_LOG_CON > 0 then
        execute immediate 'GRANT '||C_ROLE_LOG_CON||' TO '|| user_name;
     end if;

     -- C1379532
     v_sql:='GRANT CSCONNECT TO '|| user_name ;
     execute immediate v_sql;

     v_sql:='GRANT DB_LOGON_CONTROL TO '|| user_name ;
     execute immediate v_sql;

     set_resource_consumer_group(user_name, 'ANALYST_USER_GRP_2');

     if l_lock then
       etl_owner.etl_lock_util.releaselock(C_LOCK_NAME);
     end if;

     exception
       when others then
         if l_lock then
           etl_owner.etl_lock_util.releaselock(C_LOCK_NAME);
         end if;
         begin
           SET_AUDIT_LOG('CREATE_CEN_USER', v_parameters, 'ERROR', sqlerrm|| DBMS_UTILITY.format_error_backtrace);

           raise_application_error(-20111,'Cannot create CEN user '||
                                    chr(10)||v_sql||chr(10)||sqlerrm  || DBMS_UTILITY.format_error_backtrace);
          end;
   end Create_CEN_user;


   PROCEDURE Create_AUDIT_user ( user_name in varchar2, user_pswd varchar2 )
   is
   r number;
   v_sql varchar2 (500);
   v_parameters varchar2(256):= 'USER_NAME = ' || user_name;
   begin

     r:=create_database_user(user_name,user_pswd );

     v_sql:='grant AUDIT_USER to '||user_name;
     execute immediate v_sql;

     v_sql:='grant DISCO_BA_AUDIT to '||user_name;
     execute immediate v_sql;

     SET_AUDIT_LOG('CREATE_AUDIT_USER', v_parameters, 'OK', NULL);

     exception
       when others then
          begin
           SET_AUDIT_LOG('CREATE_AUDIT_USER', v_parameters, 'ERROR', sqlerrm);

           raise_application_error(-20111,'Cannot create AUDIT user '||
                                    chr(10)||v_sql||chr(10)||sqlerrm);
          end;
   end Create_AUDIT_user;


   PROCEDURE Create_EXT_user ( user_name in varchar2, user_pswd varchar2 )
   is
   r number;
   v_sql varchar2 (500);
   v_parameters varchar2(256):= 'USER_NAME = ' || user_name;
   V_ROLE_LOG_CON PLS_INTEGER := 0;
   begin

     makeLock(user_name);

     r:=create_database_user(user_name,user_pswd );

     SET_AUDIT_LOG('CREATE_EXT_USER', v_parameters, 'OK', NULL);

     --C8130
     select count(1) into V_ROLE_LOG_CON from dba_roles where role = C_ROLE_LOG_CON;
     if V_ROLE_LOG_CON > 0 then
        execute immediate 'GRANT '||C_ROLE_LOG_CON||' TO '|| user_name;
     end if;

     -- C1379532
     v_sql:='GRANT CSCONNECT TO '|| user_name ;
     execute immediate v_sql;

     v_sql:='GRANT DB_LOGON_CONTROL TO '|| user_name ;
     execute immediate v_sql;


     set_resource_consumer_group(user_name, 'ANALYST_USER_GRP_2');

     if l_lock then
       etl_owner.etl_lock_util.releaselock(C_LOCK_NAME);
     end if;

     exception
       when others then
         if l_lock then
           etl_owner.etl_lock_util.releaselock(C_LOCK_NAME);
         end if;
         begin
           SET_AUDIT_LOG('CREATE_EXT_USER', v_parameters, 'ERROR', sqlerrm);

           raise_application_error(-20111,'Cannot create EXT user '||
                                    chr(10)||v_sql||chr(10)||sqlerrm);
          end;
   end Create_EXT_user;


   PROCEDURE Create_ADMIN_User ( user_name in varchar2, user_pswd varchar2 )
   is
   r number;
   v_sql varchar2 (500);
   v_parameters varchar2(256):= 'USER_NAME = ' || user_name;
   begin

     makeLock(user_name);

     r:=create_database_user(user_name,user_pswd );

      v_sql:='grant USER_ADMINISTRATOR to '||user_name;
     execute immediate v_sql;


     SET_AUDIT_LOG('CREATE_ADMIN_USER', v_parameters, 'OK', NULL);

     set_resource_consumer_group(user_name, 'ANALYST_USER_GRP_2');

     if l_lock then
       etl_owner.etl_lock_util.releaselock(C_LOCK_NAME);
     end if;

     exception
       when others then
         if l_lock then
           etl_owner.etl_lock_util.releaselock(C_LOCK_NAME);
         end if;
         begin
           SET_AUDIT_LOG('CREATE_ADMIN_USER', v_parameters, 'ERROR', sqlerrm);

           raise_application_error(-20111,'Cannot create ADMIN user '||
                                    chr(10)||v_sql||chr(10)||sqlerrm);
          end;
   end Create_ADMIN_User;

   PROCEDURE GRANT_ROLE_TO_USER ( user_name in varchar2, role_name varchar2 )
   is
   r number;
   v_sql varchar2 (500);
   v_parameters varchar2(256):= 'USER_NAME = ' || user_name || ', ROLE_NAME = ' || role_name;
   E_NOROLE exception;
   begin

   select count(1)
   into r
   from dba_role_privs
--   where grantee = 'ALL_DWH_ROLES' and
   where grantee in (select area_super_role from redim_owner.redim_areas where area_super_role <> 'XNA') and
              granted_role = upper(role_name);


   if r=1 then
      v_sql:='grant '||role_name ||' to '||user_name;
     execute immediate v_sql;
   else
     raise E_NOROLE;
   end if;

   SET_AUDIT_LOG('GRANT_ROLE_TO_USER', v_parameters, 'OK', NULL);

   exception
       when E_NOROLE then
          begin
           SET_AUDIT_LOG('GRANT_ROLE_TO_USER', v_parameters, 'ERROR', 'Role ' || role_name || ' cannot be granted (wrong REDIM area)');
           raise_application_error(-20111, 'Cannot grant role '|| role_name);
          end;
       when others then
          begin
           SET_AUDIT_LOG('GRANT_ROLE_TO_USER', v_parameters, 'ERROR', sqlerrm);

           raise_application_error(-20111,'Cannot grant role '|| role_name ||
                                    chr(10)||sqlerrm);
          end;
   end GRANT_ROLE_TO_User;


   PROCEDURE REVOKE_ROLE_FROM_USER ( user_name in varchar2, role_name varchar2 )
   is
   r number;
   v_sql varchar2 (500);
   v_parameters varchar2(256):= 'USER_NAME = ' || user_name || ', ROLE_NAME = ' || role_name;
   E_NOROLE exception;
   begin

   select count(1)
   into r
   from dba_role_privs
--   where grantee = 'ALL_DWH_ROLES' and
   where grantee in (select area_super_role from redim_owner.redim_areas where area_super_role <> 'XNA') and
              granted_role = upper(role_name);


   if r=1 then
      v_sql:='revoke '||role_name ||' from '||user_name;
     execute immediate v_sql;
   else
     raise E_NOROLE;
   end if;

   SET_AUDIT_LOG('REVOKE_ROLE_FROM_USER', v_parameters, 'OK', NULL);

   exception
       when E_NOROLE then
          begin
           SET_AUDIT_LOG('REVOKE_ROLE_FROM_USER', v_parameters, 'ERROR', 'Role ' || role_name || ' cannot be revoked (wrong REDIM area)');
           raise_application_error(-20111, 'Cannot revoke role '|| role_name);
          end;
       when others then
          begin
           SET_AUDIT_LOG('REVOKE_ROLE_FROM_USER', v_parameters, 'ERROR', sqlerrm);

           raise_application_error(-20111,'Cannot revoke role '|| role_name ||
                                    chr(10)||sqlerrm);
          end;
   end REVOKE_ROLE_FROM_USER;

   PROCEDURE DROP_DB_USER ( user_name in varchar2 )
   is
   r number;
   v_sql varchar2 (500);
   v_parameters varchar2(256):= 'USER_NAME = ' || user_name;
   begin

     v_sql:='drop user '||user_name;-- ||' cascade';
     execute immediate v_sql;

     SET_AUDIT_LOG('DROP_DB_USER', v_parameters, 'OK', NULL);

   exception
       when others then
          begin
           SET_AUDIT_LOG('DROP_DB_USER', v_parameters, 'ERROR', sqlerrm);

           raise_application_error(-20111,'Cannot drop user '|| user_name ||
                                    chr(10)||sqlerrm);
          end;
   end DROP_DB_USER;


  PROCEDURE CHANGE_USER_PASSWORD (user_name in varchar2, user_password in varchar2)
   is
   v_sql varchar2 (500);
   v_user_check number;
   v_parameters varchar2(256):= 'USER_NAME = ' || user_name;
   begin

   if ((substr(upper(user_name),instr(upper(user_name),'_',1)+1,length(upper(user_name)))!='OWNER') and
           upper(user_name) != 'SYS' and upper(user_name)!='SYSTEM') then
         v_sql:='alter user '||user_name||' identified by "'||user_password||'"';
     execute immediate v_sql;
   else
     SET_AUDIT_LOG('CHANGE_USER_PASSWORD', v_parameters, 'ERROR', 'Cannot change user password on the technical account - purposeful error, hardcoded');

     raise_application_error(-20111,'Cannot change user password on the technical account: '|| user_name ||
                                    chr(10)||sqlerrm);
   end if;

   SET_AUDIT_LOG('CHANGE_USER_PASSWORD', v_parameters, 'OK', NULL);

   exception
       when others then
          begin
           SET_AUDIT_LOG('CHANGE_USER_PASSWORD', v_parameters, 'ERROR', sqlerrm);

           raise_application_error(-20111,'Cannot change user password on the user '|| user_name ||
                                    chr(10)||sqlerrm);
          end;

   end CHANGE_USER_PASSWORD;

  PROCEDURE LOCK_DB_USER ( user_name in varchar2 )
   is
   v_sql varchar2 (500);
   v_parameters varchar2(256):= 'USER_NAME = ' || user_name;
   begin

     v_sql:='alter user '||user_name||' account lock';
     execute immediate v_sql;

     SET_AUDIT_LOG('LOCK_DB_USER', v_parameters, 'OK', NULL);

   exception
       when others then
          begin
           SET_AUDIT_LOG('LOCK_DB_USER', v_parameters, 'ERROR', sqlerrm);

           raise_application_error(-20111,'Cannot lock user '|| user_name ||
                                    chr(10)||sqlerrm);
          end;

   end LOCK_DB_USER;

  PROCEDURE UNLOCK_DB_USER ( user_name in varchar2 )
   is
   r number;
   v_sql varchar2 (500);
   v_parameters varchar2(256):= 'USER_NAME = ' || user_name;
   begin

     v_sql:='alter user '||user_name||' account unlock';
     execute immediate v_sql;

     SET_AUDIT_LOG('UNLOCK_DB_USER', v_parameters, 'OK', NULL);

   exception
       when others then
          begin
           SET_AUDIT_LOG('UNLOCK_DB_USER', v_parameters, 'ERROR', sqlerrm);

           raise_application_error(-20111,'Cannot unlock user '|| user_name ||
                                    chr(10)||sqlerrm);
          end;
   end UNLOCK_DB_USER;

END ADMIN_DB_USERS;

/

  GRANT EXECUTE ON "SYSTEM"."ADMIN_DB_USERS" TO "REDIM_OWNER";
  GRANT EXECUTE ON "SYSTEM"."ADMIN_DB_USERS" TO "USER_ADMINISTRATOR";
--------------------------------------------------------
--  DDL for Package Body AUDIT_CTX_PKG
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE PACKAGE BODY "SYSTEM"."AUDIT_CTX_PKG" wrapped
a000000
1
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
b
1399 69b
j7DHBbsa5bXIbBDyO8fuOp/EfX8wgw3quiAF344ZAzf5W7yOwvvv4+tvpMk2BGKzYS9VZ8wt
TqIE9BOrx4rdUkUA0sb+yI5sCVFufvoJGp/bartovMfMQHPVeu8R8Tl4EYHPxK2bBYYk5Ahk
+CjtfLVQhIXBP+x8wpF6r381pYD/uBVQKuj5dutt+bBO+5KG00I9eSB+mmpfzEptypFJSJo7
0ArXpwwveGen6bCgJCJIeMQKhsmdx4f+iAAyc5+d2hwzuvn1en6f/lUcpWawltSPOt4QpdTn
rWfiUtuIYtyVCDAwh9qyL7+wV5euTPlhgyKNxJW7oFrPb+i9ZvSuIGU8cjD/Fp63/IumzBWe
oyQvscOL8xhXlZk2nXNtTk5Or1QkRF9to/5NdwBFztI6bSUAqIJQN4nzG2+FRLdXwSXs0n5K
Tq381ftGnm8IuNISwDnOOGWGVo2/ibMkqsXthF2UOupu+Dh9skCSJ7aJxq8fMug7K7Wc/+FW
DMGRMZwrPvPxNgFoXdCUvG6mc/pRXWdYlLLfoevjj9vLcWcEy4zxM2NGpYcUnRiMj/V9CyYV
yPeh4kbxoCWeLOagGOQX1dWjfO8h1L37I+cm+U1iqNLht715oUfrblhYXCZiZd2KwXi+n+27
vUpkvyR6Wsb+c+uz/XcEP46swEGz9WBS2IPUnUY0VUg8mO+qeoq7KApbvLoA2C6ycDoqa7X6
VM4zCxCPLhOTbmtWl0LneMlGFccy4dzOFBYW846lN/TFa2D7sszoI16GWH5XyWs+Z9cvk6hv
EsfxwchVgq8qeb5Vzwf/pxSyLw+geCDdHSSgJCCAtvNQ91ARRYXDAKc1Fu+CzY/cjofzXdeI
2awD6fJk53NOjAe40xG8xTfQr+HFLNy0bsP3zSmW8Bh+w5MDBB7mYtc5s54JEFRh/XLzfGxm
IgooLydci1Ayo1xjTqDFtZIvhezsUUpvfPVPmFytIy4QemPedMOPzHsMt0Xz3GqTYgN1tk2O
N9W2sPbMek0pGrotlIJaItLkU7t8OKYqHcxwFj5RWhsfWGC3bAiZYGkExhTnf8+CrvdNzs2S
M+NgfQU4tam5Qeq60v6/fVuFtu9jVUzpw1yAfFk5GazwC4Ka8WTNQZnWpWDHUMu53uF7oU3p
dIRRaAlxxJu/XH4tmoimwtKhG5UfZmyhlx1HfE/oRFrsbH3CZxX9Kbv1NAlILghAf0UQ5/Eh
9SbROKwF+/wp8QKLGQ1IspinUzgNK5PvoUqN5SBTzSNJ1Ze2zIgzQYyrPNUIjZbh271j1lWD
UX5PdL2CD9dcnlGO3CDYiW6DjBkLqEK1MjXL/m+JvZsYMVcE/YJpB299JcTGo6tdrzbUo/IF
TuIeym9b1vFzJbQM1grxGjN1z9Chmkx0nu1ZAy37EwsNeiqZmsXHlT6BrsyXg9eKmwnkLYup
o0RfDQqiKTOr7Sdz0yBGkKTgUBaec+Z39Weojd/KmOHPYcNMHGea263HCtU4Y4N4huzZwdWa
z9KZjcsNhOINyvmuQvFf64sKbHdfzgHB1TQDBx2pjGrtISgTtr6kDjNZISewhqzzUhf9sZhG
LgKcdmG/Uxn68w8gsZbO67lbYkRMy6slkB0MRTE2fFXeBbvPQyydDhV/hgqzHqunO8tJUNvB
IJ2mcZVTfQ==

/
