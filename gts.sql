prompt Gather Table Statistics for table owner.table_name
exec dbms_stats.gather_table_stats(upper('&owner'), upper('&table_name'), null, method_opt=>'FOR TABLE FOR ALL COLUMNS SIZE REPEAT', cascade=>true, no_invalidate =>  FALSE);
