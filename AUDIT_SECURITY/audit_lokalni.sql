--// neuspesne prihlaseni za posledni 2 dny //--
select to_char(LOCK_DATE,'YYYY.MM.DD HH24:MI:SS') from dba_users where username='&user';

-- ARM_TIMESTAMP a NTIMESTAMP# jsou v UTC
-- LOCK_DATE je v local time

col userid for a20
col userhost for a15
col terminal for a15
col "OS username" for a15
col IP for a15

-- poèty pøihlášení za minutu, pøevedené na sec
select trunc(timestamp, 'MI'), round(count(*)/60)
from (
;
-- AUD$ lokalni
--

SELECT
  * 
--  userid, count(*)
/*
  CAST ( (FROM_TZ (ntimestamp#, '00:00') AT LOCAL) AS DATE) as timestamp,
  userid,
  spare1 "OS username",
  USERHOST,
  TERMINAL,
  SUBSTR(SUBSTR(COMMENT$TEXT,INSTR(COMMENT$TEXT,'HOST=')+5,100),1,INSTR(SUBSTR(COMMENT$TEXT,INSTR(COMMENT$TEXT,'HOST=')+5,100),')')-1) "IP",
  ACTION#, 
  RETURNCODE
  */
FROM
  -- primo AUD$
  SYS.AUD$
  -- mezisklad ARM
  -- ARM_CLIENT.ARM_AUD$11TMP
WHERE 1=1
  AND USERID         in ('REDIM_USER','REDIM_OWNER')
  -- za posledni hodinu
  --and CAST ( (FROM_TZ (ntimestamp#, '00:00') AT LOCAL) AS DATE) > sysdate - 1/24
--  AND RETURNCODE   > 0      -- pouze neuspesne prihlaseni
  --AND ACTION#      IN (100)
--  AND ACTION#      IN (100,101) -- ACTION = LOGON/LOGOFF  --AUDIT_ACTIONS
--AND CAST ( (FROM_TZ (ntimestamp#, '00:00') AT LOCAL) AS DATE) > sysdate - 1
ORDER BY NTIMESTAMP# -- DESC
;

--
) 
group by trunc(timestamp, 'MI')
order by 1
;


select * from AUDIT_ACTIONS;

select 
   *
   --dbusername, count(*)
  from UNIFIED_AUDIT_TRAIL
 where 1=1
--    AND event_timestamp between timestamp'2015-07-08 22:00:00'
--                            and timestamp'2015-07-08 22:05:00'
  AND event_timestamp > SYSTIMESTAMP - INTERVAL '1' HOUR
-- AND UNIFIED_AUDIT_POLICIES is null 
  and ACTION_NAME='LOGON'
--    and upper(sql_text_varchar2) like '%ALTER USER%IDENTIFIED BY%'
    and upper(dbusername)='C4ADMIN'
   and return_code > 0   
-- group by dbusername
--ORDER by event_timestamp
--FETCH FIRST 5 ROWS ONLY
--FETCH FIRST 5 PERCENT ROWS ONLY
;