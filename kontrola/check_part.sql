set pages 100

col table_owner for a15 head owner
col table_name for a35
col max_partition for a30
col status for a7 head status

SELECT a.table_owner, a.table_name, a.max_partition,
       CASE
          WHEN max_partition >= LIMIT
             THEN 'OK'
             ELSE 'ERR'
       END status
  FROM (
SELECT   table_owner, table_name,
         CASE
            WHEN (UPPER (SUBSTR (MAX (partition_name), 1, 1)) = 'M')
               THEN 'M'|| TO_CHAR (ADD_MONTHS (SYSDATE - 1, 1), 'YYYYMM')
            WHEN (UPPER (SUBSTR (MAX (partition_name), 1, 1)) = 'D')
               THEN 'D'|| TO_CHAR ((SYSDATE + 3), 'YYYYMMDD')
         END AS LIMIT,
         MAX (partition_name) max_partition
    FROM dba_tab_partitions
   WHERE table_owner NOT IN ('SYSTEM', 'SYS', 'CBL')
        and table_name not in ('BDT_AUTH_SMS') -- vyjimky, ktere se nepouzivaji
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
   WHERE table_owner NOT IN ('SYSTEM', 'SYS', 'CBL')
GROUP BY table_owner, table_name
        ) a
  ORDER BY 1,2,3
/
