select round((( select sum(bytes) from v$datafile )
+ ( select sum(bytes) from v$tempfile )
+ ( select sum(bytes) from v$log l,v$logfile f where f.group#=l.group#)
+ ( select sum((select ceil(2 * sum(record_size * records_total))
from v$controlfile_record_section)) from v$controlfile))/1024/1024/1024) "dbsize [GB]"
from dual
/ 