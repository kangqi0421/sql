spool DBDetail_$ORACLE_SID.txt

set pages 1000
select to_char(FIRST_TIME,'YYMMDD-HH24'), count(*) from v$log_history
where FIRST_TIME>to_date(20180801,'YYYYMMDD')
group by to_char(FIRST_TIME,'YYMMDD-HH24') order by 1;


select to_char(FIRST_TIME,'YYMMDD'), count(*) from v$log_history
where FIRST_TIME>to_date(20180901,'YYYYMMDD')
group by to_char(FIRST_TIME,'YYMMDD') order by 1;


select to_char(FIRST_TIME,'YYMMDD-DAY'), count(*) from v$log_history
where FIRST_TIME>to_date(20181001,'YYYYMMDD')
group by to_char(FIRST_TIME,'YYMMDD-DAY') order by 1;


select RESOURCE_NAME,CURRENT_UTILIZATION as "CURRENT", MAX_UTILIZATION AS "MAX",
INITIAL_ALLOCATION as "INITIAL", LIMIT_VALUE as "LIMIT" from v$resource_limit;


select owner || '.' || table_name "Table w/ chained rows", chain_cnt "# of ch.rows"
from dba_tables where chain_cnt > 0
order by chain_cnt desc,owner,table_name ;


select name ||' has been running for ' ||
  trunc(sysdate-open_time) || ' days, ' ||
  trunc(24*((sysdate-open_time)
     - trunc(sysdate-open_time))) || ' hours and ' ||
  trunc(60*((24*((sysdate-open_time)
        - trunc(sysdate-open_time)))
     - trunc(24*((sysdate-open_time)
        - trunc(sysdate-open_time))))) || ' minutes' "Up time of the DB"
from v$thread,v$database;

select
substr(d.file_name,1,10) "Disk", d.tablespace_name,
count(1) "files count",
round(sum(d.bytes)/1048576,2) "alloc MB",
round(sum(decode(autoextensible,'YES',d.maxbytes,d.bytes))/1048576,2) "maxsize MB",
round(sum(decode(autoextensible,'YES',d.maxbytes,d.bytes)-d.bytes)/1048576,2) "extd MB",
round((sum(decode(autoextensible,'YES',d.maxbytes,d.bytes)-d.bytes)/sum(decode(autoextensible,'YES',d.maxbytes,d.bytes)))*100,0) "extd %",
free_mb "free MB tbs",
free_perc "free % tbs"
from dba_data_files d,
     (select fi.tablespace_name, round(sum(fi.bytes)/1048576,2) "size(MB)",
                    nvl(free_by,0) free_mb,
                    nvl(round((free_by/(sum(fi.bytes)/1048576))*100,2),0) free_perc
     from dba_data_files fi,
          (select tablespace_name, round(sum(bytes)/1048576) free_by
           from dba_free_space
           group by tablespace_name) fr
     where fi.tablespace_name=fr.tablespace_name  (+)
     group by fi.tablespace_name, free_by) f
where d.tablespace_name=f.tablespace_name
group by d.tablespace_name,substr(d.file_name,1,10), free_mb, free_perc
order by tablespace_name --"Disk";
col owner for a20
col object_name for a35
col object_type for a20
select owner,object_name, object_type,status from dba_objects where status<>'VALID';



set pages 1000
set lines 180
set verify off
set head off
set feed off
set echo off


break on rate on cpu_time  on elapsed_time on sql_id
column cpu_time format 999999999999
column elapsed_time format 999999999999
column cpu_rate for a22
column elapsed_rate for a22
column cpu_time heading "CPU usage [ms]"
column elapsed_time heading "Elapsed Time [ms]"


select 'CPU_TIME histogram' from dual;
                                                                                                                                                 
select '------------------' from dual;

set head on

select cpu_rate as "Total CPU Usage"
     , count(sql_id) as "SQL count"
from (
  select
    case
     when cpu_time <= 1000    then '1) less than 1 ms'
     when cpu_time >= 1000    and cpu_time <100000  then '2) less than 100 ms'
     when cpu_time >= 100000  and cpu_time <1000000 then '3) less than 1 s'
     when cpu_time >= 1000000 and cpu_time <10000000 then '4) less than 10 s'
     else '5) more than 10 s'
    end as cpu_rate
  , sql_id
  from v$sql)
group by cpu_rate
order by cpu_rate
;


set head off

select 'ELAPSED_TIME histogram' from dual;
select '----------------------' from dual;

set head on

select elapsed_rate as "Elapsed Per Exec"
     , count(sql_id) "SQL count"
