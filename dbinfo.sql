--
-- DB info
--

set lines 180 pages 10000 long 100000 longchunksize 100000 heading on feedback on trimspool on echo off

column spoolname new_value spoolname noprint;
select name ||'_'||to_char(sysdate, 'yyyyddmm_hh24miss') spoolname from v$database;

--spool &spoolname._db_info.txt

prompt DB instance info
col name for a10
col force_logging for a5
select name,log_mode,flashback_on,supplemental_log_data_min SLMIN,
       force_logging,database_role
from v$database;

prompt dba registry:
col comp_id for a15
col comp_name for a35
col version for a15
col status for a10

select substr(comp_id,1,15) comp_id,substr(comp_name,1,30) comp_name,
       substr(version,1,10) version, status
  from dba_registry
 -- where comp_id = 'CONTEXT'
 order by 1;

prompt NLS charset
column property_name format a25
column property_value format a25

select property_name, property_value from database_properties where property_name in ('NLS_CHARACTERSET');

prompt basic init params:
column name format a50
column value format a50
column comp_name format a40
column version format a12
column status format a10

select name, value, recommended
from (
select name,
   value,
   case
    when name = 'processes' and value < 1000 then 'ERR:1000'
    when name = 'resource_limit' and value <> 'TRUE' then 'ERR:TRUE'
    when name = 'session_cached_cursors' and value < 200 then 'ERR:200'
    when name = 'fast_start_mttr_target' and value  < 300 then 'ERR:300'
    when name = 'archive_lag_target' and value < 1800 then 'ERR:1800'
    when name = 'os_authent_prefix' and value is not NULL then 'ERR:'
  ELSE 'OK'
  END recommended,
  decode(name, 'db_block_size',1, 'processes',2,
      'memory_target',3, 'sga_target',4, 'pga_aggregate_target',5
        ) sort_order
  from v$parameter
where name in ('db_block_size','processes',
    'memory_target','sga_target','pga_aggregate_target',
    'session_cached_cursors','fast_start_mttr_target',
    'recyclebin','resource_limit','archive_lag_target','os_authent_prefix'
              )
      )
 order by sort_order, name;


prompt NON-default init params
select
      name,
      value
  from v$parameter
where name not in ('db_block_size','processes',
    'memory_target','sga_target','pga_aggregate_target',
    'recyclebin','archive_lag_target','db_create_file_dest','db_name',
    'db_recovery_file_dest','db_recovery_file_dest_size','log_archive_format',
    'fast_start_mttr_target','resource_limit','undo_tablespace','thread',
    'disk_asynch_io','instance_number','db_domain','remote_listener',
    'audit_file_dest','audit_sys_operations','audit_trail','control_files',
    'diagnostic_dest','os_authent_prefix','remote_login_passwordfile')
    and isdefault = 'FALSE'
order by name;

prompt redo size
select THREAD#, count(*), max(bytes)/1048576 "MB" from v$log group by THREAD#;

prompt UNDO:
SELECT t.tablespace_name, d.file_name, d.bytes/1048576 MB,
       autoextensible EXT,decode(autoextensible, 'YES', round(maxbytes/1048576), null) MAXSIZE
  FROM    dba_tablespaces t
       INNER JOIN
          dba_data_files d
       ON (t.tablespace_name = d.tablespace_name)
 WHERE t.contents = 'UNDO'
ORDER by t.tablespace_name
;

prompt tempfiles:
SELECT d.file_name, d.bytes/1048576 MB, d.autoextensible EXT,
       decode(d.autoextensible, 'YES', round(d.maxbytes/1048576), null) MAXSIZE
 from dba_temp_files d;

prompt DBA directories
col directory for a180

select
  'create or replace directory '||directory_name||' as '||
  DBMS_ASSERT.enquote_literal(directory_path)||';' "directory"
from dba_directories
  where (directory_name not like 'ORACLE%'
    and  directory_name not like 'OPATCH%'
    and  directory_name not in ('DATA_PUMP_DIR','XSDDIR','XMLDIR')
         )
;

/*
-- datafiles
prompt datafiles
select name from v$datafile;


prompt logfile a controlfile
select member from v$logfile;
select name from v$controlfile;

prompt spfile
select value from v$parameter where name = 'spfile';
*/
