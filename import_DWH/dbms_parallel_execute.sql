

-- status
select * from DBA_PARALLEL_EXECUTE_TASKS
  order by job_prefix desc;

SELECT *
  FROM dba_parallel_execute_chunks
 WHERE 1 = 1
   and task_name = 'IMPORT_TASK$_157225'
   and start_ts > sysdate - interval '1' hour
--   and status = 'PROCESSED_WITH_ERROR'
--group by error_code   
  order by end_ts desc
;

select * from load_table
 -- where run_id = 14438164
  ;
  

select * from LOAD_TABLE_LOG order by log_dt desc
;


  
--
ORA-32795: cannot insert into a generated always identity column


-- resume TASK 
exec DBMS_PARALLEL_EXECUTE.RESUME_TASK ('TEST');


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

