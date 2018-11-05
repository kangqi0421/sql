--
-- UNDO
-- enq: US - contention
--

-- How to correct performance issues with enq: US - contention related to undo segments (Doc ID 1332738.1)	
-- tohle otestovano na DWH, pomáhá
ALTER SYSTEM SET "_undo_autotune" = false;
ALTER SYSTEM SET "_rollback_segment_count"=<n>;
ALTER SYSTEM SET "_highthreshold_undoretention"=<n>;  

select x.ksppinm name,y.ksppstvl value 
  FROM x$ksppi  x,x$ksppcv y  WHERE x.indx = y.indx AND x.ksppinm like '_highthreshold_undoretention';


-- ONLINE/OFFLINE
select TABLESPACE_NAME, STATUS, count(*) 
  from dba_rollback_segs 
 where tablespace_name like 'UNDO%' 
 group by  TABLESPACE_NAME, STATUS;

-- EXPIRED/UNEXPIRED
select tablespace_name, status, count(*) 
  from dba_undo_extents 
group by tablespace_name, status;

---
-- TUNED_UNDORETENTION =  MAXQUERYLEN + 300 Sec.
--
-- calculated TUNED_UNDORETENTION with UNDO fixed size
select begin_time, tuned_undoretention, maxquerylen, maxqueryid 
  from v$undostat
 order by begin_time desc;
 
@ls UNDO%
 
