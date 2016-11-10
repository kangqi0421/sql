--
-- SSA
--

BEGIN
   dbms_auto_task_admin.enable ('auto space advisor', NULL, NULL);
END;
/


--//  the most recent run of the Auto Segment Advisor //--
-- mimo compress table
select tablespace_name, segment_name,
   -- segment_type, partition_name, 
   reclaimable_space/1048576/1024 "reclaimable space [GB]",
   --,recommendations, 
   c1 
  from
   table(dbms_space.asa_recommendations('FALSE', 'FALSE', 'FALSE'))
 where c1 not like '%compress%'
	and reclaimable_space/1048576/1024 > 1
 order by reclaimable_space desc;

ORA-6502: PL/SQL - UNSET NLS


--// vystup do HTML //--
column spoolname new_value spoolname noprint;
select name ||'_'||'_space_advisor' spoolname from v$database;


set termout off
set verify off
set echo off
set feedback off
set pages 999
set heading on
set markup HTML ON SPOOL ON ENTMAP ON PREFORMAT OFF

spool &spoolname..html

SELECT tablespace_name, segment_owner,segment_name,segment_type,
           round(allocated_space/1024/1024,1) "allocated space [MB]",
           round( used_space/1024/1024, 1 ) "used space [MB]",
           round( reclaimable_space/1024/1024) "reclaimable space [MB]",
           round(reclaimable_space/allocated_space*100,0) "pctsave [%]",
           recommendations, c1
FROM TABLE(dbms_space.asa_recommendations())
  where segment_owner not in ('SYS', 'SYSTEM')
order by 1,2,3
/

spool off
set markup html off