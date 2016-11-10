/* Formatted on 2004/11/04 16:05 (Formatter Plus v4.8.0) */
SELECT   s.hash_value, t.sql_text, SUM (s.buffer_gets), SUM (s.disk_reads),
         SUM (s.executions)
    FROM sql s, stats$sqltext t
   WHERE s.snap_id > 22306
   		 and s.snap_id < 22333
     AND s.hash_value = t.hash_value
     AND t.piece = 0                        --pouze prvni radek SQL statementu
GROUP BY s.hash_value, t.sql_text
ORDER BY 4 DESC
