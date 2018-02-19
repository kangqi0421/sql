create or replace directory MCI_ORA_APP_IMP_LOGS as '/ora_app/MCIPK/imp_logs/log';
create or replace directory MCI_ORA_APP_DB_LOGS as '/ora_app/MCIPK/imp_logs/DBlog';

-- test pres zavinac kvuli listeneru
conn system@MCIDATA

select spid from v$process p
  join v$session s on p.addr=s.paddr
   and s.sid=sys_context('userenv','sid');

strace -e trace=open -p #unix_pid

declare
  output_file  utl_file.file_type;
begin
    output_file := utl_file.fopen ('MW_CSOPS_EXP','test.txt', 'W');
    utl_file.put_line (output_file, 'TEST');
    utl_file.fclose(output_file);
end;
/
