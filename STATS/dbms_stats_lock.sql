-- SYMBOLS lock statistik
BEGIN
   FOR c IN (SELECT owner, table_name
               FROM dba_tables
              WHERE owner = 'KMDW' AND table_name like 'STA_%' 
             )
   LOOP
      dbms_stats.lock_table_stats (c.owner,c.table_name);
   END LOOP;
END;
/

SELECT stattype_locked, count(*)
  FROM dba_tab_statistics 
 WHERE owner in ('KMDW') AND table_name like 'STA_%'
 group by stattype_locked;