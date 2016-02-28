select * from DBA_WORKLOAD_CONNECTION_MAP
order by replay_id

select * from V$WORKLOAD_REPLAY_THREAD

select * from DBA_WORKLOAD_REPLAYS 
--where id = 38
order by id desc

select * from DBA_WORKLOAD_CAPTURES
--where id = 42
order by id desc

select * from dba_workload_replay_divergence
where replay_id=49

