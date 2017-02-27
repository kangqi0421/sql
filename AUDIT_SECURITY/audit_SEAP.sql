define db=INEP

--// neuspesne prihlaseni za posledni 2 dny //--
select to_char(LOCK_DATE,'YYYY.MM.DD HH24:MI:SS') from dba_users where username='&user';

-- DB
select ARM_DB_NAME, ARM_FULLID from ARM_ADMIN.ARM_DATABASES where ARM_DB_NAME like '&db%';

-- 12c Unified auditing

-- kdo zamknul účet
-- kdo co komu grantoval pres REDIM
select --/*+ parallel full  (a) */
--    a.*
--      object_schema, object_name, SQL_TEXT_VARCHAR2
    ARM_TIMESTAMP, OS_USERNAME, USERHOST, RETURN_CODE
    -- ARM_ACTION_NAME,DBUSERNAME, OS_USERNAME, USERHOST,
    -- RETURN_CODE,object_name,SQL_TEXT_VARCHAR2
  from ARM12.ARM_UNIAUD12 a
 where ARM_FULLID=(select ARM_FULLID from ARM_ADMIN.ARM_DATABASES where arm_db_name='&db')
  AND ARM_timestamp > SYSTIMESTAMP - INTERVAL '4' HOUR
  and ARM_ACTION_NAME='LOGON'
--    and upper(sql_text_varchar2) like '%ALTER USER%IDENTIFIED BY%'
    and upper(dbusername)='INTRAS'
    and return_code > 0
    and return_code  in (1017)
--  and a.ARM_ACTION_NAME in ('GRANT', 'REVOKE')
--        and a.client_program_name = 'CSAS.REDIM.WorkflowServiceHost.exe'
--        and a.role = 'CSCONNECT' -- nazev grantovane role
--        and a.target_user = 'EXT95838'
--  and object_name = 'DBMS_RLS'
--  and upper(sql_text_varchar2) like '%DBMS_RLS%'
--  Starbank
--    and dbusername = 'INFO'
--    and os_username = 'cen86206@CEN.CSIN.CZ'
order by event_timestamp DESC
--FETCH FIRST 5 PERCENT ROWS ONLY
;


-- group by HOUR
select
    trunc(event_timestamp, 'HH24'), count(*)
  from ARM12.ARM_UNIAUD12
 where ARM_FULLID = (select ARM_FULLID from ARM_ADMIN.ARM_DATABASES where ARM_DB_NAME='&db')
  AND event_timestamp > SYSTIMESTAMP - INTERVAL '7' DAY
 group by trunc(event_timestamp,'HH24')
order by   trunc(event_timestamp,'HH24')
;

-- object schema, name
select
--    *
  object_schema, object_name, return_code, count(*) cnt
--   substr(sql_text, 1, 32767)
--    sql_text, count(*)
--    action_name, return_code, count(*)
--    dbusername, count(*)
--    return_code, count(*)
-- event_timestamp, Dbusername, Client_Program_Name, Action_Name, sql_text,
-- Unified_Audit_Policies, return_code
  from ARM12.ARM_UNIAUD12
 where ARM_FULLID = (select ARM_FULLID from ARM_ADMIN.ARM_DATABASES where ARM_DB_NAME='&db')
  AND event_timestamp > SYSTIMESTAMP - INTERVAL '1' DAY
  AND return_code > 0
 AND UNIFIED_AUDIT_POLICIES is NOT null
 AND object_schema not in ('SYS', 'SYSTEM')
-- and action_name='LOGOFF BY CLEANUP'
--   and dbusername='LDAPUSER'
--group by dbusername ORDER by 2 desc
--group by return_code ORDER by 2 desc
--group by action_name, return_code order by 3 desc
--group by substr(sql_text, 1, 32767)
group by object_schema, object_name, return_code
   order by 4 desc
--FETCH FIRST 5 ROWS ONLY
--order by event_timestamp desc
--FETCH FIRST 5 PERCENT ROWS ONLY
;

-- standardní AUDIT

