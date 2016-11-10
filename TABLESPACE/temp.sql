/* alokovane misto v TEMP tablespace */

WITH query
     AS (SELECT VALUE
           FROM v$parameter
          WHERE name = 'db_block_size')
SELECT TABLESPACE_NAME,
       TOTAL_BLOCKS * q.VALUE / 1048576 "total [MB]",
       USED_BLOCKS * q.VALUE / 1048576 "used [MB]",
       FREE_BLOCKS * q.VALUE / 1048576 "free [MB]"
  FROM v$sort_segment s, query q;