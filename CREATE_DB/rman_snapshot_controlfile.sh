#!/bin/bash

{ sqlplus -s / as sysdba <<ESQL
set pagesize 0
select 'configure snapshot controlfile name to ''' || regexp_replace(name, '^(.*)/datafile/.*$', '\1/snapcf'';', 1, 1, 'i')
from v\$datafile
where file# = 1;
prompt show all;;
ESQL
} | rman target /
