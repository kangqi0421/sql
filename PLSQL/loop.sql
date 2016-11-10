--// jednoducha PL/SQL smycka //--

BEGIN
   FOR rec IN (select owner, index_name 
                 from all_indexes
                where owner = 'ASCBL' and table_name = 'BDT_MC_MSG')
LOOP
  execute immediate 'alter index '||rec.owner||'.'||rec.index_name||' MONITORING USAGE';
END LOOP;
END;
/


/* pridani 4 datafile */

begin
  for i in 1..4
  loop 
    execute immediate 'alter tablespace REV add datafile size 256m autoextend on next 256m maxsize unlimited';
  end loop;
end;
/



/* autoextend na vsech datafiles tablespace */

set serveroutput on

DECLARE
   s      VARCHAR (1000);
   CURSOR c_datafile
   IS
      SELECT file_id
        FROM dba_data_files
       WHERE tablespace_name IN (
		'LOG_DB'
		                );
BEGIN
   FOR rec IN c_datafile
   LOOP
      s := 'alter database datafile '
         || rec.file_id
         || '  autoextend on next 256m  maxsize 16384m';
	  dbms_output.put_line(s||';');	 
   END LOOP;
END;
/

/* naopak zrus autoextend u datafiles, kde BYTES dosahlo MAXBYTES */

set serveroutput on

DECLARE
   s      VARCHAR (1000);
   CURSOR c_datafile
   IS
      SELECT file_name
        FROM dba_data_files
       WHERE BYTES = MAXBYTES;
BEGIN
   FOR rec IN c_datafile
   LOOP
      execute immediate 'alter database datafile '''
         || rec.file_name
         || '''  autoextend off';
   END LOOP;
END;
/


/* skript pro dropnutí všech objektù uživatele SRBA */

DECLARE
   s      VARCHAR (1000);
   CURSOR c_objects
   IS
      SELECT object_type, object_name
        FROM dba_objects
       where owner = 'SRBA' and object_type not in ('LOB', 'INDEX', 'PACKAGE BODY');
BEGIN
   FOR rec IN c_objects
   LOOP
      s := 'drop '
         || rec.object_type ||' SRBA.'
         || rec.OBJECT_NAME;
	  execute immediate (s);	 
   END LOOP;
END;
/


/* grantovani */

BEGIN
	FOR rec
	IN (	SELECT 'GRANT SELECT ON ' || b.owner || '.' || b.object_name || ' TO DBMAIN' output
					FROM sys.all_objects b
				 WHERE b.object_type IN ('TABLE', 'MATERIALIZED VIEW')
					 AND b.owner IN
									 ('ASB24',
										'ASCARD',
										'ASCBL',
										'ASCS',
										'ASDON',
										'ASEBPP',
										'ASS24',
										'DBIMPORT',
										'FLINT',
										'INTER',
										'INTRA',
										'MCI_EPM',
										'MCI_ARM')
					 AND b.object_name NOT LIKE '%_EXT'
			ORDER BY b.owner, b.object_name)
	LOOP
		EXECUTE IMMEDIATE rec.output;
		--DBMS_OUTPUT.put_line(rec.output);
	END LOOP;
END;
/
