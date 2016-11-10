-- active sessions on CPU
SELECT cast(sample_time as date), count(*)
  FROM GV$ACTIVE_SESSION_HISTORY A
  WHERE
    a.inst_id = &inst_id
    and SAMPLE_TIME between TIMESTAMP'2014-11-27 09:00:00' and TIMESTAMP'2014-11-27 12:00:00'
    AND a.session_state     = 'ON CPU'
    group by sample_time
    order by 1;



/* DB time poèty per username, bez BACKGOUND session type */
select time, username, count(*) "DB Time"
from
(SELECT 
    trunc(sample_time, 'hh24') time,
    b.username
--    case 
--      when b.username like 'SYS' then 'BACKGROUND'
--      when b.username in ('COS_OWNER','CPR_OWNER','RET_OWNER','COGNOS_OWNER','OUT_OWNER','INT_OWNER','BSC_OWNER','PAL')
--        then 'PROVOZ'
--      else 'USERS'
--    end username    
    FROM dba_hist_active_sess_history a inner join dba_users b on (a.user_id = b.user_id)
  WHERE 
  1=1            
  and a.session_type = 'FOREGROUND'      
                         and sample_time > systimestamp - interval '4' hour
)
having count(*) > 100 -- více než 100 samples za hodinu
group by time, username
order by 1;
