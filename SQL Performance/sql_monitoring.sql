--// sql id zachycene v danem casovem useku //--

  SELECT sql_id,
         round(elapsed_time / 1000000 / 60, 1) "elapsed time [min]",
         round(cpu_time/ 1000000 / 60,1) "cpu time [min]",		 
         first_refresh_time,
         status
    FROM v$sql_monitor
   WHERE FIRST_REFRESH_TIME BETWEEN TIMESTAMP '2012-01-06 12:30:00'
                                AND TIMESTAMP '2012-01-06 14:15:00'
		AND status = 'EXECUTING'
ORDER BY elapsed_time DESC;


--// sql report //--
alter session set events='emx_control compress_xml=none';
set pagesize 0 echo off timing off linesize 1000 trimspool on trim on long 2000000 longchunksize 2000000 feedback off

select dbms_sqltune.report_sql_monitor(type=>'EM', sql_id=>'&SQL_ID') as report from dual;
