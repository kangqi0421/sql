SELECT SUBSTR (sql_text, 1, 70) "STMT",
       COUNT ( * ),
       ROUND (SUM (sharable_mem) / 1048576) "Memory [MB]",
       SUM (users_opening) "Open",
       SUM (executions) "Executions"
FROM v$sql
GROUP BY SUBSTR (sql_text, 1, 70)
HAVING SUM (sharable_mem) > 1048576
ORDER BY 3 DESC;