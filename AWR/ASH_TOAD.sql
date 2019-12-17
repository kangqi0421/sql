/* ASH */

select
 *
 --  p2, count(*)
--  sql_id, event, a.blocking_session_status, a.blocking_session
-- * cnt
--sample_time, count(*)
--  SQL_ID, COUNT(*) cnt
-- parse time
-- count(*) as dbtime,   count(nullif(A.IN_PARSE,'N')) as parse_time,  count(nullif(A.IN_HARD_PARSE,'N')) as hard_parse_time
--  event, sum(time_waited)
--  XID, count(*)
--current_obj#, count(*)   cnt
--sample_time, sql_id, sql_opname, sql_exec_start, machine
--      min(sample_time), max(sample_time)
--  sample_time, inst_id, session_id, sql_id, session_state,event
--  sample_time,sql_id,sql_opname,sql_exec_start,event,session_state, max(sample_time) over(partition by sql_id, sql_exec_start) sql_exec_start as duration
--    session_state, event, count(*)
--      sample_time, sql_plan_line_id, count(*)
--    sql_id, round(ratio_to_report(count(*)) over()*100,2) "ratio %"
--    event, round(ratio_to_report(count(*)) over()*100,2) "ratio %"
--    to_char(p2,'0XXXXXXX') p2hex
--    instance_number, session_id, count(*)
--     blocking_session, count(*)
--      sample_time, sql_id, sql_plan_hash_value, count(*), round(sum(PGA_ALLOCATED)/1048576)
--   sample_time, sql_id, sql_plan_hash_value, sql_plan_line_id, sql_plan_operation, round(pga_allocated/1048576), round(temp_space_allocated/1048576)
--  sample_time, sum(pga_allocated)/1048576, sum(temp_space_allocated)/1048576
--    sample_time, sql_id, inst_id, round(pga_allocated/1048576), round(temp_space_allocated/1048576)
--    FROM GV$ACTIVE_SESSION_HISTORY a
    FROM dba_hist_active_sess_history a
  WHERE
  1=1
       AND SAMPLE_TIME BETWEEN TIMESTAMP'2019-10-06 14:52:00'
                           AND TIMESTAMP'2019-10-06 14:53:00'
--                         and sample_time > sysdate - interval '1' hour    -- poslednich NN minut
--                           and sample_id IN (276540, 275627)
--                        and xid = '1C000D00BB9B6000'
--                         and SQL_ID in ('djc26zm8gfs46')
--                         and event = 'row cache lock'
--                           and event like 'gc%'
--                         and event not in ('enq: MC - Securefile log')
--                           and session_state  = 'ON CPU'
--                       AND IN_HARD_PARSE = 'Y' AND in_parse = 'Y' -- sql id na hard parsingu
--                          and a.BLOCKING_SESSION_STATUS = 'VALID'
--                         and blocking_session in (3963)
--                         and wait_class = 'Concurrency'  -- 'User I/O'
--                         and SESSION_ID in (15403)  and SESSION_SERIAL# in (56556)
--                         and SESSION_TYPE = 'FOREGROUND'
--                         and module like 'SQL*Plus'
--                         and machine in ('rasft1','rasft2')
--                           and action like 'JOB_RUN%'
--                         and program like 'oracle@csbponl (LGWR)'
--                         and SQL_PLAN_OPERATION = 'HASH JOIN'
--                           and sql_opname = 'UPDATE'
--                         and sql_opcode in (7,1,6,9,2)
--                         and current_obj# =  9771790
--                         and session_state <> 'WAITING'
--                         and a.instance_number = 2
--                         and a.inst_id = 2
--                         and qc_instance_id in (1,2)
--                         and user_id = (select user_id from dba_users where USERNAME in ('CEN31049'))
--                           and in_parse = 'Y'
--                           and program like '%tux%'
--  XID having count(*) > 1
--group by   sql_id ORDER by count(*) DESC
--group by event order by 2 desc
--    sql_exec_id
--group by p2
--group by  event order by  count(*) DESC
--group by  current_obj# order by count(*) desc
  --trunc(sample_time, 'mi')
--  sql_id, session_state  order by count(*) desc
  --sql_id having count(*) > 100 order by count(*) desc
  --sample_time, sql_id, sql_plan_hash_value --having round(sum(PGA_ALLOCATED)/1048576) > 2048
  --sql_id, sql_plan_line_id, sql_plan_operation order by 5 desc
  --sample_time, sql_plan_line_id
--  event order by 2 desc
--  session_state, event order by count(*) desc
  --program
  --instance_number, session_id order by count(*) desc
--group by blocking_session
--ORDER by count(*) DESC
--ORDER by session_id
ORDER BY sample_time desc  --, inst_id
;

-- min snapshot time
select min(sample_time) from dba_hist_active_sess_history;
select systimestamp - min(sample_time) from GV$ACTIVE_SESSION_HISTORY;

-- dba_objects
select * from dba_objects where object_id in (9771790);

select * from gv$sqlstats where sql_id in ('90rd3rb489wp6','0mt9bj1u0uh4h','f3v75nfzwu1t0','2qbjb44zusrky');

select * from dba_sequences where sequence_name like 'SEQ_LOG%';

