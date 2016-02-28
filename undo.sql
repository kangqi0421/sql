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
 
