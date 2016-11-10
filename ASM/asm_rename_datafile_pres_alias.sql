-- rename datafile to alias
select TABLESPACE_NAME, FILE_NAME from dba_data_files where tablespace_name like '%USER%';

-- Create an alias for the target datafile name with new path and filename
alter diskgroup SMP_D01 add alias 
'+SMP_D01/smp0/datafile/test.dbf' 
for 
'+SMP_D01/smps/datafile/test.307.832146091';

-- Startup database in mount mode/tablespace offline

-- rename datafile
alter database rename file 
'+SMP_D01/smps/datafile/test.307.832146091'
to
'+SMP_D01/smp0/datafile/test.dbf';

Note: "Rename Alias" on system-created filenames  fails with ORA-15177.
There is no way to rename a system generated ASM filename.
Once a user-created-alias is added in the diskgroup, then you can use "rename alias" to rename the filename within ASM.

set lin 32767 trims on pages 0
-- bulk alias
with files as (
SELECT   file_name old_file_name,
    -- (+dg) / (db name) / (datafile) / (file) . (number) . (number)
    REGEXP_REPLACE(file_name, '^(\+[^/]+)/([^/]+)/([^/]+)/([^\.]+\.(\d+))\.(\d+)\.*', '\1/crmp/\3/\4.dbf') new_file_name
  FROM dba_data_files
  WHERE file_name LIKE '+CRMP_D01/crmps/datafile/%'
--  and tablespace_name = 'SIEBSA_DATA'
  )
select 'alter diskgroup CRMP_D01 add alias '||
       DBMS_ASSERT.enquote_literal(new_file_name) ||
       ' for '||    
       DBMS_ASSERT.enquote_literal(old_file_name)||
       ';' cmd
  from files
;  

