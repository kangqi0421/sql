-- TABLE and INDEX PARTITION
  SELECT partition_name, round(sum(bytes)/1048576) "MB"
    FROM dba_segments
   WHERE owner = 'MW' 
GROUP BY partition_name
ORDER BY partition_name;


-- LOB PARTITIONS
  SELECT l.partition_name, ROUND (SUM (bytes) / 1048576) "MB"
    FROM    dba_segments s
         INNER JOIN
            dba_lob_partitions l
         ON (    s.owner = l.table_owner
             AND s.partition_name = l.lob_partition_name)
   WHERE s.OWNER = 'MW' AND l.table_name LIKE 'LOG%'
GROUP BY l.partition_name
order by l.partition_name;

-- LOB INDEXY
  SELECT l.partition_name, ROUND (SUM (bytes) / 1048576) "MB"
    FROM    dba_segments s
         INNER JOIN
            dba_lob_partitions l
         ON (    s.owner = l.table_owner
             AND s.partition_name = l.lob_indpart_name)
   WHERE s.OWNER = 'MW' AND l.table_name LIKE 'LOG%'
GROUP BY l.partition_name
order by l.partition_name;