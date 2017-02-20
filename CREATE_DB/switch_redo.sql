--
--
-- SQL skript pro resize online redo
--
--   :params: $1 - redo size in MB, NULL = beze zmeny velikosti redo
--
-- 2x member přes groupu, DG odvozena z nastaveni db_create_file_dest

set verify off

-- nastav redo_size_mb na NULL, pokud se nema hodnota menit
define size_mb = &1

-- optimal_logfile_size
-- pokud je nastaven FAST_START_MTTR_TARGET
-- the value for optimal_logfile_size is expressed in megabytes and it changes frequently, based on the DML load on your database
select inst_id, optimal_logfile_size, TARGET_MTTR, ESTIMATED_MTTR from gv$instance_recovery;

set serveroutput on

set lin 180 pages 40
col member for a60
select THREAD#, l.GROUP#, member, bytes/1048576
  from v$log l join v$logfile f on l.group# = f.group#
  order by THREAD#, f.GROUP#;

select thread#, current_group# from v$thread where status = 'OPEN';
alter system switch logfile;

--ALL nutný pro RAC
--BEGIN EXECUTE IMMEDIATE 'alter system switch logfile'; EXCEPTION WHEN OTHERS THEN NULL; END;
--/
--BEGIN EXECUTE IMMEDIATE 'alter system switch ALL logfile'; EXCEPTION WHEN OTHERS THEN NULL; END;
--/
--BEGIN EXECUTE IMMEDIATE 'alter system archive log all'; EXCEPTION WHEN OTHERS THEN NULL; END;
--/
--BEGIN EXECUTE IMMEDIATE 'alter system checkpoint global'; EXCEPTION WHEN OTHERS THEN NULL; END;
--/

-- RAC > single db - disable thread #2
BEGIN
for rec in (
select thread#, enabled from v$thread
  where enabled = 'PUBLIC' AND thread# > (
     select max(instance_number) from gv$instance)
   )
   LOOP
     execute immediate  'alter database disable thread '||rec.thread#;
   END LOOP;
END;
/

--
select thread#, enabled from v$thread;

-- RAC > single: drop logfile of disabled thread
BEGIN
for rec in (select group# from v$log
  where thread# in (select thread# from v$thread
                      where enabled = 'DISABLED')
  )
  LOOP
    execute immediate 'alter database drop logfile group ' || rec.group#;
  END LOOP;
END;
/

DECLARE
   -- TRUE  - print SQL statement
   -- FALSE - run the SQL
   debug BOOLEAN := FALSE;
   --
   -- redolog resize size
   -- redo_size_mb  NUMBER := NULL;
   redo_size_mb  INTEGER := &size_mb ;
   --
   -- archivelog mode
   v_log_mode VARCHAR2(12);
   -- pocet public threadu
   v_thread# INTEGER;
   --
   CURSOR rlc
   IS
        SELECT group# grp, thread# thr, bytes / 1024 bytes_k
          FROM v$log
      ORDER BY 1;
   stmt            VARCHAR2 (2048);
   inststmt        VARCHAR2 (80);
   swtstmt         VARCHAR2 (1024) := 'ALTER SYSTEM SWITCH LOGFILE';
   -- switch pro RAC
   swtstmt_rac     VARCHAR2 (1024) := 'ALTER SYSTEM ARCHIVE LOG CURRENT';
   ckpstmt         VARCHAR2 (1024) := 'alter system checkpoint global';
BEGIN
   -- detekce RAC
   select count(*) INTO v_thread#
     from v$thread where enabled = 'PUBLIC';
   IF v_thread# > 1 THEN
     swtstmt := swtstmt_rac;
   END IF;
   SELECT TRIM (VALUE)
     INTO inststmt
     FROM v$parameter
    WHERE name = 'db_create_file_dest';
   FOR rlcRec IN rlc
   LOOP
      BEGIN
        BEGIN EXECUTE IMMEDIATE swtstmt;    EXCEPTION WHEN OTHERS THEN NULL; END;
        BEGIN EXECUTE IMMEDIATE ckpstmt;    EXCEPTION WHEN OTHERS THEN NULL; END;
        stmt := 'alter database drop logfile group ' || rlcRec.grp;
        IF debug THEN
			     DBMS_OUTPUT.put_line (stmt||';');
		    ELSE
           execute immediate stmt;
		    END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            BEGIN EXECUTE IMMEDIATE swtstmt;    EXCEPTION WHEN OTHERS THEN NULL; END;
            BEGIN EXECUTE IMMEDIATE ckpstmt;    EXCEPTION WHEN OTHERS THEN NULL; END;
            EXECUTE IMMEDIATE stmt;
      END;
      -- pokud je nastavena nova hodnota redo size, pouzij ji
      stmt :=
            'alter database add logfile thread '
         || rlcRec.thr|| ' ('
         ||       DBMS_ASSERT.enquote_literal(inststmt)
         ||',' || DBMS_ASSERT.enquote_literal(inststmt)   -- second member in group#
         ||') size ';
      -- online redo size
      IF redo_size_mb IS NOT NULL
        THEN
          stmt := stmt || redo_size_mb ||'M';
        ELSE
          stmt := stmt || rlcRec.bytes_k ||'K';
      END IF;
    IF debug THEN
		  DBMS_OUTPUT.put_line (stmt||';');
	  ELSE
		  execute immediate stmt;
	  END IF;
   END LOOP;
END;
/

set lin 180 pages 40
col member for a60
select THREAD#, l.GROUP#, member, bytes/1048576
  from v$log l join v$logfile f on l.group# = f.group#
  order by THREAD#, f.GROUP#;

-- kontrola pro RAC, minimum aspoň 3 groupy pro každý thread
select THREAD#, count(*) from v$log group by THREAD#;
