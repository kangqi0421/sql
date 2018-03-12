SET ECHO OFF
SET PAUSE OFF
SET TERMOUT OFF
REM     ORACLE - License Management Services - DBA_FEATURE_USAGE_STATISTICS Extract Script
REM
REM     Prerequisites:
REM        - path separator (/ or \) has already been set into PSEP variable (by db_conn_coll_main.sql)
REM
REM
REM     Change History
REM     ---------------------------------
REM     Date        Release Author
REM     ----------- ------- ---------------
REM     2017-03-12  17.2    sserban
REM

define SCRIPT_RELEASE=17.2

SET DEFINE ON
SET MARKUP HTML OFF
SET COLSEP ' '

-- Settings for customized functionality - the last definition of each parameter will dictate the customization
-- Set SCRIPT_TS to generate filenames with or without timestamp
define SCRIPT_TS=_TS_IGNORE_THIS_ERR  -- include timestamp in names of the output directory and output files: YYYY.MM.DD.HH24.MI.SS
define SCRIPT_TS=''                   -- standard names for output directory and output files [default behavior]
-- Set SCRIPT_SD to create output subdirectory
define SCRIPT_SD=''                   -- no output subdirectory
define SCRIPT_SD=DBA_FUS              -- create output subdirectory


SET TERMOUT ON

alter session set NLS_LANGUAGE='AMERICAN';
alter session set NLS_TERRITORY='AMERICA';
alter session set NLS_DATE_FORMAT='YYYY-MM-DD_HH24:MI:SS';
alter session set NLS_TIMESTAMP_FORMAT='YYYY-MM-DD_HH24:MI:SS';
alter session set NLS_TIMESTAMP_TZ_FORMAT='YYYY-MM-DD_HH24:MI:SS_TZH:TZM';

SET TERMOUT OFF
SET TAB OFF
SET TRIMOUT ON
SET TRIMSPOOL ON
SET PAGESIZE 5000
SET LINESIZE 300
SET SERVEROUTPUT ON
col DESCRIPTION format A65 wrap



-- Get SYSDATE
define SYSDATE_START=UNKNOWN
col C0 new_val SYSDATE_START
select SYSDATE C0 from dual;

-- Get host_name and instance_name
prompt Getting HOST_NAME and INSTANCE_NAME ...
define INSTANCE_NAME=UNKNOWN
define HOST_NAME=UNKNOWN
col C1 new_val INSTANCE_NAME
col C2 new_val HOST_NAME
-- Oracle7
SELECT min(machine) C2 FROM v$session WHERE type = 'BACKGROUND';
SELECT name    C1 FROM v$database;
-- Oracle8 and higher
SELECT instance_name C1, host_name C2 FROM v$instance;
-- Oracle12 and higher
  SELECT '&&INSTANCE_NAME' || decode(value, 'TRUE', '~' || replace(sys_context('USERENV', 'CON_NAME'), '$', '_'), '') C1
  from v$parameter where name = 'enable_pluggable_database';

define OUTPUT_PATH=***
col C3 new_val OUTPUT_PATH
select '&&HOST_NAME._&&INSTANCE_NAME.' ||
       decode('&SCRIPT_TS', null, null, '_'||to_char(to_date('&SYSDATE_START', 'YYYY-MM-DD_HH24:MI:SS'), 'YYYY.MM.DD.HH24.MI.SS')) C3 from DUAL;

define GREP_PREFIX=***
col C4 new_val GREP_PREFIX noprint
SELECT 'GREP'||'ME>>,&&HOST_NAME.,&&INSTANCE_NAME.,' || '&SYSDATE_START' || ',&&HOST_NAME.,' || name as C4 FROM v$database;

