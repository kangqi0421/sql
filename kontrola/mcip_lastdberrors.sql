-- dbmain.log_db_errors
SELECT 
   ROWID, L.created_tm, L.job_name, L.job_params, 
   L.SQLCODE, L.error_desc
FROM dbmain.log_db_errors  PARTITION (M201112) L
WHERE
1=1
AND CREATED_TM between date'2011-12-03' and date'2011-12-04' 
--AND JOB_NAME = 'DBMAIN.DB_TECHNICAL_PCKG.CompressPartitions'
AND SQLCODE > -20000
-- AND MESSAGE_PARAMS LIKE '%Databanking - clients%'
ORDER BY CREATED_TM DESC NULLS LAST;

-- DBMAIN.LOG
select * from DBMAIN.LOG_DB PARTITION (M201110) L
where CREATED_TM > sysdate - 1/24;

-- DBMaintenance
SELECT 
   ROWID, L.created_tm, L.message_cd, L.message_txt, 
   L.message_params, L.process
FROM dbmain.log_db   PARTITION (M201212) L
WHERE
1=1
 AND CREATED_TM BETWEEN TO_DATE('01.12.2012 23:40:00','dd.mm.yyyy hh24:mi:ss') 
                    AND TO_DATE('01.12.2012 23:45:27','dd.mm.yyyy hh24:mi:ss')  
   --AND MESSAGE_TXT LIKE 'Table partition %'
   --AND MESSAGE_PARAMS LIKE '%AutonomousThread#209%'
ORDER BY CREATED_TM DESC NULLS LAST;