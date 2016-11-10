== Stale statistics - volitelně ==

Volitelně po migraci/upgrade přepočítat STALE statistiky

Gather database nebo schema stats pro STALE CBO statistiky

<code>
exec dbms_stats.FLUSH_DATABASE_MONITORING_INFO();

set lines 120
column owner format a20
column table_name format a30
SELECT DT.OWNER, count(*)
FROM   DBA_TABLES DT, DBA_TAB_MODIFICATIONS DTM
WHERE      DT.OWNER = DTM.TABLE_OWNER
       AND DT.TABLE_NAME = DTM.TABLE_NAME
       AND NUM_ROWS > 0
       AND ROUND ( (DELETES + UPDATES + INSERTS) / NUM_ROWS * 100) >= 10 AND OWNER NOT IN ('SYS','SYSTEM','SYSMAN','DBSNMP')
group by DT.OWNER
order by 2 desc;
</code>

= schema stats =

příklad pro PDB schema
<code>
SCHEMA=PDB
</code>

<code>
sqlplus -s / as sysdba <<EOC
begin
dbms_scheduler.create_job(
  job_name => 'Gather_Stats_$SCHEMA',
  JOB_TYPE => 'PLSQL_BLOCK',
  job_action => 'BEGIN
                   DBMS_STATS.DELETE_SCHEMA_STATS(''$SCHEMA'', force => true);
       dbms_stats.gather_schema_stats(''$SCHEMA'', cascade => true, no_invalidate => false);
     END;',
  start_date => sysdate,
  repeat_interval => NULL,
  auto_drop => TRUE,
  enabled => true);
end;
/
exit
EOC
</code>

<code>
sqlplus -s / as sysdba <<ESQL
SET LINES 300 PAGES 0 LONG 1000000
COLUMN REPORT FORMAT A200
VARIABLE my_report CLOB;
BEGIN
:my_report := DBMS_STATS.REPORT_GATHER_SCHEMA_STATS(ownname => '$SCHEMA',
detail_level => 'TYPICAL', format => 'HTML');
END;
/
spool $SCHEMA_stats.html
print my_report
spool off
exit
ESQL
</code>