--{
--Detect SQL*Plus client path separator
--Using some Unix/Linux specific syntax
host echo select \'$PWD\' as PWD_, \'rm\' as RMDEL_, \'/\' as PSEP_ from dual where \'$PWD\' like \'%/%\'\; > psep.sql 2> fii_err.txt

define PWD=*
define RMDEL=del
define PSEP=\
col PWD_   new_val PWD   noprint
col RMDEL_ new_val RMDEL noprint
col PSEP_  new_val PSEP  noprint
-- The query syntax is correct only on Unix/Linux
@psep.sql
-- Cleanup
host &RMDEL psep.sql   2> fii_err.txt
--}

HOST mkdir &SCRIPT_SD   2> fii_err.txt

define OUTPUT_PATH_SD=***
col C3 new_val OUTPUT_PATH_SD
select decode('&&SCRIPT_SD', null, '&&OUTPUT_PATH', '&&SCRIPT_SD&&PSEP&&OUTPUT_PATH') C3 from DUAL;

HOST mkdir &&OUTPUT_PATH_SD

col C3 new_val OUTPUT_PATH
select decode(instr('&&OUTPUT_PATH_SD', '&&PSEP', -1),
              length('&&OUTPUT_PATH_SD'), '&&OUTPUT_PATH_SD',   -- if terminated by path separator, do not prefix the files
                                          '&&OUTPUT_PATH_SD&&PSEP&&OUTPUT_PATH._') as C3
  from dual;
col C3 clear

SET TERMOUT ON
SET VERIFY OFF


PROMPT *****  Collecting DBA_FEATURE_USAGE_STATISTICS information ... *****

spool &&OUTPUT_PATH.dbafus.csv
SET HEADING OFF
SET FEEDBACK OFF
SET LINESIZE 1500

prompt &&GREP_PREFIX.,DBAFUS_EXTRACT,VERSION,,,&SCRIPT_RELEASE.,


-- 10g DBA_FEATURE_USAGE_STATISTICS (10g and higher)
----------------------------------------------------
define OPTION_NAME=DBA_FEATURE_USAGE_STATISTICS
define OPTION_QUERY=10g
define OPTION_QUERY_COLS=DBID,NAME,VERSION,DETECTED_USAGES,TOTAL_SAMPLES,CURRENTLY_USED,FIRST_USAGE_DATE,LAST_USAGE_DATE,AUX_COUNT,FEATURE_INFO,LAST_SAMPLE_DATE,LAST_SAMPLE_PERIOD,SAMPLE_INTERVAL
define OCOUNT=-942
col OCOUNT new_val OCOUNT noprint
select ltrim(rtrim(to_char(count(*)))) as OCOUNT
  FROM DBA_FEATURE_USAGE_STATISTICS;

select '&&GREP_PREFIX.,&OPTION_NAME.~HEADER,&OPTION_QUERY.~HEADER,&&OCOUNT.,count,&OPTION_QUERY_COLS.,'
  from dual where &&OCOUNT. > 0;

