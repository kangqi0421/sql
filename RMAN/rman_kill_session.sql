SELECT 'alter system disconnect session '''||sid||','||serial#||''' immediate;' 
FROM V$SESSION s 
 WHERE 
(
UPPER( s.PROGRAM )LIKE 'RMAN%'
)
;