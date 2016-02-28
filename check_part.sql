/* Formatted on 2006/08/21 18:40 (Formatter Plus v4.8.7) */
SELECT   table_owner, table_name,
         CASE
            WHEN (UPPER (SUBSTR (MAX (partition_name), 1, 1)) = 'M')
               THEN 'M'|| TO_CHAR (ADD_MONTHS (SYSDATE - 1, 1), 'YYYYMM')
            WHEN (UPPER (SUBSTR (MAX (partition_name), 1, 1)) = 'D')
               THEN 'D'|| TO_CHAR ((SYSDATE + 3), 'YYYYMMDD')
         END AS LIMIT,
         MAX (partition_name) max_partition
    FROM dba_tab_partitions
   WHERE table_owner NOT IN ('SYSTEM', 'SYS')
GROUP BY table_owner, table_name
UNION ALL
SELECT   table_owner, table_name,
         CASE
            WHEN (UPPER (SUBSTR (MAX (partition_name), 1, 1)) = 'M')
               THEN 'M'|| TO_CHAR (ADD_MONTHS (SYSDATE - 1, 1), 'YYYYMM')
            WHEN (UPPER (SUBSTR (MAX (partition_name), 1, 1)) = 'D')
               THEN 'D'|| TO_CHAR ((SYSDATE + 3), 'YYYYMMDD')
         END AS LIMIT,
         MAX (partition_name) max_partition
    FROM dba_lob_partitions
   WHERE table_owner NOT IN ('SYSTEM', 'SYS')
GROUP BY table_owner, table_name

