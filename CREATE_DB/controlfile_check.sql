WHENEVER OSERROR  EXIT FAILURE
WHENEVER SQLERROR EXIT SQL.SQLCODE

-- kontrola na umisteni controlfile do stejne ASM diskgroupy jako jsou data, vhodne pro klonovani
DECLARE
  v_data varchar2(4000);
BEGIN
select value into v_data
  from v$parameter2 where name = 'db_create_file_dest';
for rec in (
  select substr(value,1,instr(value, '/',1)-1) cntl
    from v$parameter2 where name = 'control_files'
     )
  LOOP
  IF rec.cntl != v_data THEN
     RAISE_APPLICATION_ERROR (-20001, 'All controlfiles are not in db_create_file_dest destination');
  END IF;
  END LOOP;
END;
/