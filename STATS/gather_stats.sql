--
-- How to gather statistics
--

https://schd.ws/hosted_files/utougtrainingdays2018/a2/Best_Practices_for_Manging_statistics.pdf

– Incremental Statistics
  • Ability to accurate generate global statistics from partition level statistics
  • Controlled by the parameter INCREMENTAL (default is FALSE)
BEGIN
  dbms_stats.Set_global_prefs('INCREMENTAL', 'TRUE');
END;
/

– Concurrent Statistics Gathering
  • Ability to gather statistics on multiple objects concurrently under a GATHER_SCHEMA_STATS
  command
  • Controlled by the parameter CONCURRENT (default is FALSE)

-- GTS pouze jedne partitions
exec dbms_stats.gather_table_stats('TELEB', 'SB_T_DEPOSITAQUERY_RESP', GRANULARITY => 'PARTITION', PARTNAME => 'P1M20170501');

-- unlock, gather, lock
BEGIN
  FOR rec IN (  SELECT b.owner, b.table_name
                  FROM all_tables b
                 WHERE b.table_name in ('STA_FM_INT_TYPE','STA_FM_INT_BASIS','STA_FM_INT_RATE')
                   AND b.owner = 'KMDW'
                  )
  LOOP
    --execute immediate 'begin dbms_stats.unlock_table_stats(ownname => '''||rec.owner ||''', tabname => '''||rec.table_name||'''); end;';
    EXECUTE IMMEDIATE   'BEGIN DBMS_STATS.gather_table_stats(ownname => '''
                     || rec.owner
                     || ''', tabname => '''
                     || rec.table_name
                     || ''', granularity => ''ALL'', no_invalidate => FALSE, cascade => TRUE, force=>TRUE); END;';
     --execute immediate 'begin dbms_stats.lock_table_stats(ownname => '''||rec.owner ||''', tabname => '''||rec.table_name||'''); end;';
  END LOOP;
END;
/

-- DBIMPORT
BEGIN
  FOR rec IN (  SELECT b.owner, b.object_name
                  FROM all_objects b
                 WHERE b.object_type = 'MATERIALIZED VIEW'
                   AND b.owner = 'DBIMPORT'
              ORDER BY b.owner, b.object_name)
  LOOP
    EXECUTE IMMEDIATE   'BEGIN DBMS_STATS.gather_table_stats(ownname => '''
                     || rec.owner
                     || ''', tabname => '''
                     || rec.object_name
                     || ''', no_invalidate => FALSE, estimate_percent => DBMS_STATS.auto_sample_size); END;';
  END LOOP;
END;
/