from (
  select
    case
     when elapsed_time/executions <= 1000    then '1) less than 1 ms'
     when elapsed_time/executions >= 1000    and elapsed_time/executions <100000  then '2) less than 100 ms'
     when elapsed_time/executions >= 100000  and elapsed_time/executions <1000000 then '3) less than 1 s'
     when elapsed_time/executions >= 1000000 and elapsed_time/executions <10000000 then '4) less than 10 s'
     else '5) more than 10 s'
    end as elapsed_rate
  , sql_id
  from v$sql where executions>0 )
group by elapsed_rate
order by elapsed_rate
;
set pages 49999
set lines 110
col DGroup format a15
col FType format a15
col name format a35
col MBYTES format a40


--spool locations.txt

SELECT SUBSTR(df.NAME,1,INSTR(df.NAME,'/',2)-1) DGroup
     ,'TABLESPACE' FType
     , tb.name Name
     , to_char(sum(df.bytes)/1024/1024) MBytes
from v$datafile df,
     v$tablespace tb
where df.ts#=tb.ts#
  and df.name like '%'
group by
       SUBSTR(df.NAME,1,INSTR(df.NAME,'/',2)-1), 'TABLESPACE', tb.name
union all
SELECT SUBSTR(tf.NAME,1,INSTR(tf.NAME,'/',2)-1) DGroup
     , 'TEMP' FType
     , tb.name Name
     , to_char(sum(tf.bytes)/1024/1024) MBytes
from v$tempfile tf,
     v$tablespace tb
where tf.ts#=tb.ts#
  and tf.name like '%'
group by
       SUBSTR(tf.NAME,1,INSTR(tf.NAME,'/',2)-1), 'TEMP', tb.name
union all
SELECT SUBSTR(MEMBER,1,INSTR(MEMBER,'/',2)-1) DGroup
     , 'ONLINELOG' FType
     , 'G-'||lf.group#||' T-'||lg.thread# Name
     , to_char(bytes/1024/1024) MBYTES
from v$logfile lf
   , v$log lg
where lf.group#=lg.group#
  and member like '%'
union all
SELECT SUBSTR(NAME,1,INSTR(NAME,'/',2)-1) DGroup
     , 'CONTROLFILE' FType
     , name
     , to_char(file_size_blks*block_size/1024/1024) MBytes
from v$controlfile
where name like '%'
union all
SELECT SUBSTR(FILENAME,1,INSTR(FILENAME,'/',2)-1) DGroup
     , 'CHANGETRACKING' FType
     , filename Name
     , to_char(bytes/1024/1024) MBytes
from v$block_change_tracking
where filename like '%'
order by FType, MBytes desc, name
;



