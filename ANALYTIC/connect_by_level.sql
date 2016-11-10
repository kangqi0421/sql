-- SQL sequences
WITH counter
AS ( SELECT LEVEL seq
       FROM DUAL
     CONNECT BY LEVEL <= 4 )
SELECT (2008 + seq - 1) myYear
  FROM counter
 ORDER BY 1
;  

-- with 11gR2 subquery
WITH T3(Years) AS (
   SELECT 2008 Years FROM dual
   UNION ALL
   SELECT Years + 1 FROM T3 WHERE Years < 2011
   )
SELECT * FROM T3;       