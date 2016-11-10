CREATE OR REPLACE VIEW sql
AS
SELECT /*+ INDEX(STATS$SQL_SUMMARY) */
                 e.snap_id, e.hash_value,
                 CASE
                    WHEN e.buffer_gets >= NVL (b.buffer_gets, 0)
                       THEN e.buffer_gets
                            - NVL (b.buffer_gets, 0)
                    ELSE e.buffer_gets
                 END buffer_gets,
                 CASE
                    WHEN e.disk_reads >= NVL (b.disk_reads, 0)
                       THEN e.disk_reads - NVL (b.disk_reads, 0)
                    ELSE e.disk_reads
                 END disk_reads,
                 CASE
                    WHEN e.executions >= NVL (b.executions, 0)
                       THEN e.executions - NVL (b.executions, 0)
                    ELSE e.executions
                 END executions,
				 CASE
                    WHEN e.cpu_time >= NVL (b.cpu_time, 0)
                       THEN e.cpu_time - NVL (b.cpu_time, 0)
                    ELSE e.cpu_time
                 END cpu_time,
				 CASE
                    WHEN e.elapsed_time >= NVL (b.elapsed_time, 0)
                       THEN e.elapsed_time - NVL (b.elapsed_time, 0)
                    ELSE e.elapsed_time
                 END elapsed_time
            FROM stats$sql_summary b, stats$sql_summary e
           WHERE b.snap_id(+) = e.snap_id - 1
             AND b.dbid(+) = e.dbid
             AND b.instance_number(+) = e.instance_number
             AND b.address(+) = e.address
             AND b.hash_value(+) = e.hash_value
/

