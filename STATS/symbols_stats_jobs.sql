ALTER SESSION Set TIME_ZONE = 'EUROPE/PRAGUE'; 
alter session set NLS_TERRITORY = 'CZECH REPUBLIC'; 


begin
  dbms_scheduler.drop_job('SYS.ANALYZE_PART_TABLES');
  dbms_scheduler.drop_job('SYS.ANALYZE_SYMBOLS');
end;
/

--// Analyze Symbols partitioned tables 3-times daily //--

begin
dbms_scheduler.create_job(
   job_name => 'ANALYZE_PART_TABLES',
   job_type => 'PLSQL_BLOCK',
   job_action => 'DECLARE
   v_high_value     VARCHAR (100);
   v_current_part   VARCHAR (10);
   v_last_part      VARCHAR (10);

   CURSOR c1
   IS
      SELECT table_owner, table_name, partition_name, high_value
        FROM SYS.all_tab_partitions
       WHERE table_name IN (''DP_TRAN_HIST'', ''RB_TRAN_HIST'', ''GL_MTH_HIST'')
	AND table_owner in (''SYMBOLS'', ''KMDW'');
--
BEGIN
   -- ziskej aktualni mesicni partition +1
   v_current_part := TO_CHAR (ADD_MONTHS (SYSDATE, 1), ''YYYY-MM'');
   v_last_part    := TO_CHAR (ADD_MONTHS (SYSDATE, 0), ''YYYY-MM'');
   -- projdi vsechny partition
   FOR c IN c1
   LOOP
      v_high_value := SUBSTR (c.high_value, 11, 7);
      -- vyber pouze tu s poslednim a aktualnim mesicem
      IF (v_high_value = v_current_part OR (v_high_value = v_last_part AND c.table_name = ''GL_MTH_HIST''))
      THEN
         -- proved prepocet aktualni partition
         SYS.DBMS_STATS.gather_table_stats (ownname               => c.table_owner,
                                            tabname               => c.table_name,
                                            partname              => c.partition_name,
                                            method_opt            => ''FOR ALL COLUMNS SIZE 1'',
                                            granularity           => ''PARTITION'',
                                            estimate_percent      => 10,
                                            CASCADE               => TRUE
                                           );
      END IF;
   END LOOP;
END;
', 
   start_date => sysdate,
   repeat_interval => 'freq=daily;byhour=6,9,15;byminute=00;bysecond=0',
   auto_drop => FALSE,
   enabled => TRUE);
END;
/

-- touhle už nepoužívat ... GATHER_AUTO totiž ignoruje globální nastavení a poèítá histogramy
--// Analyze Symbols schema daily //--

begin
dbms_scheduler.create_job(
   job_name => 'ANALYZE_SYMBOLS',
   job_type => 'PLSQL_BLOCK',
   job_action => 'BEGIN
   -- prepocet dictionary a fixnich tabulek --
   DBMS_STATS.gather_dictionary_stats;

   -- prepocet vlastnika schematu SYMBOLS (SYMBOLS|KMDW) a SYMADM schematu
   FOR c IN (SELECT name AS own
               FROM sys.user$ u
              WHERE u.name IN (''SYMBOLS'', ''SYMADM'', ''KMDW''))
   LOOP
      SYS.DBMS_STATS.GATHER_SCHEMA_STATS (
         OwnName            => c.own,
         Granularity        => ''ALL'',
         Options            => ''GATHER AUTO'',
         Gather_Temp        => TRUE,
         Estimate_Percent   => DBMS_STATS.AUTO_SAMPLE_SIZE,
         Method_opt         => ''FOR ALL COLUMNS SIZE 1'',
         Cascade            => TRUE,
         no_invalidate      => FALSE);
   END LOOP;
END;',
   schedule_name => 'MAINTENANCE_WINDOW_GROUP',
   auto_drop => FALSE,
   enabled => TRUE);
END;
/

