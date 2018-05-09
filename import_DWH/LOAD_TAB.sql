CREATE OR REPLACE PACKAGE load_tab IS
    PROCEDURE load_serial (
        p_table_owner   IN VARCHAR2,
        p_table_name    IN VARCHAR2,
        p_start_id      IN NUMBER,
        p_end_id        IN NUMBER
    );

    PROCEDURE load_schema (
        p_table_owner      IN VARCHAR2,
        p_db_link          IN VARCHAR2 := 'EXPORT_IMPDP',
        p_do_truncate      IN BOOLEAN := true
    );

    PROCEDURE run (
        p_parallel_level   NUMBER := 32
    );

END load_tab;
/


CREATE OR REPLACE PACKAGE BODY load_tab IS

    PROCEDURE do_log (
        p_info   IN load_table_log.log_info%TYPE
    ) IS
        PRAGMA autonomous_transaction;
    BEGIN
        INSERT INTO load_table_log (
            log_dt,
            log_info
        ) VALUES (
            systimestamp,
            substr(p_info,1,2000)
        );

        COMMIT;
    END;

    PROCEDURE load_serial (
        p_table_owner   IN VARCHAR2,
        p_table_name    IN VARCHAR2,
        p_start_id      IN NUMBER,
        p_end_id        IN NUMBER
    ) AS
        l_dummy   VARCHAR2(61);
    BEGIN
        l_dummy := dbms_assert.schema_name(p_table_owner);
        l_dummy := dbms_assert.sql_object_name(p_table_owner
                                                 || '.'
                                                 || p_table_name);
        do_log('p_table_owner: '
                 || p_table_owner
                 || ' p_table_name:'
                 || p_table_name
                 || ' p_start_id: '
                 || p_start_id
                 || ' p_end_id:'
                 || p_end_id);

        FOR i IN (
            SELECT
                t.load_sql
            FROM
                load_table t
            WHERE
                t.run_id BETWEEN load_serial.p_start_id AND load_serial.p_end_id
                AND t.table_owner = load_serial.p_table_owner
                AND t.table_name = load_serial.p_table_name
        ) LOOP
            do_log(i.load_sql);
      
      -- dbms_output.put_line(i.load_sql);
            EXECUTE IMMEDIATE i.load_sql;
            COMMIT;
        END LOOP;

    END;

    PROCEDURE load_schema (
        p_table_owner      IN VARCHAR2,
        p_db_link          IN VARCHAR2 := 'EXPORT_IMPDP',
        p_do_truncate      IN BOOLEAN := true
    ) IS

        l_sql_stmt    CLOB;
        l_cols        VARCHAR2(32676);
        l_dummy       VARCHAR2(61);
    BEGIN

        DELETE FROM load_table t
        WHERE t.table_owner = p_table_owner;

        FOR rec IN (
            SELECT
                table_name,
                partitioned
            FROM
                dba_tables
            WHERE
                owner = p_table_owner
                AND temporary = 'N'
                AND dropped = 'NO'
                AND external = 'NO'
            order by table_name    
        )
        LOOP         

            FOR i IN (
                SELECT
                    c.column_name
                FROM
                    dba_tab_cols c
                WHERE
                    c.owner = p_table_owner
                    AND c.table_name = rec.table_name
                    AND c.hidden_column = 'NO'
                    AND c.virtual_column = 'NO'
                ORDER BY
                    c.column_id
            ) LOOP
                IF
                    l_cols IS NULL
                THEN
                    l_cols := '"'
                              || i.column_name
                              || '"';
                ELSE
                    l_cols := l_cols
                              || ',"'
                              || i.column_name
                              || '"';
                END IF;
            END LOOP;
    
            -- SUBpartition
            l_sql_stmt := 'insert into load_table(table_owner, table_name, run_id, load_sql)
        select
          d.owner as table_owner
       , d.object_name as table_name
       ,	row_number() over(partition by d.owner, d.object_name order by d.subobject_name) as run_id
         ,
            to_clob(''insert /*+ append */ into "''||d.owner||''"."''||d.object_name||''" subpartition (''
          ||d.subobject_name||'') ('
                          || l_cols
                          || ')'')||to_clob('' select '
                          || l_cols
                          || ' from "''||d.owner||''"."''||d.object_name||''"@'
                          || p_db_link
                          || '''
          ||'' WHERE TBL$OR$IDX$PART$NUM ("''||d.owner||''"."''||d.object_name||''"@'
                          || p_db_link
                          || ', 0, 3, 0, ROWID) = ''||d.object_id)
          as insert_sql
        from dba_objects@'
                          || p_db_link
                          || ' d
        where d.owner = :p_table_owner and d.object_name = :p_table_name
            and d.object_type like ''TABLE SUBPARTITION%''';
    
            do_log(l_sql_stmt);
            EXECUTE IMMEDIATE l_sql_stmt
                USING p_table_owner, rec.table_name;

            -- partition
            l_sql_stmt := 'insert into load_table(table_owner, table_name, run_id, load_sql)
            select
              d.owner as table_owner
           , d.object_name as table_name
           ,	row_number() over(partition by d.owner, d.object_name order by d.subobject_name) as run_id
             ,
                to_clob(''insert /*+ append */ into "''||d.owner||''"."''||d.object_name||''" partition (''
              ||d.subobject_name||'') ('
                              || l_cols
                              || ')'')||to_clob('' select '
                              || l_cols
                              || ' from "''||d.owner||''"."''||d.object_name||''"@'
                              || p_db_link
                              || '''
              ||'' WHERE TBL$OR$IDX$PART$NUM ("''||d.owner||''"."''||d.object_name||''"@'
                              || p_db_link
                              || ', 0, 3, 0, ROWID) = ''||d.object_id)
              as insert_sql
            from dba_objects@'
                              || p_db_link
                              || ' d
            where d.owner = :p_table_owner and d.object_name = :p_table_name
                and d.object_type like ''TABLE PARTITION%'''
    ;
    
            do_log(l_sql_stmt);
            EXECUTE IMMEDIATE l_sql_stmt
                USING p_table_owner,p_table_name;

            -- truncate table before load
            IF nvl(p_do_truncate,true)
            THEN
                do_log('truncate table ' || l_task_name);
                EXECUTE IMMEDIATE 'truncate table ' || l_task_name;
            END IF;
            
        END LOOP;   
    END;
        
    PROCEDURE run (
        p_parallel_level   NUMBER := 32
    ) IS     
        l_task_name   VARCHAR2(120 CHAR);

    BEGIN

--        BEGIN
--            dbms_parallel_execute.drop_task(l_task_name);
--        EXCEPTION
--            WHEN dbms_parallel_execute.task_not_found THEN
--                NULL;
--        END;

        dbms_parallel_execute.create_task(l_task_name);

        l_sql_stmt := 'select 
                         t.run_id start_id,
                         t.run_id end_id
                       from load_table t
                       order by t.run_id';
        
        do_log(l_sql_stmt);
        dbms_parallel_execute.create_chunks_by_sql(task_name => l_task_name,sql_stmt => l_sql_stmt,by_rowid => false);

        do_log(l_sql_stmt);
        l_sql_stmt := 'begin load_tab.load_serial('
                      || dbms_assert.enquote_literal(p_table_owner)
                      || ','
                      || dbms_assert.enquote_literal(p_table_name)
                      || ', :start_id, :end_id); end;';

        dbms_parallel_execute.run_task(
            task_name => l_task_name,
            sql_stmt => l_sql_stmt,
            language_flag => dbms_sql.native,
            parallel_level => p_parallel_level);

        dbms_output.put_line(dbms_parallel_execute.task_status(l_task_name) );
    END;

END load_tab;
/
