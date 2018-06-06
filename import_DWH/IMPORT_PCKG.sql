--------------------------------------------------------
--  DDL for Package IMPORT_PCKG
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE PACKAGE "SYSTEM"."IMPORT_PCKG" IS
  PROCEDURE import_table (
      p_start_id      IN NUMBER,
      p_end_id        IN NUMBER
  );

  PROCEDURE load_schema (
      p_table_owner      IN VARCHAR2,
      p_db_link          IN VARCHAR2 := 'EXPORT_IMPDP',
      p_do_truncate      IN BOOLEAN := true
  );

  PROCEDURE run_parallel (
      p_parallel_level   NUMBER := 32
  );

END IMPORT_PCKG;


/
--------------------------------------------------------
--  DDL for Package Body IMPORT_PCKG
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE PACKAGE BODY "SYSTEM"."IMPORT_PCKG" IS

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

  PROCEDURE import_table (
      p_start_id      IN NUMBER,
      p_end_id        IN NUMBER
  ) AS
    l_sql_stmt    CLOB;

  BEGIN

    FOR rec IN (
        SELECT
            t.table_owner || '.' || t.table_name as table_name,
            t.load_sql,
            t.run_id
        FROM
            load_table t
        WHERE
            t.run_id BETWEEN p_start_id AND p_end_id
    ) LOOP

        do_log(rec.table_name|| ':' || rec.run_id);
        --dbms_output.put_line(rec.load_sql);
        BEGIN
          EXECUTE IMMEDIATE rec.load_sql;
          EXCEPTION
            WHEN OTHERS THEN
              IF sqlcode in (-14300, -14401)
              THEN
                -- remove sub|partition FROM v_sql
                select regexp_replace(load_sql, '^(.*)\s(subpartition|partition)\s\(\w+\)(.*)$', '\1\3')
                   INTO l_sql_stmt
                   from load_table
                  where run_id = rec.run_id;

                  do_log(rec.table_name|| ': replace partition : ' || rec.run_id);

                  EXECUTE IMMEDIATE l_sql_stmt;
                  COMMIT;
                ELSE RAISE;
              END IF;
        END;
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
  BEGIN

    DELETE FROM load_table t
    WHERE t.table_owner = p_table_owner;
    COMMIT;

    FOR rec IN (
        SELECT
            table_name, partitioned FROM all_tables
        WHERE
            owner = p_table_owner
            AND table_name not in
              (select CONTAINER_NAME from ALL_MVIEWS)
            AND temporary = 'N'
            AND dropped = 'NO'
            AND external = 'NO'
        order by table_name
    )
    LOOP

      l_cols := Null;

      FOR i IN (
          SELECT
              c.column_name
          FROM
              all_tab_cols c
          WHERE
              c.owner = p_table_owner
              AND c.table_name = rec.table_name
              AND c.data_type not like 'LONG%'
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

      IF rec.partitioned = 'YES'
      THEN

        -- row_number() over(partition by d.owner, d.object_name order by d.subobject_name) as run_id
        -- SUBpartition
        l_sql_stmt := 'insert into load_table(table_owner, table_name, run_id, load_sql)
    select
      d.owner as table_owner,
      d.object_name as table_name,
      d.object_id as run_id,
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

        -- do_log(l_sql_stmt);
        EXECUTE IMMEDIATE l_sql_stmt
            USING p_table_owner, rec.table_name;

        -- partition
        l_sql_stmt := 'insert into load_table(table_owner, table_name, run_id, load_sql)
        select
          d.owner as table_owner,
          d.object_name as table_name,
          d.object_id as run_id,
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
            and d.object_type like ''TABLE PARTITION%''';

        -- do_log(l_sql_stmt);
        EXECUTE IMMEDIATE l_sql_stmt
            USING p_table_owner, rec.table_name;

      ELSE
        -- simple table
        l_sql_stmt := 'insert into load_table(table_owner, table_name, run_id, load_sql)
        select
          d.owner as table_owner,
          d.object_name as table_name,
          d.object_id as run_id,
          to_clob(''insert /*+ append */ into "''||d.owner||''"."''||d.object_name||''"
          ('
            || l_cols
            || ')'')||to_clob('' select '
            || l_cols
            || ' from "''||d.owner||''"."''||d.object_name||''"@'
            || p_db_link
            || ''')
          as insert_sql
        from dba_objects@'
                          || p_db_link
                          || ' d
        where d.owner = :p_table_owner and d.object_name = :p_table_name
            and d.object_type like ''TABLE''';

        -- do_log(p_table_owner||'.'||rec.table_name);
        EXECUTE IMMEDIATE l_sql_stmt
            USING p_table_owner, rec.table_name;

      END IF;

        -- truncate table before load
        IF nvl(p_do_truncate,true)
        THEN
            do_log('truncate table ' || p_table_owner||'.'||rec.table_name);
          BEGIN
            EXECUTE IMMEDIATE 'truncate table '
              || DBMS_ASSERT.enquote_name(p_table_owner)||'.'||DBMS_ASSERT.enquote_name(rec.table_name);
          EXCEPTION
            WHEN OTHERS THEN
              IF sqlcode != -24005 THEN RAISE;
              END IF;
          END;

        END IF;
    END LOOP;
  END;

    PROCEDURE run_parallel (
        p_parallel_level   NUMBER := 32
    ) IS
        v_status      NUMBER;
        v_task_name   VARCHAR2(120);
        v_chunk_sql   CLOB;
        v_sql         CLOB;
    BEGIN

        v_task_name := 'IMPORT_' || DBMS_PARALLEL_EXECUTE.generate_task_name;

        -- BEGIN
        --     dbms_parallel_execute.drop_task(v_task_name);
        -- EXCEPTION
        --     WHEN dbms_parallel_execute.task_not_found THEN
        --         NULL;
        -- END;

        dbms_parallel_execute.create_task(v_task_name);

        v_chunk_sql := q'[
          select
             t.run_id start_id,
             t.run_id end_id
           from load_table t
           order by t.run_id]';

        dbms_parallel_execute.create_chunks_by_sql(
            v_task_name,
            v_chunk_sql,
            false);

        -- do_log(v_sql_stmt);
        v_sql := q'[
          begin
            import_pckg.import_table(:start_id, :end_id);
          end;
          ]';

        dbms_parallel_execute.run_task(
            task_name => v_task_name,
            sql_stmt => v_sql,
            language_flag => dbms_sql.native,
            parallel_level => p_parallel_level);

        v_status := dbms_parallel_execute.task_status(v_task_name);

        dbms_output.put_line('task_status = ' || v_status);
    END;

END IMPORT_PCKG;

/
