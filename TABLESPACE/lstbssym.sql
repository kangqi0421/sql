/* dotaz prochazi pres DBA_TABLESPACE_USAGE_METRICS, pozor na bug 6629893 */

select
 'LN:'||decode(Status,'Warning','MAJOR','CRITICAL')||' '|| sys_context('USERENV', 'DB_NAME') ||' Tablespace '||"Tablespace"||' is full ('|| "Free" ||' MB free).' as "MSG"
from
(
SELECT tablespace_category "Category",
       tablespace_name "Tablespace",
       total_space "Total",
       allocated_space "Allocated",
       free_space "Free",
       free_pct "Free Pct",
       CASE
          WHEN ( (   tablespace_category LIKE '%SML'
                  OR tablespace_category LIKE '%MED'
                  OR tablespace_category LIKE '%LRG')
                AND ROUND (free_space) > warning_limit)
          THEN  'OK'
          WHEN ( (   tablespace_category LIKE '%SML'
                  OR tablespace_category LIKE '%MED'
                  OR tablespace_category LIKE '%LRG')
                AND ROUND (free_space) > critical_limit)
          THEN  'Warning'
          WHEN ( (   tablespace_category LIKE '%SML'
                  OR tablespace_category LIKE '%MED'
                  OR tablespace_category LIKE '%LRG')
                AND ROUND (free_space) <= critical_limit)
          THEN  'Critical'
          WHEN ( (   tablespace_category LIKE '%System'
                  OR tablespace_category LIKE '%UNDO'
                  OR tablespace_category LIKE '%Other')
                AND free_pct * 100 > warning_limit)
          THEN  'OK'
          WHEN ( (   tablespace_category LIKE '%System'
                  OR tablespace_category LIKE '%UNDO'
                  OR tablespace_category LIKE '%Other')
                AND free_pct * 100 > critical_limit)
          THEN 'Warning'
          WHEN ( (   tablespace_category LIKE '%System'
                  OR tablespace_category LIKE '%UNDO'
                  OR tablespace_category LIKE '%Other')
                AND free_pct * 100 <= critical_limit)
          THEN  'Critical'
          ELSE   'OK'
       END
          AS Status
  FROM (SELECT tablespace_category,
               tablespace_name,
               total_space/1024/1024 total_space,
               allocated_space/1024/1024 allocated_space,
               free_space/1020/1024 free_space,
               free_pct,
               CASE
                  WHEN tablespace_category LIKE '%LRG' THEN 10240
                  WHEN tablespace_category LIKE '%MED' THEN 6144
                  WHEN tablespace_category LIKE '%SML' THEN 4096
                  WHEN tablespace_category LIKE '%System' THEN 15
                  WHEN tablespace_category LIKE '%Temporary' THEN 0
                  WHEN tablespace_category LIKE '%UNDO' THEN 0
                  WHEN tablespace_category LIKE '%Other' THEN 15
                  ELSE NULL
               END
                  AS warning_limit,
               CASE
                  WHEN tablespace_category LIKE '%LRG' THEN 5120
                  WHEN tablespace_category LIKE '%MED' THEN 2048
                  WHEN tablespace_category LIKE '%SML' THEN 2048
                  WHEN tablespace_category LIKE '%System' THEN 3
                  WHEN tablespace_category LIKE '%Temporary' THEN -1
                  WHEN tablespace_category LIKE '%UNDO' THEN -1
                  WHEN tablespace_category LIKE '%Other' THEN 3
                  ELSE NULL
               END
                  AS critical_limit
          FROM (  SELECT CASE
                            WHEN m.tablespace_name LIKE 'SYSTEM'
                            THEN  '1. System'
                            WHEN m.tablespace_name LIKE '%TEMP%'
                              THEN  '2. Temporary'
                            WHEN m.tablespace_name LIKE '%UNDOTBS%'
                              THEN  '3. UNDO'
                            WHEN (m.tablespace_name LIKE '%LARGE%'  AND SYS_CONTEXT ('USERENV', 'DB_NAME') = 'SMP0')
                              THEN  '4. Large/LRG'
                            WHEN m.tablespace_name LIKE '%MED' 
                              THEN   '6. Medium/MED'
                            WHEN (m.tablespace_name LIKE '%SMALL' AND SYS_CONTEXT ('USERENV', 'DB_NAME') = 'SMP0')
                            THEN   '5. Small/SML'
                            WHEN (m.tablespace_name LIKE '%SML' AND SYS_CONTEXT ('USERENV', 'DB_NAME') = 'KMP0')
                            THEN   '5. Small/SML'
                            ELSE    '9. Other'
                         END
                            AS tablespace_category,
                         m.tablespace_name tablespace_name,
                         m.tablespace_size*p.db_block_size total_space,
                         m.used_space*p.db_block_size allocated_space,
                         (m.tablespace_size - m.used_space)*p.db_block_size free_space,
                         100 - m.used_percent free_pct
                    FROM DBA_TABLESPACE_USAGE_METRICS m,  (SELECT VALUE AS db_block_size
                                      FROM v$parameter
                                      WHERE name = 'db_block_size') p
               )
         )
) where Status<>'OK'
/