-- audit action#
-- http://www.morganslibrary.org/reference/auditing.html
select * from AUDIT_ACTIONS
  where name like '%GRANT%';

-- ARM_TIMESTAMP a NTIMESTAMP# jsou v UTC
-- LOCK_DATE je v local time
col userhost for a15
col terminal for a15

-- SEAP ARM_AUD$11
select /*+ parallel full  (a) */
        userid,
--        arm_action_name,
--        /*
--        a.*,
        -- pocty prihlaseni group by
--        trunc(CAST ( (FROM_TZ (ntimestamp#, '00:00') AT LOCAL) AS DATE), 'HH24') "date", count(*) "logons"
        CAST ( (FROM_TZ (ntimestamp#, '00:00') AT LOCAL) AS DATE) "timestamp",
--        userid, ratio_to_report(count(*)) over() *100
    		spare1 "OS username",
        USERHOST,
        TERMINAL,
        SUBSTR(SUBSTR(COMMENT$TEXT,INSTR(COMMENT$TEXT,'HOST=')+5,100),1,INSTR(SUBSTR(COMMENT$TEXT,INSTR(COMMENT$TEXT,'HOST=')+5,100),')')-1) "IP",
		    IPADDRESS,
        ACTION#,
        RETURNCODE
--        entryid   -- prihlaseni primo = 1, db link = 18
  from ARM11.ARM_AUD$11 a
 where ARM_FULLID = (select ARM_FULLID from ARM_ADMIN.ARM_DATABASES where ARM_DB_NAME='&db')
--    and spare1 = 'felix'
	and userid = 'CIMBIZZ'
--    and AUTH$GRANTEE = 'CEN29290'
--    and returncode > 0
    and returncode = 1017
--  and a.arm_audid = 35841237886
--  and a.sessionid = 221963673
  and ARM_TIMESTAMP > sysdate - 3
--  	and ARM_TIMESTAMP between date'2013-10-25' and DATE'2013-10-26'
--  and ARM_TIMESTAMP > date'2014-12-10'
--        and ACTION# in (100)      -- ACTION = LOGON only
      and ACTION# in (100,101)	-- ACTION = LOGON/LOGOFF  --AUDIT_ACTIONS
--      and ACTION# in (17)       -- ACTION = GRANT
--      and ACTION# in (108)   -- ACTION = REVOKE skrz SYSTEM GRANT
--      and obj$name = 'UCET_JADRO'
-- dohledani ALTER USER
--	and ARM_TIMESTAMP between
--            SYS_EXTRACT_UTC(TIMESTAMP '2012-03-08 13:01:00') and SYS_EXTRACT_UTC(TIMESTAMP '2012-03-08 13:01:02')
--	and arm_action_name='GRANT'
--group by userid, arm_action_name order by userid, arm_action_name
--group by userid
--group by trunc(CAST ( (FROM_TZ (ntimestamp#, '00:00') AT LOCAL) AS DATE)) order by 1
--group by trunc(CAST ( (FROM_TZ (ntimestamp#, '00:00') AT LOCAL) AS DATE), 'HH24') order by 1
order by ntimestamp#
;



-- drop directory za posledni 3 dny --
  SELECT /*+ full(t) */
        CAST (
            (FROM_TZ (CAST (NTIMESTAMP# AS TIMESTAMP), 'GMT') AT LOCAL) AS DATE)
            "Local_Time",
         ARM_DB_NAME,
         ARM_ACTION_NAME,
         USERID,
         USERHOST,
         TERMINAL,
         OBJ$NAME
    FROM arm11.arm_aud$11 t
   WHERE     ARM_FULLID = (SELECT ARM_FULLID
                             FROM ARM_ADMIN.ARM_DATABASES
                            WHERE ARM_DB_NAME = 'ODSP')
         -- cas dle LOCK TIME
         AND ARM_TIMESTAMP > sysdate - 3
         AND ARM_ACTION_NAME = 'CREATE DIRECTORY'  -- action name DROP pøevedeno na CREATE, DROP neexistuje
         AND obj$name = 'TXMSG_LOGS'
ORDER BY arm_timestamp;