set lines 180 pages 9999
COL "Host Name" FORMAT A30;
COL "Option/Management Pack" FORMAT A60;
COL "Used" FORMAT A5;
with features as(
select a OPTIONS, b NAME  from
(
select 'Active Data Guard' a,  'Active Data Guard - Real-Time Query on Physical Standby' b from dual
union all
select 'Advanced Compression', 'HeapCompression' from dual
union all
select 'Advanced Compression', 'Backup BZIP2 Compression' from dual
union all
select 'Advanced Compression', 'Backup DEFAULT Compression' from dual
union all
select 'Advanced Compression', 'Backup HIGH Compression' from dual
union all
select 'Advanced Compression', 'Backup LOW Compression' from dual
union all
select 'Advanced Compression', 'Backup MEDIUM Compression' from dual
union all
select 'Advanced Compression', 'Backup ZLIB, Compression' from dual
union all
select 'Advanced Compression', 'SecureFile Compression (user)' from dual
union all
select 'Advanced Compression', 'SecureFile Deduplication (user)' from dual
union all
select 'Advanced Compression',        'Data Guard' from dual
union all
select 'Advanced Compression', 'Oracle Utility Datapump (Export)' from dual
union all
select 'Advanced Compression', 'Oracle Utility Datapump (Import)' from dual
union all
select 'Advanced Security',     'ASO native encryption and checksumming' from dual
union all
select 'Advanced Security', 'Transparent Data Encryption' from dual
union all
select 'Advanced Security', 'Encrypted Tablespaces' from dual
union all
select 'Advanced Security', 'Backup Encryption' from dual
union all
select 'Advanced Security', 'SecureFile Encryption (user)' from dual
union all
select 'Change Management Pack',        'Change Management Pack (GC)' from dual
union all
select 'Data Masking Pack',     'Data Masking Pack (GC)' from dual
union all
select 'Data Mining',   'Data Mining' from dual
union all
select 'Diagnostic Pack',       'Diagnostic Pack' from dual
union all
select 'Diagnostic Pack',       'ADDM' from dual
union all
select 'Diagnostic Pack',       'AWR Baseline' from dual
union all
select 'Diagnostic Pack',       'AWR Baseline Template' from dual
union all
select 'Diagnostic Pack',       'AWR Report' from dual
union all
select 'Diagnostic Pack',       'Baseline Adaptive Thresholds' from dual
union all
select 'Diagnostic Pack',       'Baseline Static Computations' from dual
union all
select 'Tuning  Pack',          'Tuning Pack' from dual
union all
select 'Tuning  Pack',          'Real-Time SQL Monitoring' from dual
union all
select 'Tuning  Pack',          'SQL Tuning Advisor' from dual
union all
select 'Tuning  Pack',          'SQL Access Advisor' from dual
union all
select 'Tuning  Pack',          'SQL Profile' from dual
union all
select 'Tuning  Pack',          'Automatic SQL Tuning Advisor' from dual
union all
select 'Database Vault',        'Oracle Database Vault' from dual
union all
select 'WebLogic Server Management Pack Enterprise Edition',    'EM AS Provisioning and Patch Automation (GC)' from dual
union all
select 'Configuration Management Pack for Oracle Database',     'EM Config Management Pack (GC)' from dual
union all
select 'Provisioning and Patch Automation Pack for Database',   'EM Database Provisioning and Patch Automation (GC)' from dual
union all
select 'Provisioning and Patch Automation Pack',        'EM Standalone Provisioning and Patch Automation Pack (GC)' from dual
union all
select 'Exadata',       'Exadata' from dual
union all
select 'Label Security',        'Label Security' from dual
union all
select 'OLAP',          'OLAP - Analytic Workspaces' from dual
union all
select 'Partitioning',          'Partitioning (user)' from dual
union all
select 'Real Application Clusters',     'Real Application Clusters (RAC)' from dual
union all
select 'Real Application Testing',      'Database Replay: Workload Capture' from dual
union all
select 'Real Application Testing',      'Database Replay: Workload Replay' from dual
union all
select 'Real Application Testing',      'SQL Performance Analyzer' from dual
union all
select 'Spatial'        ,'Spatial (Not used because this does not differential usage of spatial over locator, which is free)' from dual
union all
select 'Total Recall',  'Flashback Data Archive' from dual
)
)
select t.o "Option/Management Pack",
       t.u "Used",
       d.DBID "DBID",
       d.name "DB Name",
       i.version "DB Version",
       i.host_name "Host Name",
       to_char(sysdate, 'YYYY-MM-DD HH24:MI:SS') "ReportGen Time"
from
(select OPTIONS o, DECODE(sum(num),0,'NO','YES') u
   from
   (
    select f.OPTIONS OPTIONS, case
                   when f_stat.name is null then 0
                   when ( ( f_stat.currently_used = 'TRUE' and
                            f_stat.detected_usages > 0 and
                            (sysdate - f_stat.last_usage_date) < 366 and
                            f_stat.total_samples > 0
                          )
                          or
                          (f_stat.detected_usages > 0 and
                          (sysdate - f_stat.last_usage_date) < 366 and
                          f_stat.total_samples > 0)
                        ) and
                        ( f_stat.name not in('Data Guard', 'Oracle Utility Datapump (Export)', 'Oracle Utility Datapump (Import)')
                          or
                          (f_stat.name in('Data Guard', 'Oracle Utility Datapump (Export)', 'Oracle Utility Datapump (Import)') and
                           f_stat.feature_info is not null and trim(substr(to_char(feature_info), instr(to_char(feature_info), 'compression used: ',1,1) + 18, 2)) != '0')
                        )
                        then 1
                   else 0
                  end num
   from features f,
       sys.dba_feature_usage_statistics f_stat
   where f.name = f_stat.name(+)
   ) group by options) t,
  v$instance i,
  v$database d
order by 2 desc,1
;


SET ECHO        OFF
SET FEEDBACK    6
SET HEADING     ON
SET LINESIZE    256
SET PAGESIZE    50000
SET TERMOUT     ON
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      OFF

CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES

COLUMN instance_name_print  FORMAT a13                   HEADING 'Instance Name'
COLUMN snap_id              FORMAT 9999999               HEADING 'Snap ID'
COLUMN startup_time         FORMAT a21                   HEADING 'Instance Startup Time'
COLUMN begin_interval_time  FORMAT a20                   HEADING 'Begin Interval Time'
COLUMN end_interval_time    FORMAT a20                   HEADING 'End Interval Time'
COLUMN elapsed_time         FORMAT 999,999,999,999.99    HEADING 'Elapsed Time (min)'
COLUMN db_time              FORMAT 999,999,999,999.99    HEADING 'DB Time (min)'
COLUMN pct_db_time          FORMAT 999999999             HEADING '% DB Time'
COLUMN cpu_time             FORMAT 999,999,999.99        HEADING 'CPU Time (min)'

