-- Generates script for disable SL
set lines 1000
set pages 1000
select 'REVOKE SELECT ON "'||OWNER||'"."'||TABLE_NAME||'" FROM "IPX_ROLE";' command from dba_log_groups where owner not in ('SYS') order by log_group_name;
select 'ALTER TABLE "'||OWNER||'"."'||TABLE_NAME||'" DROP SUPPLEMENTAL LOG GROUP "'||LOG_GROUP_NAME||'";' command from dba_log_groups where owner not in ('SYS') order by log_group_name;