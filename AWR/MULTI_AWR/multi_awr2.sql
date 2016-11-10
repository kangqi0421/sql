set head off feed off trimout on trimspool on pagesize 0 echo off pages 0 term off ver off
spool run.sql

def format="html"
def begin="timestamp'2013-10-10 07:00:00'"
def   end="timestamp'2013-10-10 18:00:00'"

SELECT    'define  report_type=&format'
       || CHR (10)
       || 'define num_days=0'
       || CHR (10)
       || 'define inst_num='
       || instance_number
       || CHR (10)
       || 'define dbid='
       || dbid
       || CHR (10)
       || 'def begin_snap='
       || snap_id
       || CHR (10)
       || 'def end_snap='
       || next_snap
       || CHR (10)
       || 'def report_name='
       || SYS_CONTEXT ('USERENV', 'DB_NAME')
       || '_'
       || instance_number
       || '_'
       || TO_CHAR (from_time, 'YYMMDD_HH24MI')
       || '_'
       || TO_CHAR (to_time, 'YYMMDD_HH24MI')
       || '.&&format'
       || CHR (10)
       || '@?/rdbms/admin/awrrpti.sql'
       || ';'
  FROM (  SELECT snap_id,
                 dbid,
                 instance_number,
                 END_INTERVAL_TIME from_time,
                 LAG (snap_id) OVER (ORDER BY snap_id DESC) next_snap,
                 LAG (END_INTERVAL_TIME) OVER (ORDER BY snap_id DESC) to_time
            FROM DBA_HIST_SNAPSHOT
           WHERE 1 = 1
                 AND end_interval_time between &begin and &end
				 AND dbid=(select dbid from v$database where name=SYS_CONTEXT ('USERENV', 'DB_NAME'))
--               AND TO_CHAR (end_interval_time, 'mi') = 0      -- pouze kazdou celou hodinu
		 AND instance_number = sys_context('USERENV', 'INSTANCE')		-- pouze pro jednu DB instanci	
        ORDER BY snap_id)
 WHERE next_snap > 0     		                        -- mimo posledni neuplny LAG OVER
/  

spool off  