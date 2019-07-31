--
-- DBMS_STATS
--

--/* ovìøení, nad kterými sloupci se histogram spoèítal */--

SELECT table_name,
       column_name,
       num_distinct,
       density,
       num_buckets,
       histogram
  FROM dba_tab_columns
 WHERE 1 = 1
    AND owner = 'DOCBASE_EBOX'
--    AND table_name = '&table_name'
    AND histogram <> 'NONE';

--/* zjištìní nastavení default hodnot instance */--

col spare4 for a40
select sname, sval1, spare4 from sys.optstat_hist_control$;

-- Globální vypnutí přepočtu histogramu

dbms_stats.set_global_prefs('method_opt', 'FOR ALL COLUMNS SIZE 1')

-- schema DOCBASE_EBOX
DBMS_STATS.SET_SCHEMA_PREFS('DOCBASE_EBOX', 'METHOD_OPT', 'FOR ALL COLUMNS SIZE 1');

-- nastavení přepočtu nad tabulkou
DBMS_STATS.SET_TABLE_PREFS('RDB', 'CSX_OWNER_LOAD','METHOD_OPT', 'FOR ALL COLUMNS SIZE REPEAT');
