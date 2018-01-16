--
-- monitoring indexu

define owner = DATA_OWNER

spool index_monitoring_on.sql
set pages 0 lines 32767 trims on feed off head off

prompt ALTER SESSION SET ddl_lock_timeout=30;

select 'alter index '||owner||'.'||index_name||
    ' MONITORING USAGE;'
  from dba_indexes
 where owner = '&owner'
   and index_type not in ('LOB')
;

spool off

-- dotaz do slovníku
select /*csv*/
   o.object_name,
   decode(bitand(u.flags, 1), 0, 'NO', 'YES')  used
from
  sys.object_usage u join dba_objects o on u.obj# = o.object_id
order by 1;

-- OFF = nomonitoring

-- dotaz jako nahrada za gv$object_usage, ktera je pouze pro vlastnika schematu
--
define owner = 'PDB'

set lines 32767 pages 9999 trims on
col owner for a10
col table_name for a45
col index_name for a50

select u.name   owner
,      t.name   table_name
,      io.name  index_name
,      decode(bitand(i.flags, 65536), 0, 'NO', 'YES')   monitoring
,      decode(bitand(ou.flags, 1), 0, 'NO', 'YES')      used
-- ,      ou.start_monitoring  start_monitoring
-- ,      ou.end_monitoring    end_monitoring
from
  sys.user$ u
  ,   sys.obj$ io
  ,   sys.obj$ t
  ,   sys.ind$ i
  ,   sys.object_usage ou
where
  i.obj# = ou.obj#
  and io.obj# = ou.obj#
  and t.obj# = i.bo#
  and u.user# = io.owner#
  and u.name = '&owner'
order by owner, table_name, index_name
/

--// stav monitoringu jednou nad tabulkou //--
SELECT u.name "owner",
       io.name "index_name",
       t.name "table_name",
       DECODE (BITAND (i.flags, 65536), 0, 'no', 'yes') "monitoring",
       DECODE (BITAND (NVL (ou.flags, 0), 1), 0, 'no', 'yes') "used",
       ou.start_monitoring "start_monitoring",
       ou.end_monitoring "end_monitoring"
  FROM sys.obj$ io,
       sys.obj$ t,
       sys.ind$ i,
       sys.object_usage ou,
       sys.user$ u
 WHERE     t.obj# = i.bo#
       AND io.owner# = u.user#
       AND io.obj# = i.obj#
       AND u.name = 'ASCBL'
       AND t.name = 'BDT_MC_MSG'
       AND i.obj# = ou.obj#(+);