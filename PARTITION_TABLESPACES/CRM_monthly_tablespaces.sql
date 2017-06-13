CREATE OR REPLACE PROCEDURE SYS.CRM_ADD_MONTHLY_TABLESPACE(
      i_month_range integer DEFAULT 6,
      i_drop_month  integer default -15,
      i_debug       BOOLEAN DEFAULT FALSE)
IS
  ------------
  --
  --  Version: 1.1
  --
  --  The procedure add MONTHLY tablespaces for CRM databases
  --
  --   - i_month_range - range of months to add tablespaces
  --   - i_drop_month - months do DROP tablespaces
  --   - i_debug - TRUE = only send output to terminal
  --
  --  Jiri Srba jsrba@csas.cz
  --
  ------------
  DEBUG                   BOOLEAN := i_debug;
  TYPE t_tablespace_prefix_tab IS TABLE OF VARCHAR2 (20);
  v_tablespace_prefix t_tablespace_prefix_tab := t_tablespace_prefix_tab('SIEBSA_DATA_');
  v_tablespace_max_size   varchar2(10) := '1T';      -- max size pro bigfile
  v_sql                   varchar2(4000);
--
BEGIN
  -- pro vsechny prefixovane TABLESPACES
  FOR i IN v_tablespace_prefix.FIRST .. v_tablespace_prefix.LAST LOOP
    FOR REC in (
      -- vyber N i_month_range mesicu zpet, 1 mesic DOPREDU
      SELECT v_tablespace_prefix(i)||
        to_char(ADD_MONTHS (sysdate, LEVEL - i_month_range - 1), 'YYYYMM') tablespace_name
      FROM DUAL CONNECT BY LEVEL <= i_month_range + 2
      -- mimo jiz vytvorene tablespaces
      MINUS
      SELECT tablespace_name FROM dba_tablespaces
      )
    LOOP
      v_sql := 'CREATE BIGFILE tablespace '||rec.tablespace_name||
        ' datafile size 512M autoextend on next 512M maxsize '||
        v_tablespace_max_size||
        ' EXTENT MANAGEMENT LOCAL UNIFORM SIZE 2M';
      -- execute SQL
      IF (DEBUG = TRUE) THEN
        dbms_output.put_line (v_sql);
      ELSE
        execute immediate v_sql;
      END IF;
      --
      -- SIEBSA quota unlimited
      v_sql := 'ALTER USER SIEBSA QUOTA UNLIMITED ON '||rec.tablespace_name;
      IF (DEBUG = TRUE) THEN
        dbms_output.put_line (v_sql);
      ELSE
        execute immediate v_sql;
      END IF;
    END LOOP;
  END LOOP;
  -- DROP prazdnych tablespaces
  FOR rec IN (
        SELECT t.tablespace_name, sum(blocks) blocks
          FROM dba_tablespaces t
           LEFT JOIN dba_segments s ON t.tablespace_name = s.tablespace_name
        WHERE t.tablespace_name LIKE 'SIEBSA_DATA_%'
          AND t.tablespace_name <= 'SIEBSA_DATA_'
                     || to_char(ADD_MONTHS(CURRENT_DATE, i_drop_month), 'YYYYMM')
        GROUP BY t.tablespace_name)
  LOOP
    -- pouze prazdne tablespaces
    IF rec.blocks IS NULL THEN
      v_sql := 'DROP TABLESPACE ' || rec.tablespace_name;
      -- execute SQL
      IF (DEBUG = TRUE) THEN
        dbms_output.put_line (v_sql);
      ELSE
        execute immediate v_sql;
      END IF;
    END IF;
  END LOOP;
  --
END;
/

-- Unit Test
set serveroutput on
--exec CRM_ADD_MONTHLY_TABLESPACE(6, -15, TRUE);
exec CRM_ADD_MONTHLY_TABLESPACE();

-- submit scheduler jobu
ALTER SESSION Set TIME_ZONE = 'EUROPE/PRAGUE';
alter session set NLS_TERRITORY = 'CZECH REPUBLIC';
-- scheduler job CRM_ADD_MONTHLY_TBS
-- freq=daily during MAINTENANCE_WINDOW_GROUP
begin
  dbms_scheduler.create_job(
     job_name => 'SYS.CRM_ADD_MONTHLY_TBS',
     job_type => 'PLSQL_BLOCK',
     job_action => 'BEGIN SYS.CRM_ADD_MONTHLY_TABLESPACE(6); END;',
     -- start_date => sysdate,
     -- repeat_interval => 'FREQ=DAILY;byhour=2',
     schedule_name => 'SYS.MAINTENANCE_WINDOW_GROUP',
     auto_drop => FALSE,
     enabled => TRUE);
END;
/

col JOB_NAME for a20
select JOB_NAME, STATE from dba_scheduler_jobs
 where owner = 'SYS' and job_name like 'CRM_ADD_MONTHLY_TBS';

--
-- End Installation
--



SELECT cast(to_timestamp_tz(log_date) at local as date) log_date_local,
    owner,
    JOB_NAME,
    status,
    error#
  FROM DBA_SCHEDULER_JOB_RUN_DETAILS
  WHERE job_name LIKE 'CRM_ADD_MONTHLY_TBS'
--    AND status <> 'SUCCEEDED'
  ORDER BY log_date DESC;

-- list mesicnich tablespaces
select tablespace_name from dba_tablespaces
 where TABLESPACE_NAME like 'SIEBSA_DATA_%'
order by 1;

-- mesicni tablespaces vcetne poctu bloků
SELECT t.tablespace_name, sum(blocks) blocks
  FROM dba_tablespaces t
   LEFT JOIN dba_segments s ON t.tablespace_name = s.tablespace_name
WHERE t.tablespace_name LIKE 'SIEBSA_DATA_%'
--  AND t.tablespace_name <= 'SIEBSA_DATA_'
--             || to_char(ADD_MONTHS(CURRENT_DATE, -7), 'YYYYMM')
GROUP BY t.tablespace_name
;


-- 6 mìsícù zpìt, 1 navíc
SELECT 'SIEBSA_DATA_'|| to_char(ADD_MONTHS (sysdate, LEVEL - 7), 'YYYYMM') tablespace_name
  FROM DUAL CONNECT BY LEVEL <=8 --(N+1)
MINUS
SELECT tablespace_name FROM dba_tablespaces
;

select * from dba_scheduler_windows;
