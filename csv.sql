@@saveset
set termout off feedback off colsep ; lines 32767 trimspool on trimout on tab off 
set underline off -- if dont want dashes to appear between column headers and data
set pages 999

spool &1..csv
--select name, value, isdefault from v$parameter
/
spool off

@@loadset
