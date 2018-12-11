--
-- ARM locked used
-- kdo zamknul účet v jaké db :1 pro jaké schema :2
--
-- vyzkoušet, ještě netestovano

define db = '&1'
define user = '&2'

set lines 180
col OS_USERNAME for a20
col USERHOST for a20


select /*+FULL(a) */
    ARM_TIMESTAMP, OS_USERNAME, USERHOST, RETURN_CODE
  from ARM12.ARM_UNIAUD12 a
 where ARM_FULLID in (
      select ARM_FULLID from ARM_ADMIN.ARM_DATABASES
          where arm_db_name like upper('&db') and TRANSFER_ENABLED = 'Y')
  AND ARM_timestamp > SYSTIMESTAMP - INTERVAL '1' DAY
--     and ARM_TIMESTAMP between TIMESTAMP'2017-08-22 17:00:00'
  --                         and TIMESTAMP'2017-08-22 18:10:00'
      and ARM_ACTION_NAME='LOGON'
      and dbusername like upper('&user')
--      and dbusername in ('CPT','CPT_APP','CPTPK','CPTPK_APP','JOB_APP')
      and return_code > 0
      and return_code in (1017)
ORDER by event_timestamp DESC
FETCH FIRST 10 ROWS ONLY
;