BREAK ON instance_name_print ON startup_time

DEFINE spool_file=awr_snapshots_dbtime.lst

--SPOOL &spool_file

SELECT
    i.instance_name                                                                     instance_name_print
  , s.snap_id                                                                           snap_id
  , TO_CHAR(s.startup_time, 'mm/dd/yyyy HH24:MI:SS')                                    startup_time
  , TO_CHAR(s.begin_interval_time, 'mm/dd/yyyy HH24:MI:SS')                             begin_interval_time
  , TO_CHAR(s.end_interval_time, 'mm/dd/yyyy HH24:MI:SS')                               end_interval_time
  , ROUND(EXTRACT(DAY FROM  s.end_interval_time - s.begin_interval_time) * 1440 +
          EXTRACT(HOUR FROM s.end_interval_time - s.begin_interval_time) * 60 +
          EXTRACT(MINUTE FROM s.end_interval_time - s.begin_interval_time) +
          EXTRACT(SECOND FROM s.end_interval_time - s.begin_interval_time) / 60, 2)     elapsed_time
  , ROUND((e.value - b.value)/1000000/60, 2)                                            db_time
  , ROUND(((((e.value - b.value)/1000000/60) / (EXTRACT(DAY FROM  s.end_interval_time - s.begin_interval_time) * 1440 +
                                                EXTRACT(HOUR FROM s.end_interval_time - s.begin_interval_time) * 60 +
                                                EXTRACT(MINUTE FROM s.end_interval_time - s.begin_interval_time) +
                                                EXTRACT(SECOND FROM s.end_interval_time - s.begin_interval_time) / 60) ) * 100), 2)   pct_db_time
FROM
    dba_hist_snapshot       s
  , gv$instance             i
  , dba_hist_sys_time_model e
  , dba_hist_sys_time_model b
WHERE
      i.instance_number = s.instance_number
  AND e.snap_id         = s.snap_id
  AND b.snap_id         = s.snap_id - 1
  AND e.stat_id         = b.stat_id
  AND e.instance_number = b.instance_number
  AND e.instance_number = s.instance_number
  AND e.stat_name       = 'DB time'
ORDER BY
    i.instance_name
  , s.snap_id
;


SELECT
    i.instance_name                                                                     instance_name_print
  , s.snap_id                                                                           snap_id
  , TO_CHAR(s.startup_time, 'mm/dd/yyyy HH24:MI:SS')                                    startup_time
  , TO_CHAR(s.begin_interval_time, 'mm/dd/yyyy HH24:MI:SS')                             begin_interval_time
  , TO_CHAR(s.end_interval_time, 'mm/dd/yyyy HH24:MI:SS')                               end_interval_time
  , ROUND(EXTRACT(DAY FROM  s.end_interval_time - s.begin_interval_time) * 1440 +
          EXTRACT(HOUR FROM s.end_interval_time - s.begin_interval_time) * 60 +
          EXTRACT(MINUTE FROM s.end_interval_time - s.begin_interval_time) +
          EXTRACT(SECOND FROM s.end_interval_time - s.begin_interval_time) / 60, 2)     elapsed_time
  , ROUND((e.value - b.value)/1000000/60, 2)                                            db_cpu
  , ROUND(((((e.value - b.value)/1000000/60) / (EXTRACT(DAY FROM  s.end_interval_time - s.begin_interval_time) * 1440 +
                                                EXTRACT(HOUR FROM s.end_interval_time - s.begin_interval_time) * 60 +
                                                EXTRACT(MINUTE FROM s.end_interval_time - s.begin_interval_time) +
                                                EXTRACT(SECOND FROM s.end_interval_time - s.begin_interval_time) / 60) ) * 100), 2)   pct_db_time
FROM
    dba_hist_snapshot       s
  , gv$instance             i
  , dba_hist_sys_time_model e
  , dba_hist_sys_time_model b
WHERE
      i.instance_number = s.instance_number
  AND e.snap_id         = s.snap_id
  AND b.snap_id         = s.snap_id - 1
  AND e.stat_id         = b.stat_id
  AND e.instance_number = b.instance_number
  AND e.instance_number = s.instance_number
  AND e.stat_name       = 'DB CPU'
ORDER BY
    i.instance_name
  , s.snap_id
;
spool off
