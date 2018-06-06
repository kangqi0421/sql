--
-- DBMS_PARALLEL_EXECUTE
--

-- status
select * from DBA_PARALLEL_EXECUTE_TASKS
  order by job_prefix desc;

SELECT 
    *
--    distinct error_message
  FROM dba_parallel_execute_chunks
 WHERE 1 = 1
   and task_name = 'IMPORT_TASK$_1595662'
--    and start_ts > sysdate - interval '1' day
--   and status = 'PROCESSED_WITH_ERROR'
--   and error_code in (-14300, -14401)
   --and error_code = -1400
--   and status like 'PROC%'
--group by error_code   
  order by end_ts DESC
;

-- ORA-01400: cannot insert NULL into
SELECT distinct ERROR_MESSAGE
  FROM dba_parallel_execute_chunks
 WHERE 1 = 1
   and task_name = 'IMPORT_TASK$_753462'
--   and start_ts > sysdate - interval '2' day
   and status = 'PROCESSED_WITH_ERROR'
--   and error_code = -1400
;

select table_owner, table_name, load_sql, error_code, error_message
   from load_table l
     inner join dba_parallel_execute_chunks p on (l.run_id = p.start_id)
 WHERE 1 = 1
   and p.task_name = 'IMPORT_TASK$_1595662'
   and p.status = 'PROCESSED_WITH_ERROR'
--   and p.status = 'PROCESSED'
--   and p.error_code in (-1400)
--   and p.error_code in (-32795)
--   and table_owner = 'DWH_OWNER'
--   and table_owner not in ('DWH_OWNER')
 order by table_owner, table_name;
 
 
-- delete load_table
delete from load_table
  where table_name NOT in (
        'ACCOUNT_HISTORY', 'DEPOSIT_ACCOUNT_HISTORY')
    and table_owner in ('DWH_OWNER');

delete from load_table where table_owner not in ('DWH_OWNER');

select * 
  from LOAD_TABLE_LOG order by log_dt desc
;

truncate table LOAD_TABLE;
exec SYSTEM.IMPORT_PCKG.LOAD_SCHEMA('DAMI_OWNER');

exec SYSTEM.IMPORT_PCKG.import_table(67909518, 67909518);

select * from load_table
--  where run_id = 117908916
;


-- resume TASK 
exec DBMS_PARALLEL_EXECUTE.RESUME_TASK ('TEST');

-- drop task
exec DBMS_PARALLEL_EXECUTE.DROP_TASK ('IMPORT_TASK$_1174562');

exec DBMS_PARALLEL_EXECUTE.STOP_TASK ('IMPORT_TASK$_1174562');

select * from load_table
  order by run_id desc;

declare
  l_task_name varchar2(120 char) := 'TEST';
  l_sql_stmt varchar2(4000);
begin

    begin
    	dbms_parallel_execute.drop_task(l_task_name);
  	exception when dbms_parallel_execute.task_not_found then
    	null;
	  end;

  	dbms_parallel_execute.create_task(l_task_name);


    l_sql_stmt := 'select t.run_id start_id, t.run_id end_id
                     from load_table t
                    order by t.run_id';


    dbms_parallel_execute.create_chunks_by_SQL(task_name => l_task_name
        , sql_stmt => l_sql_stmt
        , by_rowid => false
    );

   execute immediate 'truncate table DWA_OWNER.ETL_REPL_REQUESTS';

   l_sql_stmt := q'[begin load_tab.load_serial('DWA_OWNER', 'ETL_REPL_REQUESTS', :start_id, :end_id); end;]';

   dbms_parallel_execute.run_task(
    		task_name => l_task_name
  		, sql_stmt => l_sql_stmt
	    , language_flag => dbms_sql.native
    	, parallel_level => 16
	 );

   dbms_output.put_line(DBMS_PARALLEL_EXECUTE.TASK_STATUS(l_task_name));


end;
/

-- rozdělení dat per partitions
select * from dba_tab_partitions
  where table_owner = 'DAMI_OWNER'
    and table_name = 'PARTY_HISTORY'
;

select count(*)
  from "DAMI_OWNER"."PARTY_HISTORY" partition (P_3000)
 -- WHERE TBL$OR$IDX$PART$NUM ("DAMI_OWNER"."PARTY_HISTORY"@EXPORT_IMPDP, 0, 3, 0, ROWID) = 67909518
;


select count(*)
  from "DAMI_OWNER"."PARTY_HISTORY" partition (P_3000)
where "PTH_VALID_TO" > TO_DATE(' 3000-01-01 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN')
;