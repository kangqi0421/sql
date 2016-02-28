--------------------------------------------------------------------------------
--
-- File name:   ash.sql
-- Purpose:     Show state within ASH for last N minutes
-- Usage:       @ash <minutes>
--------------------------------------------------------------------------------


SET TRIMSPOOL ON TRIMOUT ON VERIFY OFF

col event for a30
col wait_class for a20

DEF from_time="(sysdate - &1/60/24)"
DEF cols=session_state,event,wait_class

SELECT * FROM (
  SELECT
        &cols
      , count(*)
      , lpad(round(ratio_to_report(count(*)) over () * 100)||'%',10,' ') percent
    FROM
        v$active_session_history
        -- dba_hist_active_sess_history
    WHERE
        sample_time > &from_time
    GROUP BY
        &cols
    ORDER BY
        percent DESC
)
WHERE ROWNUM <= 5
/

DEF cols=session_state,event,sql_id
/

