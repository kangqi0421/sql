-- dba_segments
set lines 32767

spool seg.txt
col owner for a30
select owner,
    round(sum(bytes)/power(1024,3)) as GB
  from dba_segments
 where owner not in ('SYS', 'SYSTEM')
group by owner
order by 2;

spool off
exit
