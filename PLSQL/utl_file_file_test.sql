create or replace directory MCI_ORA_APP_IMP_LOGS as '/ora_app/MCIPK/imp_logs/log';
create or replace directory MCI_ORA_APP_DB_LOGS as '/ora_app/MCIPK/imp_logs/DBlog';

-- test pres zavinac kvuli listeneru
conn system@MCIDATA

declare
  output_file  utl_file.file_type;
begin
    output_file := utl_file.fopen ('MCI_CSOPS_IMP','test.txt', 'W');
    utl_file.put_line (output_file, 'TEST');
    utl_file.fclose(output_file);
end;
/
