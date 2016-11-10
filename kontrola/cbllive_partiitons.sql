SELECT   table_owner, table_name, MAX (partition_name)
    FROM dba_tab_partitions
   WHERE partition_name LIKE 'D%'
GROUP BY table_owner, table_name
/
