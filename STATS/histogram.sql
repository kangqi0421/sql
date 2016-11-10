--/* ovìøení, nad kterými sloupci se histogram spoèítal */--

SELECT table_name,
       column_name,
       num_distinct,
       density,
       num_buckets,
       histogram
  FROM dba_tab_columns
 WHERE table_name = '&table_name';
 
--/* zjištìní nastavení default hodnot instance */--

col spare4 for a40
select sname, sval1, spare4 from sys.optstat_hist_control$;