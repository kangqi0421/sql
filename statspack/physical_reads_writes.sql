select to_char(a.snap_time, 'dd.mm.yyyy hh24:mi'),
	   round(a.a_value,1) "reads",
	   round(b.b_value, 1) "writes"
from
(
select snap_time,
	   (value/c_time) a_value
from SYSSTAT_PER_SEC
where name like 'physical reads'
	  and trunc(snap_time) = trunc(sysdate - 1)
) a,
(
select snap_time,
	   (value/c_time) b_value
from SYSSTAT_PER_SEC
where name like 'physical writes'
	  and trunc(snap_time) = trunc(sysdate - 1)
) b
where a.snap_time = b.snap_time
and trunc(a.snap_time) = trunc(sysdate - 1)
 