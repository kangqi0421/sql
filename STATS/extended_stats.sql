--[DBA|ALL|USER]_STAT_EXTENSIONS views display information about the multi-column statistic

-- ORA chyba
ORA-54032: column to be renamed is used in a virtual column expression


-- virtual column
select table_name, column_name, data_default, VIRTUAL_COLUMN, HIDDEN_COLUMN
  from dba_tab_cols
 where owner = 'SP015_000'
and table_name = 'T_VYPISY'
and virtual_column = 'YES';

-- stats reference for new hidden column
select *
  from dba_stat_extensions
where owner = 'SP015_000'
and table_name = 'T_VYPISY';

-- kde všude jsou extended stats
select owner, table_name
  from dba_stat_extensions
where owner in
    (select username from dba_users where oracle_maintained = 'N')
group by owner, table_name
order by 1, 2;

-- drop extended stats
exec DBMS_STATS.DROP_EXTENDED_STATS (ownname=>'SP015_000', tabname=>'T_VYPISY', extension=>'("PLATIOD","CISUCT","UPREDCHOZI","PORCISU","UZEDNE")');
exec DBMS_STATS.DROP_EXTENDED_STATS (ownname=>'SP015_000', tabname=>'T_VYPISY', extension=>'("CISUCT","UPREDCHOZI")');
exec DBMS_STATS.DROP_EXTENDED_STATS (ownname=>'SP015_000', tabname=>'T_VYPISY', extension=>'("CISUCT","UVYRAD","UPREDCHOZI","UPOSPL","UDRUHVYP","UZEDNE","UREZEX","UREZ","UEXE")');