CREATE OR REPLACE VIEW sysstat_per_sec
(SNAP_ID, SNAP_TIME, NAME, VALUE, c_time)
AS 
select
se.snap_id,
st.snap_time,
se.name,
ev.value,
st.c_time
from
(select en.snap_id, en.name , en.statistic# from stats$sysstat en) se,
(select
e.snap_id,
e.statistic#,
case when e.value >= nvl(b.value,0)
then e.value - nvl(b.value,0)
else e.value 
end value
from stats$sysstat b, stats$sysstat e
where
b.snap_id (+) = e.snap_id - 1
and b.statistic# = e.statistic#
) ev,
(select
e.snap_id,
e.snap_time,
round(((e.snap_time - b.snap_time) * 1440 * 60), 0) c_time
from stats$snapshot b, stats$snapshot e
where
b.snap_id (+) = e.snap_id - 1
) st
where
ev.statistic# = se.statistic#
and ev.snap_id = se.snap_id
and ev.snap_id = st.snap_id
/

CREATE OR REPLACE FORCE VIEW events
(SNAP_ID, SNAP_TIME, DBID, INSTANCE_NUMBER, EVENT, 
 WAITS, TIMEOUTS, TIME, TOTAL_WAITS, TOTAL_TIME)
AS 
select
se.snap_id,
se.snap_time,
se.dbid,
se.instance_number,
se.event,
nvl(ev.waits,0) waits,
nvl(ev.timeouts,0) timeouts,
nvl(ev.time,0) time,
nvl(ev.total_waits,0) total_waits,
nvl(ev.total_time,0) total_time
from
(select en.event, sn.snap_id, sn.snap_time , sn.dbid , sn.instance_number
from
(select distinct event from stats$system_event) en,
stats$snapshot sn) se,
(select
e.snap_id,
e.event,
e.dbid,
e.instance_number,
case when e.total_waits >= nvl(b.total_waits,0)
then e.total_waits - nvl(b.total_waits,0)
else e.total_waits end waits,
e.total_waits total_waits,
case when e.total_timeouts >= nvl(b.total_timeouts,0)
then e.total_timeouts - nvl(b.total_timeouts,0)
else e.total_timeouts end timeouts,
e.total_timeouts total_timeouts,
case when e.time_waited_micro >= nvl(b.time_waited_micro,0)
then e.time_waited_micro - nvl(b.time_waited_micro,0)
else e.time_waited_micro end time,
e.time_waited_micro total_time
from stats$system_event b, stats$system_event e
where
b.snap_id (+) = e.snap_id - 1
and b.event (+) = e.event
and b.dbid (+) = e.dbid
and b.instance_number (+) = e.instance_number
) ev
where
se.snap_id > 1
and ev.event (+) = se.event
and ev.snap_id (+) = se.snap_id
and ev.dbid (+) = se.dbid
and ev.instance_number = se.instance_number;
/

CREATE OR REPLACE FORCE VIEW SYSSTAT
(SNAP_ID, SNAP_TIME, DBID, INSTANCE_NUMBER, NAME, 
 VALUE)
AS 
select
se.snap_id,
se.snap_time,
se.dbid,
se.instance_number,
se.name,
nvl(ev.value,0) value
from
(select en.name , en.statistic#, sn.snap_id, sn.snap_time , sn.dbid ,
sn.instance_number
from
(select distinct name,statistic# from stats$sysstat) en,
stats$snapshot sn) se,
(select
e.snap_id,
e.statistic#,
e.dbid,
e.instance_number,
case when e.value >= nvl(b.value,0)
then e.value - nvl(b.value,0)
else e.value end value
from stats$sysstat b, stats$sysstat e
where
b.snap_id (+) = e.snap_id - 1
and b.statistic# (+) = e.statistic#
and b.dbid (+) = e.dbid
and b.instance_number (+) = e.instance_number
) ev
where
se.snap_id > 1
and ev.statistic# (+) = se.statistic#
and ev.snap_id (+) = se.snap_id
and ev.dbid (+) = se.dbid
and ev.instance_number = se.instance_number;
/

CREATE OR REPLACE FORCE VIEW TOP_5_EVENTS
(SNAP_ID, EVENT, TOTAL_WAITS, TOTAL_TIMEOUTS, TIME_WAITED_MICRO, 
 C_TOTAL_WAITS, C_TOTAL_TIMEOUTS, C_TIME_WAITED_MICRO)
AS 
select
SNAP_ID,EVENT,TOTAL_WAITS,TOTAL_TIMEOUTS,TIME_WAITED_MICRO,C_TOTAL_WAITS,C_TOTAL_TIMEOUTS,C_TIME_WAITED_MICRO
from
(
select
 SNAP_ID,EVENT,TOTAL_WAITS,TOTAL_TIMEOUTS,TIME_WAITED_MICRO,C_TOTAL_WAITS,C_TOTAL_TIMEOUTS,C_TIME_WAITED_MICRO,
 ROW_NUMBER() OVER( PARTITION BY SNAP_ID ORDER BY C_TIME_WAITED_MICRO  desc) as RN
from
(
select
 SNAP_ID,
 EVENT,
 TOTAL_WAITS,
 TOTAL_TIMEOUTS,
 TIME_WAITED_MICRO,
 TOTAL_WAITS-nvl(LAG(TOTAL_WAITS,1) OVER ( PARTITION BY EVENT ORDER BY
SNAP_ID ),TOTAL_WAITS) as C_TOTAL_WAITS,
 TOTAL_TIMEOUTS-nvl(LAG(TOTAL_TIMEOUTS,1) OVER ( PARTITION BY EVENT
ORDER BY SNAP_ID ),TOTAL_TIMEOUTS)  as C_TOTAL_TIMEOUTS,
 TIME_WAITED_MICRO-nvl(LAG(TIME_WAITED_MICRO,1) OVER ( PARTITION BY EVENT ORDER BY
SNAP_ID ),TIME_WAITED_MICRO) as C_TIME_WAITED_MICRO
from STATS$SYSTEM_EVENT
where EVENT not in ( select EVENT from STATS$IDLE_EVENT )
)
)
where RN<6 and C_TIME_WAITED_MICRO > 0;
/

