# PQ systat

## v$sysstat
SELECT * FROM v$sysstat
where name like 'Parallel%'
ORDER BY name;

## parallel statement queueing
CTLP: parallel_max_servers = parallel_servers_target = 400

select name, value, default_value from v$parameter
  where name in ('parallel_max_servers','parallel_servers_target')
;

alter system set parallel_max_servers = 400;
alter system set parallel_servers_target = 400;


select * from v$pq_sysstat;

select * from   v$session
  where event like 'resmgr:pq queued';


select px.sid, px.serial#,px.qcsid,px.qcserial#,px.qcinst_id,px.degree,px.req_degree,
 s.username, s.sql_id, s.sql_child_number, s.event, s.state
 from v$px_session px, v$session s
 where s.sid = px.sid
   and s.serial# = px.serial#
 order by px.qcsid;

-- statement queue
SQL> alter system set "_parallel_statement_queuing"=FALSE

