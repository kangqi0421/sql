
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
                       order by t.run_id
                       ';
    
    
    dbms_parallel_execute.create_chunks_by_SQL(task_name => l_task_name
        , sql_stmt => l_sql_stmt
        , by_rowid => false
    );
    
   execute immediate 'truncate table DWA_OWNER.ETL_REPL_REQUESTS';

   l_sql_stmt := 'begin load_tab.load_serial(''''DWA_OWNER'''', ''''ETL_REPL_REQUESTS'''', :start_id, :end_id); end;';
   
   dbms_parallel_execute.run_task(
    		task_name => l_task_name
  		, sql_stmt => l_sql_stmt
	    , language_flag => dbms_sql.native
    	, parallel_level => 16
	 );

  
end;
/

