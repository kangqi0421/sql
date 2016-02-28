-- nejvyssi pocet latches
select parameter, gets
  from v$rowcache
 order by gets desc;
 
-- to see whether latch miss source can give us some more hints regarding the issue
select "WHERE", sleep_count, location
   from v$latch_misses
  where parent_name='row cache objects'
        and sleep_count > 0;