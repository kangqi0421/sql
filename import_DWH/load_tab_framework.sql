connect system/s

CREATE TABLE SYSTEM.LOAD_TABLE(
  	"TABLE_OWNER" VARCHAR2(60 CHAR) NOT NULL ENABLE,
	  "TABLE_NAME" VARCHAR2(60 CHAR) NOT NULL ENABLE,
	  "RUN_ID" NUMBER NOT NULL ENABLE,
	  "LOAD_SQL" CLOB
    );

ALTER TABLE SYSTEM.LOAD_TABLE ADD CONSTRAINT "LOAD_TABLE_PK" PRIMARY KEY ("TABLE_OWNER", "TABLE_NAME", "RUN_ID");


CREATE TABLE SYSTEM.LOAD_TABLE_LOG(
  "LOG_DT" TIMESTAMP (6),
	"LOG_INFO" VARCHAR2(4000 BYTE)
  );


create or replace PACKAGE SYSTEM.LOAD_TAB is

    procedure load_serial(p_table_owner in varchar2, p_table_name in varchar2, p_start_id in number, p_end_id in number);

    procedure load_part(
        p_table_owner in varchar2
      , p_table_name in varchar2
      , p_db_link in varchar2 := 'EXPORT_IMPDP'
      , p_parallel_level number := 32
      , p_do_truncate in boolean := true
    );


end load_tab;
/


create or replace PACKAGE BODY        LOAD_TAB is


    procedure do_log(p_info in LOAD_TABLE_LOG.log_info%type) is
    pragma autonomous_transaction;
    begin
        insert into LOAD_TABLE_LOG(log_dt, log_info) values (systimestamp, substr(p_info, 1, 2000));
        commit;
    end;


  procedure load_serial(p_table_owner in varchar2, p_table_name in varchar2, p_start_id in number, p_end_id in number)
  AS
    l_dummy varchar2(61);

  begin

  l_dummy := dbms_assert.schema_name(p_table_owner);
    l_dummy := dbms_assert.sql_object_name(p_table_owner||'.'||p_table_name);

    do_log('p_table_owner: '||p_table_owner||' p_table_name:'||p_table_name||' p_start_id: '||p_start_id||' p_end_id:'||p_end_id);

    for i in (
      select t.load_sql
      from load_table t
      where t.run_id between load_serial.p_start_id and load_serial.p_end_id
        and t.table_owner = load_serial.p_table_owner and t.table_name = load_serial.p_table_name
    ) loop


      do_log(i.load_sql);

      -- dbms_output.put_line(i.load_sql);
      execute immediate i.load_sql;
      commit;
    end loop;
  end;



