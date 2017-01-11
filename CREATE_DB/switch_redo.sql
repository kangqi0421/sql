--
--
-- skript pro resize online redo
--
--   params: $1 - redo size in MB
--
-- 2x member přes groupu, DG odvozena z nastaveni db_create_file_dest

WHENEVER SQLERROR EXIT SQL.SQLCODE

set verify off
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

--ALL nutný pro RAC
BEGIN EXECUTE IMMEDIATE 'alter system switch ALL logfile'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'alter system switch logfile'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'alter system archive log all'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'alter system checkpoint global'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

-- RAC > single db - disable thread #2
BEGIN
for rec in (
  SELECT distinct thread# thread FROM V$LOG
   where thread# > (
     select max(instance_number) from gv$instance)
   )
   LOOP
     execute immediate  'alter database disable thread '||rec.thread;
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
   CURSOR rlc
   IS
        SELECT group# grp, thread# thr, bytes / 1024 bytes_k
          FROM v$log
      ORDER BY 1;
   stmt       VARCHAR2 (2048);
   swtstmt    VARCHAR2 (1024) := 'alter system switch logfile';
   ckpstmt    VARCHAR2 (1024) := 'alter system checkpoint global';
   inststmt   VARCHAR2 (80);
BEGIN
   SELECT TRIM (VALUE)
     INTO inststmt
     FROM v$parameter
    WHERE name = 'db_create_file_dest';
   FOR rlcRec IN rlc
   LOOP
      BEGIN
         stmt := 'alter database drop logfile group ' || rlcRec.grp;
         IF debug THEN
			DBMS_OUTPUT.put_line (stmt||';');
		 ELSE
            execute immediate stmt;
		 END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            BEGIN EXECUTE IMMEDIATE swtstmt; EXCEPTION WHEN OTHERS THEN NULL; END;
            BEGIN EXECUTE IMMEDIATE ckpstmt; EXCEPTION WHEN OTHERS THEN NULL; END;
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

