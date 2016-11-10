--
-- ASH active session per user id
--
select trunc(sample_time, 'hh24') "sample_time",
       username, 
       --round(sum(time)) time, 
       count(*) cnt
from
(
SELECT   sample_time, 
         CASE 
            WHEN username IN ('INET10EXT','INET10INT','INTRAS') 
            THEN username
           ELSE 'OTHERS'
         END username ,
         --decode (username, ,'INET10EXT','INET10INT',,'INTRAS',,'OTHERS') username,
         CASE session_state  
          WHEN 'ON CPU' THEN wait_time / 1000000
          WHEN 'WAITING' THEN time_waited / 1000000
         END time 
--    FROM GV$ACTIVE_SESSION_HISTORY A
      FROM dba_hist_active_sess_history a
    INNER JOIN dba_users u
        ON (a.user_id  = u.user_id)
  WHERE 1=1
    AND sample_time     > trunc(sysdate - 1) -- poslední den
    AND SESSION_STATE   = 'ON CPU'    -- pouze CPU
--    AND wait_class NOT            IN ('Application') -- mimo aplikaèní zámku
    AND SESSION_TYPE    = 'FOREGROUND' -- mimo background procesy
)
group by trunc(sample_time, 'hh24'), username
  ORDER BY 1, 2;
  
-- ASM per service name, AVG prumer za minutu
SELECT
  TRUNC(sample_time, 'mi') sample_time,
  AVG(cnt)
FROM
  (
    SELECT
      sample_time,
      COUNT(*) cnt
    FROM
      DBA_HIST_ACTIVE_SESS_HISTORY a
    WHERE
      sample_time > sysdate - 7
      AND A.SESSION_STATE   = 'ON CPU'
    AND A.SERVICE_HASH IN
      (
        SELECT
          name_hash
        FROM
          dba_services
        WHERE
          name LIKE 'INET%'
      )
    GROUP BY
      sample_time
  )
GROUP BY
  TRUNC(sample_time, 'mi')
ORDER BY
  sample_time;
  
select * from GV$ACTIVE_SESSION_HISTORY  