select '&&GREP_PREFIX.,&OPTION_NAME.,&OPTION_QUERY.,&&OCOUNT.,count,'||
        DBID               ||  ',"'||
        NAME               || '","'||
        VERSION            || '",' ||
        DETECTED_USAGES    ||  ',' ||
        TOTAL_SAMPLES      ||  ',"'||
        CURRENTLY_USED     || '",' ||
        FIRST_USAGE_DATE   ||  ',' ||
        LAST_USAGE_DATE    ||  ',' ||
        AUX_COUNT          ||  ',"'||
        replace(replace(replace(to_char(substr(FEATURE_INFO, 1, 1000)), chr(10), '[LF]'), chr(13), '[CR]'),'"','''')   || '",' ||
        LAST_SAMPLE_DATE   ||  ',' ||
        LAST_SAMPLE_PERIOD ||  ',' ||
        SAMPLE_INTERVAL    ||  ','
  FROM DBA_FEATURE_USAGE_STATISTICS;

select '&&GREP_PREFIX.,&OPTION_NAME.,&OPTION_QUERY.,&&OCOUNT.,'||
        decode(&&OCOUNT., 0, 'count,', '"ORA-00942: table or view does not exist",')
  from dual where &&OCOUNT. in (-942, 0);


-- DBA_REGISTRY (9i_r2 and higher)
----------------------------------
define OPTION_NAME=DBA_REGISTRY
define OPTION_QUERY=>=9i_r2
define OPTION_QUERY_COLS=COMP_NAME,VERSION,STATUS,MODIFIED,SCHEMA
define OCOUNT=-942
col OCOUNT new_val OCOUNT noprint
select ltrim(rtrim(to_char(count(*)))) as OCOUNT
  from DBA_REGISTRY;

select '&&GREP_PREFIX.,&OPTION_NAME.~HEADER,&OPTION_QUERY.~HEADER,&&OCOUNT.,count,&OPTION_QUERY_COLS.,'
  from dual where &&OCOUNT. > 0;

select '&&GREP_PREFIX.,&OPTION_NAME.,&OPTION_QUERY.,&&OCOUNT.,count,'||
        '"' || COMP_NAME || '",' || VERSION || ',' || STATUS || ',' || MODIFIED || ',' || SCHEMA || ','
  from DBA_REGISTRY;

select '&&GREP_PREFIX.,&OPTION_NAME.,&OPTION_QUERY.,&&OCOUNT.,'||
        decode(&&OCOUNT., 0, 'count,', '"ORA-00942: table or view does not exist",')
  from dual where &&OCOUNT. in (-942, 0);


-- GV$PARAMETER
--------------------------------------------
define OPTION_NAME=GV$PARAMETER
define OPTION_QUERY=NULL
define OCOUNT=-942
col OCOUNT new_val OCOUNT noprint
select ltrim(rtrim(to_char(count(*)))) as OCOUNT
  from GV$PARAMETER
  where  upper(NAME) like '%CPU_COUNT%'
      or upper(NAME) like '%FAL_CLIENT%'
      or upper(NAME) like '%FAL_SERVER%'
      or upper(NAME) like '%CLUSTER%'
      or upper(NAME) like '%CONTROL_MANAGEMENT_PACK_ACCESS%'
      or upper(NAME) like '%ENABLE_DDL_LOGGING%'
      or upper(NAME) like '%COMPATIBLE%'
      or upper(NAME) like '%LOG_ARCHIVE_DEST%'
      or upper(NAME) like '%O7_DICTIONARY_ACCESSIBILITY%'  -- for troubleshooting access privileges issues
      or upper(NAME) like '%ENABLE_PLUGGABLE_DATABASE%'
      or upper(NAME) like '%INMEMORY%'
      or upper(NAME) like '%DB_UNIQUE_NAME%'
      or upper(NAME) like '%LOG_ARCHIVE_CONFIG%'
      or upper(NAME) like '%HEAT_MAP%'
  ;

SET LINESIZE 5000
select '&&GREP_PREFIX.,&OPTION_NAME.,&OPTION_QUERY.,&&OCOUNT.,count,"'||
        INST_ID      ||'","'||
        NAME         ||'","'||
        replace(VALUE,'"','''') ||'","'||
        ISDEFAULT    ||'","'||
        DESCRIPTION  ||'",'
  from GV$PARAMETER
  where  upper(NAME) like '%CPU_COUNT%'
      or upper(NAME) like '%FAL_CLIENT%'
      or upper(NAME) like '%FAL_SERVER%'
      or upper(NAME) like '%CLUSTER%'
      or upper(NAME) like '%CONTROL_MANAGEMENT_PACK_ACCESS%'
      or upper(NAME) like '%ENABLE_DDL_LOGGING%'
      or upper(NAME) like '%COMPATIBLE%'
      or upper(NAME) like '%LOG_ARCHIVE_DEST%'
      or upper(NAME) like '%O7_DICTIONARY_ACCESSIBILITY%'  -- for troubleshooting access privileges issues
      or upper(NAME) like '%ENABLE_PLUGGABLE_DATABASE%'
      or upper(NAME) like '%INMEMORY%'
      or upper(NAME) like '%DB_UNIQUE_NAME%'
      or upper(NAME) like '%LOG_ARCHIVE_CONFIG%'
      or upper(NAME) like '%HEAT_MAP%'
  order by NAME, INST_ID;
SET LINESIZE 500

select '&&GREP_PREFIX.,&OPTION_NAME.,&OPTION_QUERY.,&&OCOUNT.,'||
        decode(&&OCOUNT., 0, 'count,', '"ORA-00942: table or view does not exist",')
  from dual where &&OCOUNT. in (-942, 0);


-- V$VERSION - DB Version
-------------------------
define OPTION_NAME=V$VERSION
define OPTION_QUERY=NULL
define OCOUNT=-942
col OCOUNT new_val OCOUNT noprint
select ltrim(rtrim(to_char(count(*)))) as OCOUNT
  FROM V$VERSION;

select '&&GREP_PREFIX.,&OPTION_NAME.,&OPTION_QUERY.,&&OCOUNT.,count,"'||
        BANNER           ||'",'
  FROM V$VERSION;

select '&&GREP_PREFIX.,&OPTION_NAME.,&OPTION_QUERY.,&&OCOUNT.,'||
        decode(&&OCOUNT., 0, 'count,', '"ORA-00942: table or view does not exist",')
  from dual where &&OCOUNT. in (-942, 0);


--- OEM 10G AND HIGHER --- components
----------------------
define OPTION_NAME=OEM
define OPTION_QUERY=MGMT_INV_COMPONENT
define OPTION_QUERY_COLS=CONTAINER_TYPE,CONTAINER_NAME,CONTAINER_LOCATION,OUI_PLATFORM,IS_CLONABLE,NAME,VERSION,DESCRIPTION,EXTERNAL_NAME,INSTALLED_LOCATION,INSTALLER_VERSION,MIN_DEINSTALLER_VERSION,IS_TOP_LEVEL,TIMESTAMP
define OCOUNT=-942
col OCOUNT new_val OCOUNT noprint
select ltrim(rtrim(to_char(count(*)))) as OCOUNT
  from            SYSMAN.MGMT_INV_CONTAINER a
  full outer join SYSMAN.MGMT_INV_COMPONENT b on a.CONTAINER_GUID = b.CONTAINER_GUID
  ;

select '&&GREP_PREFIX.,&OPTION_NAME.~HEADER,&OPTION_QUERY.~HEADER,&&OCOUNT.,count,&OPTION_QUERY_COLS.,'
  from dual where &&OCOUNT. > 0;

SET LINESIZE 1500
select '&&GREP_PREFIX.,&OPTION_NAME.,&OPTION_QUERY.,&&OCOUNT.,count,"'||
    a.CONTAINER_TYPE        || '","' ||
    a.CONTAINER_NAME        || '","' ||
    a.CONTAINER_LOCATION    || '","' ||
    a.OUI_PLATFORM          || '","' ||
    a.IS_CLONABLE           || '","' ||
    NAME                    || '","' ||
    VERSION                 || '","' ||
    substr(replace(replace(replace(to_char(substr(b.DESCRIPTION, 1, 1000)), chr(10), '[LF]'), chr(13), '[CR]'),'"',''''), 1, 255) || '","' ||
    EXTERNAL_NAME           || '","' ||
    INSTALLED_LOCATION      || '","' ||
    INSTALLER_VERSION       || '","' ||
    MIN_DEINSTALLER_VERSION || '","' ||
    IS_TOP_LEVEL            || '","' ||
    TIMESTAMP               || '",'
  from            SYSMAN.MGMT_INV_CONTAINER a
  full outer join SYSMAN.MGMT_INV_COMPONENT b on a.CONTAINER_GUID = b.CONTAINER_GUID
  ;
SET LINESIZE 500


-- OEM PACK USAGE (12c Cloud Control)
define OPTION_NAME=OEM
define OPTION_QUERY=PACK_USAGE
define OPTION_QUERY_COLS=PACK_NAME,TARGET_NAME,TARGET_DISPLAY_NAME,TARGET_TYPE,HOST_NAME,CURRENTLY_USED,DETECTED_USAGES,TOTAL_SAMPLES,LAST_USAGE_DATE,FIRST_SAMPLE_DATE,LAST_SAMPLE_DATE,PACK_ID
define OCOUNT=-942
col OCOUNT new_val OCOUNT noprint

select ltrim(rtrim(to_char(count(*)))) as OCOUNT
  FROM SYSMAN.mgmt_fu_registrations reg,
       SYSMAN.mgmt_fu_statistics    stat,
       SYSMAN.mgmt_targets          tgts
  WHERE (stat.isused = 1 or stat.detected_samples > 0) -- current or past usage
    AND stat.target_guid = tgts.target_guid
    AND reg.feature_id = stat.feature_id
    AND reg.collection_mode = 2
  --AND tgts.display_name = 'TARGET_NAME'
  ;

select '&&GREP_PREFIX.,&OPTION_NAME.~HEADER,&OPTION_QUERY.~HEADER,&&OCOUNT.,count,&OPTION_QUERY_COLS.,'
  from dual where &&OCOUNT. > 0;

select '&&GREP_PREFIX.,&OPTION_NAME.,&OPTION_QUERY.,&&OCOUNT.,count,"'||
        reg.feature_name                           || '","'  ||
        tgts.target_name                           || '","'  ||
        tgts.display_name                          || '","'  ||
        tgts.type_display_name                     || '","'  ||
        tgts.host_name                             || '","'  ||
        DECODE(stat.isused, 1, 'TRUE', 'FALSE')    || '",'   ||
        stat.detected_samples                      || ','    ||
        stat.total_samples                         || ','    ||
        stat.last_usage_date                       || ','    ||
        stat.first_sample_date                     || ','    ||
        stat.last_sample_date                      || ',"'   ||
        reg.feature_id                             || '",'
  FROM SYSMAN.mgmt_fu_registrations reg,
       SYSMAN.mgmt_fu_statistics    stat,
       SYSMAN.mgmt_targets          tgts
  WHERE (stat.isused = 1 or stat.detected_samples > 0) -- current or past usage
    AND stat.target_guid = tgts.target_guid
    AND reg.feature_id = stat.feature_id
    AND reg.collection_mode = 2
  --AND tgts.display_name = 'TARGET_NAME'
 ORDER BY decode(tgts.target_type, 'oracle_database', 1, 'rac_database', 1, 2), -- db packs first
          reg.feature_name,
          tgts.type_display_name,
          tgts.display_name,
          tgts.host_name;

select '&&GREP_PREFIX.,&OPTION_NAME.,&OPTION_QUERY.,&&OCOUNT.,'||
        decode(&&OCOUNT., 0, 'count,', '"ORA-00942: table or view does not exist",')
  from dual where &&OCOUNT. in (-942, 0);




PROMPT

select 'LMS Review Lite Script runtime:' " ",
       (sysdate - to_date('&SYSDATE_START', 'YYYY-MM-DD_HH24:MI:SS'))*24*60*60 " ",
       'seconds' " "
  from dual;

PROMPT END OF SCRIPT
SPOOL OFF

-- Log collection completed
SET VERIFY OFF
SPOOL DB_sql_&&LOGS.002.log
DECLARE
  INSTANCE_N        VARCHAR2(900)  := '&&INSTANCE_NAME_0';
  HOST_N            VARCHAR2(200)  := '&&HOST_NAME';
  PDB_N             VARCHAR2(200)  := '';
BEGIN
  begin
    -- Get PDB name if applicable
    execute immediate 'select '' PDB: '' || sys_context(''USERENV'', ''CON_NAME'') from V$PARAMETER where NAME = ''enable_pluggable_database'' and VALUE = ''TRUE''' into PDB_N;
  exception
    when others then
      null;
  end;
  dbms_output.put_line('DB: LMS-02000: COLLECTED: Database Instance: ' || INSTANCE_N || PDB_N || ' running on Host: ' || HOST_N);
END;
/
SPOOL OFF
