--
-- kontrola Streams
--

set head off feed off pages 0 lines 80 verify off
set colsep '	'
col name for a20
col state for a40

def color_ok  = chr(27)||'[1;36m'||'OK'||chr(27)||'[0;39m'
def color_err = chr(27)||'[0;31m'||'ERR'||chr(27)||'[0;39m'

-- capture
prompt
prompt CAPTURE and PROPAGATION site
prompt ============================
prompt
SELECT 'V_STREAMS_CAPTURE:' name, case when state = 'WAITING FOR TRANSACTION' then &color_ok else &color_err||state end state
  FROM V$STREAMS_CAPTURE where CAPTURE_NAME = 'CAPTURE01';
select 'DBA_CAPTURE:' name, case when STATUS = 'ENABLED' then &color_ok else &color_err ||': '||ERROR_MESSAGE||CAPTURED_SCN||APPLIED_SCN end state
  from DBA_CAPTURE where CAPTURE_NAME = 'CAPTURE01';
select 'DBA_PROPAGATION:' name, case when STATUS = 'ENABLED' then &color_ok else &color_err ||': '||error_message end state
  FROM DBA_PROPAGATION where PROPAGATION_NAME = 'CAPTURE01';

-- apply
prompt
prompt APPLY side
prompt ==========
prompt
SELECT 'DBA_APPLY:' name, case when STATUS = 'ENABLED' then &color_ok else &color_err||': '||error_message end state
  FROM DBA_APPLY where APPLY_NAME = 'APPLY01';
select 'DBA_APPLY_ERR:' name, decode(count(*),0,&color_ok,&color_err ||':'||count(*)) state 
  from DBA_APPLY_ERROR;
select 'HeartBeat:' name, case when extract(minute from (current_timestamp - datum)) < 1 then &color_ok else &color_err ||': '||to_char(cast( datum as date), 'dd.mm.yyyy hh24:mi:ss') end state 
  from mw.heartbeat;

set head on feed on