procedure load_part(
    p_table_owner in varchar2
  , p_table_name in varchar2
  , p_db_link in varchar2 := 'EXPORT_IMPDP'
  , p_parallel_level number := 32
  , p_do_truncate in boolean := true
  ) is

    l_task_name varchar2(120 char);
    l_sql_stmt clob;
    l_cols varchar2(32676);
    l_cnt number;
    l_dummy varchar2(61);
  begin


  l_dummy := dbms_assert.schema_name(p_table_owner);
    l_dummy := dbms_assert.sql_object_name(p_table_owner||'.'||p_table_name);
    l_dummy := dbms_assert.simple_sql_name(p_db_link);


    l_task_name := '"'||p_table_owner||'"."'||p_table_name||'"';


    begin
      dbms_parallel_execute.drop_task(l_task_name);
    exception when dbms_parallel_execute.task_not_found then
      null;
    end;


    dbms_parallel_execute.create_task(l_task_name);


    delete from load_table t where t.table_owner = p_table_owner and t.table_name = p_table_name;

    for i in (
      select c.column_name
      from all_tab_cols c
      where c.owner = p_table_owner
        and c.table_name = p_table_name
        and c.hidden_column = 'NO'
        and c.virtual_column = 'NO'
      order by c.column_id
    ) loop
      if l_cols is null then
        l_cols := '"'||i.column_name||'"';
      else
        l_cols := l_cols||',"'||i.column_name||'"';
      end if;
    end loop;


    l_sql_stmt :=

    'insert into load_table(table_owner, table_name, run_id, load_sql)
    select
      d.owner as table_owner
    , d.object_name as table_name
    , row_number() over(partition by d.owner, d.object_name order by d.subobject_name) as run_id
      ,
        to_clob(''insert /*+ append */ into "''||d.owner||''"."''||d.object_name||''" subpartition (''
      ||d.subobject_name||'') ('||l_cols||')'')||to_clob('' select '||l_cols||' from "''||d.owner||''"."''||d.object_name||''"@'||p_db_link||'''
      ||'' WHERE TBL$OR$IDX$PART$NUM ("''||d.owner||''"."''||d.object_name||''"@'||p_db_link||', 0, 3, 0, ROWID) = ''||d.object_id)
      as insert_sql
    from dba_objects@'||p_db_link||' d
    where d.owner = :p_table_owner and d.object_name = :p_table_name
      and d.object_type like ''TABLE SUBPARTITION%''';

    do_log(substr(l_sql_stmt, 1, 2000));


    execute immediate l_sql_stmt using p_table_owner, p_table_name;

    select count(*)
    into l_cnt
    from load_table t
    where t.table_owner = p_table_owner and t.table_name = p_table_name
      and rownum = 1;

    if l_cnt = 0 then


        l_sql_stmt :=

        'insert into load_table(table_owner, table_name, run_id, load_sql)
        select
          d.owner as table_owner
        , d.object_name as table_name
        , row_number() over(partition by d.owner, d.object_name order by d.subobject_name) as run_id
          ,
            to_clob(''insert /*+ append */ into "''||d.owner||''"."''||d.object_name||''" partition (''
          ||d.subobject_name||'') ('||l_cols||')'')||to_clob('' select '||l_cols||' from "''||d.owner||''"."''||d.object_name||''"@'||p_db_link||'''
          ||'' WHERE TBL$OR$IDX$PART$NUM ("''||d.owner||''"."''||d.object_name||''"@'||p_db_link||', 0, 3, 0, ROWID) = ''||d.object_id)
          as insert_sql
        from dba_objects@'||p_db_link||' d
        where d.owner = :p_table_owner and d.object_name = :p_table_name
            and d.object_type like ''TABLE PARTITION%''';

        do_log(substr(l_sql_stmt, 1, 2000));


        execute immediate l_sql_stmt using p_table_owner, p_table_name;


    end if;


    l_sql_stmt := 'select t.run_id start_id, t.run_id end_id
                       from load_table t
                       where t.table_owner = '''||p_table_owner||''' and t.table_name = '''||p_table_name||'''
                       order by t.run_id
                       ';

    do_log(substr(l_sql_stmt, 1, 2000));


    dbms_parallel_execute.create_chunks_by_SQL(
        task_name => l_task_name,
        sql_stmt => l_sql_stmt,
        by_rowid => false
    );


    do_log(l_sql_stmt);
    l_sql_stmt := 'begin load_tab.load_serial('||DBMS_ASSERT.enquote_literal(p_table_owner)
      ||','||DBMS_ASSERT.enquote_literal(p_table_name)
      ||', :start_id, :end_id); end;';

    -- grant DROP ANY TABLE
    if nvl(p_do_truncate, true) then
        do_log('truncate table '||l_task_name);
        execute immediate 'truncate table '||l_task_name;
    end if;


  dbms_parallel_execute.run_task(
        task_name => l_task_name
      , sql_stmt => l_sql_stmt
      , language_flag => dbms_sql.native
      , parallel_level => p_parallel_level
   );

     dbms_output.put_line(DBMS_PARALLEL_EXECUTE.TASK_STATUS(l_task_name));


  end;


end load_tab;
/