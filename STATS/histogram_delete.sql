BEGIN
   FOR rec
      IN (SELECT owner, table_name, column_name
            FROM dba_tab_columns
           WHERE     histogram <> 'NONE'
                 AND owner = 'KMDW'
                 AND table_name IN ('STA_CL_HISTORY')
		  )
   LOOP
      DBMS_STATS.delete_column_stats (ownname         => rec.owner,
                                      tabname         => rec.table_name,
                                      colname         => rec.column_name,
                                      cascade_parts   => TRUE,
                                      col_stat_type   => 'HISTOGRAM');
   END LOOP;
END;
/

-- SYMBOLS delete histograms
BEGIN
   FOR c IN (SELECT owner, table_name, column_name
               FROM dba_tab_columns
              WHERE owner in ('KMDW', 'SYMBOLS','SYMADM') 
                AND histogram <> 'NONE'
             )
   LOOP
      DBMS_STATS.delete_column_stats (ownname         => c.owner,
                                      tabname         => c.table_name,
                                      colname         => c.column_name,
                                      cascade_parts   => TRUE,
				      no_invalidate   => FALSE,
                                      col_stat_type   => 'HISTOGRAM');
   END LOOP;
END;
/

-- CPS delete histogram
BEGIN
  FOR c IN
  (
    SELECT   owner,
        table_name,
        column_name
      FROM dba_tab_columns
      WHERE OWNER IN
        (
          SELECT DISTINCT owner
            FROM DBA_SEGMENTS
            WHERE OWNER LIKE 'CPS%'
        )
      AND histogram <> 'NONE'
  )
  LOOP
    DBMS_STATS.delete_column_stats (ownname => c.owner, tabname => c.table_name
    , colname => c.column_name, cascade_parts => TRUE, no_invalidate => FALSE,
    col_stat_type => 'HISTOGRAM');
  END LOOP;
END;
/