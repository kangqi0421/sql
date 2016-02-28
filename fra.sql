--
-- FRA settings
--

set numwidth 20
set lin 250

col name for a15

show parameter db_recovery_file_dest

/*
SELECT name fra_dg, round(total_mb/1024) total_GB,
       round(USABLE_FILE_MB/1024) Usable_Free_File_GB
   FROM v$asm_diskgroup
  WHERE name in (select ltrim(value,'+') from v$parameter where name = 'db_recovery_file_dest');
*/

SELECT   
    a.name, 
	round(total_mb/1024) ASM_total_GB,
	round(total_mb*0.95) ASM_5pct_MB,
    ROUND(space_limit/power(1024,2)) FRA_limit,
    round(USABLE_FILE_MB/1024) ASM_Free_GB,
    ROUND(space_used       /power(1024,3)) FRA_used,
    ROUND(SPACE_RECLAIMABLE/power(1024,3)) FRA_reclaim,
    ROUND(space_used       /space_limit*100) pct_used
  FROM V$RECOVERY_FILE_DEST r INNER JOIN v$asm_diskgroup a
            ON ltrim(r.name,'+') = a.name;
 
SELECT * FROM V$RECOVERY_AREA_USAGE;

-- poslední archivní redo ve FRA - ve dnech
-- aktuální sysdate - maximum redo first time, co je ve FRA
select round(sysdate - max(first_time), 1) "max days FRA"
  from v$archived_log where deleted = 'YES';


--// jak daleko do shistorie muzi jit pøi flashbacku --//
-- prompt oldest flashback time 
-- select (sysdate - oldest_flashback_time)*24*60 "min" from v$flashback_database_log;

--// nejstarsi flashback log //--
-- prompt nejstarsi flashback log
-- select min(first_time), (sysdate-min(first_time))*24*60 from v$flashback_database_logfile;
