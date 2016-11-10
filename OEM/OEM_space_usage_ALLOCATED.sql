--// Trocha analytickych funkci pro zobrazeni narustu za poslednich N dni //-

ALTER session SET NLS_NUMERIC_CHARACTERS = ', ';

define target_name = "'CPSP'"
define pocet_dni = "add_months(sysdate,-1)"     //poslední mìsíc

col target_name for a10

SELECT target_name,
       metric_column,
       rollup_timestamp,
       average,
       average - LAG (average) OVER (PARTITION BY metric_column ORDER BY rollup_timestamp)  diff
  FROM (SELECT target_name,
               metric_column,
               rollup_timestamp,
               average,
               ROW_NUMBER () OVER (PARTITION BY metric_column ORDER BY rollup_timestamp ASC) RN1,
               ROW_NUMBER () OVER (PARTITION BY metric_column ORDER BY rollup_timestamp DESC) RN2
          FROM mgmt$metric_daily a
         WHERE     metric_column IN ('ALLOCATED_GB', 'USED_GB')
               AND target_name in (&target_name)
               AND rollup_timestamp > &pocet_dni)
 WHERE RN1 = 1 OR RN2 = 1;


SELECT   m.rollup_timestamp AS rollup_timestamp,
         m.target_name, m.metric_column,
         m.average AS VALUE
    FROM mgmt$metric_daily m
   WHERE 1 = 1 
--         AND m.target_name in (&target_name)
--         AND REGEXP_LIKE(m.target_name, '^BRA[TD][ABCD]_.*1')
         AND m.target_name in (
         -- pouze DB targety
         select target_name from MGMT_TARGETS
             where Category_Prop_3 = 'DB'
              AND Host_Name like '%ordb04%'
              and target_name in ('CR','EPAKUAT1','FATAL','MASTER','PARDE','PARDEDU','PARDINT','PARDPRS','PARDSYS','REVP','REVPK')
         )
         AND m.rollup_timestamp > systimestamp - NUMTOYMINTERVAL( 3, 'MONTH' )
         AND m.target_type in (
            'rac_database', 
            'oracle_database')
         AND m.metric_name = 'DATABASE_SIZE'
         AND (m.metric_column = 'ALLOCATED_GB' 
             --OR t.metric_column = 'USED_GB'
              )
ORDER BY m.rollup_timestamp, m.metric_column, m.target_name
;