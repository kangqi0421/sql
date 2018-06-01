set lines 32767 pages 0 trims on head off feed off
spool public.sql

select 'GRANT '||privilege||' "'||owner||'"."'||
table_name||'" to '||grantee||' '||grantable||';' as CMD
  from (
  select GRANTEE, OWNER, TABLE_NAME,
  case
    when privilege in ('READ','WRITE')  THEN privilege||' ON '||'DIRECTORY'
    else privilege||' ON'
  end privilege,
  decode(grantable,'YES','WITH Grant option') grantable
from dba_tab_privs@EXPORT_IMPDP
  where grantee = 'PUBLIC'
);

SELECT 'CREATE PUBLIC SYNONYM ' || synonym_name || ' FOR '
|| table_owner || '.' || table_name || ';' cmd
FROM dba_synonyms@EXPORT_IMPDP
WHERE owner='PUBLIC'
  and table_owner in
    (select username from dba_users@EXPORT_IMPDP
       where oracle_maintained = 'N')
;

spool off

exit

