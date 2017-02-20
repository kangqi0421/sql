--
-- SQL skript pro pridani dalsich redolog group, typicky aspon 4
--

define size_mb = &1
define pocet_redo_group = &2

DECLARE
		debug BOOLEAN          := FALSE;
		redo_size_mb           INTEGER := &size_mb;
		v_pocet_groups         INTEGER := &pocet_redo_group;
    v_actual_groups        INTEGER;
		v_db_create_file_dest  VARCHAR2(80);
		stmt       		         VARCHAR2(2048);
BEGIN
   SELECT COUNT(*) INTO v_actual_groups
     FROM V$LOG where thread# = 1;
   SELECT TRIM (VALUE)
     INTO v_db_create_file_dest
     FROM v$parameter
    WHERE name = 'db_create_file_dest';
   IF v_actual_groups < v_pocet_groups THEN
     FOR rec IN 1..(v_pocet_groups - v_actual_groups)
     LOOP
       for inst in (select inst_id from gv$instance)
       LOOP
          stmt := 'alter database add logfile thread '
             || inst.inst_id || ' ('
             ||       DBMS_ASSERT.enquote_literal(v_db_create_file_dest)
             ||',' || DBMS_ASSERT.enquote_literal(v_db_create_file_dest)   -- second member in group#
             ||') size '|| redo_size_mb ||'M';
          IF debug THEN
            DBMS_OUTPUT.put_line (stmt||';');
          ELSE
            execute immediate stmt;
        END IF;
       END LOOP;
     END LOOP;
   END IF;
END;
/
