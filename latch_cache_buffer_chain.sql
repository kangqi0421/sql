https://sites.google.com/site/embtdbo/wait-event-documentation/oracle-latch-cache-buffers-chains

select
    count(*),
    p1RAW
from v$session_wait
where event='latch: cache buffers chains'
group by p1raw
order by count(*);   

select o.name, bh.dbarfil, bh.dbablk, bh.tch
from x$bh bh, obj$ o
where tch > 5
  and hladdr='&ADDR'
  and o.obj#=bh.obj
order by tch;

-- right now query
select 
        name, file#, dbablk, obj, tch, hladdr 
from x$bh bh
    , obj$ o
 where 
       o.obj#(+)=bh.obj and
      hladdr in 
(
    select P1RAW
    from v$session_wait
    where event like 'latch: cache buffers chains'
    group by p1RAW 
    having count(*) > 5
)
   and tch > 5
order by tch   ;