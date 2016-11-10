-- 
-- RAC connection imbalance
--
-- https://iiotzov.wordpress.com/2015/05/08/detecting-connection-imbalance-in-oracle-rac/
--

SELECT COUNT(*) cnt
FROM
    (SELECT STATS_CROSSTAB(inst_id, username, 'CHISQ_SIG') p_value
    FROM gv$session
    WHERE username LIKE 'KRIMI%'    
    )
WHERE p_value < 0.05;  