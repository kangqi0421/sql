WITH query
     AS (SELECT a.CURRENT_UTILIZATION * b.VALUE AS MAX_CURSORS
           FROM v$resource_limit a, v$parameter b
          WHERE b.name LIKE 'open_cursors' AND a.resource_name = 'sessions')
SELECT max_cursors * 0.85 "Warning at 85%",
       max_cursors * 0.97 "Critical - not set"
  FROM query;