-- wait event, count
select event, count(*), sum(time_waited)
    FROM GV$ACTIVE_SESSION_HISTORY a
  WHERE 1 = 1
--    AND event = 'enq: IV -  contention'
    AND sql_id IN ('8s6a8wh7vtvnx','6nn5rv7n469cq','d4dj07j54ram2','24hw1hptpxmqg')
--        AND SAMPLE_TIME BETWEEN TIMESTAMP'2019-01-13 15:00:00'
--                           AND TIMESTAMP'2019-01-13 16:00:00'
                         and sample_time > sysdate - interval '4' hour -- poslednich NN minut
group by event order by 3 desc;

select * from V$SQL_PLAN
  where SQL_ID = 'byus5kg9cbs7d'
  and id in (30,34);

SELECT *
  from GV$SQL_SHARED_CURSOR where SQL_ID = 'cnb44fs1u7aka';


select * from dba_indexes
  where owner = 'L1_OWNER'
    and index_name = 'PT_PK';

select * from dba_users
 where username like 'CEN31049'
-- where user_id = 102
 ;

--
-- CPU/wait count sessions
SELECT
   cast(sample_time as date), session_state, count(*)
from
--  dba_hist_active_sess_history a
    GV$ACTIVE_SESSION_HISTORY A
  WHERE 1=1
    and SAMPLE_TIME between TIMESTAMP'2016-11-14 14:07:00' and TIMESTAMP'2016-11-14 14:14:00'
--  and SQL_ID in ('0s8j6ka2nu948')
--  and user_id = 107
   and session_state = 'ON CPU'
group by cast(sample_time as date), session_state
order by 1;

-- WAIT session state
SELECT
   state, sum(time), round(ratio_to_report(sum(time)) over()*100,2) "ratio %"
from
(
SELECT
    case session_state
      when 'WAITING' then event
      when 'ON CPU'  then session_state
    end state,
    case session_state
      when 'WAITING' then time_waited
      when 'ON CPU'  then wait_time
    end time
--    from dba_hist_active_sess_history a
    FROM gv$active_session_history a
  WHERE 1=1
    and SAMPLE_TIME between TIMESTAMP'2014-11-27 09:00:00' and TIMESTAMP'2014-11-27 12:00:00'
--  and SQL_ID in ('0s8j6ka2nu948')
   --and user_id = 107
)
group by cast(sample_time as date), state
order by 1;

-- active sessions on CPU only
SELECT cast(sample_time as date), count(*)
  FROM GV$ACTIVE_SESSION_HISTORY A
  WHERE
    a.inst_id = &inst_id
    and SAMPLE_TIME between TIMESTAMP'2014-12-01 09:00:00' and TIMESTAMP'2014-12-01 12:00:00'
    AND a.session_state     = 'ON CPU'
    group by sample_time
    order by 1;

-- CPU active sessions p�es ob� DB instance
WITH cpu AS
    (
      SELECT   inst_id,
          CAST(sample_time AS DATE) TIME,
          COUNT(*) cnt
        FROM GV$ACTIVE_SESSION_HISTORY A
        WHERE SAMPLE_TIME BETWEEN TIMESTAMP'2014-12-01 09:00:00'
                              AND TIMESTAMP '2014-12-01 12:00:00'
          AND a.session_state = 'ON CPU'
        GROUP BY inst_id, sample_time
    )
  SELECT   cpu1.time,
      cpu1.cnt "MCIP1",
      cpu2.cnt "MCIP2"
    FROM
      (SELECT   TIME, cnt FROM cpu WHERE inst_id = 1) cpu1
    LEFT OUTER JOIN
      (SELECT   TIME, cnt FROM cpu WHERE inst_id = 2) cpu2
    ON (cpu1.time = cpu2.time)
    order by 1;

-- v$sql_bind_capture
SELECT   sq.sql_fulltext, sq.sql_id, sq.address, sb.bind_name, sb.POSITION,
         sb.datatype, sb.max_length, sb.array_len, sc.value_string
    FROM v$sql sq, v$sql_bind_metadata sb, v$sql_bind_capture sc
   WHERE sq.sql_id = '9t5hryt4zu48s'
     AND ':' || sb.bind_name = sc.NAME
     AND sb.address = sq.child_address
     AND sc.child_address = sq.child_address
     AND ':' || sb.bind_name = sc.NAME
ORDER BY sb.POSITION, sb.max_length;

SELECT sample_time, username, event, session_id, blocking_session, a.time_waited, b.owner, object_name, a.sql_id, d.sql_text
    FROM v$active_session_history a, dba_objects b, dba_users c, v$sql d
   WHERE sample_time BETWEEN TO_DATE ('15.10.2007 13:45',
                                      'dd.mm.yyyy hh24:mi')
                         AND TO_DATE ('15.10.2007 14:02', 'dd.mm.yyyy hh24:mi')
   and a.current_obj# = b.object_id
   and a.user_id = c.user_id
   and a.sql_id = d.sql_id
   and wait_class not in  ('User I/O', 'System I/O', 'Commit', 'Administrative')
   --and event like 'enq: %'
ORDER BY sample_time desc




-- mutex sleep
select * from V$MUTEX_SLEEP_HISTORY
order by sleep_timestamp;
