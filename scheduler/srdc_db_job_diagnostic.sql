REM VARIABLE the_results VARCHAR2(30000);
REM VARIABLE the_results VARCHAR2(32767);
VARIABLE the_results CLOB;
SET echo OFF
REM define SRDCNAME='DB_JOB_CONFIG'
define SRDCNAME='DB'
define selection = '&1'
PROMPT theselection is '&1'
set verify off
select 'An incorrect parameter value was passed in or no parameter value was passed in.  Available options are:  1-6.'
from dual
where '&selection.' not in ('1','2','3','4','5','6');
SET serveroutput ON
REM SET SERVEROUTPUT ON size unlimited
REM prompt Please select one:
REM prompt 1: Autotask
REM prompt 2: Notification
REM prompt 3: Job Configuration
REM prompt 4: Job Execution
REM prompt 5: Externals Jobs
REM prompt 6: DBMS Jobs
REM accept selection prompt "Enter option 1-6: "
SET LONG 1000000 linesize 150 pagesize 2000 verify OFF sqlprompt "" term OFF echo OFF
COLUMN script new_value v_selected
SELECT
  CASE '&selection.'
  WHEN '1'  THEN 'JOB_AUTOTASK'
  WHEN '2'  THEN 'JOB_NOTIFICATION'
  WHEN '3'  THEN 'JOB_CONFIGURATION'
  WHEN '4'  THEN 'JOB_EXECUTION'
  WHEN '5'  THEN 'EXTERNAL_JOBS'
  WHEN '6'  THEN 'DBMS_JOBS'
  ELSE 'menu'
  END AS script
FROM dual;
COLUMN SRDCSPOOLNAME NOPRINT NEW_VALUE SRDCSPOOLNAME
SELECT 'SRDC_' ||upper('&&SRDCNAME') ||'_' || '&&v_selected' || '_'||SUBSTR(version,1,2) ||'_' ||upper(instance_name) ||'_' || TO_CHAR(sysdate,'YYYYMMDD_HH24MISS') SRDCSPOOLNAME
FROM v$instance;
spool &&SRDCSPOOLNAME..htm
DECLARE
  --*********************************************************
  --
  --  PLSQL TABLES
  --
  --*********************************************************
TYPE message_type
IS
  RECORD
  (
    print_order     NUMBER,
    print_msg       NUMBER,
    check_status    VARCHAR2(30),
    msg_type        VARCHAR2(30),
    msg_name        VARCHAR2 (200),
    msg_title       VARCHAR2 (200),
    msg_body        VARCHAR2 (32767),
    msg_fail        VARCHAR2 (32767),
    msg_pass        VARCHAR2 (32767),
    msg_query_fetch VARCHAR2 (1000),
    msg_query_count VARCHAR2 (1000),
    msg_body_html CLOB,
    msg_body_xml CLOB,
    msg_table    VARCHAR2 (200),
    msg_bookmark VARCHAR2 (200));
TYPE message_tab
IS
  TABLE OF message_type INDEX BY BINARY_INTEGER;
  t_message message_tab;
TYPE common_message
IS
  RECORD
  (
    msg_type  VARCHAR2(30),
    msg_name  VARCHAR2 (100),
    msg_title VARCHAR2 (200),
    msg_body  VARCHAR2(1000));
TYPE common_message_tab
IS
  TABLE OF common_message INDEX BY BINARY_INTEGER;
  t_common_message common_message_tab;
  --*********************************************************
  --
  --  VARIABLES
  --
  --*********************************************************
  SRDCNAME                    VARCHAR2(50) := 'SRDC_DB_JOB_CONFIG';
  v_SRDCSPOOLNAME             VARCHAR2(100) := '&SRDCSPOOLNAME';
  script_selected             VARCHAR2(100) := '&v_selected';
  msg_num                     NUMBER := 0;
  common_msg_num              NUMBER := 0;
  cur_msg_num                 NUMBER := 0;
  num_checks                  NUMBER := 0;
  instance_name               VARCHAR2(50) := '';
  db_name                     VARCHAR2(50) := '';
  report_time                 VARCHAR2(25) := '';
  startup_time                VARCHAR2(25) := '';
  host_name                   VARCHAR2(50) := '';
  db_version                  VARCHAR2(10) := '';
  db_version_short            VARCHAR2(2) :='';
  cur_date                    VARCHAR2(25) := '';
  cur_systimestamp            VARCHAR2(50) := '';
  compatible_param            VARCHAR2(100) := '';
  job_queue_processes_param   VARCHAR2(100) := '';
  resource_limit_param        VARCHAR2(100) := '';
  statistic_level_param       VARCHAR2(20) := '';
  sched_win_resource_plan     VARCHAR2(1000) := '';
  resource_manager_plan_param VARCHAR2(1000) := '';
  a_cl_optimizer_found        NUMBER :=0;
  a_cl_space_found            NUMBER :=0;
  a_cl_sql_tuning_found       NUMBER :=0;
  item_found                  NUMBER := '0';
  item_value                  VARCHAR2(200);
  scheduler_chains_found      NUMBER := '0';
  filewatcher_jobs_found      NUMBER := '0';
  notifications_found         NUMBER := '0';
  dba_jobs_found              NUMBER := '0';
  scheduler_jobs_found        NUMBER := '0';
  aq_srvntfn_table_found      NUMBER := '0';
  aq_srvntfn_table_list       VARCHAR2(3000);
  dba_objects_job_found       NUMBER := '0';
  job_style_light_weight_cnt  NUMBER := '0';
  job_style_regular_cnt       NUMBER := '0';
  scheduler_window_found      NUMBER := '0';
  weeknight_window_found      NUMBER := '0';
  weekend_window_found        NUMBER := '0';
  the_xml CLOB;
  the_html CLOB;
  full_result_msg VARCHAR2(30000) := '';
  l_cur_table     VARCHAR2(1000) := '';
  l_bookmark      VARCHAR2(200) := '';
  p_check_name    VARCHAR2(200) := '';
  msg_str_fail    VARCHAR2(32767) := '';
  msg_str_pass    VARCHAR2(32767) := '';
  msg_query_fetch VARCHAR2(32767) := '';
  msg_query_count VARCHAR2(32767) := '';
  the_count_cursor  VARCHAR2(2000) := '';
  the_data_cursor  VARCHAR2(2000) := '';
  var1 VARCHAR2(32767) := '';
  var2 VARCHAR2(32767) := '';
  var3 VARCHAR2(32767) := '';
  var4 VARCHAR2(32767) := '';
  var5 VARCHAR2(32767) := '';
  date1 INTERVAL DAY TO SECOND;
  --*********************************************************
  --
  --  CURSORS
  --
  --*********************************************************
  l_cursor sys_refcursor;
  --*********************************************************
  --
  --  PROCEDURES
  --
  --*********************************************************
--*********************************************************
--
--  chkVersion
--
--*********************************************************
FUNCTION chkVersion(
    v_1 IN VARCHAR2,
    v_2 IN VARCHAR2,
    num_places IN NUMBER)
  RETURN VARCHAR2
IS
  retval VARCHAR2(2);
  v1     NUMBER;
  v2     NUMBER;
BEGIN
  FOR i IN 1..num_places
  LOOP
    v1 := to_number(regexp_substr(v_1,'\d{1,}',1,i));
    v2 := to_number(regexp_substr(v_2,'\d{1,}',1,i));
    IF v1 > v2 THEN
      RETURN 'GT';
    END IF;
    IF v1 < v2 THEN
      RETURN 'LT';
    END IF;
  END LOOP;
  IF v1 = v2 THEN
    RETURN 'EQ';
  END IF;
END;
--*********************************************************
--
--  store_table_data
--
--*********************************************************
PROCEDURE store_table_data(
    v_msg_num IN NUMBER,
    v_print_msg IN NUMBER,
    v_check_status IN VARCHAR2,
    v_msg_type IN VARCHAR2,
    v_msg_name IN VARCHAR2,
    v_msg_title IN VARCHAR2,
    v_msg_body IN VARCHAR2,
    v_msg_fail IN VARCHAR2,
    v_msg_pass IN VARCHAR2,
    v_msg_query_fetch IN VARCHAR2,
    v_msg_query_count IN VARCHAR2,
    v_msg_body_html IN CLOB,
    v_msg_body_xml IN CLOB,
    v_msg_table IN VARCHAR2,
    v_msg_bookmark IN VARCHAR2)
IS
  v_offset     NUMBER DEFAULT 1;
  v_chunk_size NUMBER := 10000;
BEGIN
  t_message(v_msg_num).print_order := v_msg_num;
  t_message(v_msg_num).print_msg := v_print_msg;
  t_message(v_msg_num).check_status := v_check_status;
  t_message(v_msg_num).msg_type := v_msg_type;
  t_message(v_msg_num).msg_name := v_msg_name;
  t_message(v_msg_num).msg_title := v_msg_title;
  t_message(v_msg_num).msg_body := v_msg_body;
  t_message(v_msg_num).msg_fail := v_msg_fail;
  t_message(v_msg_num).msg_pass := v_msg_pass;
  t_message(v_msg_num).msg_query_fetch := v_msg_query_fetch;
  t_message(v_msg_num).msg_query_count := v_msg_query_count;
  t_message(v_msg_num).msg_body_html := v_msg_body_html;
  t_message(v_msg_num).msg_body_xml := v_msg_body_xml;
  t_message(v_msg_num).msg_table := v_msg_table;
  t_message(v_msg_num).msg_bookmark := v_msg_bookmark;
END store_table_data;
--*********************************************************
--
--  set_check_status
--
--*********************************************************
PROCEDURE set_check_status(
    v_msg_num IN NUMBER,
    v_check_status IN VARCHAR2)
IS
BEGIN
  t_message(v_msg_num).check_status := v_check_status;
END set_check_status;
--*********************************************************
--
--  print_clob
--
--*********************************************************
PROCEDURE print_clob(
    p_clob IN CLOB )
IS
  v_offset      NUMBER DEFAULT 1;
  v_chunk_size  NUMBER := 10000;
  v_clob_length NUMBER;
BEGIN
--dbms_output.put_line('DEBUG:  print_clob:  IN');
  v_clob_length := dbms_lob.getlength(p_clob);
  --  dbms_output.put_line('DEBUG:  print_clob - clob length ['||v_clob_length||']');
  LOOP
    EXIT
  WHEN v_offset > v_clob_length;
    dbms_output.put_line( dbms_lob.substr( p_clob, v_chunk_size, v_offset ) );
    v_offset := v_offset + v_chunk_size;
  END LOOP;
-- dbms_output.put_line('DEBUG:  print_clob:  OUT');
END print_clob;
--*********************************************************
--
--  XMLtoHTML
--
--*********************************************************
PROCEDURE XMLtoHTML(
    p_msg_num NUMBER,
    rf SYS_REFCURSOR,
    p_xml_str OUT CLOB,
    p_html_str OUT CLOB)
IS
  v_html_output XMLType;
  v_xsl CLOB := '';
  v_xml_data XMLType;
  v_context DBMS_XMLGEN.CTXHANDLE;
  v_hdr_str CLOB := '';
BEGIN
--  dbms_output.put_line('DEBUG:  XMLtoHTML -BEGIN: msg_num ['||p_msg_num||']  name ['||t_message(p_msg_num).msg_name||']  msg_query_count ['||t_message(p_msg_num).msg_query_count||']  msg_query_fetch ['||t_message(p_msg_num).msg_query_fetch||']' );
  -- get a handle on the ref cursor --
  v_context := DBMS_XMLGEN.NEWCONTEXT(rf);
  -- setNullHandling to 1 (or 2) to allow null columns to be displayed --
  DBMS_XMLGEN.setNullHandling(v_context,1);
  -- create XML from ref cursor --
  v_xml_data := DBMS_XMLGEN.GETXMLTYPE(v_context,DBMS_XMLGEN.NONE);
  -- this is a generic XSL for Oracle's default XML row and rowset tags --
  -- " " is a non-breaking space --
  v_xsl := v_xsl || q'[<?xml version="1.0" encoding="ISO-8859-1"?>]';
  v_xsl := v_xsl || q'[<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">]';
  v_xsl := v_xsl || q'[ <xsl:output method="html"/>]';
  v_xsl := v_xsl || q'[ <xsl:template match="/">]';
  v_xsl := v_xsl || q'[   <table border="1">]';
  v_xsl := v_xsl || q'[     <tr bgcolor="cyan">]';
  v_xsl := v_xsl || q'[      <xsl:for-each select="/ROWSET/ROW[1]/*">]';
  v_xsl := v_xsl || q'[       <th><xsl:value-of select="name()"/></th>]';
  v_xsl := v_xsl || q'[      </xsl:for-each>]';
  v_xsl := v_xsl || q'[     </tr>]';
  v_xsl := v_xsl || q'[     <xsl:for-each select="/ROWSET/*">]';
  v_xsl := v_xsl || q'[      <tr>]';
  v_xsl := v_xsl || q'[       <xsl:for-each select="./*">]';
  v_xsl := v_xsl || q'[        <td><xsl:value-of select="text()"/> </td>]';
  v_xsl := v_xsl || q'[       </xsl:for-each>]';
  v_xsl := v_xsl || q'[      </tr>]';
  v_xsl := v_xsl || q'[     </xsl:for-each>]';
  v_xsl := v_xsl || q'[   </table>]';
  v_xsl := v_xsl || q'[ </xsl:template>]';
  v_xsl := v_xsl || q'[</xsl:stylesheet>]';
  -- XSL transformation to convert XML to HTML --
--    dbms_output.put_line('DEBUG:  p_msg_num ['||p_msg_num||'] XMLtoHTML - v_xsl ['||v_xsl||']' );
  v_html_output := v_xml_data.transform(XMLType(v_xsl));
  -- convert XMLType to Clob --
  p_xml_str := v_xml_data.getClobVal();
  p_html_str := v_html_output.getClobVal();
  v_hdr_str := v_hdr_str || '<H1><a name="'||t_message(p_msg_num).msg_bookmark||'">' ||t_message(p_msg_num).msg_title || '</a></H1>' || chr(13) || chr(10);
  v_hdr_str := v_hdr_str || '<p>' || t_message(p_msg_num).msg_query_fetch || '</p>' || chr(13) || chr(10);
  p_html_str := v_hdr_str || p_html_str || '<br>' || chr(13) || chr(10);
  t_message(p_msg_num).msg_body_html := p_html_str;
  t_message(p_msg_num).msg_body_xml := p_xml_str;
--    dbms_output.put_line('DEBUG:  XMLtoHTML - OUT' );

END XMLtoHTML;
--*********************************************************
--
--  write_html_hdr
--
--*********************************************************
PROCEDURE write_html_hdr(
    p_report_title IN VARCHAR2)
IS
  v_html_hdr VARCHAR2(32767) := '';
BEGIN
  v_html_hdr := v_html_hdr || '<HTML>'|| chr(13) || chr(10);
  v_html_hdr := v_html_hdr || '<HEAD>'|| chr(13) || chr(10);
  v_html_hdr := v_html_hdr || '<TITLE>'||p_report_title||'</TITLE>'|| chr(13) || chr(10);
  v_html_hdr := v_html_hdr || '<style>'|| chr(13) || chr(10);
  v_html_hdr := v_html_hdr || 'body {font-size:1em;font-family: Arial,Helvetica,sans-serif; color:#000; background:#fff;}'|| chr(13) || chr(10);
  v_html_hdr := v_html_hdr || 'p {font-size:1em; color:#000; background:#fff;}'|| chr(13) || chr(10);
  v_html_hdr := v_html_hdr || 'table,tr {font-size:.9em; color:#000; background:#f7f7e7; padding:3px; margin:3px; border-collapse: collapse;}'|| chr(13) || chr(10);
  v_html_hdr := v_html_hdr || 'table, td {padding: 3px 7px;}'|| chr(13) || chr(10);
  v_html_hdr := v_html_hdr || 'th {font-weight:bold; font-size:1em; color:#336699; background:#cccc99; padding:3px; border: 1px solid #000}'|| chr(13) || chr(10);
  v_html_hdr := v_html_hdr || 'h1 {font-weight:bold;font-size:1em; color:#336699; background-color:#fff; border-bottom:0px solid #cccc99; margin-top:0pt; margin-bottom:0pt; padding:0px;}'|| chr(13) || chr(10);
  v_html_hdr := v_html_hdr || 'h1:first-child {padding-bottom: 21px;}'|| chr(13) || chr(10);
  v_html_hdr := v_html_hdr || 'h2 {font-weight:bold; font-size:10pt; color:#336699; background-color:#fff; margin-top:3pt; margin-bottom:0pt;}'|| chr(13) || chr(10);
  v_html_hdr := v_html_hdr || 'a {font-size:1em; color:#663300; background:#ffffff; margin-top:0pt; margin-bottom:0pt; vertical-align:top;}'|| chr(13) || chr(10);
  v_html_hdr := v_html_hdr || '.info {color:#000; background: #99ff66;font-weight: bold;}'|| chr(13) || chr(10);
  v_html_hdr := v_html_hdr || '.fail {color:#000; background: #ff5050; font-weight: bold;}'|| chr(13) || chr(10);
  v_html_hdr := v_html_hdr || '.pass {color:#000; background: #99ff66;font-weight: bold;}'|| chr(13) || chr(10);
  v_html_hdr := v_html_hdr || '.warn {color:#000; background: #ffff66;font-weight: bold;}'|| chr(13) || chr(10);
  v_html_hdr := v_html_hdr || '.error {color:#000; background: #ffff66;font-weight: bold;}'|| chr(13) || chr(10);
  v_html_hdr := v_html_hdr || 'table.data { border-collapse: collapse; border: 1px solid #000; }'|| chr(13) || chr(10);
  v_html_hdr := v_html_hdr || '.data tr:nth-child(odd){ background-color: #cbcb9c;}'|| chr(13) || chr(10);
  v_html_hdr := v_html_hdr || '.data td {border: 1px solid #000;}'|| chr(13) || chr(10);
  v_html_hdr := v_html_hdr || '</style>'|| chr(13) || chr(10);
  v_html_hdr := v_html_hdr || '</HEAD>'|| chr(13) || chr(10);
  v_html_hdr := v_html_hdr || '<BODY>'|| chr(13) || chr(10);
  v_html_hdr := v_html_hdr || '<H1>'||p_report_title||'</H1>'|| chr(13) || chr(10);
  dbms_output.put_line(v_html_hdr);
END write_html_hdr;
--*********************************************************
--
--  write_html_msg
--
--*********************************************************
PROCEDURE write_html_msg(
    p_max_msg_num NUMBER,
    p_full_output_str OUT VARCHAR2)
IS
  v_html_msg     VARCHAR2(32767) := '';
  v_xml_msg      VARCHAR2(32767) := '';
  v_mod_html_msg VARCHAR2(32767) := '';
  v_mod_xml_msg  VARCHAR2(32767) := '';
  v_do_not_print NUMBER := 0;
BEGIN

--DBMS_OUTPUT.put_line('DEBUG:  write_html_msg: IN');
  p_full_output_str := '';

  FOR j IN 1..p_max_msg_num
  LOOP
--    dbms_output.put_line('DEBUG:  write_html_msg:  Max_msg_num: ['||p_max_msg_num||']   Cur_msg_num: ['||j||']  name: ['||t_message(j).msg_title||']  name: ['||t_message(j).check_status||']   name: ['||t_message(j).msg_type||']');
    v_html_msg := '';
    v_xml_msg := '';
    IF (t_message(j).check_status = 'FAIL') THEN
      v_mod_html_msg :=(REPLACE(t_message(j).msg_fail,'[[NL]]','<br>'|| chr(13)||chr(10)));
      v_mod_xml_msg := (REPLACE(t_message(j).msg_fail,'[[NL]]', chr(13)||chr(10)));
      p_full_output_str := p_full_output_str || t_message(j).msg_title ||'[[NL]]' || 'Check Status: ' || t_message(j).check_status || '[[NL]]' || t_message(j).msg_fail || '[[NL]]';
    ELSIF ((t_message(j).check_status = 'PASS') OR (t_message(j).check_status = 'WARN') OR (t_message(j).check_status = 'INFO')) THEN
      v_mod_html_msg :=(REPLACE(t_message(j).msg_pass,'[[NL]]','<br>'|| chr(13)||chr(10)));
      v_mod_xml_msg := (REPLACE(t_message(j).msg_pass,'[[NL]]', chr(13)||chr(10)));
    ELSIF (t_message(j).check_status = 'NA') THEN
      v_mod_html_msg :=(REPLACE(t_message(j).msg_body,'[[NL]]','<br>'|| chr(13)||chr(10)));
      v_mod_xml_msg := (REPLACE(t_message(j).msg_body,'[[NL]]', chr(13)||chr(10)));
    ELSE
      v_mod_html_msg := 'The check did not run as expected.'|| '<br>'|| chr(13)||chr(10);
      v_mod_xml_msg := 'The check did not run as expected.' || chr(13)||chr(10);
    END IF;
    IF t_message(j).msg_type = 'data' THEN
      v_html_msg := v_html_msg || '<H1>'||t_message(j).msg_title||'</H1>'|| chr(13) || chr(10);
      v_html_msg := v_html_msg || '<TABLE BORDER="1">'|| chr(13) || chr(10);
      v_html_msg := v_html_msg || '<TR><TH>'||t_message(j).msg_title||'</TH></TR>'|| chr(13) || chr(10);
      v_html_msg := v_html_msg || '<TR>'|| chr(13) || chr(10);
      v_html_msg := v_html_msg || '<TD>'||v_mod_html_msg||'</TD>' || chr(13) || chr(10);
      v_html_msg := v_html_msg || '</TR>'|| chr(13) || chr(10);
      v_html_msg := v_html_msg || '</TABLE>'|| chr(13) || chr(10);
      v_html_msg := v_html_msg || '<br>'|| chr(13) || chr(10);
      v_xml_msg := v_xml_msg || '<RESULT>'|| chr(13) || chr(10);
      v_xml_msg := v_xml_msg || '<RESULT_NAME>'||t_message(j).msg_title|| '</RESULT_NAME>'|| chr(13) || chr(10);
      v_xml_msg := v_xml_msg || '<RESULT_STATUS>'||t_message(j).check_status|| '</RESULT_STATUS>'|| chr(13) || chr(10);
      v_xml_msg := v_xml_msg || '<RESULT_MSG>'||v_mod_xml_msg|| '</RESULT_MSG>'|| chr(13) || chr(10);
      v_xml_msg := v_xml_msg || '</RESULT>'|| chr(13) || chr(10);
    ELSIF t_message(j).msg_type = 'message' THEN
      v_html_msg := v_html_msg || '<H1>'||t_message(j).msg_title||'</H1>'|| chr(13) || chr(10);
      v_html_msg := v_html_msg || '<TABLE BORDER="1">'|| chr(13) || chr(10);
      v_html_msg := v_html_msg || '<TR><TH>'||t_message(j).msg_title||'</TH></TR>'|| chr(13) || chr(10);
      v_html_msg := v_html_msg || '<TR>'|| chr(13) || chr(10);
      v_html_msg := v_html_msg || '<TD class="'||lower(t_message(j).check_status)||'"> Check Status:  '||t_message(j).check_status||'</TD>' || chr(13) || chr(10);
      v_html_msg := v_html_msg || '</TR>'|| chr(13) || chr(10);
      v_html_msg := v_html_msg || '<TR>'|| chr(13) || chr(10);
      v_html_msg := v_html_msg || '<TD>' || chr(13) || chr(10);
      v_html_msg := v_html_msg || v_mod_html_msg || '<br>' || chr(13) || chr(10);
      v_html_msg := v_html_msg || 'Click <a href="#'||t_message(j).msg_bookmark||'">here</a> to view the data from '||t_message(j).msg_table||'.<br>'|| chr(13) || chr(10);
      v_html_msg := v_html_msg || '</TD>' || chr(13) || chr(10);
      v_html_msg := v_html_msg || '</TR>'|| chr(13) || chr(10);
      v_html_msg := v_html_msg || '</TABLE>'|| chr(13) || chr(10);
      v_html_msg := v_html_msg || '<br>'|| chr(13) || chr(10);
      v_xml_msg := v_xml_msg || '<RESULT>'|| chr(13) || chr(10);
      v_xml_msg := v_xml_msg || '<RESULT_NAME>'||t_message(j).msg_title|| '</RESULT_NAME>'|| chr(13) || chr(10);
      v_xml_msg := v_xml_msg || '<RESULT_STATUS>'||t_message(j).check_status|| '</RESULT_STATUS>'|| chr(13) || chr(10);
      v_xml_msg := v_xml_msg || '<RESULT_MSG>'||v_mod_xml_msg|| '</RESULT_MSG>'|| chr(13) || chr(10);
      v_xml_msg := v_xml_msg || '</RESULT>'|| chr(13) || chr(10);
    ELSIF t_message(j).msg_type = 'rpt_info' THEN
      v_html_msg := v_html_msg || '<TABLE BORDER="1">'|| chr(13) || chr(10);
      v_html_msg := v_html_msg || '<TR><TH>'||t_message(j).msg_title||'</TH></TR>'|| chr(13) || chr(10);
      v_html_msg := v_html_msg || '<TR>'|| chr(13) || chr(10);
      v_html_msg := v_html_msg || '<TD> Check Status:  '||t_message(j).check_status||'</TD>' || chr(13) || chr(10);
      v_html_msg := v_html_msg || '</TR>'|| chr(13) || chr(10);
      v_html_msg := v_html_msg || '<TR>'|| chr(13) || chr(10);
      v_html_msg := v_html_msg || '<TD>'||v_mod_html_msg||'</TD>' || chr(13) || chr(10);
      v_html_msg := v_html_msg || '</TR>'|| chr(13) || chr(10);
      v_html_msg := v_html_msg || '</TABLE>'|| chr(13) || chr(10);
      v_html_msg := v_html_msg || '<br>'|| chr(13) || chr(10);
      v_xml_msg := v_xml_msg || '<REPORT_DETAILS>'|| chr(13) || chr(10);
      v_xml_msg := v_xml_msg || '<DETAIL_NAME>'||t_message(j).msg_title|| '</DETAIL_NAME>'|| chr(13) || chr(10);
      v_xml_msg := v_xml_msg || '<DETAIL_MSG>'||v_mod_xml_msg|| '</DETAIL_MSG>'|| chr(13) || chr(10);
      v_xml_msg := v_xml_msg || '</REPORT_DETAILS>'|| chr(13) || chr(10);
    END IF;
    t_message(j).msg_body_xml := v_xml_msg;
    IF ((t_message(j).check_status = 'PASS') AND (upper(SUBSTR(t_message(j).msg_title,1,3)) = 'BUG')) THEN
      v_do_not_print := 1;
    ELSE
      dbms_output.put_line(v_html_msg);
    END IF;
--        dbms_output.put_line('DEBUG:  write_html_msg:  Out of Loop');
  END LOOP;
--  DBMS_OUTPUT.put_line('DEBUG:  write_html_msg: OUT');
END write_html_msg;

--*********************************************************
--
--  write_html_query_output
--
--*********************************************************
PROCEDURE write_html_query_output(
    p_max_msg_num NUMBER)
IS
  --  v_msg_str_fail VARCHAR2(1000) := '';
  v_item_found NUMBER := 0;

BEGIN
--  DBMS_OUTPUT.put_line('DEBUG:  write_html_query_output: IN');
  FOR j IN 1..p_max_msg_num
  LOOP
--    DBMS_OUTPUT.put_line('DEBUG:  write_html_query_output: inside loop '||t_message(j).msg_name);
	p_check_name := t_message(j).msg_name;
    IF ((t_message(j).msg_type = 'query') AND (t_message(j).print_msg = 1)) THEN
      item_found:=0;
--    DBMS_OUTPUT.put_line('DEBUG:  write_html_query_output: inside IF '||t_message(j).msg_name);
--      DBMS_OUTPUT.put_line('DEBUG:  message title ['||t_message(j).msg_title||']');
      OPEN l_cursor FOR t_message(j).msg_query_count;
      FETCH l_cursor
      INTO v_item_found;
      CLOSE l_cursor;
      IF (v_item_found > 0) THEN
--          DBMS_OUTPUT.put_line('DEBUG:  write_html_query_output: count found - in ['||t_message(j).msg_name ||']');
        OPEN l_cursor FOR t_message(j).msg_query_fetch;
--        DBMS_OUTPUT.put_line('DEBUG:  write_html_query_output: before XMLtoHTML');
        XMLtoHTML(j,l_cursor,the_xml,the_html);
--        DBMS_OUTPUT.put_line('DEBUG:  write_html_query_output: before print_clob');
        print_clob(t_message(j).msg_body_html);
        CLOSE l_cursor;
--        DBMS_OUTPUT.put_line('DEBUG:  write_html_query_output: count found - out '||t_message(j).msg_name);
      ELSE
        t_message(j).print_msg := 1;
        t_message(j).msg_body_html := '';
        t_message(j).msg_body_html := t_message(j).msg_body_html || '<H1><a name="'||t_message(j).msg_bookmark||'">' ||t_message(j).msg_title || '</a></H1>' || chr(13) || chr(10);
        t_message(j).msg_body_html := t_message(j).msg_body_html || '<p>' || t_message(j).msg_query_fetch || '</p>' || chr(13) || chr(10);
        t_message(j).msg_body_html := t_message(j).msg_body_html || '<TABLE BORDER="1">'|| chr(13) || chr(10);
        t_message(j).msg_body_html := t_message(j).msg_body_html || '<TR><TH>'||t_message(j).msg_title||'</TH></TR>'|| chr(13) || chr(10);
        t_message(j).msg_body_html := t_message(j).msg_body_html || '<TR>'|| chr(13) || chr(10);
        t_message(j).msg_body_html := t_message(j).msg_body_html || '<TD>No data found</TD>' || chr(13) || chr(10);
        t_message(j).msg_body_html := t_message(j).msg_body_html || '</TR>'|| chr(13) || chr(10);
        t_message(j).msg_body_html := t_message(j).msg_body_html || '</TABLE>'|| chr(13) || chr(10);
        t_message(j).msg_body_html := t_message(j).msg_body_html || '<br>'|| chr(13) || chr(10);
        DBMS_OUTPUT.put_line(t_message(j).msg_body_html);
        t_message(j).msg_body_xml := '';
        t_message(j).msg_body_xml := t_message(j).msg_body_xml || 'No data found' || chr(13) || chr(10);
      END IF;
--          DBMS_OUTPUT.put_line('DEBUG:  write_html_query_output: exiting IF '||t_message(j).msg_name);
    END IF;
--    DBMS_OUTPUT.put_line('DEBUG:  write_html_query_output: OUT OF LOOP');
  END LOOP;
--    DBMS_OUTPUT.put_line('DEBUG:  write_html_query_output: OUT');

EXCEPTION
WHEN NO_DATA_FOUND THEN
DBMS_OUTPUT.put_line('No data found FOR the query against the following TABLE:  ' || l_cur_table);
WHEN OTHERS THEN -- handles all other errors
IF SQLCODE = -10027 THEN
DBMS_OUTPUT.put_line('Buffer Overflow : [' || l_cur_table ||']');
ELSIF SQLCODE = -00942 THEN
DBMS_OUTPUT.put_line('TABLE OR VIEW does NOT exist : [' || l_cur_table ||']');
ELSIF SQLCODE = -00376 THEN
DBMS_OUTPUT.put_line('TABLE OR VIEW does NOT exist : [' || l_cur_table ||']');
ELSE
DBMS_OUTPUT.put_line('Other Error in write_html_query_output: Check with error: ['|| p_check_name ||']  Table used by check: [' || l_cur_table ||']');
DBMS_OUTPUT.put_line('SQLCODE : [' || SQLCODE ||']');
DBMS_OUTPUT.put_line('MESSAGE : [' || SQLERRM ||']');
END IF;

END write_html_query_output;
--*********************************************************
--
--  write_xml
--
--*********************************************************
PROCEDURE write_xml(
    p_max_msg_num IN NUMBER)
IS
  v_xml_str CLOB := '';
BEGIN
--    DBMS_OUTPUT.put_line('DEBUG:  write_xml: BEGIN');
  v_xml_str := v_xml_str || '<!-- ######BEGIN DX SUMMARY######' || chr(13) || chr(10);
  v_xml_str := v_xml_str || '<diagnostic>' || chr(13) || chr(10);
  v_xml_str := v_xml_str || '<REPORT_DETAIL_SET>' || chr(13) || chr(10);
  dbms_output.put_line(v_xml_str);
  FOR j IN 1..p_max_msg_num
  LOOP
    v_xml_str := '';
    IF ((t_message(j).msg_type = 'rpt_info') AND (t_message(j).print_msg = 1)) THEN
      v_xml_str := t_message(j).msg_body_xml || chr(13) || chr(10);
      DBMS_OUTPUT.put_line(v_xml_str);
      -- print_clob(v_xml_str);
    END IF;
  END LOOP;
  v_xml_str := '';
  v_xml_str := v_xml_str || '</REPORT_DETAIL_SET>' || chr(13) || chr(10);
  v_xml_str := v_xml_str || '<RESULT_SET>' || chr(13) || chr(10);
  dbms_output.put_line(v_xml_str);
  FOR j IN 1..p_max_msg_num
  LOOP
--      DBMS_OUTPUT.put_line('DEBUG:  write_xml: DATA LOOP j=['||j||']');
    v_xml_str := '';
    IF (((t_message(j).msg_type = 'data') OR (t_message(j).msg_type = 'message')) AND (t_message(j).print_msg = 1)) THEN
      v_xml_str := t_message(j).msg_body_xml || chr(13) || chr(10);
      DBMS_OUTPUT.put_line(v_xml_str);
      -- print_clob(v_xml_str);
    END IF;
  END LOOP;
  v_xml_str := '';
  v_xml_str := v_xml_str || '</RESULT_SET>' || chr(13) || chr(10);
  v_xml_str := v_xml_str || '<DATA_SET>' || chr(13) || chr(10);
  dbms_output.put_line(v_xml_str);
  v_xml_str := '';
  FOR j IN 1..p_max_msg_num
  LOOP
--        DBMS_OUTPUT.put_line('DEBUG:  write_xml: QUERY LOOP j=['||j||']');
    v_xml_str := '';
    IF ((t_message(j).msg_type = 'query') AND (t_message(j).print_msg = 1)) THEN
      l_cur_table := 'write_v_xml_str - QUERY: [' || t_message(j).msg_title ||'] SQL: ['||t_message(j).msg_query_fetch||']';
      v_xml_str := v_xml_str || '<DATA>' || chr(13) || chr(10);
      v_xml_str := v_xml_str || '<TABLE_NAME>'|| t_message(j).msg_title ||'</TABLE_NAME>'|| chr(13) || chr(10);
      v_xml_str := v_xml_str || '<QUERY>'|| t_message(j).msg_query_fetch ||'</QUERY>'|| chr(13) || chr(10);
      v_xml_str := v_xml_str || '<QUERY_RESULTS>'|| chr(13) || chr(10);
      v_xml_str := v_xml_str || t_message(j).msg_body_xml;
      v_xml_str := v_xml_str || '</QUERY_RESULTS>'|| chr(13) || chr(10);
      v_xml_str := v_xml_str || '</DATA>' || chr(13) || chr(10);
      print_clob(v_xml_str);
    END IF;
  END LOOP;
  v_xml_str := '';
  v_xml_str := v_xml_str || '</DATA_SET>' || chr(13) || chr(10);
  v_xml_str := v_xml_str || '</diagnostic>' || chr(13) || chr(10);
  v_xml_str := v_xml_str || ' ######END DX SUMMARY######-->' || chr(13) || chr(10);
  dbms_output.put_line(v_xml_str);
--      DBMS_OUTPUT.put_line('DEBUG:  write_xml: OUT');
END write_xml;
--*********************************************************
--
--  write_html_end
--
--*********************************************************
PROCEDURE write_html_end
IS
  v_html_end CLOB := '';
BEGIN
  v_html_end := v_html_end || '</BODY>'|| chr(13) || chr(10);
  v_html_end := v_html_end || '</HTML>'|| chr(13) || chr(10);
  dbms_output.put_line(v_html_end);
END write_html_end;

--*********************************************************
--
--  check_data
--
--*********************************************************
PROCEDURE check_data(
    p_check IN VARCHAR2,
    p_script_selected IN VARCHAR2)
IS
  check_status VARCHAR(10);
  temp_value VARCHAR(200);
  item_found NUMBER := 0;
BEGIN
  p_check_name := p_check;
  CASE
    --*********************************************************
    --
    --  V$INSTANCE DATA
    --
    --*********************************************************
--  VLC modified on 8/14/16 Added data collection
  WHEN p_check = 'V_INSTANCE_DATA' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'V$INSTANCE';
    l_bookmark := 'V_INSTANCE_DATA';
    msg_num := msg_num + 1;
    msg_query_fetch := '';
    msg_query_count := '';
--    msg_query_fetch := msg_query_fetch || 'SELECT INSTANCE_NAME, HOST_NAME, VERSION, SUBSTR(VERSION,1,2), TO_CHAR(SYSDATE,''YYYYMMDD_HH24MISS''), TO_CHAR(STARTUP_TIME, ''DD-MON-YY HH:MI:SS AM''), TO_CHAR(SYSDATE,''YYYY-MM-DD HH24:MI:SS'') FROM V$INSTANCE';
    msg_query_fetch := msg_query_fetch || 'SELECT INSTANCE_NAME, HOST_NAME, VERSION, SUBSTR(VERSION,1,2)  db_version_short, TO_CHAR(SYSDATE,''YYYYMMDD_HH24MISS'')  cur_date, TO_CHAR(STARTUP_TIME, ''DD-MON-YY HH:MI:SS AM'')  startup_time, TO_CHAR(SYSDATE,''YYYY-MM-DD HH24:MI:SS'') report_time  FROM V$INSTANCE';
    msg_query_count := msg_query_count || 'SELECT COUNT(*) FROM V$INSTANCE';
    store_table_data (msg_num,1,'NA','query',l_cur_table,l_cur_table,'','','',msg_query_fetch,msg_query_count,'','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  V$PARAMETER Checks
    --
    --*********************************************************
--  VLC modified on 8/14/16 Added parameter AQ_TM_PROCESS to the list
  WHEN p_check = 'V_PARAMETER_DATA' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'V$PARAMETER';
    l_bookmark := 'V_PARAMETER_DATA';
    msg_num := msg_num + 1;
    msg_query_fetch := '';
    msg_query_count := '';
    msg_query_fetch := msg_query_fetch || 'SELECT name, value FROM v$parameter WHERE upper(name) in (''COMPATIBLE'',''JOB_QUEUE_PROCESSES'',''RESOURCE_LIMIT'',''STATISTICS_LEVEL'',''RESOURCE_MANAGER_PLAN'',''AQ_TM_PROCESS'')';
    msg_query_count := msg_query_count || 'SELECT COUNT(*) FROM v$parameter WHERE upper(name) in (''COMPATIBLE'',''JOB_QUEUE_PROCESSES'',''RESOURCE_LIMIT'',''STATISTICS_LEVEL'',''RESOURCE_MANAGER_PLAN'',''AQ_TM_PROCESS'')';
    store_table_data (msg_num,1,'NA','query',l_cur_table,l_cur_table,'','','',msg_query_fetch,msg_query_count,'','',l_cur_table,l_bookmark);

    --*********************************************************
    --
    --  DBA_JOBS DATA COLLECTION
    --
    --*********************************************************
  WHEN p_check = 'DBA_JOBS_DATA' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_JOBS';
    l_bookmark := 'DBA_JOBS_DATA';
    msg_num := msg_num + 1;
    msg_query_fetch := '';
    msg_query_count := '';
    msg_query_fetch := msg_query_fetch || 'SELECT job, What,priv_user,schema_user, last_date, Next_Date, Interval,Failures FROM DBA_JOBS ORDER BY LAST_DATE DESC';
    msg_query_count := msg_query_count || 'SELECT COUNT(*) FROM DBA_JOBS';
    store_table_data (msg_num,1,'NA','query',l_cur_table,l_cur_table,'','','',msg_query_fetch,msg_query_count,'','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  DBA_JOBS_RUNNING DATA COLLECTION
    --
    --*********************************************************
  WHEN p_check = 'DBA_JOBS_RUNNING_DATA' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_JOBS_RUNNING';
    l_bookmark := 'DBA_JOBS_RUNNING_DATA';
    msg_num := msg_num + 1;
    msg_query_fetch := '';
    msg_query_count := '';
    msg_query_fetch := msg_query_fetch || 'SELECT SID as Session_ID, job, this_Date, instance, failures from DBA_JOBS_RUNNING';
    msg_query_count := msg_query_count || 'SELECT COUNT(*) from DBA_JOBS_RUNNING';
    store_table_data (msg_num,1,'NA','query',l_cur_table,l_cur_table,'','','',msg_query_fetch,msg_query_count,'','',l_cur_table,l_bookmark);

     --*********************************************************
    --
    --  SESSIONTIMEZONE DATA COLLECTION
    --
    --*********************************************************
  WHEN p_check = 'SESSIONTIMEZONE_DATA' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'SESSIONTIMEZONE';
    l_bookmark := 'SESSIONTIMEZONE_DATA';
    msg_num := msg_num + 1;
    msg_query_fetch := '';
    msg_query_count := '';
    msg_query_fetch := msg_query_fetch || 'SELECT SESSIONTIMEZONE FROM DUAL';
    msg_query_count := msg_query_count || 'SELECT COUNT(*) FROM DUAL';
    store_table_data (msg_num,1,'NA','query',l_cur_table,l_cur_table,'','','',msg_query_fetch,msg_query_count,'','',l_cur_table,l_bookmark);

    --*********************************************************
    --
    --  DBMS_SCHEDULER.STIME DATA COLLECTION
    --
    --*********************************************************
  WHEN p_check = 'DBMS_SCHEDULER_STIME_DATA' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBMS_SCHEDULER.STIME';
    l_bookmark := 'DBMS_SCHEDULER_STIME_DATA';
    msg_num := msg_num + 1;
    msg_query_fetch := '';
    msg_query_count := '';
    msg_query_fetch := msg_query_fetch || 'SELECT DBMS_SCHEDULER.STIME FROM DUAL';
    msg_query_count := msg_query_count || 'SELECT COUNT(*) FROM DUAL GROUP BY DBMS_SCHEDULER.STIME';
    store_table_data (msg_num,1,'NA','query',l_cur_table,l_cur_table,'','','',msg_query_fetch,msg_query_count,'','',l_cur_table,l_bookmark);

    --*********************************************************
    --
    --  DBA_SCHEDULER_GLOBAL_ATTRIBUTE SCHEDULER DATA COLLECTION
    --
    --*********************************************************
  WHEN p_check = 'DBA_SCHEDULER_GLOBAL_ATTRIBUTE_DATA' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_GLOBAL_ATTRIBUTE';
    l_bookmark := 'DBA_SCHEDULER_GLOBAL_ATTRIBUTE_DATA';
    msg_num := msg_num + 1;
    msg_query_fetch := '';
    msg_query_count := '';
    msg_query_fetch := msg_query_fetch || 'SELECT * FROM DBA_SCHEDULER_GLOBAL_ATTRIBUTE';
    msg_query_count := msg_query_count || 'SELECT COUNT(*) FROM DBA_SCHEDULER_GLOBAL_ATTRIBUTE';
    store_table_data (msg_num,1,'NA','query',l_cur_table,l_cur_table,'','','',msg_query_fetch,msg_query_count,'','',l_cur_table,l_bookmark);

    --*********************************************************
    --
    --  DBA_OBJECTS DBMS_SCHEDULER DATA COLLECTION
    --
    --*********************************************************
  WHEN p_check = 'DBA_OBJECTS_DBMS_SCHEDULER_DATA' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_OBJECTS';
    l_bookmark := 'DBA_OBJECTS_DBMS_SCHEDULER_DATA';
    msg_num := msg_num + 1;
    msg_query_fetch := '';
    msg_query_count := '';
    msg_query_fetch := msg_query_fetch || 'SELECT * FROM DBA_OBJECTS WHERE OBJECT_NAME = ''DBMS_SCHEDULER''';
    msg_query_count := msg_query_count || 'SELECT COUNT(*) FROM DBA_OBJECTS WHERE OBJECT_NAME = ''DBMS_SCHEDULER''';
    store_table_data (msg_num,1,'NA','query',l_cur_table,l_cur_table,'','','',msg_query_fetch,msg_query_count,'','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  DBA_OBJECTS JOB DATA COLLECTION
    --
    --*********************************************************
  WHEN p_check = 'DBA_OBJECTS_JOB_DATA' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_OBJECTS';
    l_bookmark := 'DBA_OBJECTS_JOB_DATA';
    msg_num := msg_num + 1;
    msg_query_fetch := '';
    msg_query_count := '';
    msg_query_fetch := msg_query_fetch || 'SELECT * FROM dba_objects WHERE object_type = ''JOB''';
    msg_query_count := msg_query_count || 'SELECT COUNT(*) FROM dba_objects WHERE object_type = ''JOB''';
    store_table_data (msg_num,1,'NA','query',l_cur_table,l_cur_table,'','','',msg_query_fetch,msg_query_count,'','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  DBA_SCHEDULER_RUNNING_JOBS DATA COLLECTION
    --
    --*********************************************************
  WHEN p_check = 'DBA_SCHEDULER_RUNNING_JOBS_DATA' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_RUNNING_JOBS';
    l_bookmark := 'DBA_SCHEDULER_RUNNING_JOBS_DATA';
    msg_num := msg_num + 1;
    msg_query_fetch := '';
    msg_query_count := '';
IF (p_script_selected = 'JOB_EXECUTION') THEN
    msg_query_fetch := msg_query_fetch || 'SELECT JOB_NAME,SESSION_ID,SLAVE_PROCESS_ID,SLAVE_OS_PROCESS_ID,RUNNING_INSTANCE,RESOURCE_CONSUMER_GROUP FROM DBA_SCHEDULER_RUNNING_JOBS';
    ELSE
    msg_query_fetch := msg_query_fetch || 'SELECT * FROM DBA_SCHEDULER_RUNNING_JOBS';
END IF;
    msg_query_count := msg_query_count || 'SELECT COUNT(*) FROM DBA_SCHEDULER_RUNNING_JOBS';
    store_table_data (msg_num,1,'NA','query',l_cur_table,l_cur_table,'','','',msg_query_fetch,msg_query_count,'','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  DBA_SCHEDULER_JOBS DATA COLLECTION
    --  The columns FILE_WATCHER_NAME and FILE_WATCHER_OWNER do not exist in 11.1.
    --  They do exist in 11.2 and 12c.
    --
    --*********************************************************
--  VLC fixed on 07/26/16 - added DB version check to avoid the  errors  ORA-00904: "FILE_WATCHER_NAME": invalid identifier ORA-06550: on DB Version 11
  WHEN p_check = 'DBA_SCHEDULER_JOBS_DATA' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_JOBS';
    l_bookmark := 'DBA_SCHEDULER_JOBS_DATA';
    msg_num := msg_num + 1;
    msg_query_fetch := '';
    msg_query_count := '';
    IF (p_script_selected = 'JOB_CONFIGURATION') THEN
      IF ((chkVersion(db_version, '11.2',2) = 'EQ') OR (chkVersion(db_version, '11.2',2) = 'GT')) THEN
        msg_query_fetch := msg_query_fetch || 'SELECT OWNER, JOB_NAME, JOB_STYLE, JOB_TYPE, JOB_ACTION, START_DATE, REPEAT_INTERVAL, LAST_START_DATE, NEXT_RUN_DATE, LOGGING_LEVEL, INSTANCE_ID, PROGRAM_NAME, SCHEDULE_NAME, FILE_WATCHER_NAME,FILE_WATCHER_OWNER  FROM DBA_SCHEDULER_JOBS';
      ELSE
        msg_query_fetch := msg_query_fetch || 'SELECT OWNER, JOB_NAME, JOB_STYLE, JOB_TYPE, JOB_ACTION, START_DATE, REPEAT_INTERVAL, LAST_START_DATE, NEXT_RUN_DATE, LOGGING_LEVEL, PROGRAM_NAME, SCHEDULE_NAME  FROM DBA_SCHEDULER_JOBS';
      END IF;
      msg_query_count := msg_query_count || 'SELECT COUNT(*) FROM DBA_SCHEDULER_JOBS';
    ELSIF (p_script_selected = 'JOB_AUTOTASK') THEN
      msg_query_fetch := msg_query_fetch || 'SELECT OWNER, JOB_NAME, SCHEDULE_NAME, SCHEDULE_TYPE,AUTO_DROP,  RESTARTABLE, STATE, RUN_COUNT, MAX_RUNS, FAILURE_COUNT, RETRY_COUNT,LAST_START_DATE,LAST_RUN_DURATION,NEXT_RUN_DATE,INSTANCE_STICKINESS,CREDENTIAL_OWNER,CREDENTIAL_NAME FROM DBA_SCHEDULER_JOBS WHERE job_name IN (''AUTO_SPACE_ADVISOR_JOB'',''GATHER_STATS_JOB'')';
      msg_query_count := msg_query_count || 'SELECT COUNT(*) FROM DBA_SCHEDULER_JOBS WHERE job_name IN (''AUTO_SPACE_ADVISOR_JOB'',''GATHER_STATS_JOB'')';
    ELSIF (p_script_selected = 'JOB_EXECUTION') THEN
      msg_query_fetch := msg_query_fetch || 'SELECT OWNER,JOB_NAME,PROGRAM_NAME,JOB_TYPE,SCHEDULE_NAME,STATE,LAST_START_DATE,NEXT_RUN_DATE,FAILURE_COUNT,LOGGING_LEVEL,STOP_ON_WINDOW_CLOSE  FROM DBA_SCHEDULER_JOBS WHERE job_name IN (''AUTO_SPACE_ADVISOR_JOB'',''GATHER_STATS_JOB'') and LAST_START_DATE > sysdate+7';
      msg_query_count := msg_query_count || 'SELECT COUNT(*) FROM DBA_SCHEDULER_JOBS WHERE LAST_START_DATE > sysdate+7';
    ELSIF (p_script_selected = 'EXTERNAL_JOBS') THEN
      msg_query_fetch := msg_query_fetch || 'SELECT OWNER,JOB_NAME,JOB_ACTION,PROGRAM_NAME,STATE,CREDENTIAL_NAME FROM DBA_SCHEDULER_JOBS WHERE job_type = ''EXECUTABLE''';
      msg_query_count := msg_query_count || 'SELECT COUNT(*) FROM DBA_SCHEDULER_JOBS WHERE job_type = ''EXECUTABLE''';
    END IF;
      store_table_data (msg_num,1,'NA','query',l_cur_table,l_cur_table,'','','',msg_query_fetch,msg_query_count,'','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  DBA_SCHEDULER_CREDENTIALS and DBA_SCHEDULER_JOBS DATA COLLECTION
    --
    --*********************************************************
  WHEN p_check = 'DBA_SCHEDULER_CREDENTIALS_DBA_SCHEDULER_JOBS_DATA' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_CREDENTIALS and DBA_SCHEDULER_JOBS';
    l_bookmark := 'DBA_SCHEDULER_CREDENTIALS_DBA_SCHEDULER_JOBS_DATA';
    msg_num := msg_num + 1;
    msg_query_fetch := '';
    msg_query_count := '';
    msg_query_fetch := msg_query_fetch || 'SELECT * FROM DBA_SCHEDULER_CREDENTIALS WHERE CREDENTIAL_NAME in (SELECT CREDENTIAL_NAME FROM DBA_SCHEDULER_JOBS WHERE JOB_TYPE = ''EXECUTABLE'')';
    msg_query_count := msg_query_count || 'SELECT COUNT(*) FROM DBA_SCHEDULER_CREDENTIALS WHERE CREDENTIAL_NAME in (SELECT CREDENTIAL_NAME FROM DBA_SCHEDULER_JOBS WHERE JOB_TYPE = ''EXECUTABLE'')';
    store_table_data (msg_num,1,'NA','query',l_cur_table,l_cur_table,'','','',msg_query_fetch,msg_query_count,'','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  DBA_SCHEDULER_JOBS AQ JOBS DATA COLLECTION
    --
    --*********************************************************
  WHEN p_check = 'DBA_SCHEDULER_JOBS_AQ_JOBS_DATA' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_JOBS';
    l_bookmark := 'DBA_SCHEDULER_JOBS_AQ_JOBS_DATA';
    msg_num := msg_num + 1;
    msg_query_fetch := '';
    msg_query_count := '';
    msg_query_fetch := msg_query_fetch || 'SELECT COUNT(*) FROM DBA_SCHEDULER_JOBS WHERE JOB_NAME LIKE ''AQ$_PLSQL_NTFN_%''';
    msg_query_count := msg_query_count || 'SELECT COUNT(*) FROM DBA_SCHEDULER_JOBS WHERE JOB_NAME LIKE ''AQ$_PLSQL_NTFN_%''';
    store_table_data (msg_num,1,'NA','query',l_cur_table,l_cur_table,'','','',msg_query_fetch,msg_query_count,'','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  DBA_SCHEDULER_JOBS and DBA_SCHEDULER_NOTIFICATIONS DATA COLLECTION
    --
    --  The table DBA_SCHEDULER_NOTIFICATIONS does not exist in 11.1.
    --  The table does exist in 11.2 and 12c
    --
    --*********************************************************
--  VLC fixed on 07/25/16  Added cursor logic to avoid future parsing errors for invalid identifiers or tables that don't exist
--  VLC modified on 8/14/16  updating query per Susan.  Changed columns to display
  WHEN p_check = 'DBA_SCHEDULER_JOBS_DBA_SCHEDULER_NOTIFICATIONS_DATA' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_JOBS and DBA_SCHEDULER_NOTIFICATIONS';
    l_bookmark := 'DBA_SCHEDULER_JOBS_DBA_SCHEDULER_NOTIFICATIONS_DATA';
    msg_num := msg_num + 1;
    msg_query_fetch := '';
    msg_query_count := '';
    msg_query_fetch := msg_query_fetch || 'SELECT OWNER, JOB_NAME, EVENT_QUEUE_NAME, EVENT_CONDITION, STATE,FAILURE_COUNT, LAST_START_DATE FROM DBA_SCHEDULER_JOBS WHERE JOB_NAME IN (SELECT JOB_NAME FROM DBA_SCHEDULER_NOTIFICATIONS)';
--    msg_query_fetch := msg_query_fetch || 'SELECT OWNER, JOB_NAME, JOB_SUBNAME, JOB_STYLE, JOB_CREATOR, PROGRAM_OWNER, PROGRAM_NAME, JOB_TYPE, JOB_ACTION, SCHEDULE_OWNER, SCHEDULE_NAME, SCHEDULE_TYPE, REPEAT_INTERVAL, EVENT_QUEUE_OWNER, EVENT_QUEUE_NAME, EVENT_QUEUE_AGENT, EVENT_CONDITION, EVENT_RULE, FILE_WATCHER_OWNER, FILE_WATCHER_NAME, JOB_CLASS, ENABLED, LAST_START_DATE, NEXT_RUN_DATE, NUMBER_OF_DESTINATIONS, DESTINATION_OWNER, DESTINATION, CREDENTIAL_OWNER, CREDENTIAL_NAME FROM DBA_SCHEDULER_JOBS WHERE JOB_NAME IN (SELECT JOB_NAME FROM DBA_SCHEDULER_NOTIFICATIONS)';
    msg_query_count := msg_query_count || 'SELECT COUNT(*) FROM DBA_SCHEDULER_JOBS WHERE JOB_NAME IN (SELECT JOB_NAME FROM DBA_SCHEDULER_NOTIFICATIONS)';
    store_table_data (msg_num,1,'NA','query',l_cur_table,l_cur_table,'','','',msg_query_fetch,msg_query_count,'','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  DBA_SCHEDULER_JOBS and DBA_SCHEDULER_PROGRAMS DATA COLLECTION
    --
    --*********************************************************
--  VLC fixed on 10/2/16  Changing query to be a join of DBA_SCHEDULER_JOBS and DBA_SCHEDULER_PROGRAMS
	WHEN p_check = 'DBA_SCHEDULER_JOBS_DBA_SCHEDULER_PROGRAMS_DATA' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_JOBS and DBA_SCHEDULER_PROGRAMS';
    l_bookmark := 'DBA_SCHEDULER_JOBS_DBA_SCHEDULER_PROGRAMS_DATA';
    msg_num := msg_num + 1;
    msg_query_fetch := '';
    msg_query_count := '';
    msg_query_fetch := msg_query_fetch || 'select a.owner "job Owner",a.JOB_NAME, a.PROGRAM_OWNER,a.PROGRAM_NAME,b.program_type,b.program_action,b.enabled from dba_scheduler_jobs a, dba_scheduler_programs b where a.PROGRAM_NAME=b.PROGRAM_NAME and a.PROGRAM_OWNER=b.owner';
    msg_query_count := msg_query_count || 'select COUNT(*) from dba_scheduler_jobs a, dba_scheduler_programs b where a.PROGRAM_NAME=b.PROGRAM_NAME and a.PROGRAM_OWNER=b.owner';
    store_table_data (msg_num,1,'NA','query',l_cur_table,l_cur_table,'','','',msg_query_fetch,msg_query_count,'','',l_cur_table,l_bookmark);
	--*********************************************************
    --
    --  DBA_SCHEDULER_JOBS and DBA_SCHEDULER_SCHEDULES DATA COLLECTION
    --
    --*********************************************************
--  VLC fixed on 10/2/16  Changing query to be a join of DBA_SCHEDULER_JOBS and DBA_SCHEDULER_SCHEDULES
	WHEN p_check = 'DBA_SCHEDULER_JOBS_DBA_SCHEDULER_SCHEDULES_DATA' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_JOBS and DBA_SCHEDULER_SCHEDULES';
    l_bookmark := 'DBA_SCHEDULER_JOBS_DBA_SCHEDULER_SCHEDULES_DATA';
    msg_num := msg_num + 1;
    msg_query_fetch := '';
    msg_query_count := '';
	msg_query_fetch := msg_query_fetch || 'select a.owner "job Owner",a.JOB_NAME,a.SCHEDULE_OWNER,a.SCHEDULE_NAME,a.SCHEDULE_TYPE,b.START_DATE,b.REPEAT_INTERVAL,b.END_DATE from  dba_scheduler_jobs a,  dba_scheduler_schedules b where a.SCHEDULE_NAME=b.SCHEDULE_NAME and a.SCHEDULE_OWNER=b.OWNER';
	msg_query_count := msg_query_count || 'select COUNT(*) from  dba_scheduler_jobs a,  dba_scheduler_schedules b where a.SCHEDULE_NAME=b.SCHEDULE_NAME and a.SCHEDULE_OWNER=b.OWNER';

    store_table_data (msg_num,1,'NA','query',l_cur_table,l_cur_table,'','','',msg_query_fetch,msg_query_count,'','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  DBA_SUBSCR_REGISTRATIONS and DBA_USERS DATA COLLECTION
    --
    --*********************************************************
  WHEN p_check = 'DBA_SUBSCR_REGISTRATIONS_DBA_USERS_DATA' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SUBSCR_REGISTRATIONS and DBA_USERS';
    l_bookmark := 'DBA_SUBSCR_REGISTRATIONS_DBA_USERS_DATA';
    msg_num := msg_num + 1;
    msg_query_fetch := '';
    msg_query_count := '';
    msg_query_fetch := msg_query_fetch || 'SELECT B.USERNAME, A.SUBSCRIPTION_NAME FROM DBA_SUBSCR_REGISTRATIONS A, DBA_USERS B WHERE SUBSCRIPTION_NAME LIKE ''%SCHED$_AGT2%'' AND A.USER#=B.USER_ID';
    msg_query_count := msg_query_count || 'SELECT COUNT(*) FROM DBA_SUBSCR_REGISTRATIONS A, DBA_USERS B WHERE SUBSCRIPTION_NAME LIKE ''%SCHED$_AGT2%'' AND A.USER#=B.USER_ID';
    store_table_data (msg_num,1,'NA','query',l_cur_table,l_cur_table,'','','',msg_query_fetch,msg_query_count,'','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  DBA_SCHEDULER_WINDOW_LOG DATA COLLECTION
    --
    --*********************************************************
  WHEN p_check = 'DBA_SCHEDULER_WINDOW_LOG_DATA' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_WINDOW_LOG';
    l_bookmark := 'DBA_SCHEDULER_WINDOW_LOG_DATA';
    msg_num := msg_num + 1;
    msg_query_fetch := '';
    msg_query_count := '';
      msg_query_fetch := msg_query_fetch || 'SELECT * FROM DBA_SCHEDULER_WINDOW_LOG where LOG_DATE > sysdate+7';
      msg_query_count := msg_query_count || 'SELECT COUNT(*) FROM DBA_SCHEDULER_WINDOW_LOG where LOG_DATE > sysdate+7';
    store_table_data (msg_num,1,'NA','query',l_cur_table,l_cur_table,'','','',msg_query_fetch,msg_query_count,'','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  DBA_SCHEDULER_WINDOW_GROUPS DATA COLLECTION
    --
    --*********************************************************
  WHEN p_check = 'DBA_SCHEDULER_WINDOW_GROUPS_DATA' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_WINDOW_GROUPS';
    l_bookmark := 'DBA_SCHEDULER_WINDOW_GROUPS_DATA';
    msg_num := msg_num + 1;
    msg_query_fetch := '';
    msg_query_count := '';
    IF (p_script_selected = 'JOB_AUTOTASK') THEN
      msg_query_fetch := msg_query_fetch || 'SELECT * FROM DBA_SCHEDULER_WINDOW_GROUPS';
      msg_query_count := msg_query_count || 'SELECT COUNT(*) FROM DBA_SCHEDULER_WINDOW_GROUPS';
    ELSIF ((p_script_selected = 'JOB_CONFIGURATION') or (p_script_selected = 'JOB_EXECUTION')) THEN
      msg_query_fetch := msg_query_fetch || 'SELECT WINDOW_GROUP_NAME, ENABLED, NEXT_START_DATE FROM DBA_SCHEDULER_WINDOW_GROUPS';
      msg_query_count := msg_query_count || 'SELECT COUNT(*) FROM DBA_SCHEDULER_WINDOW_GROUPS';
    END IF;
    store_table_data (msg_num,1,'NA','query',l_cur_table,l_cur_table,'','','',msg_query_fetch,msg_query_count,'','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  ALL_SCHEDULER_WINDOW_DETAILS DATA COLLECTION
    --
    --*********************************************************
  WHEN p_check = 'ALL_SCHEDULER_WINDOW_DETAILS_DATA' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'ALL_SCHEDULER_WINDOW_DETAILS ';
    l_bookmark := 'ALL_SCHEDULER_WINDOW_DETAILS_DATA';
    msg_num := msg_num + 1;
    msg_query_fetch := '';
    msg_query_count := '';
      msg_query_fetch := msg_query_fetch || 'SELECT * FROM ALL_SCHEDULER_WINDOW_DETAILS WHERE ((REQ_START_DATE != ACTUAL_START_DATE ) OR (WINDOW_DURATION != ACTUAL_DURATION)) and LOG_DATE > sysdate-7';
      msg_query_count := msg_query_count || 'SELECT COUNT(*) FROM ALL_SCHEDULER_WINDOW_DETAILS WHERE ((REQ_START_DATE != ACTUAL_START_DATE ) OR (WINDOW_DURATION != ACTUAL_DURATION)) and LOG_DATE > sysdate-7';
    store_table_data (msg_num,1,'NA','query',l_cur_table,l_cur_table,'','','',msg_query_fetch,msg_query_count,'','',l_cur_table,l_bookmark);
     --*********************************************************
    --
    --  DBA_SCHEDULER_WINGROUP_MEMBERS DATA COLLECTION
    --
    --*********************************************************
  WHEN p_check = 'DBA_SCHEDULER_WINGROUP_MEMBERS_DATA' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_WINGROUP_MEMBERS';
    l_bookmark := 'DBA_SCHEDULER_WINGROUP_MEMBERS_DATA';
    msg_num := msg_num + 1;
    msg_query_fetch := '';
    msg_query_count := '';
    IF (p_script_selected = 'JOB_AUTOTASK') THEN
      msg_query_fetch := msg_query_fetch || 'SELECT * FROM DBA_SCHEDULER_WINGROUP_MEMBERS';
      msg_query_count := msg_query_count || 'SELECT COUNT(*) FROM DBA_SCHEDULER_WINGROUP_MEMBERS';
    ELSIF (p_script_selected = 'JOB_CONFIGURATION') THEN
      msg_query_fetch := msg_query_fetch || 'SELECT WINDOW_GROUP_NAME, WINDOW_NAME FROM DBA_SCHEDULER_WINGROUP_MEMBERS group by WINDOW_GROUP_NAME, WINDOW_NAME';
      msg_query_count := msg_query_count || 'SELECT COUNT(*) FROM DBA_SCHEDULER_WINGROUP_MEMBERS';
    END IF;
    store_table_data (msg_num,1,'NA','query',l_cur_table,l_cur_table,'','','',msg_query_fetch,msg_query_count,'','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  DBA_SCHEDULER_WINDOWS DATA COLLECTION
    --
    --*********************************************************
  WHEN p_check = 'DBA_SCHEDULER_WINDOWS_DATA' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_WINDOWS';
    l_bookmark := 'DBA_SCHEDULER_WINDOWS_DATA';
    msg_num := msg_num + 1;
    msg_query_fetch := '';
    msg_query_count := '';
    IF (p_script_selected = 'JOB_AUTOTASK') THEN
      IF (chkVersion('10',db_version,1) = 'EQ') THEN
        msg_query_fetch := msg_query_fetch || 'SELECT WINDOW_NAME, RESOURCE_PLAN, REPEAT_INTERVAL, LAST_START_DATE, NEXT_START_DATE FROM DBA_SCHEDULER_WINDOWS WHERE window_name IN (''WEEKNIGHT_WINDOW'', ''WEEKEND_WINDOW'')';
        msg_query_count := msg_query_count || 'SELECT COUNT(*) FROM DBA_SCHEDULER_WINDOWS WHERE window_name IN (''WEEKNIGHT_WINDOW'', ''WEEKEND_WINDOW'')';
      ELSIF ((chkVersion('11',db_version,1) = 'EQ') OR (chkVersion('12',db_version,1) = 'EQ')) THEN
        msg_query_fetch := msg_query_fetch || 'SELECT WINDOW_NAME,RESOURCE_PLAN,LAST_START_DATE,NEXT_START_DATE,ENABLED,ACTIVE,REPEAT_INTERVAL,DURATION FROM DBA_SCHEDULER_WINDOWS';
        msg_query_count := msg_query_count || 'SELECT COUNT(*) FROM DBA_SCHEDULER_WINDOWS';
      END IF;
    ELSE
      msg_query_fetch := msg_query_fetch || 'SELECT WINDOW_NAME, RESOURCE_PLAN, SCHEDULE_NAME, START_DATE, REPEAT_INTERVAL, NEXT_START_DATE, LAST_START_DATE, DURATION, ENABLED, ACTIVE FROM DBA_SCHEDULER_WINDOWS';
      msg_query_count := msg_query_count || 'SELECT COUNT(*) FROM DBA_SCHEDULER_WINDOWS';
    END IF;
    store_table_data (msg_num,1,'NA','query',l_cur_table,l_cur_table,'','','',msg_query_fetch,msg_query_count,'','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  DBA_SCHEDULER_JOB_CLASSES DATA COLLECTION
    --
    --*********************************************************
  WHEN p_check = 'DBA_SCHEDULER_JOB_CLASSES_DATA' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_JOB_CLASSES';
    l_bookmark := 'DBA_SCHEDULER_JOB_CLASSES_DATA';
    msg_num := msg_num + 1;
    msg_query_fetch := '';
    msg_query_count := '';
    msg_query_fetch := msg_query_fetch || 'SELECT JOB_CLASS_NAME , RESOURCE_CONSUMER_GROUP, SERVICE FROM DBA_SCHEDULER_JOB_CLASSES';
    msg_query_count := msg_query_count || 'SELECT COUNT(*) FROM DBA_SCHEDULER_JOB_CLASSES';
    store_table_data (msg_num,1,'NA','query',l_cur_table,l_cur_table,'','','',msg_query_fetch,msg_query_count,'','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  DBA_SCHEDULER_JOBS AND DBA_SCHEDULER_JOB_CLASSES DATA COLLECTION
    --
    --*********************************************************
--  VLC fixed on 08/07/16  fixed the msg_query_fect is set 2 times for autotask.  One of the queries should be count.
  WHEN p_check = 'DBA_SCHEDULER_JOBS_AND_DBA_SCHEDULER_JOB_CLASSES_DATA' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_JOBS_AND_DBA_SCHEDULER_JOB_CLASSES';
    l_bookmark := 'DBA_SCHEDULER_JOBS_AND_DBA_SCHEDULER_JOB_CLASSES_DATA';
    msg_num := msg_num + 1;
    msg_query_fetch := '';
    msg_query_count := '';
    IF (p_script_selected = 'JOB_AUTOTASK') THEN
      msg_query_fetch := msg_query_fetch || 'SELECT J.JOB_NAME, J.SCHEDULE_NAME, JC.JOB_CLASS_NAME, JC.RESOURCE_CONSUMER_GROUP FROM DBA_SCHEDULER_JOBS J, DBA_SCHEDULER_JOB_CLASSES JC WHERE J.JOB_CLASS = JC.JOB_CLASS_NAME AND J.JOB_NAME NOT IN (''AUTO_SPACE_ADVISOR_JOB'',''GATHER_STATS_JOB'')';
      msg_query_count := msg_query_count || 'SELECT COUNT(*) FROM DBA_SCHEDULER_JOBS J, DBA_SCHEDULER_JOB_CLASSES JC WHERE J.JOB_CLASS = JC.JOB_CLASS_NAME AND J.JOB_NAME NOT IN (''AUTO_SPACE_ADVISOR_JOB'',''GATHER_STATS_JOB'')';
    ELSE
      msg_query_fetch := msg_query_fetch || 'SELECT J.JOB_NAME, J.SCHEDULE_NAME, JC.JOB_CLASS_NAME, JC.RESOURCE_CONSUMER_GROUP,JC.SERVICE FROM DBA_SCHEDULER_JOBS J, DBA_SCHEDULER_JOB_CLASSES JC WHERE J.JOB_CLASS = JC.JOB_CLASS_NAME';
      msg_query_count := msg_query_count || 'SELECT COUNT(*) FROM DBA_SCHEDULER_JOBS J, DBA_SCHEDULER_JOB_CLASSES JC WHERE J.JOB_CLASS = JC.JOB_CLASS_NAME';
    END IF;
    store_table_data (msg_num,1,'NA','query',l_cur_table,l_cur_table,'','','',msg_query_fetch,msg_query_count,'','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  DBA_SCHEDULER_RUNNING_JOBS INVALID SLAVE_OS_PROCESS_ID DATA COLLECTION
    --
    --*********************************************************
  WHEN p_check = 'DBA_SCHEDULER_RUNNING_JOBS_SLAVE_OS_PROCESS_ID_DATA' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_RUNNING_JOBS_SLAVE_OS_PROCESS_ID';
    l_bookmark := 'DBA_SCHEDULER_RUNNING_JOBS_SLAVE_OS_PROCESS_ID_DATA';
    msg_num := msg_num + 1;
    msg_query_fetch := '';
    msg_query_count := '';
    msg_query_fetch := msg_query_fetch || 'SELECT JOB_NAME,SLAVE_OS_PROCESS_ID FROM DBA_SCHEDULER_RUNNING_JOBS WHERE SLAVE_OS_PROCESS_ID NOT IN (SELECT SPID FROM V$PROCESS)';
    msg_query_count := msg_query_count || 'SELECT COUNT(*) FROM DBA_SCHEDULER_RUNNING_JOBS WHERE SLAVE_OS_PROCESS_ID NOT IN (SELECT SPID FROM V$PROCESS)';
    store_table_data (msg_num,1,'NA','query',l_cur_table,l_cur_table,'','','',msg_query_fetch,msg_query_count,'','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  DBA_PROFILES DATA COLLECTION
    --
    --*********************************************************
  WHEN p_check = 'DBA_PROFILES_DATA' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_PROFILES';
    l_bookmark := 'DBA_PROFILES_DATA';
    msg_num := msg_num + 1;
    msg_query_fetch := '';
    msg_query_count := '';
    msg_query_fetch := msg_query_fetch || 'SELECT PROFILE, RESOURCE_NAME, RESOURCE_TYPE, LIMIT FROM DBA_PROFILES WHERE RESOURCE_NAME =''SESSIONS_PER_USER'' AND PROFILE IN(SELECT DISTINCT PROFILE FROM DBA_USERS WHERE USERNAME IN (SELECT DISTINCT OWNER FROM DBA_SCHEDULER_JOBS))';
    msg_query_count := msg_query_count || 'SELECT COUNT(*) FROM DBA_PROFILES WHERE RESOURCE_NAME =''SESSIONS_PER_USER'' AND PROFILE IN(SELECT DISTINCT PROFILE FROM DBA_USERS WHERE USERNAME IN (SELECT DISTINCT OWNER FROM DBA_SCHEDULER_JOBS))';
    store_table_data (msg_num,1,'NA','query',l_cur_table,l_cur_table,'','','',msg_query_fetch,msg_query_count,'','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  DBA_SCHEDULER_CHAINS DATA COLLECTION
    --
    --*********************************************************
  WHEN p_check = 'DBA_SCHEDULER_CHAINS_DATA' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_CHAINS';
    l_bookmark := 'DBA_SCHEDULER_CHAINS_DATA';
    msg_num := msg_num + 1;
    msg_query_fetch := '';
    msg_query_count := '';
    msg_query_fetch := msg_query_fetch || 'SELECT * FROM DBA_SCHEDULER_CHAINS';
    msg_query_count := msg_query_count || 'SELECT COUNT(*) FROM DBA_SCHEDULER_CHAINS';
    store_table_data (msg_num,1,'NA','query',l_cur_table,l_cur_table,'','','',msg_query_fetch,msg_query_count,'','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  DBA_SCHEDULER_CHAIN_STEPS DATA COLLECTION
    --
    --*********************************************************
  WHEN p_check = 'DBA_SCHEDULER_CHAIN_STEPS_DATA' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_CHAIN_STEPS';
    l_bookmark := 'DBA_SCHEDULER_CHAIN_STEPS_DATA';
    msg_num := msg_num + 1;
    msg_query_fetch := '';
    msg_query_count := '';
    msg_query_fetch := msg_query_fetch || 'SELECT OWNER,CHAIN_NAME,STEP_NAME,PROGRAM_OWNER,PROGRAM_NAME,STEP_TYPE FROM DBA_SCHEDULER_CHAIN_STEPS ORDER BY OWNER, CHAIN_NAME, STEP_NAME';
    msg_query_count := msg_query_count || 'SELECT COUNT(*) FROM DBA_SCHEDULER_CHAIN_STEPS';
    store_table_data (msg_num,1,'NA','query',l_cur_table,l_cur_table,'','','',msg_query_fetch,msg_query_count,'','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  DBA_SCHEDULER_CHAIN_RULES DATA COLLECTION
    --
    --*********************************************************
  WHEN p_check = 'DBA_SCHEDULER_CHAIN_RULES_DATA' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_CHAIN_RULES  ';
    l_bookmark := 'DBA_SCHEDULER_CHAIN_RULES_DATA';
    msg_num := msg_num + 1;
    msg_query_fetch := '';
    msg_query_count := '';
    msg_query_fetch := msg_query_fetch || 'SELECT OWNER,CHAIN_NAME,RULE_OWNER,RULE_NAME,CONDITION,ACTION,COMMENTS FROM DBA_SCHEDULER_CHAIN_RULES ORDER BY OWNER, CHAIN_NAME, RULE_OWNER, RULE_NAME';
    msg_query_count := msg_query_count || 'SELECT COUNT(*) FROM DBA_SCHEDULER_CHAIN_RULES';
    store_table_data (msg_num,1,'NA','query',l_cur_table,l_cur_table,'','','',msg_query_fetch,msg_query_count,'','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  DBA_SCHEDULER_RUNNING_CHAINS DATA COLLECTION
    --
    --*********************************************************
  WHEN p_check = 'DBA_SCHEDULER_RUNNING_CHAINS_DATA' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_RUNNING_CHAINS  ';
    l_bookmark := 'DBA_SCHEDULER_RUNNING_CHAINS_DATA';
    msg_num := msg_num + 1;
    msg_query_fetch := '';
    msg_query_count := '';
    msg_query_fetch := msg_query_fetch || 'SELECT OWNER,JOB_NAME,CHAIN_OWNER,CHAIN_NAME,STEP_NAME,STATE,ERROR_CODE,COMPLETED,START_DATE,END_DATE  FROM DBA_SCHEDULER_RUNNING_CHAINS ORDER BY OWNER, JOB_NAME, CHAIN_NAME, STEP_NAME';
    msg_query_count := msg_query_count || 'SELECT COUNT(*) FROM DBA_SCHEDULER_RUNNING_CHAINS';
    store_table_data (msg_num,1,'NA','query',l_cur_table,l_cur_table,'','','',msg_query_fetch,msg_query_count,'','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  AQ$SCHEDULER$_EVENT_QTAB DATA COLLECTION
    --
    --*********************************************************
  WHEN p_check = 'AQ$SCHEDULER$_EVENT_QTAB_DATA' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'SYS.AQ$SCHEDULER$_EVENT_QTAB';
    l_bookmark := 'AQ$SCHEDULER$_EVENT_QTAB_DATA';
    msg_num := msg_num + 1;
    msg_query_fetch := '';
    msg_query_count := '';
    msg_query_fetch := msg_query_fetch || 'SELECT COUNT(*), MSG_STATE, QUEUE, CONSUMER_NAME FROM AQ$SCHEDULER$_EVENT_QTAB GROUP BY MSG_STATE, QUEUE, CONSUMER_NAME';
    msg_query_count := msg_query_count || 'SELECT COUNT(*) FROM SYS.AQ$SCHEDULER$_EVENT_QTAB';
    store_table_data (msg_num,1,'NA','query',l_cur_table,l_cur_table,'','','',msg_query_fetch,msg_query_count,'','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  SCHEDULER$_EVENT_QTAB DATA COLLECTION
    --
    --*********************************************************
  WHEN p_check = 'SCHEDULER$_EVENT_QTAB_DATA' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'SYS.SCHEDULER$_EVENT_QTAB';
    l_bookmark := 'SCHEDULER$_EVENT_QTAB_DATA';
    msg_num := msg_num + 1;
    msg_query_fetch := '';
    msg_query_count := '';
    msg_query_fetch := msg_query_fetch || 'SELECT USER_DATA FROM SYS.SCHEDULER$_EVENT_QTAB WHERE ENQ_TIME > SYSDATE -1';
    msg_query_count := msg_query_count || 'SELECT COUNT(*) FROM SYS.SCHEDULER$_EVENT_QTAB';
    store_table_data (msg_num,1,'NA','query',l_cur_table,l_cur_table,'','','',msg_query_fetch,msg_query_count,'','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  DBA_SCHEDULER_NOTIFICATIONS DATA COLLECTION
    --
    --  Table DBA_SCHEDULER_NOTIFICATIONS does not exist in 11.1.
    --  The table does exist in 11.2 and 12c.
    --
    --*********************************************************
--  VLC fixed on 07/25/16  Added cursor logic to avoid future parsing errors for invalid identifiers or tables that don't exist
  WHEN p_check = 'DBA_SCHEDULER_NOTIFICATIONS_DATA' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_NOTIFICATIONS';
    l_bookmark := 'DBA_SCHEDULER_NOTIFICATIONS_DATA';
    msg_num := msg_num + 1;
    msg_query_fetch := '';
    msg_query_count := '';
    msg_query_fetch := msg_query_fetch || 'SELECT * FROM DBA_SCHEDULER_NOTIFICATIONS';
    msg_query_count := msg_query_count || 'SELECT COUNT(*) FROM DBA_SCHEDULER_NOTIFICATIONS';
    store_table_data (msg_num,1,'NA','query',l_cur_table,l_cur_table,'','','',msg_query_fetch,msg_query_count,'','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  USER_SCHEDULER_NOTIFICATIONS DATA COLLECTION
    --  The table USER_SCHEDULER_NOTIFICATIONS doesn't exist in 11.1.
    --  The table does exist in 11.2 and 12c.
    --
    --*********************************************************
--  VLC 07/25/16  Causing error on 11
--  VLC fixed on 07/26/16 - changed to to avoid the  errors  ORA-00904: "FILE_WATCHER_NAME": invalid identifier ORA-06550:
  WHEN p_check = 'USER_SCHEDULER_NOTIFICATIONS_DATA' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'USER_SCHEDULER_NOTIFICATIONS';
    l_bookmark := 'USER_SCHEDULER_NOTIFICATIONS_DATA';
    msg_num := msg_num + 1;
    msg_query_fetch := '';
    msg_query_count := '';
    msg_query_fetch := msg_query_fetch || 'SELECT JOB_NAME, RECIPIENT, EVENT, FILTER_CONDITION FROM USER_SCHEDULER_NOTIFICATIONS';
    msg_query_count := msg_query_count || 'SELECT COUNT(*) FROM USER_SCHEDULER_NOTIFICATIONS';
    store_table_data (msg_num,1,'NA','query',l_cur_table,l_cur_table,'','','',msg_query_fetch,msg_query_count,'','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  USER_SCHEDULER_FILE_WATCHERS DATA COLLECTION
    --  The table USER_SCHEDULER_FILE_WATCHERS does not exist in 11.1.
    --  The table does exist in 11.2 and 12c.
    --
    --*********************************************************
--  VLC 07/25/16  Causing error on 11
--  VLC 07/26/16 - to avoid the  errors  ORA-00904: "FILE_WATCHER_NAME": invalid identifier ORA-06550:
  WHEN p_check = 'USER_SCHEDULER_FILE_WATCHERS_DATA' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'USER_SCHEDULER_FILE_WATCHERS';
    l_bookmark := 'USER_SCHEDULER_FILE_WATCHERS_DATA';
    msg_num := msg_num + 1;
    msg_query_fetch := '';
    msg_query_count := '';
    msg_query_fetch := msg_query_fetch || 'SELECT * FROM USER_SCHEDULER_FILE_WATCHERS';
    msg_query_count := msg_query_count || 'SELECT COUNT(*) FROM USER_SCHEDULER_FILE_WATCHERS';
    store_table_data (msg_num,1,'NA','query',l_cur_table,l_cur_table,'','','',msg_query_fetch,msg_query_count,'','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  ALL_SCHEDULER_EXTERNAL_DESTS DATA COLLECTION
    --
    --*********************************************************
  WHEN p_check = 'ALL_SCHEDULER_EXTERNAL_DESTS_DATA' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'ALL_SCHEDULER_EXTERNAL_DESTS';
    l_bookmark := 'ALL_SCHEDULER_EXTERNAL_DESTS_DATA';
    msg_num := msg_num + 1;
    msg_query_fetch := '';
    msg_query_count := '';
    msg_query_fetch := msg_query_fetch || 'SELECT * FROM ALL_SCHEDULER_EXTERNAL_DESTS';
    msg_query_count := msg_query_count || 'SELECT COUNT(*) FROM ALL_SCHEDULER_EXTERNAL_DESTS';
    store_table_data (msg_num,1,'NA','query',l_cur_table,l_cur_table,'','','',msg_query_fetch,msg_query_count,'','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  USER_SCHEDULER_DESTS DATA COLLECTION
    --
    --*********************************************************
  WHEN p_check = 'USER_SCHEDULER_DESTS_DATA' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'USER_SCHEDULER_DESTS';
    l_bookmark := 'USER_SCHEDULER_DESTS_DATA';
    msg_num := msg_num + 1;
    msg_query_fetch := '';
    msg_query_count := '';
    msg_query_fetch := msg_query_fetch || 'SELECT * FROM USER_SCHEDULER_DESTS';
    msg_query_count := msg_query_count || 'SELECT COUNT(*) FROM USER_SCHEDULER_DESTS';
    store_table_data (msg_num,1,'NA','query',l_cur_table,l_cur_table,'','','',msg_query_fetch,msg_query_count,'','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  DBA_TABLES_DATA DATA COLLECTION
    --
    --*********************************************************

--  VLC fixed on 10/2/16   Added cursor logic to avoid future parsing errors for invalid identifiers or tables that don't exist
--  VLC 07/25/16  Causing error on DB version 11
--  VLC 07/26/16 - to avoid the  errors  ORA-00904: "FILE_WATCHER_NAME": invalid identifier ORA-06550:
  WHEN p_check = 'DBA_TABLES_DATA' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_TABLES';
    l_bookmark := 'DBA_TABLES_DATA';
    msg_num := msg_num + 1;
    msg_query_fetch := '';
    msg_query_count := '';
    msg_query_fetch := msg_query_fetch || 'SELECT TABLE_NAME FROM DBA_TABLES WHERE TABLE_NAME LIKE ''%AQ_SRVNTFN_TABLE%''';
    msg_query_count := msg_query_count || 'SELECT COUNT(*) FROM DBA_TABLES WHERE TABLE_NAME LIKE ''%AQ_SRVNTFN_TABLE%''';
    store_table_data (msg_num,1,'NA','query',l_cur_table,l_cur_table,'','','',msg_query_fetch,msg_query_count,'','',l_cur_table,l_bookmark);
    aq_srvntfn_table_list := '';
    the_count_cursor := 'SELECT COUNT(*) FROM dba_tables WHERE table_name LIKE ''%AQ_SRVNTFN_TABLE%''';
    the_data_cursor  := 'SELECT table_name FROM dba_tables WHERE table_name LIKE ''%AQ_SRVNTFN_TABLE%''';
    OPEN l_cursor FOR the_count_cursor;
    FETCH l_cursor
    INTO aq_srvntfn_table_found;
    CLOSE l_cursor;
    IF (aq_srvntfn_table_found > 0) THEN
      OPEN l_cursor FOR the_data_cursor;
      LOOP
        FETCH l_cursor INTO var1;
        EXIT WHEN l_cursor%notfound;
        l_cur_table := var1;
        l_bookmark := var1||'_DATA';
        msg_num := msg_num + 1;
        msg_query_fetch := '';
        msg_query_count := '';
--        msg_query_fetch := msg_query_fetch || 'SELECT COUNT(*), MSG_STATE, QUEUE FROM '||i.table_name||' GROUP BY MSG_STATE, QUEUE';
--      Queue = Q_NAME and MSG_STATE = STATE in version 12
--   VLCFIX  need to find out what the column names are for version 10 and 11
        msg_query_fetch := msg_query_fetch || 'SELECT COUNT(*), STATE, Q_NAME FROM '||var1||' GROUP BY STATE, Q_NAME';
        msg_query_count := msg_query_count || 'SELECT COUNT(*) FROM '||var1;
        aq_srvntfn_table_list := aq_srvntfn_table_list || '<a href="#'||l_bookmark||'">'||l_cur_table||'</a>' || '[[NL]]';
        store_table_data (msg_num,1,'NA','query',l_cur_table,l_cur_table,'','','',msg_query_fetch,msg_query_count,'','',l_cur_table,l_bookmark);
      END LOOP;
      CLOSE l_cursor;
    END IF;

    --*********************************************************
    --
    --  DBA_QUEUES DATA COLLECTION
    --
    --*********************************************************
  WHEN p_check = 'DBA_QUEUES_DATA' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_QUEUES';
    l_bookmark := 'DBA_QUEUES_DATA';
    msg_num := msg_num + 1;
    msg_query_fetch := '';
    msg_query_count := '';
    msg_query_fetch := msg_query_fetch || 'SELECT QUEUE_TABLE, MAX_RETRIES, RETRY_DELAY, RETENTION FROM DBA_QUEUES WHERE NAME = ''SCHEDULER$_EVENT_QUEUE''';
    msg_query_count := msg_query_count || 'SELECT COUNT(*) FROM DBA_QUEUES WHERE NAME = ''SCHEDULER$_EVENT_QUEUE''';
    store_table_data (msg_num,1,'NA','query',l_cur_table,l_cur_table,'','','',msg_query_fetch,msg_query_count,'','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  DBA_QUEUE_SUBSCRIBERS DATA COLLECTION
    --
    --*********************************************************
  WHEN p_check = 'DBA_QUEUE_SUBSCRIBERS_DATA' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_QUEUE_SUBSCRIBERS';
    l_bookmark := 'DBA_QUEUE_SUBSCRIBERS_DATA';
    msg_num := msg_num + 1;
    msg_query_fetch := '';
    msg_query_count := '';
    msg_query_fetch := msg_query_fetch || 'SELECT CONSUMER_NAME FROM DBA_QUEUE_SUBSCRIBERS WHERE QUEUE_NAME = ''SCHEDULER$_EVENT_QUEUE''';
    msg_query_count := msg_query_count || 'SELECT COUNT(*) FROM DBA_QUEUE_SUBSCRIBERS WHERE QUEUE_NAME = ''SCHEDULER$_EVENT_QUEUE''';
    store_table_data (msg_num,1,'NA','query',l_cur_table,l_cur_table,'','','',msg_query_fetch,msg_query_count,'','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  DBA_SCHEDULER_JOB_LOG DATA COLLECTION
    --
    --*********************************************************

  WHEN p_check = 'DBA_SCHEDULER_JOB_LOG_DATA' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_JOB_LOG';
    l_bookmark := 'DBA_SCHEDULER_JOB_LOG_DATA';
    msg_num := msg_num + 1;
    msg_query_fetch := '';
    msg_query_count := '';
	IF ((chkVersion('10',db_version,1) = 'EQ') and  (p_script_selected = 'JOB_AUTOTASK'))THEN
    msg_query_fetch := msg_query_fetch || 'SELECT JOB_NAME, LOG_DATE, STATUS, ADDITIONAL_INFO FROM DBA_SCHEDULER_JOB_LOG WHERE job_name IN (''AUTO_SPACE_ADVISOR_JOB'',''GATHER_STATS_JOB'') and LOG_DATE > sysdate-7';
    msg_query_count := msg_query_count || 'SELECT COUNT(*) FROM DBA_SCHEDULER_JOB_LOG WHERE job_name IN (''AUTO_SPACE_ADVISOR_JOB'',''GATHER_STATS_JOB'') and LOG_DATE > sysdate-7';
	ELSIF (((chkVersion('11',db_version,1) = 'EQ') OR (chkVersion('12',db_version,1) = 'EQ')) and  (p_script_selected = 'JOB_AUTOTASK')) THEN
    msg_query_fetch := msg_query_fetch || 'SELECT JOB_NAME, LOG_DATE, STATUS, ADDITIONAL_INFO FROM DBA_SCHEDULER_JOB_LOG WHERE JOB_NAME LIKE ''ORA$AT%'' and LOG_DATE > sysdate-7';
    msg_query_count := msg_query_count || 'SELECT COUNT(*) FROM DBA_SCHEDULER_JOB_LOG WHERE JOB_NAME LIKE ''ORA$AT%'' and LOG_DATE > sysdate-7';
	ELSIF (p_script_selected = 'JOB_EXECUTION') THEN
    msg_query_fetch := msg_query_fetch || 'SELECT distinct OWNER, JOB_NAME FROM DBA_SCHEDULER_JOB_LOG WHERE JOB_NAME NOT LIKE ''%AQ$_PLSQL_NTFN_%'' GROUP BY OWNER, JOB_NAME';
    msg_query_count := msg_query_count || 'SELECT COUNT(*) FROM DBA_SCHEDULER_JOB_LOG WHERE JOB_NAME NOT LIKE ''%AQ$_PLSQL_NTFN_%''';
	END IF;
    store_table_data (msg_num,1,'NA','query',l_cur_table,l_cur_table,'','','',msg_query_fetch,msg_query_count,'','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    -- DBA_SCHEDULER_JOB_RUN_DETAILS DATA COLLECTION
    --
    --*********************************************************

  WHEN p_check = 'DBA_SCHEDULER_JOB_RUN_DETAILS_DATA' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_JOB_RUN_DETAILS';
    l_bookmark := 'DBA_SCHEDULER_JOB_RUN_DETAILS_DATA';
    msg_num := msg_num + 1;
    msg_query_fetch := '';
    msg_query_count := '';
    IF (p_script_selected = 'JOB_AUTOTASK') THEN
      IF (chkVersion('10.2.0.5',db_version,4) = 'LT') THEN
       msg_query_fetch := msg_query_fetch || 'SELECT JOB_NAME, STATUS, TO_CHAR(LOG_DATE,''DD-MON-YY HH24:MI'') LOG_DATE, TO_CHAR(ACTUAL_START_DATE,''DD-MON-YYYY HH24:MI'') ACTUAL_START_DATE, RUN_DURATION, STATUS,INSTANCE_ID, ADDITIONAL_INFO FROM DBA_SCHEDULER_JOB_RUN_DETAILS WHERE job_name IN (''AUTO_SPACE_ADVISOR_JOB'',''GATHER_STATS_JOB'') and log_date > sysdate-7';
      ELSIF (chkVersion('10.2.0.5',db_version,4) = 'EQ') THEN
        msg_query_fetch := msg_query_fetch || 'SELECT JOB_NAME, STATUS, TO_CHAR(LOG_DATE,''DD-MON-YY HH24:MI'') LOG_DATE, TO_CHAR(ACTUAL_START_DATE,''DD-MON-YYYY HH24:MI'') ACTUAL_START_DATE, RUN_DURATION, STATUS,INSTANCE_ID FROM DBA_SCHEDULER_JOB_RUN_DETAILS WHERE job_name IN (''AUTO_SPACE_ADVISOR_JOB'',''GATHER_STATS_JOB'') and log_date > sysdate-7';
      END IF;
      msg_query_count := msg_query_count || 'SELECT COUNT(*) FROM DBA_SCHEDULER_JOB_RUN_DETAILS WHERE job_name IN (''AUTO_SPACE_ADVISOR_JOB'',''GATHER_STATS_JOB'') and log_date > sysdate-7';
    ELSIF ( ((chkVersion('11',db_version,1) = 'EQ') OR (chkVersion('12',db_version,1) = 'EQ')) and (p_script_selected = 'JOB_AUTOTASK'))  THEN
      msg_query_fetch := msg_query_fetch || 'SELECT JOB_NAME, STATUS, TO_CHAR(LOG_DATE,''DD-MON-YY HH24:MI'') LOG_DATE, TO_CHAR(REQ_START_DATE,''DD-MON-YYYY HH24:MI'') REQUESTED_START_DATE ,TO_CHAR(ACTUAL_START_DATE,''DD-MON-YYYY HH24:MI'') ACTUAL_START_DATE, RUN_DURATION, STATUS,INSTANCE_ID, ADDITIONAL_INFO, ERROR#  FROM DBA_SCHEDULER_JOB_RUN_DETAILS where job_name like ''ORA$AT_%'' AND log_date >sysdate -7  order by log_date';
      msg_query_count := msg_query_count || 'SELECT COUNT(*)  FROM DBA_SCHEDULER_JOB_RUN_DETAILS where job_name like ''ORA$AT_%'' AND LOG_DATE > sysdate-7';
    ELSE
      IF ((chkVersion(db_version, '12.1',2) = 'EQ') OR (chkVersion(db_version, '12.1',2) = 'GT')) THEN
        msg_query_fetch := msg_query_fetch || 'SELECT OWNER,JOB_NAME,STATUS,ERROR# as ERROR_NUM,INSTANCE_ID,REQ_START_DATE,ACTUAL_START_DATE,ADDITIONAL_INFO,OUTPUT  FROM DBA_SCHEDULER_JOB_RUN_DETAILS where log_date >sysdate -7  order by log_date';
      ELSE
        msg_query_fetch := msg_query_fetch || 'SELECT OWNER,JOB_NAME,STATUS,ERROR# as ERROR_NUM,INSTANCE_ID,REQ_START_DATE,ACTUAL_START_DATE,ADDITIONAL_INFO FROM DBA_SCHEDULER_JOB_RUN_DETAILS where log_date >sysdate -7  order by log_date';
      END IF;
      msg_query_count := msg_query_count || 'SELECT COUNT(*)  FROM DBA_SCHEDULER_JOB_RUN_DETAILS where LOG_DATE > sysdate-7';
    END IF;
      store_table_data (msg_num,1,'NA','query',l_cur_table,l_cur_table,'','','',msg_query_fetch,msg_query_count,'','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    -- DBA_SCHEDULER_JOB_RUN_DETAILS LATEST EXECUTION DATA COLLECTION
    --
    --*********************************************************
  WHEN p_check = 'DBA_SCHEDULER_JOB_RUN_DETAILS_LATEST_EXECUTION_DATA' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_JOB_RUN_DETAILS';
    l_bookmark := 'DBA_SCHEDULER_JOB_RUN_DETAILS_LATEST_EXECUTION_DATA';
    msg_num := msg_num + 1;
    msg_query_fetch := '';
    msg_query_count := '';
--      msg_query_fetch := msg_query_fetch || 'select * from dba_scheduler_job_run_details where log_id in (select max(log_id) from dba_scheduler_job_run_details where job_name not like ''%AQ$_PLSQL_NTFN_%''  group by job_name)';
      msg_query_fetch := msg_query_fetch || 'select OWNER,JOB_NAME,STATUS,ERROR# as ERROR_NUM,INSTANCE_ID,REQ_START_DATE,ACTUAL_START_DATE,ADDITIONAL_INFO,OUTPUT  from dba_scheduler_job_run_details where log_id in (select max(log_id) from dba_scheduler_job_run_details where job_name not like ''%AQ$_PLSQL_NTFN_%''  group by job_name)';
      msg_query_count := msg_query_count || 'SELECT COUNT(*) from dba_scheduler_job_run_details where log_id in (select max(log_id) from dba_scheduler_job_run_details where job_name not like ''%AQ$_PLSQL_NTFN_%''  group by job_name)';
      store_table_data (msg_num,1,'NA','query',l_cur_table,l_cur_table,'','','',msg_query_fetch,msg_query_count,'','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  DBA_SCHEDULER_JOB_RUN_DETAILS and DBA_SCHEDULER_JOBS DATA COLLECTION
    --
    --*********************************************************
    WHEN p_check = 'DBA_SCHEDULER_JOB_RUN_DETAILS_DBA_SCHEDULER_JOBS_DATA' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_JOB_RUN_DETAILS and DBA_SCHEDULER_JOBS';
    l_bookmark := 'DBA_SCHEDULER_JOB_RUN_DETAILS_DBA_SCHEDULER_JOBS_DATA';
    msg_num := msg_num + 1;
    msg_query_fetch := '';
    msg_query_count := '';
    msg_query_fetch := msg_query_fetch || 'SELECT STATUS, JOB_NAME, ERROR#, ADDITIONAL_INFO, TO_CHAR(LOG_DATE, ''MM/DD/YYYY HH24:MI:SS'') LOG_DATE  FROM DBA_SCHEDULER_JOB_RUN_DETAILS WHERE JOB_NAME IN (SELECT JOB_NAME FROM DBA_SCHEDULER_JOBS WHERE JOB_TYPE = ''EXECUTABLE'') ORDER BY LOG_DATE';
    msg_query_count := msg_query_count || 'SELECT COUNT(*) FROM DBA_SCHEDULER_JOB_RUN_DETAILS WHERE JOB_NAME IN (SELECT JOB_NAME FROM DBA_SCHEDULER_JOBS WHERE JOB_TYPE = ''EXECUTABLE'')';
    store_table_data (msg_num,1,'NA','query',l_cur_table,l_cur_table,'','','',msg_query_fetch,msg_query_count,'','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  11g,12c - DBA_AUTOTASK_TASK DATA COLLECTION
    --
    --*********************************************************
  WHEN p_check = 'DBA_AUTOTASK_TASK_DATA' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_AUTOTASK_TASK';
    l_bookmark := 'DBA_AUTOTASK_TASK_DATA';
    msg_num := msg_num + 1;
    msg_query_fetch := '';
    msg_query_count := '';
    msg_query_fetch := msg_query_fetch || 'SELECT CLIENT_NAME,LAST_GOOD_DATE,LAST_TRY_RESULT,MEAN_GOOD_DURATION FROM DBA_AUTOTASK_TASK';
    msg_query_count := msg_query_count || 'SELECT COUNT(*) FROM DBA_AUTOTASK_TASK';
    store_table_data (msg_num,1,'NA','query',l_cur_table,l_cur_table,'','','',msg_query_fetch,msg_query_count,'','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  11g,12c - DBA_AUTOTASK_CLIENT DATA COLLECTION
    --
    --*********************************************************
  WHEN p_check = 'DBA_AUTOTASK_CLIENT_DATA' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_AUTOTASK_CLIENT';
    l_bookmark := 'DBA_AUTOTASK_CLIENT_DATA';
    msg_num := msg_num + 1;
    msg_query_fetch := '';
    msg_query_count := '';
    msg_query_fetch := msg_query_fetch || 'SELECT * FROM DBA_AUTOTASK_CLIENT';
    msg_query_count := msg_query_count || 'SELECT COUNT(*) FROM DBA_AUTOTASK_CLIENT';
    store_table_data (msg_num,1,'NA','query',l_cur_table,l_cur_table,'','','',msg_query_fetch,msg_query_count,'','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  11g,12c - DBA_AUTOTASK_CLIENT_JOB DATA COLLECTION
    --
    --*********************************************************
  WHEN p_check = 'DBA_AUTOTASK_CLIENT_JOB_DATA' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_AUTOTASK_CLIENT_JOB';
    l_bookmark := 'DBA_AUTOTASK_CLIENT_JOB_DATA';
    msg_num := msg_num + 1;
    msg_query_fetch := '';
        msg_query_count := '';
    msg_query_fetch := msg_query_fetch || 'SELECT * FROM DBA_AUTOTASK_CLIENT_JOB';
    msg_query_count := msg_query_count || 'SELECT COUNT(*) FROM DBA_AUTOTASK_CLIENT_JOB';
    store_table_data (msg_num,1,'NA','query',l_cur_table,l_cur_table,'','','',msg_query_fetch,msg_query_count,'','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  11g,12c - DBA_AUTOTASK_JOB_HISTORY DATA COLLECTION
    --
    --*********************************************************
--  VLC fixed on 9/19/16  Added cursor logic to parsing avoid error.  Table DBA_AUTOTASK_JOB_HISTORY does not exist in 10.x
  WHEN p_check = 'DBA_AUTOTASK_JOB_HISTORY_DATA' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_AUTOTASK_JOB_HISTORY';
    l_bookmark := 'DBA_AUTOTASK_JOB_HISTORY_DATA';
    msg_num := msg_num + 1;
    msg_query_fetch := '';
    msg_query_count := '';
--    SELECT COUNT(*)
--    INTO item_found
--    FROM dba_autotask_job_history
--    WHERE JOB_ERROR != 0;
    the_count_cursor := 'SELECT COUNT(*) FROM dba_autotask_job_history WHERE JOB_ERROR != 0';
    OPEN l_cursor FOR the_count_cursor;
    FETCH l_cursor
    INTO item_found;
    CLOSE l_cursor;
    IF (item_found > 0) THEN
      msg_query_fetch := msg_query_fetch || 'SELECT * FROM DBA_AUTOTASK_JOB_HISTORY WHERE JOB_ERROR != 0 AND WINDOW_START_TIME < sysdate-7 ORDER BY WINDOW_START_TIME DESC';
      msg_query_count := msg_query_count || 'SELECT COUNT(*) FROM DBA_AUTOTASK_JOB_HISTORY WHERE JOB_ERROR != 0';
    ELSE
      msg_query_fetch := msg_query_fetch || 'SELECT * FROM DBA_AUTOTASK_JOB_HISTORY WHERE ROWNUM <= 10';
      msg_query_count := msg_query_count || 'SELECT COUNT(*) FROM DBA_AUTOTASK_JOB_HISTORY WHERE ROWNUM <= 10';
    END IF;
    store_table_data (msg_num,1,'NA','query',l_cur_table,l_cur_table,'','','',msg_query_fetch,msg_query_count,'','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  11g,12c - DBA_AUTOTASK_WINDOW_CLIENTS DATA COLLECTION
    --
    --*********************************************************
  WHEN p_check = 'DBA_AUTOTASK_WINDOW_CLIENTS_DATA' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_AUTOTASK_WINDOW_CLIENTS';
    l_bookmark := 'DBA_AUTOTASK_WINDOW_CLIENTS_DATA';
    msg_num := msg_num + 1;
    msg_query_fetch := '';
    msg_query_count := '';
    msg_query_fetch := msg_query_fetch || 'SELECT WINDOW_NAME,AUTOTASK_STATUS,OPTIMIZER_STATS,WINDOW_NEXT_TIME,WINDOW_ACTIVE,SEGMENT_ADVISOR,SQL_TUNE_ADVISOR,HEALTH_MONITOR FROM DBA_AUTOTASK_WINDOW_CLIENTS';
    msg_query_count := msg_query_count || 'SELECT COUNT(*) FROM DBA_AUTOTASK_WINDOW_CLIENTS';
    store_table_data (msg_num,1,'NA','query',l_cur_table,l_cur_table,'','','',msg_query_fetch,msg_query_count,'','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  11g,12c - DBA_AUTOTASK_OPERATION DATA COLLECTION
    --
    --*********************************************************
  WHEN p_check = 'DBA_AUTOTASK_OPERATION_DATA' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_AUTOTASK_OPERATION';
    l_bookmark := 'DBA_AUTOTASK_OPERATION_DATA';
    msg_num := msg_num + 1;
    msg_query_fetch := '';
    msg_query_count := '';
    msg_query_fetch := msg_query_fetch || 'SELECT CLIENT_NAME, STATUS FROM DBA_AUTOTASK_OPERATION';
    msg_query_count := msg_query_count || 'SELECT COUNT(*) FROM DBA_AUTOTASK_OPERATION';
    store_table_data (msg_num,1,'NA','query',l_cur_table,l_cur_table,'','','',msg_query_fetch,msg_query_count,'','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  11g,12c - DBA_AUTOTASK_SCHEDULE DATA COLLECTION
    --
    --*********************************************************
  WHEN p_check = 'DBA_AUTOTASK_SCHEDULE_DATA' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_AUTOTASK_SCHEDULE';
    l_bookmark := 'DBA_AUTOTASK_SCHEDULE_DATA';
    msg_num := msg_num + 1;
    msg_query_fetch := '';
    msg_query_count := '';
    msg_query_fetch := msg_query_fetch || 'SELECT WINDOW_NAME,START_TIME,DURATION FROM DBA_AUTOTASK_SCHEDULE WHERE start_time IN (SELECT MAX(start_time) FROM DBA_AUTOTASK_SCHEDULE GROUP BY window_name)';
    msg_query_count := msg_query_count || 'SELECT COUNT(*) FROM DBA_AUTOTASK_SCHEDULE WHERE start_time IN (SELECT MAX(start_time) FROM DBA_AUTOTASK_SCHEDULE GROUP BY window_name)';
    store_table_data (msg_num,1,'NA','query',l_cur_table,l_cur_table,'','','',msg_query_fetch,msg_query_count,'','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  11g,12c - DBA_AUTOTASK_WINDOW_HISTORY Checks
    --
    --*********************************************************
--  VLC fixed on 3/13/17 - modified count query to have where clause
	WHEN p_check = 'DBA_AUTOTASK_WINDOW_HISTORY_DATA' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_AUTOTASK_WINDOW_HISTORY';
    l_bookmark := 'DBA_AUTOTASK_WINDOW_HISTORY_DATA';
    msg_num := msg_num + 1;
    msg_query_fetch := '';
    msg_query_count := '';
    msg_query_fetch := msg_query_fetch || 'SELECT WINDOW_NAME,WINDOW_START_TIME,WINDOW_END_TIME FROM DBA_AUTOTASK_WINDOW_HISTORY WHERE WINDOW_START_TIME > sysdate -7 ORDER BY window_start_time DESC';
    msg_query_count := msg_query_count || 'SELECT COUNT(*) FROM DBA_AUTOTASK_WINDOW_HISTORY WHERE WINDOW_START_TIME > sysdate -7';
    store_table_data (msg_num,1,'NA','query',l_cur_table,l_cur_table,'','','',msg_query_fetch,msg_query_count,'','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  11g,12c - V$SESSION DATA COLLECTION
    --
    --*********************************************************
  WHEN p_check = 'V_SESSION_DATA' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'V$SESSION';
    l_bookmark := 'V$SESSION_DATA';
    msg_num := msg_num + 1;
    msg_query_fetch := '';
    msg_query_count := '';
    msg_query_fetch := msg_query_fetch || 'SELECT * FROM v$session WHERE event = ''resmgr:cpu quantum''';
    msg_query_count := msg_query_count || 'SELECT COUNT(*) FROM v$session WHERE event = ''resmgr:cpu quantum''';
    store_table_data (msg_num,1,'NA','query',l_cur_table,l_cur_table,'','','',msg_query_fetch,msg_query_count,'','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  11g,12c - DBA_RSRC_PLANS_DATA DATA COLLECTION
    --
    --*********************************************************
  WHEN p_check = 'DBA_RSRC_PLANS_DATA' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_RSRC_PLANS';
    l_bookmark := 'DBA_RSRC_PLANS_DATA';
    msg_num := msg_num + 1;
    msg_query_fetch := '';
    msg_query_count := '';
    msg_query_fetch := msg_query_fetch || 'select * from dba_rsrc_plans where plan in (' || sched_win_resource_plan || ')';
    msg_query_count := msg_query_count || 'SELECT COUNT(*) from dba_rsrc_plans where plan in (' || sched_win_resource_plan || ')';
    store_table_data (msg_num,1,'NA','query',l_cur_table,l_cur_table,'','','',msg_query_fetch,msg_query_count,'','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  11g,12c - DBA_RSRC_PLAN_DIRECTIVES DATA COLLECTION
    --
    --*********************************************************
  WHEN p_check = 'DBA_RSRC_PLAN_DIRECTIVES_DATA' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_RSRC_PLAN_DIRECTIVES';
    l_bookmark := 'DBA_RSRC_PLAN_DIRECTIVES_DATA';
    msg_num := msg_num + 1;
    msg_query_fetch := '';
    msg_query_count := '';
    msg_query_fetch := msg_query_fetch || 'SELECT * FROM DBA_RSRC_PLAN_DIRECTIVES WHERE PLAN IN (' || sched_win_resource_plan || ')';
    msg_query_count := msg_query_count || 'SELECT COUNT(*) FROM DBA_RSRC_PLAN_DIRECTIVES WHERE PLAN IN (' || sched_win_resource_plan || ')';
    store_table_data (msg_num,1,'NA','query',l_cur_table,l_cur_table,'','','',msg_query_fetch,msg_query_count,'','',l_cur_table,l_bookmark);
  ELSE
    dbms_output.put_line('Undefined Check for check_data: '||p_check);
  END CASE;
END check_data;


--*********************************************************
--
--  check_logic
--
--*********************************************************
PROCEDURE check_logic(
    p_check IN VARCHAR2,
    p_script_selected IN VARCHAR2)
IS
  check_status VARCHAR(10);
  temp_value VARCHAR(200);
  item_found NUMBER := 0;
BEGIN
  p_check_name := p_check;
  CASE
    --*********************************************************
    --
    --  DB_VERSION CHECK
    --
    --*********************************************************
--  VLC modified on 8/14/16 Added DB version check
  WHEN p_check = 'DB_VERSION' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'V$INSTANCE';
    l_bookmark := 'V_INSTANCE_DATA';
    check_status := 'PASS';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_fail := msg_str_fail || 'The Email Notifications Feature not is available for '||db_version||'.  This feature is available from 11gR2 and above. Upgrade to a latest release.' || '[[NL]]';
    msg_str_pass := msg_str_pass || 'The Email Notifications Feature is available for '||db_version||'.'||'[[NL]]';
    IF ((chkVersion(db_version, '11.1',2) = 'EQ') OR (chkVersion('10',db_version,1) = 'EQ')) THEN
      check_status := 'FAIL';
    ELSIF ((chkVersion(db_version, '11.2',2) = 'EQ') OR (chkVersion('12',db_version,1) = 'EQ')) THEN
      check_status := 'PASS';
    END IF;
    store_table_data (msg_num,1,check_status,'message','DB_VERSION','EMAIL NOTIFICATIONS FEATURE', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);

    --*********************************************************
    --
    --  DATABASE PARAMETERS Checks
    --
    --*********************************************************
--  VLC fixed on 3/13/17 The name of the check should be DATABASE_PARAMETERS not DATABASE_PARAMETERS_RESOURCE_LIMIT
	--  VLC fixed on 8/8/16  removing the "Fail message not defined" message
--  VLC fixed on 8/14/16 Adding details for the  AQ_TM_PROCESS parameter
--  VLC fixed on 7/30/16  added checks for DBMS_JOBS
--  WHEN p_check = 'DATABASE_PARAMETERS_RESOURCE_LIMIT' THEN
  WHEN p_check = 'DATABASE_PARAMETERS' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'V$PARAMETER';
    l_bookmark := 'V_PARAMETER_DATA';
    check_status := 'PASS';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';

      the_count_cursor := 'SELECT COUNT(*) FROM V$PARAMETER WHERE upper(name) = ''COMPATIBLE'' OR upper(name) = ''JOB_QUEUE_PROCESSES'' OR upper(name) = ''RESOURCE_LIMIT''';
      the_data_cursor  := 'SELECT NAME, VALUE FROM V$PARAMETER WHERE upper(name) = ''COMPATIBLE'' OR upper(name) = ''JOB_QUEUE_PROCESSES'' OR upper(name) = ''RESOURCE_LIMIT''';
      OPEN l_cursor FOR the_count_cursor;
      FETCH l_cursor
      INTO item_found;
      CLOSE l_cursor;
	  IF (item_found > 0) THEN
		OPEN l_cursor FOR the_data_cursor;
		LOOP
	    FETCH l_cursor INTO var1,var2;
	    EXIT WHEN l_cursor%notfound;
			IF (upper(var1) = 'JOB_QUEUE_PROCESSES') THEN
			msg_str_pass := msg_str_pass || 'The '||var1||' parameter is set to '|| var2 ||'. No action is required.'||'[[NL]]';
			msg_str_fail := msg_str_fail || 'The '||var1||' parameter is set to '|| var2 ||'. Ensure the JOB_QUEUE_PROCESSES parameter is set appropriately. Refer to Note:2118028.1 JOB_QUEUE_PROCESSES Parameter and its Significance.'||'[[NL]]';
				IF (p_script_selected = 'DBMS_JOBS') THEN
				-- IF count(*) from dba_jobs is higher than JOB_QUEUE_PROCESSES then fail
				--  If the max count(*) from dba_jobs group by NEXT_DATE) is higher than JOB_QUEUE_PROCESSES then fail.
					select count(*) into item_found from DBA_JOBS;
					IF (item_found > var2) THEN
					check_status := 'INFO';
					msg_str_fail := msg_str_fail || 'The number of dba jobs is '||item_found||' which higher than the value of JOB_QUEUE_PROCESSES.'||'[[NL]]';
					END IF;
					select count(*) into item_found from DBA_JOBS_RUNNING;
					IF (item_found > var2) THEN
					check_status := 'FAIL';
					msg_str_fail := msg_str_fail || 'The number of dba jobs running is '||item_found||' which higher than the value of JOB_QUEUE_PROCESSES.'||'[[NL]]';
					END IF;
					select max(count(*))  into item_found from dba_jobs group by NEXT_DATE;
					IF (item_found > var2) THEN
					check_status := 'FAIL';
					msg_str_fail := msg_str_fail || 'The number of dba jobs running is '||item_found||' which higher than the value of JOB_QUEUE_PROCESSES.'||'[[NL]]';
					END IF;

				ELSIF (((p_script_selected = 'JOB_CONFIGURATION') OR (p_script_selected = 'JOB_EXECUTION')) AND (var2 != 1000)) THEN
				check_status := 'FAIL';
				END IF;
			ELSE
			msg_str_pass := msg_str_pass || 'The '||var1||' parameter is set to '|| var2 ||'. No action is required.'||'[[NL]]';
			msg_str_fail := msg_str_fail || 'The '||var1||' parameter is set to '|| var2 ||'. No action is required.'||'[[NL]]';
			END IF;
		END LOOP;
		END IF;


	/*

    FOR i IN
    (SELECT NAME, VALUE
    FROM V$PARAMETER
    WHERE upper(name) = 'COMPATIBLE' OR upper(name) = 'JOB_QUEUE_PROCESSES' OR upper(name) = 'RESOURCE_LIMIT'
    )
    LOOP
      IF (upper(i.name) = 'JOB_QUEUE_PROCESSES') THEN
        msg_str_pass := msg_str_pass || 'The '||i.name||' parameter is set to '|| i.value ||'. No action is required.'||'[[NL]]';
        msg_str_fail := msg_str_fail || 'The '||i.name||' parameter is set to '|| i.value ||'. Ensure the JOB_QUEUE_PROCESSES parameter is set appropriately. Refer to Note:2118028.1 JOB_QUEUE_PROCESSES Parameter and its Significance.'||'[[NL]]';
        IF (p_script_selected = 'DBMS_JOBS') THEN
          select count(*) into item_found from DBA_JOBS;
          IF (item_found > i.value) THEN
            check_status := 'FAIL';
            msg_str_fail := msg_str_fail || 'The number of dba jobs is '||item_found||' which higher than the value of JOB_QUEUE_PROCESSES.'||'[[NL]]';
          END IF;
           select count(*) into item_found from DBA_JOBS_RUNNING;
          IF (item_found > i.value) THEN
            check_status := 'FAIL';
            msg_str_fail := msg_str_fail || 'The number of dba jobs running is '||item_found||' which higher than the value of JOB_QUEUE_PROCESSES.'||'[[NL]]';
          END IF;
        ELSIF (((p_script_selected = 'JOB_CONFIGURATION') OR (p_script_selected = 'JOB_EXECUTION')) AND (i.value != 1000)) THEN
          check_status := 'FAIL';
        END IF;
      ELSE
        msg_str_pass := msg_str_pass || 'The '||i.name||' parameter is set to '|| i.value ||'. No action is required.'||'[[NL]]';
        msg_str_fail := msg_str_fail || 'The '||i.name||' parameter is set to '|| i.value ||'. No action is required.'||'[[NL]]';
      END IF;
    END LOOP;

	*/
    store_table_data (msg_num,1,check_status,'message','DATABASE_PARAMETERS','DATABASE PARAMETERS', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);


    --*********************************************************
    --
    --  DATABASE PARAMETERS STATISTIC_LEVEL
    --
    --*********************************************************
--  VLC fixed on 9/19/16   Added cursor logic to avoid future parsing errors for invalid identifiers or tables that don't exist
  WHEN p_check = 'DATABASE_PARAMETERS_STATISTICS_LEVEL' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'V$PARAMETER';
    l_bookmark := 'V_PARAMETER_DATA';
    check_status := 'PASS';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_fail := msg_str_fail || 'For default maintenance jobs to work properly, you would have to set the STATISTICS_LEVEL initialization parameter to at least TYPICAL.' || '[[NL]]';
    msg_str_fail := msg_str_fail || 'To set STATISTICS_LEVEL appropriately, execute the following command: ' || '[[NL]]';
    msg_str_fail := msg_str_fail || 'ALTER SYSTEM SET STATISTICS_LEVEL=''TYPICAL'';' || '[[NL]]';
    msg_str_fail := msg_str_fail || 'Ensure to set it in the pfile /spfile also.' || '[[NL]]';
    msg_str_pass := msg_str_pass || 'The STATISTICS_LEVEL parameter is set to '|| item_value ||'. No action is required.'||'[[NL]]';

    the_data_cursor  := 'SELECT value FROM v$parameter WHERE upper(name) = ''STATISTICS_LEVEL''';
    OPEN l_cursor FOR the_data_cursor;
    FETCH l_cursor
    INTO statistic_level_param;
    CLOSE l_cursor;
    IF (upper(statistic_level_param) = 'BASIC') THEN
      check_status := 'FAIL';
    ELSIF ((upper(statistic_level_param) = 'TYPICAL') OR ( upper(statistic_level_param) = 'ALL' ) ) THEN
      check_status := 'PASS';
    END IF;
    store_table_data (msg_num,1,check_status,'message','DATABASE_PARAMETERS_STATISTICS_LEVEL','STATISTICS_LEVEL PARAMETER', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);

  --*********************************************************
  --
  --  DATABASE PARAMETERS RESOURCE_MANAGER_PLAN Checks
  --
  --*********************************************************
--  VLC fixed on 9/19/16   Added cursor logic to avoid future parsing errors for invalid identifiers or tables that don't exist
  WHEN p_check = 'DATABASE_PARAMETERS_RESOURCE_MANAGER_PLAN' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'V$PARAMETER';
    l_bookmark := 'V_PARAMETER_DATA';
    check_status := 'PASS';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    the_data_cursor  := 'SELECT value FROM v$parameter WHERE upper(name) = ''RESOURCE_MANAGER_PLAN''';
    OPEN l_cursor FOR the_data_cursor;
    FETCH l_cursor
    INTO resource_manager_plan_param;
    CLOSE l_cursor;
    IF (resource_manager_plan_param IS NOT NULL) THEN
      check_status := 'PASS';
      msg_str_pass := msg_str_pass || 'The currently active resource plan is '|| resource_manager_plan_param || '[[NL]]';
    ELSE
      check_status := 'FAIL';
      msg_str_fail := msg_str_fail || 'The resource_plan_manager parameter is not set.' || '[[NL]]';
    END IF;
    store_table_data (msg_num,1,check_status,'message','DATABASE_PARAMETERS_RESOURCE_MANAGER_PLAN','RESOURCE_MANAGER_PLAN PARAMETER', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);

    --*********************************************************
    --
    --  DATABASE_PARAMETERS_AQ_TM_PROCESS Checks
    --
    --*********************************************************
--  VLC fixed on 9/19/16   Added cursor logic to avoid future parsing errors for invalid identifiers or tables that don't exist
--  VLC modified on 8/14/16  Add this new check
  WHEN p_check = 'DATABASE_PARAMETERS_AQ_TM_PROCESS' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'V$PARAMETER';
    l_bookmark := 'V_PARAMETER_DATA';
    check_status := 'PASS';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    the_count_cursor := 'SELECT count(*) FROM v$parameter WHERE upper(name) = ''AQ_TM_PROCESS''';
    the_data_cursor  := 'SELECT value FROM v$parameter WHERE upper(name) = ''AQ_TM_PROCESS''';
    OPEN l_cursor FOR the_count_cursor;
    FETCH l_cursor
    INTO item_found;
    CLOSE l_cursor;
    IF (item_found > 0) THEN
      OPEN l_cursor FOR the_data_cursor;
      FETCH l_cursor
      INTO item_value;
      CLOSE l_cursor;
      IF (item_value > 0) THEN
        check_status := 'PASS';
        msg_str_pass := msg_str_pass || 'Queue Monitoring is enabled.  AQ_TM_PROCESS is set to '|| item_value ||'.  No action required.' || '[[NL]]';
      ELSE
        check_status := 'FAIL';
        msg_str_fail := msg_str_fail || 'Queue Monitoring is disabled. Set AQ_TM_PROCESS to 1 or above for Job Notifications to work properly.' || '[[NL]]';
      END IF;
    ELSE
      check_status := 'FAIL';
      msg_str_fail := msg_str_fail || 'Queue Monitoring is not set. Set AQ_TM_PROCESS to 1 or above for Job Notifications to work properly.' || '[[NL]]';
    END IF;
        store_table_data (msg_num,1,check_status,'message','DATABASE_PARAMETERS_AQ_TM_PROCESS','AQ_TM_PROCESS PARAMETER', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);
   --*********************************************************
    --
    --  DBA_JOBS USING DBMS_JOBS Check
    --
    --*********************************************************
--  VLC fixed on 9/19/16   Added cursor logic to avoid future parsing errors for invalid identifiers or tables that don't exist
  WHEN p_check = 'DBA_JOBS_DBMS_JOB' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_JOBS';
    l_bookmark := 'DBA_JOBS_DATA';
    check_status := 'PASS';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_fail := msg_str_fail || 'Fail message not defined.' || '[[NL]]';
    the_count_cursor := 'SELECT COUNT(*)FROM DBA_JOBS';
    OPEN l_cursor FOR the_count_cursor;
    FETCH l_cursor
    INTO dba_jobs_found;
    CLOSE l_cursor;
    IF (dba_jobs_found > 0) THEN
      msg_str_pass := msg_str_pass || 'There are '|| dba_jobs_found || ' jobs scheduled using dbms_jobs.'||'[[NL]]';
      msg_str_pass := msg_str_pass || 'Click the link below for the list of jobs.'||'[[NL]]';
    END IF;
          store_table_data (msg_num,1,check_status,'message','DBA_JOBS_DBMS_JOB','DBA_JOBS SCHEDULED USING DBMS_JOB', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);

    --*********************************************************
    --
    --  DBA_JOBS BROKEN Check
    --
    --*********************************************************
--  VLC fixed on 9/19/16   Added cursor logic to avoid future parsing errors for invalid identifiers or tables that don't exist
--  VLC fixed on 7/30/16  Added order by clause to query
  WHEN p_check = 'DBA_JOBS_BROKEN' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_JOBS';
    l_bookmark := 'DBA_JOBS_DATA';
    check_status := 'PASS';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_fail := msg_str_fail || 'The following jobs are marked as broken.' || '[[NL]]';
    msg_str_pass := msg_str_pass || 'There are no broken jobs.  No action is needed.'||'[[NL]]';
    the_count_cursor := 'SELECT COUNT(*) FROM DBA_JOBS WHERE BROKEN = ''Y''';
    the_data_cursor  := 'SELECT JOB, BROKEN, WHAT FROM DBA_JOBS WHERE BROKEN = ''Y'' ORDER BY  LAST_DATE DESC';
    OPEN l_cursor FOR the_count_cursor;
    FETCH l_cursor
    INTO item_found;
    CLOSE l_cursor;
    IF (item_found > 0) THEN
      check_status := 'FAIL';
      OPEN l_cursor FOR the_data_cursor;
      LOOP
        FETCH l_cursor INTO var1,var2,var3;
        EXIT WHEN l_cursor%notfound;
        msg_str_fail := msg_str_fail ||'JOB_ID: '||var1 ||' BROKEN: ' || var2 || ' WHAT: ' || var3 || '[[NL]]';
      END LOOP;
      CLOSE l_cursor;
      msg_str_fail := msg_str_fail || 'Refer to Note:2118423.1 How to Fix Broken Jobs.' ||'[[NL]]';
    END IF;
        store_table_data (msg_num,1,check_status,'message','DBA_JOBS_BROKEN','DBA_JOBS BROKEN', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);

    --*********************************************************
    --
    --  DBA_JOBS INSTANCE Check
    --
    --*********************************************************
--  VLC fixed on 9/19/16   Added cursor logic to avoid future parsing errors for invalid identifiers or tables that don't exist
  WHEN p_check = 'DBA_JOBS_INSTANCE' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_JOBS';
    l_bookmark := 'DBA_JOBS_DATA';
    check_status := 'PASS';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_fail := msg_str_fail || 'The following jobs are attached to specific nodes:' || '[[NL]]';
    msg_str_pass := msg_str_pass || 'There are no jobs attached to a specific node.  No action needed.'||'[[NL]]';
    the_count_cursor := 'SELECT COUNT(*) FROM DBA_JOBS WHERE INSTANCE != ''0''';
    the_data_cursor  := 'SELECT JOB, INSTANCE, WHAT FROM DBA_JOBS WHERE INSTANCE != ''0''';
    OPEN l_cursor FOR the_count_cursor;
    FETCH l_cursor
    INTO item_found;
    CLOSE l_cursor;
    IF (item_found > 0) THEN
      OPEN l_cursor FOR the_data_cursor;
      LOOP
        FETCH l_cursor INTO var1,var2,var3;
        EXIT WHEN l_cursor%notfound;
        msg_str_fail := msg_str_fail  ||'JOB_ID: '|| var1 ||' INSTANCE: ' || var2 || ' WHAT: ' || var3 || '[[NL]]';
      END LOOP;
      CLOSE l_cursor;
    END IF;
    store_table_data (msg_num,1,check_status,'message','DBA_JOBS_INSTANCE','DBA_JOBS WITH INSTANCE DEFINED', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);

    --*********************************************************
    --
    --  DBA_JOBS NEXT DATE Check
    --
    --*********************************************************
--  VLC fixed on 9/19/16   Added cursor logic to avoid future parsing errors for invalid identifiers or tables that don't exist
--  VLC fixed on 8/8/16   removing the first call to store_table_data.  Do not need 2 calls.
  WHEN p_check = 'DBA_JOBS_NEXT_DATE' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_JOBS';
    l_bookmark := 'DBA_JOBS_DATA';
    check_status := 'PASS';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_fail := msg_str_fail || 'The following jobs have the next execution date in the past. Review and take corrective action:' || '[[NL]]';
    msg_str_pass := msg_str_pass || 'There are no jobs where the next execution date is in the past.  No action needed.'||'[[NL]]';
    the_count_cursor := 'SELECT COUNT(*) FROM DBA_JOBS WHERE NEXT_DATE < SYSDATE';
    the_data_cursor  := 'SELECT JOB, NEXT_DATE FROM DBA_JOBS WHERE NEXT_DATE < SYSDATE';
    OPEN l_cursor FOR the_count_cursor;
    FETCH l_cursor
    INTO item_found;
    CLOSE l_cursor;
    IF (item_found > 0) THEN
      check_status := 'FAIL';
      OPEN l_cursor FOR the_data_cursor;
      LOOP
        FETCH l_cursor INTO var1,var2;
        EXIT WHEN l_cursor%notfound;
        msg_str_fail := msg_str_fail ||'JOB_ID: '|| var1 ||' NEXT_DATE: ' || var2 || '[[NL]]';
      END LOOP;
      CLOSE l_cursor;
      msg_str_fail := msg_str_fail  || '[[NL]]';
      msg_str_fail := msg_str_fail  || 'The next_date can be altered using dbms_jobs.change' || '[[NL]]';
      msg_str_fail := msg_str_fail  || 'DBMS_JOB.CHANGE(  JOB IN BINARY_INTEGER,' || '[[NL]]';
      msg_str_fail := msg_str_fail  || 'what                  IN VARCHAR2 DEFAULT NULL, ' || '[[NL]]';
      msg_str_fail := msg_str_fail  || 'next_date             IN DATE DEFAULT NULL,' || '[[NL]]';
      msg_str_fail := msg_str_fail  || 'interval              IN VARCHAR2 DEFAULT NULL,' || '[[NL]]';
      msg_str_fail := msg_str_fail  || 'instance              IN BINARY_INTEGER DEFAULT NULL,' || '[[NL]]';
      msg_str_fail := msg_str_fail  || 'force                 IN BOOLEAN DEFAULT FALSE );' || '[[NL]]';
      msg_str_fail := msg_str_fail  || '[[NL]]';
      msg_str_fail := msg_str_fail  || 'Example:' || '[[NL]]';
      msg_str_fail := msg_str_fail  || 'BEGIN' || '[[NL]]';
      msg_str_fail := msg_str_fail  || 'DBMS_JOB.CHANGE(14144, null, null, ''sysdate+3'');' || '[[NL]]';
      msg_str_fail := msg_str_fail  || 'COMMIT;' || '[[NL]]';
      msg_str_fail := msg_str_fail  || 'END;' || '[[NL]]';
     END IF;
    store_table_data (msg_num,1,'PASS','message','DBA_JOBS_NEXT_DATE','DBA_JOBS NEXT DATE PAST DUE', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);

    --*********************************************************
    --
    --  DBA_JOBS NLS_ENV or MISC_ENV  Check
    --
    --*********************************************************
--  VLC fixed on 9/19/16   Added cursor logic to avoid future parsing errors for invalid identifiers or tables that don't exist
  WHEN p_check = 'DBA_JOBS_NLS_ENV_MISC_ENV' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_JOBS';
    l_bookmark := 'DBA_JOBS_DATA';
    check_status := 'PASS';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_fail := msg_str_fail || 'The following jobs have custom session parameters defined:' || '[[NL]]';
    msg_str_pass := msg_str_pass || 'There are no jobs with custom session paramters defined.  No action needed.'||'[[NL]]';
    the_count_cursor := 'SELECT COUNT(*) FROM DBA_JOBS';
    the_data_cursor  := 'SELECT JOB, NLS_ENV, MISC_ENV FROM DBA_JOBS WHERE (NLS_ENV IS NOT NULL) OR (MISC_ENV IS NOT NULL)';
    OPEN l_cursor FOR the_count_cursor;
    FETCH l_cursor
    INTO item_found;
    CLOSE l_cursor;
    IF (item_found > 0) THEN
      check_status := 'FAIL';
      OPEN l_cursor FOR the_data_cursor;
    LOOP
      FETCH l_cursor INTO var1,var2,var3;
      EXIT WHEN l_cursor%notfound;
      msg_str_fail := msg_str_fail ||'JOB_ID: '|| var1 ||' NLS_ENV: ' || var2 || ' MISC_ENV: ' || var3 || '[[NL]]';
    END LOOP;
    CLOSE l_cursor;
   END IF;
    store_table_data (msg_num,1,check_status,'message','DBA_JOBS_NLS_ENV_MISC_ENV','DBA_JOBS NLS_ENV or MISC_ENV', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);

    --*********************************************************
    --
    --  DBA_JOBS_RUNNING Checks
    --
    --*********************************************************
--  VLC fixed on 10/2/16   Added cursor logic to avoid future parsing errors for invalid identifiers or tables that don't exist
--  VLC fixed on 10/2/16   Added query for number of jobs running. Added job count to pass message.
  WHEN p_check = 'DBA_JOBS_RUNNING_CHK' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_JOBS_RUNNING';
    l_bookmark := 'DBA_JOBS_RUNNING_DATA';
    check_status := 'INFO';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    the_count_cursor := 'SELECT COUNT(*) from DBA_JOBS_RUNNING';
    OPEN l_cursor FOR the_count_cursor;
    FETCH l_cursor
    INTO item_found;
    CLOSE l_cursor;
    msg_str_pass := msg_str_pass ||item_found||' jobs (scheduled using DBMS_JOB) are executing currently.'||'[[NL]]';
    msg_str_pass := msg_str_pass || 'Click the link below for a list of jobs currently running in the database.'||'[[NL]]';
    store_table_data (msg_num,1,check_status,'message','DBA_JOBS_RUNNING_CHK','DBA_JOBS_RUNNING', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  DBMS_SCHEDULER.STIME CHECK
    --
    --*********************************************************
  WHEN p_check = 'DBMS_SCHEDULER_STIME' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBMS_SCHEDULER.STIME';
    l_bookmark := 'DBMS_SCHEDULER_STIME_DATA';
    check_status := 'PASS';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_fail := msg_str_fail || 'The default timezone for the scheduler is not set. It is recommended to set it according to the timezone in which the jobs are scheduled to run.' || '[[NL]]';
    msg_str_fail := msg_str_fail || 'For example:' || '[[NL]]';
    msg_str_fail := msg_str_fail || 'BEGIN ' || '[[NL]]';
    msg_str_fail := msg_str_fail || 'DBMS_SCHEDULER.set_scheduler_attribute (attribute => ''default_timezone'',value => ''US/Eastern'');' || '[[NL]]';
    msg_str_fail := msg_str_fail || 'END; ' || '[[NL]]';
    msg_str_fail := msg_str_fail || '/' || '[[NL]]';
    msg_str_fail := msg_str_fail || 'Refer to Doc ID 1488157.1 for more information.' || '[[NL]]';
    msg_str_pass := msg_str_pass || 'The default timezone for the scheduler is set as recommended.'||'[[NL]]';
    SELECT COUNT(*) INTO item_found FROM DUAL GROUP BY DBMS_SCHEDULER.STIME;
    IF item_found = 0 THEN
      check_status := 'FAIL';
    ELSE
      SELECT DBMS_SCHEDULER.STIME INTO item_value FROM DUAL;
      check_status := 'PASS';
      msg_str_pass := msg_str_pass  || 'The default timezone of the scheduler is '||item_value||'.' || '[[NL]]';
      msg_str_pass := msg_str_pass  || 'If you want to change the stime (or default timezone) use DBMS_SCHEDULER.set_scheduler_attribute. For example:' || '[[NL]]';
      msg_str_pass := msg_str_pass  || 'BEGIN' || '[[NL]]';
      msg_str_pass := msg_str_pass  || 'DBMS_SCHEDULER.set_scheduler_attribute (attribute => ''default_timezone'',value => ''US/Eastern'');' || '[[NL]]';
      msg_str_pass := msg_str_pass  || 'END;' || '[[NL]]';
      msg_str_pass := msg_str_pass  || '/' || '[[NL]]';
      msg_str_pass := msg_str_pass  || 'Refer to Doc ID 1488157.1 for more information.' || '[[NL]]';
    END IF;
        store_table_data (msg_num,1,check_status,'message','DBMS_SCHEDULER_STIME','DEFAULT TIMEZONE STATE', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);

    --*********************************************************
    --
    --  DBA_SCHEDULER_GLOBAL_ATTRIBUTE SCHEDULER DISABLED Check
    --
    --*********************************************************
--  VLC fixed on 10/2/16   Added cursor logic to avoid future parsing errors for invalid identifiers or tables that don't exist
  WHEN p_check = 'DBA_SCHEDULER_GLOBAL_ATTRIBUTE_SCHEDULER_DISABLED' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_GLOBAL_ATTRIBUTE';
    l_bookmark := 'DBA_SCHEDULER_GLOBAL_ATTRIBUTE_DATA';
    check_status := 'PASS';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_fail := msg_str_fail || 'Scheduler is disabled. Run the following command to enable the scheduler: ' || '[[NL]]';
    msg_str_fail := msg_str_fail || 'exec DBMS_SCHEDULER.set_scheduler_attribute(''SCHEDULER_DISABLED'', ''FALSE'');' || '[[NL]]';
    msg_str_pass := msg_str_pass || 'Scheduler is enabled. No action required.' || '[[NL]]';
    the_count_cursor := 'SELECT COUNT(*) FROM DBA_SCHEDULER_GLOBAL_ATTRIBUTE WHERE upper(ATTRIBUTE_NAME) = ''SCHEDULER_DISABLED''';
    the_data_cursor  := 'SELECT value FROM DBA_SCHEDULER_GLOBAL_ATTRIBUTE WHERE upper(ATTRIBUTE_NAME) = ''SCHEDULER_DISABLED''';
    OPEN l_cursor FOR the_count_cursor;
    FETCH l_cursor
    INTO item_found;
    CLOSE l_cursor;
    IF (item_found > 0) THEN
    OPEN l_cursor FOR the_data_cursor;
    LOOP
      FETCH l_cursor INTO var1;
      EXIT WHEN l_cursor%notfound;
      IF (var1 = 'TRUE') THEN
        check_status := 'FAIL';
      END IF;
    END LOOP;
    CLOSE l_cursor;
    END IF;
    store_table_data (msg_num,1,check_status,'message','DBA_SCHEDULER_GLOBAL_ATTRIBUTE_SCHEDULER_DISABLED','DBA_SCHEDULER_GLOBAL_ATTRIBUTE: SCHEDULER_DISABLED', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);

    --*********************************************************
    --
    --  DBA_SCHEDULER_GLOBAL_ATTRIBUTE CURRENT OPEN WINDOW Check
    --
    --*********************************************************
--  VLC fixed on 10/2/16   Added cursor logic to avoid future parsing errors for invalid identifiers or tables that don't exist
--  VLC fixed on 10/2/16   check_status will alwasy be INFO.  Only setting the pass message.
  WHEN p_check = 'DBA_SCHEDULER_GLOBAL_ATTRIBUTE_CURRENT_OPEN_WINDOW' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_GLOBAL_ATTRIBUTE';
    l_bookmark := 'DBA_SCHEDULER_GLOBAL_ATTRIBUTE_DATA';
    check_status := 'INFO';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';

    the_count_cursor := 'SELECT COUNT(*) FROM DBA_SCHEDULER_GLOBAL_ATTRIBUTE WHERE upper(ATTRIBUTE_NAME) = ''CURRENT_OPEN_WINDOW''';
    the_data_cursor  := 'SELECT VALUE FROM DBA_SCHEDULER_GLOBAL_ATTRIBUTE WHERE upper(ATTRIBUTE_NAME) = ''CURRENT_OPEN_WINDOW''';
    OPEN l_cursor FOR the_count_cursor;
    FETCH l_cursor
    INTO item_found;
    CLOSE l_cursor;
    IF (item_found > 0) THEN
    OPEN l_cursor FOR the_data_cursor;
    LOOP
      FETCH l_cursor INTO var1;
      EXIT WHEN l_cursor%notfound;
      IF (var1 IS NOT NULL) THEN
        check_status := 'FAIL';
         msg_str_pass := msg_str_pass  || 'The Window which is currently opened is '||var1|| '. If this is not expected, close the window using DBMS_SCHEDULER.close_window. For example:' || '[[NL]]';
         msg_str_pass := msg_str_pass  || 'exec DBMS_SCHEDULER.close_window (''WEEKNIGHT_WINDOW'');' || '[[NL]]';
      ELSE
        msg_str_pass := msg_str_pass || 'No Windows are open currently.' || '[[NL]]';
      END IF;
    END LOOP;
    CLOSE l_cursor;
    ELSE
    msg_str_pass := msg_str_pass || 'No Windows are open currently.' || '[[NL]]';
    END IF;
    store_table_data (msg_num,1,check_status,'message','DBA_SCHEDULER_GLOBAL_ATTRIBUTE_CURRENT_OPEN_WINDOW','DBA_SCHEDULER_GLOBAL_ATTRIBUTE: CURRENT_OPEN_WINDOW', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);

    --*********************************************************
    --
    --  DBA_SCHEDULER_GLOBAL_ATTRIBUTE DEFAULT TIMEZONE Check
    --
    --*********************************************************
--  VLC fixed on 10/2/16   Added cursor logic to avoid future parsing errors for invalid identifiers or tables that don't exist
--  VLC fixed on 10/2/16   Changed status to be always be INFO
--  VLC fixed on 10/2/16   Changed logic and messages
  WHEN p_check = 'DBA_SCHEDULER_GLOBAL_ATTRIBUTE_DEFAULT_TIMEZONE' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_GLOBAL_ATTRIBUTE';
    l_bookmark := 'DBA_SCHEDULER_GLOBAL_ATTRIBUTE_DATA';
    check_status := 'INFO';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';

    the_count_cursor := 'SELECT COUNT(*)FROM DBA_SCHEDULER_GLOBAL_ATTRIBUTE WHERE upper(ATTRIBUTE_NAME) = ''DEFAULT_TIMEZONE''';
    the_data_cursor  := 'SELECT VALUE FROM DBA_SCHEDULER_GLOBAL_ATTRIBUTE WHERE upper(ATTRIBUTE_NAME) = ''DEFAULT_TIMEZONE''';
    OPEN l_cursor FOR the_count_cursor;
    FETCH l_cursor
    INTO item_found;
    CLOSE l_cursor;
    IF (item_found > 0) THEN
    OPEN l_cursor FOR the_data_cursor;
    LOOP
      FETCH l_cursor INTO var1;
      EXIT WHEN l_cursor%notfound;
      IF (var1 IS NULL) THEN
        msg_str_pass := msg_str_pass || 'Scheduler timezone is not set. If this is not correct, refer Doc ID 1488157.1 for details on how to modify the timezone.' || '[[NL]]';
      ELSE
        msg_str_pass := msg_str_pass || 'The current scheduler timezone is '||var1||'. If this is not correct, refer Doc ID 1488157.1 for details on how to modify the timezone.' || '[[NL]]';
      END IF;
    END LOOP;
    CLOSE l_cursor;
    ELSE
        msg_str_pass := msg_str_pass || 'Scheduler timezone is not set. If this is not correct, refer Doc ID 1488157.1 for details on how to modify the timezone.' || '[[NL]]';
    END IF;
    store_table_data (msg_num,1,check_status,'message','DBA_SCHEDULER_GLOBAL_ATTRIBUTE_DEFAULT_TIMEZONE','DBA_SCHEDULER_GLOBAL_ATTRIBUTE: DEFAULT_TIMEZONE', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);

    --*********************************************************
    --
    --  DBA_SCHEDULER_GLOBAL_ATTRIBUTE ATTRIBUTE LOG HISTORY Check
    --
    --*********************************************************
--  VLC fixed on 10/2/16   Added cursor logic to avoid future parsing errors for invalid identifiers or tables that don't exist
--  VLC fixed on 10/2/16   Changed status to be always be INFO
--  VLC fixed on 10/2/16   Changed message to be a pass message
  WHEN p_check = 'DBA_SCHEDULER_GLOBAL_ATTRIBUTE_LOG_HISTORY' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_GLOBAL_ATTRIBUTE';
    l_bookmark := 'DBA_SCHEDULER_GLOBAL_ATTRIBUTE_DATA';
    check_status := 'INFO';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    the_count_cursor := 'SELECT COUNT(*)FROM DBA_SCHEDULER_GLOBAL_ATTRIBUTE WHERE upper(ATTRIBUTE_NAME) = ''LOG_HISTORY''';
    the_data_cursor  := 'SELECT VALUE FROM DBA_SCHEDULER_GLOBAL_ATTRIBUTE WHERE upper(ATTRIBUTE_NAME) = ''LOG_HISTORY''';
    OPEN l_cursor FOR the_count_cursor;
    FETCH l_cursor
    INTO item_found;
    CLOSE l_cursor;
    IF (item_found > 0) THEN
    OPEN l_cursor FOR the_data_cursor;
    LOOP
      FETCH l_cursor INTO var1;
      EXIT WHEN l_cursor%notfound;
      IF (item_value IS NOT NULL) THEN
        msg_str_pass := msg_str_pass  || 'The log entries for job log and window log are retained for '||var1||'.' || '[[NL]]';
        msg_str_pass := msg_str_pass  || 'Note: This is the global setting. The value set for the Job Class takes precedence. This can be checked from dba_scheduler_job_classes.' || '[[NL]]';
        msg_str_pass := msg_str_pass  || 'Example of how to set the log history as a global attribute to the value of 10:' || '[[NL]]';
        msg_str_pass := msg_str_pass  || 'BEGIN' || '[[NL]]';
        msg_str_pass := msg_str_pass  || 'DBMS_SCHEDULER.set_scheduler_attribute (attribute => ''LOG_HISTORY'',value => 10);' || '[[NL]]';
        msg_str_pass := msg_str_pass  || 'End;' || '[[NL]]';
        msg_str_pass := msg_str_pass  || '/' || '[[NL]]';
        msg_str_pass := msg_str_pass  || 'Example of how to set the log history for the default_job_class to a value of 15:' || '[[NL]]';
        msg_str_pass := msg_str_pass  || 'BEGIN' || '[[NL]]';
        msg_str_pass := msg_str_pass  || 'DBMS_SCHEDULER.set_attribute(name => ''DEFAULT_JOB_CLASS'',attribute => ''log_history'',value => 15);' || '[[NL]]';
        msg_str_pass := msg_str_pass  || 'End;' || '[[NL]]';
        msg_str_pass := msg_str_pass  || '/' || '[[NL]]';
      END IF;
    END LOOP;
    CLOSE l_cursor;
   END IF;
   store_table_data (msg_num,1,check_status,'message','DBA_SCHEDULER_GLOBAL_ATTRIBUTE_LOG_HISTORY','DBA_SCHEDULER_GLOBAL_ATTRIBUTE: LOG_HISTORY', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);

    --*********************************************************
    --
    --  DBA_SCHEDULER_GLOBAL_ATTRIBUTE EMAIL SERVER Check
    --
    --*********************************************************
-- VLC fixed on 10/2/16   Added cursor logic to avoid future parsing errors for invalid identifiers or tables that don't exist
-- VLC modified on 8/14/16  updating logic per Susan.  Changed logic to handle no record found condition.
-- VLC modified on 8/14/16  Changed pass and fail message.  Changed check status from PASS to INFO
  WHEN p_check = 'DBA_SCHEDULER_GLOBAL_ATTRIBUTE_EMAIL_SERVER' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_GLOBAL_ATTRIBUTE';
    l_bookmark := 'DBA_SCHEDULER_GLOBAL_ATTRIBUTE_DATA';
    check_status := 'INFO';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_fail := msg_str_fail || 'EMAIL_SERVER is not configured. To configure EMAIL_SERVER do the following:' || '[[NL]]';
    msg_str_fail := msg_str_fail || 'exec DBMS_SCHEDULER.SET_SCHEDULER_ATTRIBUTE(''email_server'',''host[:port]'');' || '[[NL]]';
    msg_str_fail := msg_str_fail || 'Refer to DOC ID 1107813.1 for details.' || '[[NL]]';
    the_count_cursor := 'SELECT COUNT(*)FROM DBA_SCHEDULER_GLOBAL_ATTRIBUTE WHERE upper(ATTRIBUTE_NAME) = ''EMAIL_SERVER''';
    the_data_cursor  := 'SELECT VALUE FROM DBA_SCHEDULER_GLOBAL_ATTRIBUTE WHERE upper(ATTRIBUTE_NAME) = ''EMAIL_SERVER''';
    OPEN l_cursor FOR the_count_cursor;
    FETCH l_cursor
    INTO item_found;
    CLOSE l_cursor;
    IF (item_found > 0) THEN
    OPEN l_cursor FOR the_data_cursor;
    LOOP
      FETCH l_cursor INTO var1;
      EXIT WHEN l_cursor%notfound;
      IF (var1 IS NOT NULL) THEN
        check_status := 'INFO';
        msg_str_pass := msg_str_pass || 'The Email Server for job notifications is set.' || '[[NL]]';
        msg_str_pass := msg_str_pass || 'Ensure that '||var1||' is valid and resolvable by using ping or telnet.' || '[[NL]]';
       ELSE
        check_status := 'FAIL';
      END IF;
    END LOOP;
    CLOSE l_cursor;
    ELSE
        check_status := 'FAIL';
    END IF;
    store_table_data (msg_num,1,check_status,'message','DBA_SCHEDULER_GLOBAL_ATTRIBUTE_EMAIL_SERVER','DBA_SCHEDULER_GLOBAL_ATTRIBUTE: EMAIL_SERVER', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);

    --*********************************************************
    --
    --  DBA_SCHEDULER_GLOBAL_ATTRIBUTE EMAIL SENDER Check
    --
    --*********************************************************
--  VLC fixed on 10/2/16   Added cursor logic to avoid future parsing errors for invalid identifiers or tables that don't exist
-- VLC modified on 8/14/16  updating logic per Susan.  Changed logic to handle no record found condition.
-- VLC modified on 8/14/16  Changed pass and fail message.  Changed check status from PASS to INFO
  WHEN p_check = 'DBA_SCHEDULER_GLOBAL_ATTRIBUTE_EMAIL_SENDER' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_GLOBAL_ATTRIBUTE';
    l_bookmark := 'DBA_SCHEDULER_GLOBAL_ATTRIBUTE_DATA';
    check_status := 'INFO';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_fail := msg_str_fail || 'EMAIL_SENDER is not configured. To configure EMAIL_SENDER do the following:' || '[[NL]]';
    msg_str_fail := msg_str_fail || 'exec DBMS_SCHEDULER.SET_SCHEDULER_ATTRIBUTE(''email_sender'',''valid email address'');' || '[[NL]]';
    msg_str_fail := msg_str_fail || 'Refer to DOC ID 1107813.1 for details.' || '[[NL]]';

    the_count_cursor := 'SELECT COUNT(*)FROM DBA_SCHEDULER_GLOBAL_ATTRIBUTE WHERE upper(ATTRIBUTE_NAME) = ''EMAIL_SENDER''';
    the_data_cursor  := 'SELECT VALUE FROM DBA_SCHEDULER_GLOBAL_ATTRIBUTE WHERE upper(ATTRIBUTE_NAME) = ''EMAIL_SENDER''';
    OPEN l_cursor FOR the_count_cursor;
    FETCH l_cursor
    INTO item_found;
    CLOSE l_cursor;
    IF (item_found > 0) THEN
    OPEN l_cursor FOR the_data_cursor;
    LOOP
      FETCH l_cursor INTO var1;
      EXIT WHEN l_cursor%notfound;
      IF (var1 IS NOT NULL) THEN
        check_status := 'INFO';
        msg_str_pass := msg_str_pass || 'The default Email Sender for job notifications is set.' || '[[NL]]';
        msg_str_pass := msg_str_pass || 'Ensure that '||var1||' is a valid email address.' || '[[NL]]';       ELSE
        check_status := 'FAIL';
      END IF;
    END LOOP;
    CLOSE l_cursor;
    ELSE
        check_status := 'FAIL';
    END IF;
    store_table_data (msg_num,1,check_status,'message','DBA_SCHEDULER_GLOBAL_ATTRIBUTE_EMAIL_SENDER','DBA_SCHEDULER_GLOBAL_ATTRIBUTE: EMAIL_SENDER', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);

    --*********************************************************
    --
    --  DBA_OBJECTS DBMS_SCHEDULER CHECK
    --
    --*********************************************************
  WHEN p_check = 'DBA_OBJECTS_DBMS_SCHEDULER' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_OBJECTS';
    l_bookmark := 'DBA_OBJECTS_DBMS_SCHEDULER_DATA';
    check_status := 'PASS';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_fail := msg_str_fail || 'One or more of the DBMS_SCHEDULER objects has an invalid status. ' || '[[NL]]';
    msg_str_pass := msg_str_pass || 'All DBMS_SCHEDULER objects have a valid status.  No action is required.' || '[[NL]]';
    FOR i IN
    (SELECT * FROM DBA_OBJECTS WHERE OBJECT_NAME = 'DBMS_SCHEDULER'
    )
    LOOP
      IF i.STATUS != 'VALID' THEN
        check_status := 'FAIL';
        msg_str_fail := msg_str_fail || 'Validate the objects using the utlrp.sql script.' || '[[NL]]';
      END IF;
    END LOOP;
	store_table_data (msg_num,1,check_status,'message','DBA_OBJECTS_DBMS_SCHEDULER','DBMS_SCHEDULER OBJECT STATUS', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);

    --*********************************************************
    --
    --  DBA_OBJECTS JOB Checks
    --
    --*********************************************************
  WHEN p_check = 'DBA_OBJECTS_JOB' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_OBJECTS';
    l_bookmark := 'DBA_OBJECTS_JOB_DATA';
    check_status := 'PASS';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_fail := msg_str_fail || 'The default maintenance jobs do not exist. It can be recreated by running the following scripts: ' || '[[NL]]';
    msg_str_fail := msg_str_fail || t_common_message(1).msg_body;
    msg_str_pass := msg_str_pass || 'The default maintenance jobs do exist. No action is required.' || '[[NL]]';
    SELECT COUNT(*)
    INTO dba_objects_job_found
    FROM dba_objects
    WHERE upper(object_type) = 'JOB' AND ((upper(object_name) = 'AUTO_SPACE_ADVISOR_JOB') OR (upper(object_name) = 'GATHER_STATS_JOB'));
    IF (dba_objects_job_found < 2) THEN
      check_status := 'FAIL';
    END IF;
    store_table_data (msg_num,1,check_status,'message','DBA_OBJECTS_JOB','MAINTENANCE JOB MISSING', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);

   --*********************************************************
    --
    --  DBA_SCHEDULER_RUNNING_JOBS Checks
    --
    --*********************************************************
--  VLC fixed on 10/2/16   Added cursor logic to avoid future parsing errors for invalid identifiers or tables that don't exist
--  VLC fixed on 10/2/16   Changed status to be always be INFO
  WHEN p_check = 'DBA_SCHEDULER_RUNNING_JOBS' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_RUNNING_JOBS';
    l_bookmark := 'DBA_SCHEDULER_RUNNING_JOBS_DATA';
    check_status := 'INFO';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_fail := msg_str_fail || 'Fail message not defined.' || '[[NL]]';
    the_count_cursor := 'SELECT COUNT(*)FROM DBA_SCHEDULER_RUNNING_JOBS';
    OPEN l_cursor FOR the_count_cursor;
    FETCH l_cursor
    INTO item_found;
    CLOSE l_cursor;
    IF item_found > 0 THEN
      msg_str_pass := msg_str_pass || 'The number of scheduler jobs currently running in the database is '||item_value||'.  No action required.' || '[[NL]]';
    ELSE
      msg_str_pass := msg_str_pass || 'There are no scheduler jobs currently running in the database.  No action required.' || '[[NL]]';
    END IF;
	store_table_data (msg_num,1,check_status,'message','DBA_SCHEDULER_RUNNING_JOBS','DBA_SCHEDULER_RUNNING_JOBS RUNNING', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  DBA_SCHEDULER_RUNNING_JOBS JOB_NAME Checks
    --
    --  VLCFIX For the next version of the script, provide hyperlinks for the jobs data if possible.
    --*********************************************************

  WHEN p_check = 'DBA_SCHEDULER_RUNNING_JOBS_JOB_NAME' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_RUNNING_JOBS';
    l_bookmark := 'DBA_SCHEDULER_JOBS_DATA';  -- Need to see data from scheduler jobs not scheduler running
    check_status := 'INFO';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_fail := msg_str_fail || 'Fail message not defined.' || '[[NL]]';
    SELECT COUNT(*) INTO item_found FROM DBA_SCHEDULER_RUNNING_JOBS WHERE JOB_NAME in (SELECT JOB_NAME FROM DBA_SCHEDULER_JOBS  WHERE LAST_START_DATE > sysdate+7 );
    IF (item_found > 0) THEN
    msg_str_pass := msg_str_pass || 'The following jobs are not default database jobs:' || '[[NL]]';
    FOR i IN
    (SELECT JOB_NAME FROM DBA_SCHEDULER_RUNNING_JOBS WHERE JOB_NAME in (SELECT JOB_NAME FROM DBA_SCHEDULER_JOBS))
    LOOP
      msg_str_pass := msg_str_pass || 'Job Name: ['||i.JOB_NAME||']' || '[[NL]]';
    END LOOP;
    ELSE
        msg_str_pass :=  msg_str_pass || 'There are no default database jobs.  No action required.' || '[[NL]]';
    END IF;

    SELECT COUNT(*) INTO item_found FROM DBA_SCHEDULER_RUNNING_JOBS WHERE JOB_NAME not in (SELECT JOB_NAME FROM DBA_SCHEDULER_JOBS  WHERE LAST_START_DATE > sysdate+7);
    IF (item_found > 0) THEN
    msg_str_pass := msg_str_pass || 'The following jobs are default database jobs:' || '[[NL]]';
    FOR i IN
    (SELECT JOB_NAME FROM DBA_SCHEDULER_RUNNING_JOBS WHERE JOB_NAME not in (SELECT JOB_NAME FROM DBA_SCHEDULER_JOBS))
    LOOP
      msg_str_pass := msg_str_pass || 'Job Name: ['||i.JOB_NAME||']' || '[[NL]]';
    END LOOP;
    ELSE
        msg_str_pass :=  msg_str_pass || 'There are no default database jobs.  No action required.' || '[[NL]]';
    END IF;
    store_table_data (msg_num,1,check_status,'message','DBA_SCHEDULER_RUNNING_JOBS_JOB_NAME','DBA_SCHEDULER_RUNNING_JOBS JOB_NAME', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);



    --*********************************************************
    --
    --  DBA_SCHEDULER_JOBS SCHEDULED Check
    --
    --*********************************************************
--  VLC fixed on 10/2/16   Added cursor logic to avoid future parsing errors for invalid identifiers or tables that don't exist
--  VLC fixed on 10/2/16   Changed status to be always be INFO
  WHEN p_check = 'DBA_SCHEDULER_JOBS_SCHEDULED' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_JOBS';
    l_bookmark := 'DBA_SCHEDULER_JOBS_DATA';
    check_status := 'INFO';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    the_count_cursor := 'SELECT COUNT(*)FROM DBA_SCHEDULER_JOBS';
    OPEN l_cursor FOR the_count_cursor;
    FETCH l_cursor
    INTO scheduler_jobs_found;
    CLOSE l_cursor;
    IF scheduler_jobs_found > 0 THEN
      msg_str_pass := msg_str_pass ||scheduler_jobs_found||' jobs are scheduled using dbms_jobs.  No action required.' || '[[NL]]';
    END IF;
    store_table_data (msg_num,1,check_status,'message','DBA_SCHEDULER_JOBS_SCHEDULED','DBA_SCHEDULER_JOBS SCHEDULED', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);

    --*********************************************************
    --
    --  DBA_SCHEDULER_JOBS CREDENTIAL_NAME Check
    --
    --*********************************************************
--  VLC fixed on 10/2/16   Changed status to be always be INFO
--  VLC fixed on 9/19/16  Added cursor to eliminate error about invalid identifier "CREDENTIAL_NAME"
  WHEN p_check = 'DBA_SCHEDULER_JOBS_CREDENTIAL_NAME' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_JOBS';
    l_bookmark := 'DBA_SCHEDULER_JOBS_DATA';
    check_status := 'INFO';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    the_count_cursor := 'SELECT COUNT(*) FROM DBA_SCHEDULER_JOBS WHERE JOB_TYPE = ''EXECUTABLE'' AND CREDENTIAL_NAME IS NULL';
    OPEN l_cursor FOR the_count_cursor;
    FETCH l_cursor
    INTO item_found;
    CLOSE l_cursor;
    IF ((item_found > 0) and ((chkVersion(db_version, '11.2',2) = 'EQ') OR (chkVersion('10',db_version,1) = 'EQ')))THEN
      msg_str_pass := msg_str_pass || 'Oracle recommends using credentials for all local and remote external jobs as the default values may be deprecated in the future. Create the credential using DBMS_SCHEDULER.CREATE_CREDENTIAL. Add the credentials to the job using dbms_scheduler.set_attribute.' || '[[NL]]';
    ELSIF ((item_found > 0) and (chkVersion('12',db_version,1) = 'EQ')) THEN
      msg_str_pass := msg_str_pass || 'Oracle recommends using credentials for all local and remote external jobs as the default values may be deprecated in the future. Create the credential using DBMS_CREDENTIAL. Add the credentials to the job using dbms_scheduler.set_attribute.' || '[[NL]]';
    ELSE
        msg_str_pass := msg_str_pass || 'All external jobs are running with credentials.  No action required.' || '[[NL]]';
    END IF;
    store_table_data (msg_num,1,check_status,'message','DBA_SCHEDULER_JOBS_CREDENTIAL_NAME','DBA_SCHEDULER_JOBS CREDENTIAL_NAME', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);

    --*********************************************************
    --
    --  DBA_SCHEDULER_JOBS PERMISSION Check
    --
    --*********************************************************
  WHEN p_check = 'DBA_SCHEDULER_JOBS_PERMISSION' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_JOBS';
    l_bookmark := 'DBA_SCHEDULER_JOBS_DATA';
    check_status := 'INFO';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_pass := msg_str_pass || 'Ensure that the full path and the name of the executable and/or scripts are defined for each job. Check Doc ID 389685.1 for more details.' || '[[NL]]';
    msg_str_fail := msg_str_fail || 'Fail message not defined.'  || '[[NL]]';
    SELECT COUNT(*) INTO item_found FROM DBA_SCHEDULER_JOBS WHERE JOB_TYPE = 'EXECUTABLE' ;
    IF item_found > 0 THEN
      FOR i IN
      (SELECT OWNER, JOB_NAME, JOB_ACTION, PROGRAM_NAME
      FROM DBA_SCHEDULER_JOBS
      WHERE JOB_TYPE ='EXECUTABLE'
      )
      LOOP
        msg_str_pass := msg_str_pass || 'JOB_OWNER: '||i.OWNER|| 'JOB_NAME: '||i.JOB_NAME||'  JOB_ACTION: '||i.JOB_ACTION||'  PROGRAM_NAME: '||i.PROGRAM_NAME||  '[[NL]]';
      END LOOP;
    END IF;
    store_table_data (msg_num,1,check_status,'message','DBA_SCHEDULER_JOBS_PERMISSION','DBA_SCHEDULER_JOBS PERMISSION', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);

    --*********************************************************
    --
    --  DBA_SCHEDULER_JOBS JOB_ACTION Check
    --
    --*********************************************************
--  VLC fixed on 10/2/16   Added cursor logic to avoid future parsing errors for invalid identifiers or tables that don't exist
  WHEN p_check = 'DBA_SCHEDULER_JOBS_JOB_ACTION' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_JOBS';
    l_bookmark := 'DBA_SCHEDULER_JOBS_DATA';
    check_status := 'PASS';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_pass := msg_str_pass || 'No external jobs are calling a batch file directly.  No action required.' || '[[NL]]';
    msg_str_fail := msg_str_fail || 'A batch file (ending in .bat) cannot be called directly by the Scheduler. Instead a cmd.exe must be used and the name of the batch file passed in as an argument.' || '[[NL]]';
    msg_str_fail := msg_str_fail || 'For example:' || '[[NL]]';
    msg_str_fail := msg_str_fail || 'begin' || '[[NL]]';
    msg_str_fail := msg_str_fail || 'dbms_scheduler.create_job(''myjob'',' || '[[NL]]';
    msg_str_fail := msg_str_fail || 'job_action=>''C:\WINDOWS\SYSTEM32\CMD.EXE'',' || '[[NL]]';
    msg_str_fail := msg_str_fail || 'number_of_arguments=>3,' || '[[NL]]';
    msg_str_fail := msg_str_fail || 'job_type=>''executable'', enabled=>false);' || '[[NL]]';
    msg_str_fail := msg_str_fail || 'dbms_scheduler.set_job_argument_value(''myjob'',1,''/q'');' || '[[NL]]';
    msg_str_fail := msg_str_fail || 'dbms_scheduler.set_job_argument_value(''myjob'',2,''/c'');' || '[[NL]]';
    msg_str_fail := msg_str_fail || 'dbms_scheduler.set_job_argument_value(''myjob'',3,''c:\temp\test.bat'');' || '[[NL]]';
    msg_str_fail := msg_str_fail || 'dbms_scheduler.enable(''myjob'');' || '[[NL]]';
    msg_str_fail := msg_str_fail || 'end;' || '[[NL]]';
    msg_str_fail := msg_str_fail || '/' || '[[NL]]';
    msg_str_fail := msg_str_fail || 'The following jobs are configured incorrectly:' || '[[NL]]';
    the_count_cursor := 'SELECT COUNT(*) FROM DBA_SCHEDULER_JOBS WHERE upper(JOB_ACTION) like ''%.BAT%''';
    the_data_cursor  := 'SELECT OWNER, JOB_NAME, JOB_ACTION FROM DBA_SCHEDULER_JOBS WHERE upper(JOB_ACTION) like ''%.BAT%''';
    OPEN l_cursor FOR the_count_cursor;
    FETCH l_cursor
    INTO item_found;
    CLOSE l_cursor;
    IF (item_found > 0) THEN
    OPEN l_cursor FOR the_data_cursor;
    LOOP
      FETCH l_cursor INTO var1,var2,var3;
      EXIT WHEN l_cursor%notfound;
      msg_str_fail := msg_str_fail || 'JOB_OWNER: '||var1|| 'JOB_NAME: '||var2||'  JOB_ACTION: '||var3|| '[[NL]]';
    END LOOP;
    CLOSE l_cursor;
   END IF;
    store_table_data (msg_num,1,check_status,'message','DBA_SCHEDULER_JOBS_JOB_ACTION','DBA_SCHEDULER_JOBS JOB_ACTION', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);



    --*********************************************************
    --
    --  DBA_SCHEDULER_JOBS JOB_STYLE Check
    --
    --*********************************************************
--  VLC fixed on 10/2/16   Changed status to be always be INFO
--  VLC fixed on 9/19/16  Added cursor to eliminate parsing error about invalid identifier "JOB_STYLE"
--  VLC fixed on 8/9/16  The job counts should be in the pass message, not the fail message
--  VLC fixed on 8/11/16  Removed the setting of check_status to false if the counts are > 0
  WHEN p_check = 'DBA_SCHEDULER_JOBS_STYLE' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_JOBS';
    l_bookmark := 'DBA_SCHEDULER_JOBS_DATA';
    check_status := 'INFO';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_pass := msg_str_pass || 'There are one or more jobs with a job_style equal to regular or light weight.' || '[[NL]]';
    the_count_cursor := 'SELECT COUNT(*) FROM DBA_SCHEDULER_JOBS WHERE JOB_STYLE = ''REGULAR''';
    OPEN l_cursor FOR the_count_cursor;
    FETCH l_cursor
    INTO job_style_regular_cnt;
    CLOSE l_cursor;
    the_count_cursor := 'SELECT COUNT(*) FROM DBA_SCHEDULER_JOBS WHERE JOB_STYLE = ''LIGHT WEIGHT''';
    OPEN l_cursor FOR the_count_cursor;
    FETCH l_cursor
    INTO job_style_light_weight_cnt;
    CLOSE l_cursor;
    IF ((job_style_light_weight_cnt >0 ) OR (job_style_regular_cnt >0)) THEN
      msg_str_pass := msg_str_pass || 'There are '||job_style_regular_cnt || 'jobs with style equal REGULAR.' || '[[NL]]';
      msg_str_pass := msg_str_pass || 'There are '||job_style_light_weight_cnt || 'jobs with style equal REGULAR.' || '[[NL]]';
    END IF;
    store_table_data (msg_num,1,check_status,'message','DBA_SCHEDULER_JOBS_STYLE','DBA_SCHEDULER_JOBS: JOB_STYLES', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);

    --*********************************************************
    --
    --  DBA_SCHEDULER_JOBS JOB_TYPE Check
    --
    --*********************************************************
--  VLC fixed on 10/2/16   Added cursor logic to avoid future parsing errors for invalid identifiers or tables that don't exist
--  VLC fixed on 10/2/16   Changed status to be always be INFO
--  VLC fixed on 8/9/16  The list of jobs was stored in the failed message.  should be pass message
--  VLC fixed on 8/11/16  Removed the setting of check_status to false if item_found > 0
  WHEN p_check = 'DBA_SCHEDULER_JOBS_TYPE' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_JOBS';
    l_bookmark := 'DBA_SCHEDULER_JOBS_DATA';
    check_status := 'INFO';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_pass := msg_str_pass || 'There are one or more jobs with a job type equal to PLSQL_BLOCK, STORED_PROCEDURE, EXECUTABLE, CHAIN, SQL_SCRIPT, BACKUP_SCRIPT or EXTERNAL_SCRIPT.' || '[[NL]]';
    the_count_cursor := 'SELECT COUNT(*) FROM DBA_SCHEDULER_JOBS WHERE JOB_TYPE IN (''PLSQL_BLOCK'', ''STORED_PROCEDURE'', ''EXECUTABLE'', ''CHAIN'', ''SQL_SCRIPT'', ''BACKUP_SCRIPT'', ''EXTERNAL_SCRIPT'')';
    the_data_cursor  := 'SELECT JOB_NAME, JOB_TYPE FROM DBA_SCHEDULER_JOBS WHERE JOB_TYPE IN (''PLSQL_BLOCK'', ''STORED_PROCEDURE'', ''EXECUTABLE'', ''CHAIN'', ''SQL_SCRIPT'', ''BACKUP_SCRIPT'', ''EXTERNAL_SCRIPT'')';
    OPEN l_cursor FOR the_count_cursor;
    FETCH l_cursor
    INTO item_found;
    CLOSE l_cursor;
    IF (item_found > 0) THEN
    OPEN l_cursor FOR the_data_cursor;
    LOOP
      FETCH l_cursor INTO var1,var2;
      EXIT WHEN l_cursor%notfound;
        msg_str_pass := msg_str_pass || 'JOB_NAME: '||var1||'  JOB_TYPE: '||var2|| '[[NL]]';
    END LOOP;
    CLOSE l_cursor;
	END IF;
    store_table_data (msg_num,1,check_status,'message','DBA_SCHEDULER_JOBS_TYPE','DBA_SCHEDULER_JOBS: JOB_TYPES', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);

    --*********************************************************
    --
    --  DBA_SCHEDULER_JOBS FILE_WATCHER_NAME Check
    --
    --  The columns FILE_WATCHER_NAME and FILE_WATCHER_OWNER do not exist in 11.1.
    --  They do exist in 11.2 and 12c.
    --
    --*********************************************************
--  VLC fixed on 10/2/16   Changed status to be always be INFO
--  VLC fixed on 10/2/16   Added pass message for "No rows exist"  case
--  VLC fixed on 8/11/16  Added logic to check if item_found > 0
--  VLC fixed on 8/9/16  The list of jobs was stored in the failed message.  should be pass message
--  VLC fixed on 07/26/16   Added cursor logic to avoid the  errors  ORA-00904: "FILE_WATCHER_NAME": invalid identifier ORA-06550: on DB version 11

  WHEN p_check = 'DBA_SCHEDULER_JOBS_FILE_WATCHER_NAME' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_JOBS';
    l_bookmark := 'DBA_SCHEDULER_JOBS_DATA';
    check_status := 'INFO';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_pass := msg_str_pass || 'There are one or more Filewatcher jobs.' || '[[NL]]';
    the_count_cursor := 'SELECT COUNT(*) FROM DBA_SCHEDULER_JOBS WHERE FILE_WATCHER_NAME IS NOT NULL';
    the_data_cursor  := 'SELECT JOB_NAME, FILE_WATCHER_NAME, FILE_WATCHER_OWNER FROM DBA_SCHEDULER_JOBS WHERE FILE_WATCHER_NAME IS NOT NULL';
    OPEN l_cursor FOR the_count_cursor;
    FETCH l_cursor
    INTO item_found;
    CLOSE l_cursor;
    IF (item_found > 0) THEN
    OPEN l_cursor FOR the_data_cursor;
    LOOP
      FETCH l_cursor INTO var1,var2,var3;
      EXIT WHEN l_cursor%notfound;
      msg_str_pass := msg_str_pass || 'JOB_NAME: '||var1||'  FILE_WATCHER_NAME: '||var2|| 'FILE_WATCHER_OWNER: '||var3 || '[[NL]]';
    END LOOP;
    CLOSE l_cursor;
    ELSE
      msg_str_pass := '';
      msg_str_pass := msg_str_pass || 'No filewatcher job configured.' || '[[NL]]';
    END IF;
    store_table_data (msg_num,1,check_status,'message','DBA_SCHEDULER_JOBS_FILE_WATCHER_NAME','DBA_SCHEDULER_JOBS: FILE_WATCHER_NAME', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);

    --*********************************************************
    --
    --  DBA_SCHEDULER_JOBS ENABLED Check
    --
    --*********************************************************
  WHEN p_check = 'DBA_SCHEDULER_JOBS_ENABLED' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_JOBS';
    l_bookmark := 'DBA_SCHEDULER_JOBS_DATA';
    check_status := 'PASS';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_fail := msg_str_fail || 'One or more jobs are not enabled. The jobs can be enabled by executing the following command(s):' || '[[NL]]';
    msg_str_pass := msg_str_pass || 'There are no disabled jobs.  No action is required.' || '[[NL]]';
    FOR i IN
    (SELECT JOB_NAME FROM DBA_SCHEDULER_JOBS WHERE ENABLED = 'FALSE'
    )
    LOOP
      IF (p_script_selected = 'JOB_AUTOTASK') THEN
        IF ((upper(i.JOB_NAME) = 'AUTO_SPACE_ADVISOR_JOB') OR (upper(i.JOB_NAME) = 'GATHER_STATS_JOB')) THEN
          msg_str_fail := msg_str_fail || 'exec sys.dbms_scheduler.enable( ''"SYS"."'||i.JOB_NAME||'"'');' || '[[NL]]';
          item_found := item_found + 1;
        END IF;
      ELSE
        msg_str_fail := msg_str_fail || 'exec sys.dbms_scheduler.enable( ''"SYS"."'||i.JOB_NAME||'"'');' || '[[NL]]';
        item_found := item_found + 1;
      END IF;
    END LOOP;
    IF (item_found > 0) THEN
      check_status := 'FAIL';
    END IF;
        store_table_data (msg_num,1,check_status,'message','DBA_SCHEDULER_JOBS_ENABLED','DBA_SCHEDULER_JOBS: ENABLED', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);

    --*********************************************************
    --
    --  DBA_SCHEDULER_JOBS JOBS STATE DISABLED Check
    --
    --*********************************************************
--  VLC fixed on 10/2/16   Added cursor logic to avoid future parsing errors for invalid identifiers or tables that don't exist
--  VLC fixed on 10/2/16   Changed logic to be specific to the script being executed.
  WHEN p_check = 'DBA_SCHEDULER_JOBS_STATE_DISABLED' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_JOBS';
    l_bookmark := 'DBA_SCHEDULER_JOBS_DATA';
    check_status := 'PASS';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_fail := msg_str_fail || 'One or more jobs are disabled. The jobs can be enabled by executing the following command(s): ' || '[[NL]]';
    msg_str_pass := msg_str_pass || 'The jobs are enabled. No action is required.' || '[[NL]]';

    IF (p_script_selected = 'JOB_CONFIGURATION') THEN
      the_count_cursor := 'SELECT COUNT(*) FROM DBA_SCHEDULER_JOBS WHERE STATE = ''DISABLED''';
      the_data_cursor  := 'SELECT JOB_NAME FROM DBA_SCHEDULER_JOBS WHERE STATE = ''DISABLED''';
    ELSIF (p_script_selected = 'JOB_AUTOTASK') THEN
      the_count_cursor := 'SELECT COUNT(*) FROM DBA_SCHEDULER_JOBS WHERE STATE = ''DISABLED'' AND UPPER(JOB_NAME IN (''AUTO_SPACE_ADVISOR_JOB'',''GATHER_STATS_JOB''))';
      the_data_cursor  := 'SELECT JOB_NAME FROM DBA_SCHEDULER_JOBS WHERE STATE = ''DISABLED'' AND UPPER(JOB_NAME IN (''AUTO_SPACE_ADVISOR_JOB'',''GATHER_STATS_JOB''))';
    ELSIF (p_script_selected = 'EXTERNAL_JOBS') THEN
      the_count_cursor := 'SELECT COUNT(*) FROM DBA_SCHEDULER_JOBS WHERE STATE = ''DISABLED'' AND JOB_TYPE = ''EXECUTABLE''';
      the_data_cursor  := 'SELECT JOB_NAME FROM DBA_SCHEDULER_JOBS WHERE STATE = ''DISABLED'' AND JOB_TYPE = ''EXECUTABLE''';
    END IF;
    OPEN l_cursor FOR the_count_cursor;
    FETCH l_cursor
    INTO item_found;
    CLOSE l_cursor;
    IF (item_found > 0) THEN
    check_status := 'FAIL';
    OPEN l_cursor FOR the_data_cursor;
    LOOP
      FETCH l_cursor INTO var1;
      EXIT WHEN l_cursor%notfound;
      msg_str_fail := msg_str_fail || 'exec sys.dbms_scheduler.enable( ''"SYS"."'||var1||'"'');' || '[[NL]]';
    END LOOP;
    CLOSE l_cursor;
	END IF;
    store_table_data (msg_num,1,check_status,'message','DBA_SCHEDULER_JOBS_STATE_DISABLED','JOBS WHICH ARE DISABLED','',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);

    --*********************************************************
    --
    --  DBA_SCHEDULER_JOBS STATE SCHEDULED Check
    --
    --*********************************************************
--  VLC fixed on 10/2/16   Added cursor logic to avoid future parsing errors for invalid identifiers or tables that don't exist
--  VLC fixed on 10/2/16   Changed logic to be specific to the script being executed.
--  VLC fixed on 10/2/16   Changed status to be INFO instead of PASS
  WHEN p_check = 'DBA_SCHEDULER_JOBS_STATE_SCHEDULED' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_JOBS';
    l_bookmark := 'DBA_SCHEDULER_JOBS_DATA';
    check_status := 'INFO';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_fail := msg_str_fail || 'One or more jobs are scheduled: ' || '[[NL]]';
    msg_str_pass := msg_str_pass || 'The jobs are not scheduled. No action is required.' || '[[NL]]';

     IF (p_script_selected = 'JOB_CONFIGURATION') THEN
      the_count_cursor := 'SELECT COUNT(*) FROM DBA_SCHEDULER_JOBS WHERE STATE = ''SCHEDULED'' AND NEXT_RUN_DATE < SYSDATE';
      the_data_cursor  := 'SELECT JOB_NAME,NEXT_RUN_DATE FROM DBA_SCHEDULER_JOBS WHERE STATE = ''SCHEDULED'' AND NEXT_RUN_DATE < SYSDATE';
    ELSIF (p_script_selected = 'JOB_AUTOTASK') THEN
      the_count_cursor := 'SELECT COUNT(*) FROM DBA_SCHEDULER_JOBS WHERE STATE = ''SCHEDULED'' AND UPPER(JOB_NAME IN (''AUTO_SPACE_ADVISOR_JOB'',''GATHER_STATS_JOB'')) AND NEXT_RUN_DATE < SYSDATE';
      the_data_cursor  := 'SELECT JOB_NAME,NEXT_RUN_DATE FROM DBA_SCHEDULER_JOBS WHERE STATE = ''SCHEDULED'' AND UPPER(JOB_NAME IN (''AUTO_SPACE_ADVISOR_JOB'',''GATHER_STATS_JOB'')) AND NEXT_RUN_DATE < SYSDATE';
    ELSIF (p_script_selected = 'EXTERNAL_JOBS') THEN
      the_count_cursor := 'SELECT COUNT(*) FROM DBA_SCHEDULER_JOBS WHERE STATE = ''SCHEDULED'' AND JOB_TYPE = ''EXECUTABLE'' AND NEXT_RUN_DATE < SYSDATE';
      the_data_cursor  := 'SELECT JOB_NAME,NEXT_RUN_DATE FROM DBA_SCHEDULER_JOBS WHERE STATE = ''SCHEDULED'' AND JOB_TYPE = ''EXECUTABLE'' AND NEXT_RUN_DATE < SYSDATE';
    END IF;
    OPEN l_cursor FOR the_count_cursor;
    FETCH l_cursor
    INTO item_found;
    CLOSE l_cursor;
    IF (item_found > 0) THEN
    check_status := 'FAIL';
    OPEN l_cursor FOR the_data_cursor;
    LOOP
      FETCH l_cursor INTO var1,var2;
      EXIT WHEN l_cursor%notfound;
      msg_str_fail := msg_str_fail || 'The job '||var1|| ' is scheduled to be executed on '||var2||'.' || '[[NL]]';
    END LOOP;
    CLOSE l_cursor;
	END IF;
	store_table_data (msg_num,1,check_status,'message','DBA_SCHEDULER_JOBS_STATE_SCHEDULED','JOBS WHICH ARE SCHEDULED','',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  DBA_SCHEDULER_JOBS STATE RUNNING Check
    --
    --*********************************************************
--  VLC fixed on 10/2/16   Added cursor logic to avoid future parsing errors for invalid identifiers or tables that don't exist
--  VLC fixed on 10/2/16   Changed logic to be specific to the script being executed.
--  VLC fixed on 10/2/16   Changed status to be always be INFO
--  VLC fixed on 10/2/16   Changed message to be a pass message
  WHEN p_check = 'DBA_SCHEDULER_JOBS_STATE_RUNNING' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_JOBS';
    l_bookmark := 'DBA_SCHEDULER_JOBS_DATA';
    check_status := 'INFO';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_pass := msg_str_pass || 'One or more jobs are running. If this is not your maintenance window, consider stopping the following jobs:' || '[[NL]]';

     IF (p_script_selected = 'JOB_CONFIGURATION') THEN
      the_count_cursor := 'SELECT COUNT(*) FROM DBA_SCHEDULER_JOBS WHERE STATE = ''RUNNING''';
      the_data_cursor  := 'SELECT JOB_NAME FROM DBA_SCHEDULER_JOBS WHERE STATE = ''RUNNING''';
    ELSIF (p_script_selected = 'JOB_AUTOTASK') THEN
      the_count_cursor := 'SELECT COUNT(*) FROM DBA_SCHEDULER_JOBS WHERE STATE = ''RUNNING'' AND UPPER(JOB_NAME IN (''AUTO_SPACE_ADVISOR_JOB'',''GATHER_STATS_JOB''))';
      the_data_cursor  := 'SELECT JOB_NAME FROM DBA_SCHEDULER_JOBS WHERE STATE = ''RUNNING'' AND UPPER(JOB_NAME IN (''AUTO_SPACE_ADVISOR_JOB'',''GATHER_STATS_JOB''))';
    ELSIF (p_script_selected = 'EXTERNAL_JOBS') THEN
      the_count_cursor := 'SELECT COUNT(*) FROM DBA_SCHEDULER_JOBS WHERE STATE = ''RUNNING'' AND JOB_TYPE = ''EXECUTABLE''';
      the_data_cursor  := 'SELECT JOB_NAME FROM DBA_SCHEDULER_JOBS WHERE STATE = ''RUNNING'' AND JOB_TYPE = ''EXECUTABLE''';
    END IF;
    OPEN l_cursor FOR the_count_cursor;
    FETCH l_cursor
    INTO item_found;
    CLOSE l_cursor;
    IF (item_found > 0) THEN
    OPEN l_cursor FOR the_data_cursor;
    LOOP
      FETCH l_cursor INTO var1;
      EXIT WHEN l_cursor%notfound;
      msg_str_pass := msg_str_pass || 'The job '||var1|| '  is currently running.' || '[[NL]]' ;
    END LOOP;
    CLOSE l_cursor;
    ELSE
      msg_str_pass := '';
      msg_str_pass := msg_str_pass || 'The jobs are not running. No action is required.' || '[[NL]]';
    END IF;
	store_table_data (msg_num,1,check_status,'message','DBA_SCHEDULER_JOBS_STATE_RUNNING','JOBS WHICH ARE RUNNING','',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);

    --*********************************************************
    --
    --  DBA_SCHEDULER_JOBS STATE COMPLETED Check
    --
    --*********************************************************
  WHEN p_check = 'DBA_SCHEDULER_JOBS_STATE_COMPLETED' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_JOBS';
    l_bookmark := 'DBA_SCHEDULER_JOBS_DATA';
    check_status := 'PASS';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_fail := msg_str_fail || 'The following job(s) have completed and are not scheduled to run again. Check the Next date and try to reschedule the job(s).' || '[[NL]]';
    msg_str_pass := msg_str_pass || 'The completed jobs have been re-scheduled. No action is required.' || '[[NL]]';

	IF (p_script_selected = 'JOB_CONFIGURATION') THEN
      the_count_cursor := 'SELECT COUNT(*) FROM DBA_SCHEDULER_JOBS WHERE STATE = ''COMPLETED''';
      the_data_cursor  := 'SELECT JOB_NAME, RUN_COUNT, MAX_RUNS FROM DBA_SCHEDULER_JOBS WHERE STATE = ''COMPLETED''';
    ELSIF (p_script_selected = 'JOB_AUTOTASK') THEN
      the_count_cursor := 'SELECT COUNT(*) FROM DBA_SCHEDULER_JOBS WHERE STATE = ''COMPLETED'' AND UPPER(JOB_NAME IN (''AUTO_SPACE_ADVISOR_JOB'',''GATHER_STATS_JOB''))';
      the_data_cursor  := 'SELECT JOB_NAME, RUN_COUNT, MAX_RUNS FROM DBA_SCHEDULER_JOBS WHERE STATE = ''COMPLETED'' AND UPPER(JOB_NAME IN (''AUTO_SPACE_ADVISOR_JOB'',''GATHER_STATS_JOB''))';
    ELSIF (p_script_selected = 'EXTERNAL_JOBS') THEN
      the_count_cursor := 'SELECT COUNT(*) FROM DBA_SCHEDULER_JOBS WHERE STATE = ''COMPLETED'' AND JOB_TYPE = ''EXECUTABLE''';
      the_data_cursor  := 'SELECT JOB_NAME, RUN_COUNT, MAX_RUNS FROM DBA_SCHEDULER_JOBS WHERE STATE = ''COMPLETED'' AND JOB_TYPE = ''EXECUTABLE''';
    END IF;
    OPEN l_cursor FOR the_count_cursor;
    FETCH l_cursor
    INTO item_found;
    CLOSE l_cursor;
    IF (item_found > 0) THEN
    check_status := 'FAIL';
    OPEN l_cursor FOR the_data_cursor;
    LOOP
      FETCH l_cursor INTO var1,var2,var3;
      EXIT WHEN l_cursor%notfound;
      msg_str_fail := msg_str_fail || var1 || 'RUN_COUNT: ['|| var2 || ']    MAX_RUNS: ['|| var3 ||']' || '[[NL]]';
    END LOOP;
    CLOSE l_cursor;
    END IF;
	store_table_data (msg_num,1,check_status,'message','DBA_SCHEDULER_JOBS_STATE_COMPLETED','JOBS WHICH ARE COMPLETED','',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);

    --*********************************************************
    --
    --  DBA_SCHEDULER_JOBS STATE STOPPED Check
    --
    --*********************************************************
--  VLC fixed on 10/2/16   Added cursor logic to avoid future parsing errors for invalid identifiers or tables that don't exist
--  VLC fixed on 10/2/16   Changed logic to be specific to the script being executed.
--  VLC fixed on 10/2/16   Changed status to be always be INFO
--  VLC fixed on 10/2/16   Changed message to be a pass message
  WHEN p_check = 'DBA_SCHEDULER_JOBS_STATE_STOPPED' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_JOBS';
    l_bookmark := 'DBA_SCHEDULER_JOBS_DATA';
    check_status := 'INFO';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_pass := msg_str_pass || 'One or more job(s) were scheduled to run once and were stopped while running. Check that the Window duration from the dba_autotask_operation view is enough to execute the job(s). If not, consider increasing the Window duration.' || '[[NL]]';

     IF (p_script_selected = 'JOB_CONFIGURATION') THEN
      the_count_cursor := 'SELECT COUNT(*) FROM DBA_SCHEDULER_JOBS WHERE STATE = ''STOPPED''';
      the_data_cursor  := 'SELECT JOB_NAME FROM DBA_SCHEDULER_JOBS WHERE STATE = ''STOPPED''';
    ELSIF (p_script_selected = 'JOB_AUTOTASK') THEN
      the_count_cursor := 'SELECT COUNT(*) FROM DBA_SCHEDULER_JOBS WHERE STATE = ''STOPPED'' AND UPPER(JOB_NAME IN (''AUTO_SPACE_ADVISOR_JOB'',''GATHER_STATS_JOB''))';
      the_data_cursor  := 'SELECT JOB_NAME FROM DBA_SCHEDULER_JOBS WHERE STATE = ''STOPPED'' AND UPPER(JOB_NAME IN (''AUTO_SPACE_ADVISOR_JOB'',''GATHER_STATS_JOB''))';
    ELSIF (p_script_selected = 'EXTERNAL_JOBS') THEN
      the_count_cursor := 'SELECT COUNT(*) FROM DBA_SCHEDULER_JOBS WHERE STATE = ''STOPPED'' AND JOB_TYPE = ''EXECUTABLE''';
      the_data_cursor  := 'SELECT JOB_NAME FROM DBA_SCHEDULER_JOBS WHERE STATE = ''STOPPED'' AND JOB_TYPE = ''EXECUTABLE''';
    END IF;
    OPEN l_cursor FOR the_count_cursor;
    FETCH l_cursor
    INTO item_found;
    CLOSE l_cursor;
    IF (item_found > 0) THEN
    OPEN l_cursor FOR the_data_cursor;
    LOOP
      FETCH l_cursor INTO var1;
      EXIT WHEN l_cursor%notfound;
      msg_str_pass := msg_str_pass || var1 || ' was stopped.' || '[[NL]]';
    END LOOP;
    CLOSE l_cursor;
    ELSE
      msg_str_pass := '';
      msg_str_pass := msg_str_pass || 'The job ran successfully. No action is required.' || '[[NL]]';
    END IF;
	store_table_data (msg_num,1,check_status,'message','DBA_SCHEDULER_JOBS_STATE_STOPPED','JOBS WHICH ARE STOPPED','',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);

    --*********************************************************
    --
    --  DBA_SCHEDULER_JOBS STATE BROKEN Check
    --
    --*********************************************************
--  VLC fixed on 10/2/16   Added cursor logic to avoid future parsing errors for invalid identifiers or tables that don't exist
--  VLC fixed on 10/2/16   Changed logic to be specific to the script being executed.
  WHEN p_check = 'DBA_SCHEDULER_JOBS_STATE_BROKEN' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_JOBS';
    l_bookmark := 'DBA_SCHEDULER_JOBS_DATA';
    check_status := 'PASS';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_fail := msg_str_fail || 'One or more job(s) are broken. Try recreating the job using the following commands: ' || '[[NL]]';
    msg_str_fail := msg_str_fail || t_common_message(1).msg_body;
    msg_str_pass := msg_str_pass || 'There are no broken jobs. No action is required.' || '[[NL]]';

     IF (p_script_selected = 'JOB_CONFIGURATION') THEN
      the_count_cursor := 'SELECT COUNT(*) FROM DBA_SCHEDULER_JOBS WHERE STATE = ''BROKEN''';
      the_data_cursor  := 'SELECT JOB_NAME FROM DBA_SCHEDULER_JOBS WHERE STATE = ''BROKEN''';
    ELSIF (p_script_selected = 'JOB_AUTOTASK') THEN
      the_count_cursor := 'SELECT COUNT(*) FROM DBA_SCHEDULER_JOBS WHERE STATE = ''BROKEN'' AND UPPER(JOB_NAME IN (''AUTO_SPACE_ADVISOR_JOB'',''GATHER_STATS_JOB''))';
      the_data_cursor  := 'SELECT JOB_NAME FROM DBA_SCHEDULER_JOBS WHERE STATE = ''BROKEN'' AND UPPER(JOB_NAME IN (''AUTO_SPACE_ADVISOR_JOB'',''GATHER_STATS_JOB''))';
    ELSIF (p_script_selected = 'EXTERNAL_JOBS') THEN
      the_count_cursor := 'SELECT COUNT(*) FROM DBA_SCHEDULER_JOBS WHERE STATE = ''BROKEN'' AND JOB_TYPE = ''EXECUTABLE''';
      the_data_cursor  := 'SELECT JOB_NAME FROM DBA_SCHEDULER_JOBS WHERE STATE = ''BROKEN'' AND JOB_TYPE = ''EXECUTABLE''';
    END IF;
    OPEN l_cursor FOR the_count_cursor;
    FETCH l_cursor
    INTO item_found;
    CLOSE l_cursor;
    IF (item_found > 0) THEN
    check_status := 'FAIL';
    OPEN l_cursor FOR the_data_cursor;
    LOOP
      FETCH l_cursor INTO var1;
      EXIT WHEN l_cursor%notfound;
      msg_str_fail := msg_str_fail || var1 || ' is broken.' || '[[NL]]';
    END LOOP;
    CLOSE l_cursor;
    END IF;
	store_table_data (msg_num,1,check_status,'message','DBA_SCHEDULER_JOBS_STATE_BROKEN','JOBS WHICH ARE BROKEN','',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);

    --*********************************************************
    --
    --  DBA_SCHEDULER_JOBS STATE FAILED Check
    --
    --*********************************************************
--  VLC fixed on 10/2/16   Added cursor logic to avoid future parsing errors for invalid identifiers or tables that don't exist
--  VLC fixed on 10/2/16   Changed logic to be specific to the script being executed.
  WHEN p_check = 'DBA_SCHEDULER_JOBS_STATE_FAILED' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_JOBS';
    l_bookmark := 'DBA_SCHEDULER_JOBS_DATA';
    check_status := 'PASS';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_fail := msg_str_fail || 'One or more job(s) are were scheduled to run once and failed. Try recreating the job using the following commands: ' || '[[NL]]';
    msg_str_fail := msg_str_fail || t_common_message(1).msg_body;
    msg_str_pass := msg_str_pass || 'The scheduled jobs ran successfully. No action is required.' || '[[NL]]';

     IF (p_script_selected = 'JOB_CONFIGURATION') THEN
      the_count_cursor := 'SELECT COUNT(*) FROM DBA_SCHEDULER_JOBS WHERE STATE = ''FAILED''';
      the_data_cursor  := 'SELECT JOB_NAME FROM DBA_SCHEDULER_JOBS WHERE STATE = ''FAILED''';
    ELSIF (p_script_selected = 'JOB_AUTOTASK') THEN
      the_count_cursor := 'SELECT COUNT(*) FROM DBA_SCHEDULER_JOBS WHERE STATE = ''FAILED'' AND UPPER(JOB_NAME IN (''AUTO_SPACE_ADVISOR_JOB'',''GATHER_STATS_JOB''))';
      the_data_cursor  := 'SELECT JOB_NAME FROM DBA_SCHEDULER_JOBS WHERE STATE = ''FAILED'' AND UPPER(JOB_NAME IN (''AUTO_SPACE_ADVISOR_JOB'',''GATHER_STATS_JOB''))';
    ELSIF (p_script_selected = 'EXTERNAL_JOBS') THEN
      the_count_cursor := 'SELECT COUNT(*) FROM DBA_SCHEDULER_JOBS WHERE STATE = ''FAILED'' AND JOB_TYPE = ''EXECUTABLE''';
      the_data_cursor  := 'SELECT JOB_NAME FROM DBA_SCHEDULER_JOBS WHERE STATE = ''FAILED'' AND JOB_TYPE = ''EXECUTABLE''';
    END IF;
    OPEN l_cursor FOR the_count_cursor;
    FETCH l_cursor
    INTO item_found;
    CLOSE l_cursor;
    IF (item_found > 0) THEN
    check_status := 'FAIL';
    OPEN l_cursor FOR the_data_cursor;
    LOOP
      FETCH l_cursor INTO var1;
      EXIT WHEN l_cursor%notfound;
      msg_str_fail := msg_str_fail || var1 || ' failed.' || '[[NL]]';
    END LOOP;
    CLOSE l_cursor;
    END IF;
	store_table_data (msg_num,1,check_status,'message','DBA_SCHEDULER_JOBS_STATE_FAILED','JOBS WHICH FAILED','',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);

    --*********************************************************
    --
    --  DBA_SCHEDULER_JOBS STATE RETRY SCHEDULED Check
    --
    --*********************************************************
--  VLC fixed on 10/2/16   Added cursor logic to avoid future parsing errors for invalid identifiers or tables that don't exist
--  VLC fixed on 10/2/16   Changed logic to be specific to the script being executed.
--  VLC fixed on 10/2/16   Changed status to be always be INFO
--  VLC fixed on 10/2/16   Changed message to be a pass message
  WHEN p_check = 'DBA_SCHEDULER_JOBS_STATE_RETRY_SCHEDULED' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_JOBS';
    l_bookmark := 'DBA_SCHEDULER_JOBS_DATA';
    check_status := 'INFO';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_pass := msg_str_pass || 'One or more job(s) have failed at least once and a retry has been scheduled to be executed. Monitor the job during the next window. If it fails again, try recreating the job using the following commands:' || '[[NL]]';
    msg_str_pass := msg_str_pass || t_common_message(1).msg_body;

     IF (p_script_selected = 'JOB_CONFIGURATION') THEN
      the_count_cursor := 'SELECT COUNT(*) FROM DBA_SCHEDULER_JOBS WHERE STATE = ''RETRY SCHEDULED''';
      the_data_cursor  := 'SELECT JOB_NAME FROM DBA_SCHEDULER_JOBS WHERE STATE = ''RETRY SCHEDULED''';
    ELSIF (p_script_selected = 'JOB_AUTOTASK') THEN
      the_count_cursor := 'SELECT COUNT(*) FROM DBA_SCHEDULER_JOBS WHERE STATE = ''RETRY SCHEDULED'' AND UPPER(JOB_NAME IN (''AUTO_SPACE_ADVISOR_JOB'',''GATHER_STATS_JOB''))';
      the_data_cursor  := 'SELECT JOB_NAME FROM DBA_SCHEDULER_JOBS WHERE STATE = ''RETRY SCHEDULED'' AND UPPER(JOB_NAME IN (''AUTO_SPACE_ADVISOR_JOB'',''GATHER_STATS_JOB''))';
    ELSIF (p_script_selected = 'EXTERNAL_JOBS') THEN
      the_count_cursor := 'SELECT COUNT(*) FROM DBA_SCHEDULER_JOBS WHERE STATE = ''RETRY SCHEDULED'' AND JOB_TYPE = ''EXECUTABLE''';
      the_data_cursor  := 'SELECT JOB_NAME FROM DBA_SCHEDULER_JOBS WHERE STATE = ''RETRY SCHEDULED'' AND JOB_TYPE = ''EXECUTABLE''';
    END IF;
    OPEN l_cursor FOR the_count_cursor;
    FETCH l_cursor
    INTO item_found;
    CLOSE l_cursor;
    IF (item_found > 0) THEN
    OPEN l_cursor FOR the_data_cursor;
    LOOP
      FETCH l_cursor INTO var1;
      EXIT WHEN l_cursor%notfound;
      msg_str_pass := msg_str_pass || var1 || ' failed at least and has been re-scheduled.' || '[[NL]]';
    END LOOP;
    CLOSE l_cursor;
    ELSE
    msg_str_pass := '';
    msg_str_pass := msg_str_pass || 'All jobs ran successfully. No action is required.' || '[[NL]]';
    END IF;
	store_table_data (msg_num,1,check_status,'message','DBA_SCHEDULER_JOBS_STATE_RETRY_SCHEDULED','JOBS WHICH ARE SCHEDULED FOR RETRY','',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);

    --*********************************************************
    --
    --  DBA_SCHEDULER_JOBS STATE SUCCEEDED Check
    --
    --*********************************************************
--  VLC fixed on 10/2/16   Added cursor logic to avoid future parsing errors for invalid identifiers or tables that don't exist
--  VLC fixed on 10/2/16   Changed logic to be specific to the script being executed.
--  VLC fixed on 10/2/16   Changed status to be always be INFO
--  VLC fixed on 10/2/16   Changed message to be a pass message
  WHEN p_check = 'DBA_SCHEDULER_JOBS_STATE_SUCCEEDED' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_JOBS';
    l_bookmark := 'DBA_SCHEDULER_JOBS_DATA';
    check_status := 'INFO';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_pass := msg_str_pass || 'One or more job(s) were scheduled to run once and completed successfully.' || '[[NL]]';

     IF (p_script_selected = 'JOB_CONFIGURATION') THEN
      the_count_cursor := 'SELECT COUNT(*) FROM DBA_SCHEDULER_JOBS WHERE STATE = ''SUCCEEDED''';
      the_data_cursor  := 'SELECT JOB_NAME FROM DBA_SCHEDULER_JOBS WHERE STATE = ''SUCCEEDED''';
    ELSIF (p_script_selected = 'JOB_AUTOTASK') THEN
      the_count_cursor := 'SELECT COUNT(*) FROM DBA_SCHEDULER_JOBS WHERE STATE = ''SUCCEEDED'' AND UPPER(JOB_NAME IN (''AUTO_SPACE_ADVISOR_JOB'',''GATHER_STATS_JOB''))';
      the_data_cursor  := 'SELECT JOB_NAME FROM DBA_SCHEDULER_JOBS WHERE STATE = ''SUCCEEDED'' AND UPPER(JOB_NAME IN (''AUTO_SPACE_ADVISOR_JOB'',''GATHER_STATS_JOB''))';
    ELSIF (p_script_selected = 'EXTERNAL_JOBS') THEN
      the_count_cursor := 'SELECT COUNT(*) FROM DBA_SCHEDULER_JOBS WHERE STATE = ''SUCCEEDED'' AND JOB_TYPE = ''EXECUTABLE''';
      the_data_cursor  := 'SELECT JOB_NAME FROM DBA_SCHEDULER_JOBS WHERE STATE = ''SUCCEEDED'' AND JOB_TYPE = ''EXECUTABLE''';
    END IF;
    OPEN l_cursor FOR the_count_cursor;
    FETCH l_cursor
    INTO item_found;
    CLOSE l_cursor;
    IF (item_found > 0) THEN
    OPEN l_cursor FOR the_data_cursor;
    LOOP
      FETCH l_cursor INTO var1;
      EXIT WHEN l_cursor%notfound;
      msg_str_pass := msg_str_pass  || var1 || ' succeeded.' || '[[NL]]';
    END LOOP;
    CLOSE l_cursor;
    ELSE
    msg_str_pass := '';
    msg_str_pass := msg_str_pass || 'No scheduled jobs have completed successfully.' || '[[NL]]';
    END IF;
	store_table_data (msg_num,1,check_status,'message','DBA_SCHEDULER_JOBS_STATE_SUCCEEDED','JOBS WHICH SUCCEEDED','',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);

    --*********************************************************
    --
    --  DBA_SCHEDULER_CREDENTIALS OWNER Check
    --
    --*********************************************************
--  VLC fixed on 9/19/16  Added cursor to eliminate error about invalid identifier "CREDENTIAL_NAME"
--  VLC fixed on 9/19/16  DBA_SCHEDULER_CREDENTIALS does not exist in 10.x
  WHEN p_check = 'DBA_SCHEDULER_CREDENTIALS_OWNER' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_CREDENTIALS and DBA_SCHEDULER_JOBS';
    l_bookmark := 'DBA_SCHEDULER_CREDENTIALS_DBA_SCHEDULER_JOBS_DATA';
    check_status := 'INFO';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_pass := msg_str_pass || 'The credential should be owned by the job owner.' || '[[NL]]';

    the_count_cursor := 'SELECT COUNT(*) FROM DBA_SCHEDULER_JOBS SJ, DBA_SCHEDULER_CREDENTIALS SC WHERE JOB_TYPE = ''EXECUTABLE'' AND SJ.CREDENTIAL_NAME IS NOT NULL AND SJ.CREDENTIAL_NAME = SC.CREDENTIAL_NAME AND SJ.OWNER != SC.OWNER';
    the_data_cursor  := 'SELECT SJ.OWNER as SJ_OWNER, SC.OWNER as SC_OWNER, SJ.JOB_NAME, SJ.CREDENTIAL_NAME FROM DBA_SCHEDULER_JOBS SJ, DBA_SCHEDULER_CREDENTIALS SC WHERE JOB_TYPE = ''EXECUTABLE'' AND SJ.CREDENTIAL_NAME IS NOT NULL AND SJ.CREDENTIAL_NAME = SC.CREDENTIAL_NAME AND SJ.OWNER != SC.OWNER';
    OPEN l_cursor FOR the_count_cursor;
    FETCH l_cursor
    INTO item_found;
    CLOSE l_cursor;
    IF (item_found > 0) THEN
    OPEN l_cursor FOR the_data_cursor;
    LOOP
      FETCH l_cursor INTO var1,var2,var3,var4;
      EXIT WHEN l_cursor%notfound;
      msg_str_pass := msg_str_pass || 'The credential '||var4||' is owned by '||var2||' whereas the '||var3||' using this credential is owned by '||var1|| '.' || '[[NL]]';
    END LOOP;
    ELSE
      msg_str_pass := '';
      msg_str_pass := msg_str_pass || 'The credential owner is the same as the job owner for all external jobs.  No action required.'||'[[NL]]';
    END IF;
        store_table_data (msg_num,1,check_status,'message','DBA_SCHEDULER_CREDENTIALS_OWNER','DBA_SCHEDULER_CREDENTIALS OWNER', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  DBA_SCHEDULER_JOBS AQ JOBS Check
    --
    --*********************************************************
-- VLC modified on 8/14/16  updating logic per Susan.  Changed condition for item_found from 1000 to 100.
-- VLC modified on 8/14/16  Changed pass and fail message.  Changed check status from WARN to INFO
	WHEN p_check = 'DBA_SCHEDULER_JOBS_AQ_JOBS' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_JOBS';
    l_bookmark := 'DBA_SCHEDULER_JOBS_AQ_JOBS_DATA';
    check_status := 'INFO';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';

    SELECT COUNT(*)
    INTO item_found
    FROM DBA_SCHEDULER_JOBS
    WHERE JOB_NAME LIKE 'AQ$_PLSQL_NTFN_%';
    IF (item_found > 100) THEN
      check_status := 'FAIL';
      msg_str_fail := msg_str_fail || 'When a large number of jobs with a name like AQ$_PLSQL_NTFN% exist performance issues and notification delays may occur.' || '[[NL]]';
      msg_str_fail := msg_str_fail || item_found ||' jobs with the name ''AQ$_PLSQL_NTFN_%'' exists in the database.' || '[[NL]]';
      msg_str_fail := msg_str_fail || 'Refer to DOC ID 1924526.1 for more information.' || '[[NL]]';
    ELSIF (item_found > 0) THEN
      check_status := 'INFO';
      msg_str_pass := msg_str_pass || item_found ||' jobs with the name ''AQ$_PLSQL_NTFN_%'' exists in the database.' || '[[NL]]';
    END IF;
        store_table_data (msg_num,1,check_status,'message','DBA_SCHEDULER_JOBS_AQ_JOBS','AQ PLSQL NOTIFICATION', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);

    --*********************************************************
    --
    --  DDBA_SCHEDULER_JOBS and DBA_SCHEDULER_NOTIFICATIONS CHECK
    --
    --  The table DBA_SCHEDULER_NOTIFICATIONS does not exist in 11.1.
    --  The table does exist in 11.2 and 12c
    --
    --  There is no check to perform.  For information only.
    --*********************************************************
--  VLC fixed on 9/19/16   Added cursor logic to avoid future parsing errors for invalid identifiers or tables that don't exist
-- VLC modified on 8/14/16  Updating per Susan.  Changed pass and fail message.  Changed check status from PASS to INFO
--  VLC fixed on 07/25/16  Added cursor logic to avoid future parsing errors for invalid identifiers or tables that don't exist
	WHEN p_check = 'DBA_SCHEDULER_JOBS_DBA_SCHEDULER_NOTIFICATIONS' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_JOBS and DBA_SCHEDULER_NOTIFICATIONS';
    l_bookmark := 'DBA_SCHEDULER_JOBS_DBA_SCHEDULER_NOTIFICATIONS_DATA';
    check_status := 'INFO';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    the_count_cursor := 'SELECT COUNT(*) FROM DBA_SCHEDULER_JOBS WHERE JOB_NAME IN (SELECT JOB_NAME FROM DBA_SCHEDULER_NOTIFICATIONS)';
    OPEN l_cursor FOR the_count_cursor;
    FETCH l_cursor
    INTO item_found;
    CLOSE l_cursor;
    IF (item_found > 0) THEN
      check_status := 'FAIL';
      msg_str_fail := msg_str_fail || 'There are no jobs with email notification configured. To configure one refer to Doc ID 1107813.1.' || '[[NL]]';
    ELSIF (item_found >0) THEN
      check_status := 'INFO';
      msg_str_pass := msg_str_pass || 'There are '||item_found||' jobs with email notification configured.  Click the link below to see the details.' || '[[NL]]';
	END IF;
	store_table_data (msg_num,1,'PASS','message','DBA_SCHEDULER_JOBS_DBA_SCHEDULER_NOTIFICATIONS','DBA_SCHEDULER_JOBS_DBA_SCHEDULER_NOTIFICATIONS', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);

    --*********************************************************
    --
    --  DBA_SCHEDULER_JOBS_PROGRAM_NAME Checks
    --
    --  There is no check to perform.  For information only.
    --*********************************************************
--  VLC fixed on 10/2/16   Merging with DBA_SCHEDULER_JOBS_PROGRAM_NAME_OLD.  Removing the check and only displaying data.
--  VLC fixed on 10/2/16   Added cursor logic to avoid future parsing errors for invalid identifiers or tables that don't exist
--  VLC fixed on 10/2/16   Changed status to be always be INFO
	WHEN p_check = 'DBA_SCHEDULER_JOBS_PROGRAM_NAME' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_JOBS and DBA_SCHEDULER_PROGRAMS';
    l_bookmark := 'DBA_SCHEDULER_JOBS_DBA_SCHEDULER_PROGRAMS_DATA';
    check_status := 'INFO';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
	msg_str_pass := msg_str_pass || 'Click the link below to view jobs with assigned program names.' || '[[NL]]';
	store_table_data (msg_num,1,check_status,'message','DBA_SCHEDULER_JOBS_PROGRAM_NAME','DBA_SCHEDULER_JOBS WITH ASSIGNED PROGRAM NAMES', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);

    --*********************************************************
    --
    --  DBA_SCHEDULER_JOBS_SCHEDULE_NAME Checks
    --
    --  There is no check to perform.  For information only.
    --*********************************************************
--  VLC fixed on 10/2/16   Merging with DBA_SCHEDULER_JOBS_PROGRAM_NAME.  Removing the check and only displaying data.
--  VLC fixed on 10/2/16   Added cursor logic to avoid future parsing errors for invalid identifiers or tables that don't exist
--  VLC fixed on 10/2/16   Changed status to be always be INFO
	WHEN p_check = 'DBA_SCHEDULER_JOBS_SCHEDULE_NAME' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_JOBS and DBA_SCHEDULER_SCHEDULES';
    l_bookmark := 'DBA_SCHEDULER_JOBS_DBA_SCHEDULER_SCHEDULES_DATA';
    check_status := 'INFO';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
	msg_str_pass := msg_str_pass || 'Click below to view jobs with assigned schedule names.' || '[[NL]]';
	store_table_data (msg_num,1,check_status,'message','DBA_SCHEDULER_JOBS_SCHEDULE_NAME','DBA_SCHEDULER_JOBS WITH ASSIGNED SCHEDULE NAMES', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);

    --*********************************************************
    --
    --  DBA_SUBSCR_REGISTRATIONS and DBA_USERS Check
    --
    --  There is no check to perform.  For information only.
    --*********************************************************
-- VLC modified on 8/14/16  Per Susan, changed pass message.
  WHEN p_check = 'DBA_SUBSCR_REGISTRATIONS_DBA_USERS' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SUBSCR_REGISTRATIONS and DBA_USERS';
    l_bookmark := 'DBA_SUBSCR_REGISTRATIONS_DBA_USERS_DATA';
    check_status := 'PASS';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_pass := msg_str_pass || 'Click the link below to view the AQ related data. There are no checks defined as of now. The data is available for Oracle support review and collaboration with the AQ team if required.' || '[[NL]]';
    store_table_data (msg_num,1,'PASS','message','DBA_SUBSCR_REGISTRATIONS_DBA_USERS','OTHER AQ RELATED CHECKS - DBA_SUBSCR_REGISTRATIONS and DBA_USERS', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);

    --*********************************************************
    --
    --  DBA_SCHEDULER_WINDOW_LOG Checks
    --
    --*********************************************************
  WHEN p_check = 'DBA_SCHEDULER_WINDOW_LOG_CHK' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_WINDOW_LOG';
    l_bookmark := 'DBA_SCHEDULER_WINDOW_LOG_DATA';
     check_status := 'INFO';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_pass := msg_str_pass || 'Click the link below for details about the scheduler window logs in the database.'||'[[NL]]';
    store_table_data (msg_num,1,check_status,'message','DBA_SCHEDULER_WINDOW_LOG_CHK','DBA_SCHEDULER_WINDOW_LOG', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);

    --*********************************************************
    --
    --  DBA_SCHEDULER_WINDOW_GROUPS Checks
    --
    --*********************************************************
  WHEN p_check = 'DBA_SCHEDULER_WINDOW_GROUPS_CHK' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_WINDOW_GROUPS';
    l_bookmark := 'DBA_SCHEDULER_WINDOW_GROUPS_DATA';
     check_status := 'INFO';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_pass := msg_str_pass || 'Click the link below for details about the scheduler window groups in the database.'||'[[NL]]';
    store_table_data (msg_num,1,check_status,'message','DBA_SCHEDULER_WINDOW_GROUPS_CHK','DBA_SCHEDULER_WINDOW_GROUPS', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  DBA_SCHEDULER_WINDOW_GROUPS NEXT_START_DATE Checks
    --
    --*********************************************************
  WHEN p_check = 'DBA_SCHEDULER_WINDOW_GROUPS_NEXT_START_DATE' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_WINDOW_GROUPS';
    l_bookmark := 'DBA_SCHEDULER_WINDOW_GROUPS_DATA';
    check_status := 'PASS';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_fail := msg_str_fail || 'The next start date is past due for one or more groups.  If the group is not a currently active Window, drop the maintenance window and recreate it using the following commands: ' || '[[NL]]';
    msg_str_fail := msg_str_fail || 'Login as SYSDBA' || '[[NL]]';
    msg_str_fail := msg_str_fail || '@?/rdbms/admin/catnomwn.sql' || '[[NL]]';
    msg_str_fail := msg_str_fail || '@?/rdbms/admin/catmwin.sql' || '[[NL]]';
    msg_str_pass := msg_str_pass || 'The next start date is current for all groups. No action is required.' || '[[NL]]';
    FOR i IN
    (SELECT * FROM dba_scheduler_window_groups
    )
    LOOP
      IF ((to_timestamp_tz(i.NEXT_START_DATE,'DD-MON-YY HH:MI:SS:FF6 PM  TZR') at TIME zone 'GMT') < cur_systimestamp) THEN
        check_status := 'FAIL';
        msg_str_fail := msg_str_fail || 'The start date for '||i.WINDOW_GROUP_NAME||' is a past date '|| i.NEXT_START_DATE|| '[[NL]]';
      END IF;
    END LOOP;
    store_table_data (msg_num,1,check_status,'message','DBA_SCHEDULER_WINDOW_GROUPS_NEXT_START_DATE','GROUP NEXT START DATE', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  DBA_SCHEDULER_WINDOW_GROUPS START DATE Checks
    --
    --*********************************************************
--  VLC fixed on 10/2/16   Added cursor logic to avoid future parsing errors for invalid identifiers or tables that don't exist
--  VLC fixed on 10/2/16   Changed fail message text
  WHEN p_check = 'DBA_SCHEDULER_WINDOW_GROUPS_ENABLED' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_WINDOW_GROUPS';
    l_bookmark := 'DBA_SCHEDULER_WINDOW_GROUPS_DATA';
    check_status := 'PASS';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_fail := msg_str_fail || 'One of more window groups are not enabled.' || '[[NL]]';
    msg_str_fail := msg_str_fail || 'To get the list of window group names use: '|| '[[NL]]';
    msg_str_fail := msg_str_fail || 'select WINDOW_GROUP_NAME,ENABLED from DBA_SCHEDULER_WINDOW_GROUPS;'|| '[[NL]]';
    msg_str_fail := msg_str_fail || 'To enable the group(s) use the command(s): ' || '[[NL]]';
    msg_str_pass := msg_str_pass || 'All groups are enabled. No action is required.' || '[[NL]]';
    the_count_cursor := 'SELECT COUNT(*) FROM DBA_SCHEDULER_WINDOW_GROUPS WHERE ENABLED != ''TRUE''';
    the_data_cursor  := 'SELECT WINDOW_GROUP_NAME FROM DBA_SCHEDULER_WINDOW_GROUPS WHERE ENABLED != ''TRUE''';
    OPEN l_cursor FOR the_count_cursor;
    FETCH l_cursor
    INTO item_found;
    CLOSE l_cursor;
    IF (item_found > 0) THEN
    check_status := 'FAIL';
    OPEN l_cursor FOR the_data_cursor;
    LOOP
      FETCH l_cursor INTO var1;
      EXIT WHEN l_cursor%notfound;
      msg_str_fail := msg_str_fail || 'EXEC DBMS_SCHEDULER.ENABLE('||var1||');';
    END LOOP;
    CLOSE l_cursor;
	END IF;
    store_table_data (msg_num,1,check_status,'message','DBA_SCHEDULER_WINDOW_GROUPS_ENABLED','WINDOW GROUP ENABLED', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  ALL_SCHEDULER_WINDOW_DETAILS Checks
    --
    --*********************************************************
--  VLC fixed on 11/8/16 - the check is info only.  Removing the fail message.
	WHEN p_check = 'ALL_SCHEDULER_WINDOW_DETAILS_CHK' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'ALL_SCHEDULER_WINDOW_DETAILS';
    l_bookmark := 'ALL_SCHEDULER_WINDOW_DETAILS_DATA';
     check_status := 'INFO';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_pass := msg_str_pass || 'Click the link below for details about the scheduler window details.  No action is required.'||'[[NL]]';
    store_table_data (msg_num,1,check_status,'message','ALL_SCHEDULER_WINDOW_DETAILS_CHK','ALL_SCHEDULER_WINDOW_DETAILS_CHK', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);
   --*********************************************************
    --
    --  DBA_SCHEDULER_WINGROUP_MEMBERS Checks
    --
    --*********************************************************
    -- VLC fixed on 11/8/16  Modified the queries for Autotask to include "AND WINDOW_GROUP_NAME=MAINTENANCE_WINDOW_GROUP" in the where clause
	--  VLC fixed on 10/2/16   Added cursor logic to avoid future parsing errors for invalid identifiers or tables that don't exist
  WHEN p_check = 'DBA_SCHEDULER_WINGROUP_MEMBERS' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_WINGROUP_MEMBERS';
    l_bookmark := 'DBA_SCHEDULER_WINGROUP_MEMBERS_DATA';
    check_status := 'INFO';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    IF (p_script_selected = 'JOB_CONFIGURATION') THEN
      msg_str_pass := msg_str_pass || 'Click the link below for details about the members of the scheduler window groups.'||'[[NL]]';
    ELSIF (p_script_selected = 'JOB_AUTOTASK') THEN
      the_count_cursor := 'SELECT COUNT(*) FROM DBA_SCHEDULER_WINGROUP_MEMBERS WHERE WINDOW_NAME = ''WEEKNIGHT_WINDOW'' AND WINDOW_GROUP_NAME=''MAINTENANCE_WINDOW_GROUP''';
      OPEN l_cursor FOR the_count_cursor;
      FETCH l_cursor
      INTO weeknight_window_found;
      CLOSE l_cursor;
      the_count_cursor := 'SELECT COUNT(*) FROM DBA_SCHEDULER_WINGROUP_MEMBERS WHERE WINDOW_NAME = ''WEEKEND_WINDOW'' AND WINDOW_GROUP_NAME=''MAINTENANCE_WINDOW_GROUP''';
      OPEN l_cursor FOR the_count_cursor;
      FETCH l_cursor
      INTO weekend_window_found;
      CLOSE l_cursor;
      IF (weeknight_window_found = 0) OR ( weekend_window_found = 0 ) THEN
        check_status := 'FAIL';
        msg_str_fail := msg_str_fail || 'The WEEKEND and WEEKNIGHT windows are not added to the MAINTENANCE_WINDOW_GROUP group. Add them using the following commands:' || '[[NL]]';
        msg_str_fail := msg_str_fail || 'exec dbms_scheduler.add_window_group_member(''MAINTENANCE_WINDOW_GROUP'', ''WEEKNIGHT_WINDOW'');' || chr(13) || chr(10);
        msg_str_fail := msg_str_fail || 'exec dbms_scheduler.add_window_group_member(''MAINTENANCE_WINDOW_GROUP'',''WEEKEND_WINDOW'');' || chr(13) || chr(10);
      ELSE
        check_status := 'PASS';
        msg_str_pass := msg_str_pass || 'The WEEKEND and WEEKNIGHT windows have been added to the MAINTENANCE_WINDOW_GROUP group. No action is required.' || '[[NL]]';
      END IF;
    END IF;
	store_table_data (msg_num,1,check_status,'message','DBA_SCHEDULER_WINGROUP_MEMBERS','DBA_SCHEDULER_WINGROUP_MEMBERS', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  DBA_SCHEDULER_WINDOWS Checks
    --
    --*********************************************************
  WHEN p_check = 'DBA_SCHEDULER_WINDOWS' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_WINDOWS';
    l_bookmark := 'DBA_SCHEDULER_WINDOWS_DATA';
    check_status := 'INFO';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_pass := msg_str_pass || 'Click the link below for details about the scheduler windows in the database.'||'[[NL]]';
    store_table_data (msg_num,1,check_status,'message','DBA_SCHEDULER_WINDOWS','DBA_SCHEDULER_WINDOWS', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);

    --*********************************************************
    --
    --  DBA_SCHEDULER_WINDOWS EXIST  Checks
    --
    --*********************************************************
--  VLC fixed on 10/2/16   Added cursor logic to avoid future parsing errors for invalid identifiers or tables that don't exist
--  VLC fixed on 8/8/16  Changing to only call store_table_data one time
--  VLC fixed on 8/9/16  Fixed pass message,  'The' was missing the T

  WHEN p_check = 'DBA_SCHEDULER_WINDOWS_EXIST' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_WINDOWS';
    l_bookmark := 'DBA_SCHEDULER_WINDOWS_DATA';
    check_status := 'PASS';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    the_count_cursor := 'SELECT COUNT(*) FROM dba_scheduler_windows WHERE ENABLED = ''TRUE'' and WINDOW_NAME in (''WEEKEND_WINDOW'',''WEEKNIGHT_WINDOW'')';

    OPEN l_cursor FOR the_count_cursor;
    FETCH l_cursor
    INTO item_found;
    CLOSE l_cursor;
    IF (chkVersion('10',db_version,1) = 'EQ') THEN
	  IF (item_found < 2) THEN
		check_status := 'FAIL';
		msg_str_fail := msg_str_fail || 'The Maintenance Windows are not created. They can be recreated by running the following scripts: ' || '[[NL]]';
		msg_str_fail := msg_str_fail || t_common_message(1).msg_body;
	  ELSE
		msg_str_pass := msg_str_pass || 'The Maintenance Windows are created. No action is required. ' || '[[NL]]';
	  END IF;
	ELSIF ((chkVersion('11',db_version,1) = 'EQ') OR (chkVersion('12',db_version,1) = 'EQ')) THEN
      IF (item_found > 0) THEN
		check_status := 'FAIL';
		msg_str_fail := msg_str_fail || 'The WEEKEND_WINDOW and WEEKNIGHT_WINDOW are the old 10g windows and should not be enabled. Disable them using the following:' || '[[NL]]';
		msg_str_fail := msg_str_fail || 'EXEC DBMS_SCHEDULER.DISABLE (''WEEKEND_WINDOW'');' || '[[NL]]';
		msg_str_fail := msg_str_fail || 'EXEC DBMS_SCHEDULER.DISABLE (''WEEKNIGHT_WINDOW'');' || '[[NL]]';
	  ELSE
		msg_str_pass := msg_str_pass || 'The WEEKEND_WINDOW and WEEKNIGHT_WINDOW do not exist which is expected for 11g and 12c. No action is required.' || '[[NL]]';
	  END IF;
	END IF;
	store_table_data (msg_num,1,check_status,'message','DBA_SCHEDULER_WINDOWS_EXIST','MAINTENANCE WINDOWS EXIST', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);

    --*********************************************************
    --
    --  DBA_SCHEDULER_WINDOWS ENABLED Checks
    --
    --*********************************************************
  WHEN p_check = 'DBA_SCHEDULER_WINDOWS_ENABLED' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_WINDOWS';
    l_bookmark := 'DBA_SCHEDULER_WINDOWS_DATA';
    check_status := 'PASS';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';

    IF (chkVersion('10',db_version,1) = 'EQ') THEN
      msg_str_pass := msg_str_pass || 'Both the WEEKNIGHT_WINDOW and WEEKEND_WINDOW are enabled. No action is required to enable the window.' || '[[NL]]';
      SELECT COUNT(*)
      INTO item_found
      FROM dba_scheduler_windows
      WHERE window_name IN ('WEEKNIGHT_WINDOW','WEEKEND_WINDOW') AND ENABLED != 'TRUE';
      IF (item_found > 0) THEN
        check_status := 'FAIL';
        FOR i IN
        (SELECT WINDOW_NAME, ENABLED
        FROM dba_scheduler_windows
        WHERE window_name IN ('WEEKNIGHT_WINDOW','WEEKEND_WINDOW')
        )
        LOOP
          IF (i.ENABLED != 'TRUE') THEN
            msg_str_fail := msg_str_fail || 'The '||i.WINDOW_NAME ||' is not enabled. The following command can be used to enable WINDOWS: ' || '[[NL]]';
            --            msg_str_fail := msg_str_fail || 'EXEC DBMS_SCHEDULER.ENABLE (''SYS.'||i.WINDOW_NAME ||''');' || '[[NL]]';
          ELSE
            msg_str_fail := msg_str_fail || 'The '||i.WINDOW_NAME ||' is enabled. No action is required to enable this window.' || '[[NL]]';
          END IF;
        END LOOP;
      END IF;
     ELSIF ((chkVersion('11',db_version,1) = 'EQ') OR (chkVersion('12',db_version,1) = 'EQ')) THEN
      msg_str_fail := msg_str_fail || 'One or more windows are disabled.  Use the following to enable the window:' || '[[NL]]';
      msg_str_pass := msg_str_pass || 'All windows are enabled. No action is required.' || '[[NL]]';
      SELECT COUNT(*)
      INTO item_found
      FROM dba_scheduler_windows
      WHERE ((WINDOW_NAME NOT IN ('WEEKEND_WINDOW', 'WEEKNIGHT_WINDOW') AND ENABLED = 'FALSE') OR (WINDOW_NAME IN ('WEEKEND_WINDOW', 'WEEKNIGHT_WINDOW') AND ENABLED = 'TRUE'));
      IF (item_found > 0) THEN
        check_status := 'FAIL';
        FOR i IN
        (SELECT WINDOW_NAME, ENABLED FROM dba_scheduler_windows
        )
        LOOP
          IF (((i.WINDOW_NAME = 'WEEKEND_WINDOW') OR ( i.WINDOW_NAME = 'WEEKNIGHT_WINDOW' ) ) AND ( i.ENABLED = 'TRUE' ) ) THEN
            msg_str_fail := msg_str_fail || 'EXEC DBMS_SCHEDULER.DISABLE ('''||i.WINDOW_NAME ||''');' || '[[NL]]';
          END IF;
          IF (((i.WINDOW_NAME != 'WEEKEND_WINDOW') AND ( i.WINDOW_NAME != 'WEEKNIGHT_WINDOW' ) ) AND ( i.ENABLED = 'FALSE' ) ) THEN
            msg_str_fail := msg_str_fail || 'EXEC DBMS_SCHEDULER.ENABLE ('''||i.WINDOW_NAME||''');' || '[[NL]]';
          END IF;
        END LOOP;
      END IF;
    END IF;
    store_table_data (msg_num,1,check_status,'message','DBA_SCHEDULER_WINDOWS_ENABLED','DBA_SCHEDULER_WINDOWS ENABLED', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  DBA_SCHEDULER_WINDOWS NEXT_START_DATE Checks
    --
    --*********************************************************
--  VLC fixed on 10/2/16   Added cursor logic to avoid future parsing errors for invalid identifiers or tables that don't exist
--  VLC fixed on 10/2/16   Added pass message for version 11g+
--  VLC fixed on 10/2/16   Changed to compare NEXT_START_DATE to cur_systimestamp
	WHEN p_check = 'DBA_SCHEDULER_WINDOWS_NEXT_START_DATE' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_WINDOWS';
    l_bookmark := 'DBA_SCHEDULER_WINDOWS_DATA';
    check_status := 'PASS';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';

	IF (chkVersion('10',db_version,1) = 'EQ') THEN
      the_count_cursor := 'SELECT COUNT(*) FROM dba_scheduler_windows WHERE window_name IN (''WEEKNIGHT_WINDOW'',''WEEKEND_WINDOW'') AND (to_timestamp_tz(NEXT_START_DATE,''DD-MON-YY HH:MI:SS:FF6 PM  TZR'') at TIME zone ''GMT'') < '''||cur_systimestamp||'''';
      the_data_cursor  := 'SELECT WINDOW_NAME, NEXT_START_DATE FROM dba_scheduler_windows WHERE window_name IN (''WEEKNIGHT_WINDOW'',''WEEKEND_WINDOW'')';
      OPEN l_cursor FOR the_count_cursor;
      FETCH l_cursor
      INTO item_found;
      CLOSE l_cursor;
      IF (item_found > 0) THEN
	  check_status := 'FAIL';
      OPEN l_cursor FOR the_data_cursor;
      LOOP
	    FETCH l_cursor INTO var1,var2;
	    EXIT WHEN l_cursor%notfound;
	    IF ((to_timestamp_tz(var2,'DD-MON-YY HH:MI:SS:FF6 PM  TZR') at TIME zone 'GMT') < cur_systimestamp) THEN
          msg_str_fail := msg_str_fail || 'The NEXT_START_DATE for '|| var1||' is a past date. Reset the window.' || '[[NL]]';
	    ELSE
  	      msg_str_fail := msg_str_fail || 'The NEXT_START_DATE for '|| var1||' is a current date. No action is required to reset this window.' || '[[NL]]';
	    END IF;
	    END LOOP;
      CLOSE l_cursor;
      ELSE
        msg_str_pass := msg_str_pass || 'The NEXT_START_DATE for both the WEEKNIGHT_WINDOW and WEEKEND_WINDOW is a current date. No action is required.' || '[[NL]]';
      END IF;
	ELSIF ((chkVersion('11',db_version,1) = 'EQ') OR (chkVersion('12',db_version,1) = 'EQ')) THEN
      the_count_cursor := 'SELECT COUNT(*) FROM dba_scheduler_windows WHERE (to_timestamp_tz(NEXT_START_DATE,''DD-MON-YY HH:MI:SS:FF6 PM  TZR'') at TIME zone ''GMT'') < '''||cur_systimestamp||'''';
      the_data_cursor  := 'SELECT WINDOW_NAME, NEXT_START_DATE FROM dba_scheduler_windows WHERE (to_timestamp_tz(NEXT_START_DATE,''DD-MON-YY HH:MI:SS:FF6 PM  TZR'') at TIME zone ''GMT'') < '''||cur_systimestamp||'''';
      OPEN l_cursor FOR the_count_cursor;
      FETCH l_cursor
      INTO item_found;
      CLOSE l_cursor;
      IF (item_found > 0) THEN
	    check_status := 'FAIL';
        msg_str_fail := msg_str_fail || 'One or more windows have a next start date that is past due. Consider re-creating the whole AutoTask for 11g AS follow : ' || '[[NL]]';
        msg_str_fail := msg_str_fail || 'connect as sysdba' || '[[NL]]';
        msg_str_fail := msg_str_fail || '@ $ORACLE_HOME/rdbms/admin/catnomwn.sql' || '[[NL]]';
        msg_str_fail := msg_str_fail || '@ $ORACLE_HOME/rdbms/admin/catmwin.sql' || '[[NL]]';
        msg_str_fail := msg_str_fail || 'The following windows have a next start date that is past due.' || '[[NL]]';
      OPEN l_cursor FOR the_data_cursor;
      LOOP
	    FETCH l_cursor INTO var1,var2;
	    EXIT WHEN l_cursor%notfound;
	    msg_str_fail := msg_str_fail || var1 || '  is scheduled to start '||var2 || '[[NL]]';
	    END LOOP;
      CLOSE l_cursor;
      ELSE
        msg_str_pass := msg_str_pass || 'The NEXT_START_DATE for the windows is a current date. No action is required.' || '[[NL]]';
      END IF;
	END IF;
    store_table_data (msg_num,1,check_status,'message','DBA_SCHEDULER_WINDOWS_NEXT_START_DATE','NEXT START DATE IS OLD', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  DBA_SCHEDULER_WINDOWS ACTIVE Checks
    --
    --*********************************************************
--  VLC fixed on 10/2/16   Added cursor logic to avoid future parsing errors for invalid identifiers or tables that don't exist

  WHEN p_check = 'DBA_SCHEDULER_WINDOWS_ACTIVE' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_WINDOWS';
    l_bookmark := 'DBA_SCHEDULER_WINDOWS_DATA';
    check_status := 'PASS';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_pass := msg_str_pass || 'The windows are not currently active. No action is required.' || '[[NL]]';

    IF (chkVersion('10',db_version,1) = 'EQ') THEN
      the_count_cursor := 'SELECT COUNT(*) FROM dba_scheduler_windows WHERE window_name IN (''WEEKNIGHT_WINDOW'',''WEEKEND_WINDOW'') AND ACTIVE = ''TRUE''';
      the_data_cursor  := 'SELECT WINDOW_NAME, ACTIVE FROM dba_scheduler_windows WHERE window_name IN (''WEEKNIGHT_WINDOW'',''WEEKEND_WINDOW'')';
      OPEN l_cursor FOR the_count_cursor;
      FETCH l_cursor
      INTO item_found;
      CLOSE l_cursor;
      IF (item_found > 0) THEN
        check_status := 'FAIL';
        OPEN l_cursor FOR the_data_cursor;
        LOOP
          FETCH l_cursor INTO var1,var2;
          EXIT WHEN l_cursor%notfound;
          IF (var2 = 'TRUE') THEN
            msg_str_fail := msg_str_fail || var1|| ' is currently active.' || '[[NL]]';
          ELSE
            msg_str_fail := msg_str_fail || var1|| ' is not currently active. No action is required for this window.' || '[[NL]]';
          END IF;
        END LOOP;
        CLOSE l_cursor;
      END IF;
    ELSIF ((chkVersion('11',db_version,1) = 'EQ') OR (chkVersion('12',db_version,1) = 'EQ')) THEN
      the_count_cursor := 'SELECT COUNT(*) FROM dba_scheduler_windows WHERE ACTIVE = ''TRUE''';
      the_data_cursor  := 'SELECT WINDOW_NAME, ACTIVE FROM dba_scheduler_windows WHERE ACTIVE = ''TRUE''';
      OPEN l_cursor FOR the_count_cursor;
      FETCH l_cursor
      INTO item_found;
      CLOSE l_cursor;
      IF (item_found > 0) THEN
        check_status := 'FAIL';
        msg_str_fail := msg_str_fail || 'One or more windows is currently active. If this is not expected,  please close the window manually using the following command: ' || '[[NL]]';
        OPEN l_cursor FOR the_data_cursor;
        LOOP
          FETCH l_cursor INTO var1,var2;
          EXIT WHEN l_cursor%notfound;
          msg_str_fail := msg_str_fail || 'EXECUTE DBMS_SCHEDULER.CLOSE_WINDOW ('''||var1||''');' || '[[NL]]';
        END LOOP;
      END IF;
    END IF;
    store_table_data (msg_num,1,check_status,'message','DBA_SCHEDULER_WINDOWS_ACTIVE','DBA_SCHEDULER_WINDOWS ACTIVE', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  11g,12c - DBA_SCHEDULER_WINDOWS RESOURCE_PLAN Checks
    --
    --*********************************************************
  WHEN p_check = 'DBA_SCHEDULER_WINDOWS_RESOURCE_PLAN' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_WINDOWS';
    l_bookmark := 'DBA_SCHEDULER_WINDOWS_DATA';
    sched_win_resource_plan := '''DEFAULT_MAINTENANCE_PLAN''';
    FOR i IN
    (SELECT DISTINCT resource_plan
    FROM dba_scheduler_windows
    WHERE enabled = 'TRUE'
    )
    LOOP
      IF ( i.resource_plan != 'DEFAULT_MAINTENANCE_PLAN') THEN
          sched_win_resource_plan := sched_win_resource_plan ||','''|| i.resource_plan|| '''';
      END IF;
    END LOOP;
    --*********************************************************
    --
    --  DBA_SCHEDULER_JOB_CLASSES Checks
    --
    --*********************************************************
  WHEN p_check = 'DBA_SCHEDULER_JOB_CLASSES' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_JOB_CLASSES';
    l_bookmark := 'DBA_SCHEDULER_JOB_CLASSES_DATA';
    check_status := 'INFO';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_pass := msg_str_pass || 'Click the link below for details about the scheduler job classes in the database.'||'[[NL]]';
    store_table_data (msg_num,1,check_status,'message','DBA_SCHEDULER_JOB_CLASSES','DBA_SCHEDULER_JOB_CLASSES', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  DBA_SCHEDULER_JOBS AND DBA_SCHEDULER_JOB_CLASSES Checks
    --
    --*********************************************************
--VLC fixed on 11/8/16  No check needed.  Info only.  Removing the fail message.
	WHEN p_check = 'DBA_SCHEDULER_JOBS_AND_DBA_SCHEDULER_JOB_CLASSES' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_JOBS_AND_DBA_SCHEDULER_JOB_CLASSES';
    l_bookmark := 'DBA_SCHEDULER_JOBS_AND_DBA_SCHEDULER_JOB_CLASSES_DATA';
    check_status := 'INFO';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    IF (p_script_selected = 'JOB_AUTOTASK') THEN
      msg_str_pass := msg_str_pass || 'Identify the job class and its consumer group linked to a specific job.';
    ELSE
      msg_str_pass := msg_str_pass || 'Click the link below for details about the scheduled jobs that are assigned job classes.'||'[[NL]]';
    END IF;
    store_table_data (msg_num,1,check_status,'message','DBA_SCHEDULER_JOBS_AND_DBA_SCHEDULER_JOB_CLASSES','DBA_SCHEDULER_JOBS AND DBA_SCHEDULER_JOB_CLASSES', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  DBA_SCHEDULER_RUNNING_JOBS INVALID SLAVE_OS_PROCESS_ID CHECK
    --
    --*********************************************************
  WHEN p_check = 'DBA_SCHEDULER_RUNNING_JOBS_SLAVE_OS_PROCESS_ID' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_RUNNING_JOBS_SLAVE_OS_PROCESS_ID';
    l_bookmark := 'DBA_SCHEDULER_RUNNING_JOBS_SLAVE_OS_PROCESS_ID_DATA';
    check_status := 'INFO';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_fail := msg_str_fail || 'Click the link below for details about jobs currently being executed and without a valid Slave OS Process ID.' || '[[NL]]';
    msg_str_pass := msg_str_pass || 'All jobs are currently being executed with a valid Slave OS process ID.'||'[[NL]]';

	the_count_cursor := 'SELECT COUNT(*) from dba_scheduler_running_jobs where SLAVE_OS_PROCESS_ID not in (select spid from V$process)';
    the_data_cursor  := 'select JOB_NAME,SLAVE_OS_PROCESS_ID from dba_scheduler_running_jobs where SLAVE_OS_PROCESS_ID not in (select spid from V$process)';
      OPEN l_cursor FOR the_count_cursor;
      FETCH l_cursor
      INTO item_found;
      CLOSE l_cursor;
      IF (item_found > 0) THEN
	  check_status := 'FAIL';
	  END IF;
    store_table_data (msg_num,1,check_status,'message','DBA_SCHEDULER_RUNNING_JOBS_SLAVE_OS_PROCESS_ID','DBA_SCHEDULER_RUNNING_JOBS INVALID SLAVE_OS_PROCESS_ID', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  DBA_PROFILES CHECK
    --
    --*********************************************************
--VLC fixed on 11/8/16  Check will be info only. Changed the pass message.  removed the fail message.
	WHEN p_check = 'DBA_PROFILES' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_PROFILES';
    l_bookmark := 'DBA_PROFILES_DATA';
    check_status := 'INFO';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_pass := msg_str_pass || 'Click the link below for details about the SESSIONS_PER_USER resource.'||'[[NL]]';
    store_table_data (msg_num,1,check_status,'message','DBA_PROFILES','DBA_PROFILES', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  DBA_SCHEDULER_CHAINS CHECK
    --
    --*********************************************************
--VLC fixed on 11/8/16 The check is info only.  Removing the fail message.
	WHEN p_check = 'DBA_SCHEDULER_CHAINS' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_CHAINS';
    l_bookmark := 'DBA_SCHEDULER_CHAINS_DATA';
    check_status := 'INFO';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    SELECT COUNT(*)
    INTO scheduler_chains_found
    FROM DBA_SCHEDULER_CHAINS;
    msg_str_pass := msg_str_pass || 'There are '||scheduler_chains_found||' chained jobs in the database. '||'[[NL]]';
    store_table_data (msg_num,1,check_status,'message','DBA_SCHEDULER_CHAINS','DBA_SCHEDULER_CHAINS', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  DBA_SCHEDULER_CHAIN_STEPS CHECK
    --
    --*********************************************************
--VLC fixed on 11/8/16 The check is info only.  Chaged pass message. Removed the fail message.
	WHEN p_check = 'DBA_SCHEDULER_CHAIN_STEPS' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_CHAIN_STEPS';
    l_bookmark := 'DBA_SCHEDULER_CHAIN_STEPS_DATA';
    check_status := 'INFO';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_pass := msg_str_pass || 'Click below to view the DBA_SCHEDULER_CHAIN_STEPS data.'||'[[NL]]';
    store_table_data (msg_num,1,check_status,'message','DBA_SCHEDULER_CHAIN_STEPS','DBA_SCHEDULER_CHAIN_STEPS', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  DBA_SCHEDULER_CHAIN_RULES CHECK
    --
    --*********************************************************
--VLC fixed on 11/8/16 The check is info only.  Chaged pass message. Removed the fail message.
	WHEN p_check = 'DBA_SCHEDULER_CHAIN_RULES' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_CHAIN_RULES';
    l_bookmark := 'DBA_SCHEDULER_CHAIN_RULES_DATA';
    check_status := 'INFO';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_pass := msg_str_pass || 'Click below to view the DBA_SCHEDULER_CHAIN_RULES data.'||'[[NL]]';
    store_table_data (msg_num,1,check_status,'message','DBA_SCHEDULER_CHAIN_RULES','DBA_SCHEDULER_CHAIN_RULES', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  DBA_SCHEDULER_RUNNING_CHAINS CHECK
    --
    --*********************************************************
  WHEN p_check = 'DBA_SCHEDULER_RUNNING_CHAINS' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_RUNNING_CHAINS';
    l_bookmark := 'DBA_SCHEDULER_RUNNING_CHAINS_DATA';
    check_status := 'INFO';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_fail := msg_str_fail || 'Fail message not defined.' || '[[NL]]';

    SELECT COUNT(*)
    INTO item_found
    FROM DBA_SCHEDULER_RUNNING_CHAINS;

    IF (item_found = 0) THEN
    msg_str_pass := msg_str_pass || 'No chained jobs are currently being executed. No action required.'||'[[NL]]';
    ELSE
    msg_str_pass := msg_str_pass || 'There are '||item_found||' chained jobs currently being executed. No action required.'||'[[NL]]';
    END IF;
    store_table_data (msg_num,1,check_status,'message','DBA_SCHEDULER_RUNNING_CHAINS','DBA_SCHEDULER_RUNNING_CHAINS', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  AQ$SCHEDULER$_EVENT_QTAB CHECK
    --
    --  No check here.  Information only.
    --*********************************************************
-- VLC modified on 8/14/16  Per Susan, changed pass message.
-- VLC fixed on 11/8/16 The check is info only.  Removing the fail message.
  WHEN p_check = 'AQ$SCHEDULER$_EVENT_QTAB' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'SYS.AQ$SCHEDULER$_EVENT_QTAB';
    l_bookmark := 'AQ$SCHEDULER$_EVENT_QTAB_DATA';
    check_status := 'INFO';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_pass := msg_str_pass || 'Click the link below to view the AQ related data. There are no checks defined as of now. The data is available for Oracle support review and collaboration with the AQ team if required.' || '[[NL]]';
    store_table_data (msg_num,1,check_status,'message','AQ$SCHEDULER$_EVENT_QTAB','AQ$SCHEDULER$_EVENT_QTAB', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  SCHEDULER$_EVENT_QTAB CHECK
    --
    --*********************************************************
  WHEN p_check = 'SCHEDULER$_EVENT_QTAB' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'SYS.SCHEDULER$_EVENT_QTAB';
    l_bookmark := 'SCHEDULER$_EVENT_QTAB_DATA';
    check_status := 'INFO';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_fail := msg_str_fail || 'Fail message not defined.' || '[[NL]]';
    msg_str_pass := msg_str_pass || 'Click below to see AQ related checks. '||'[[NL]]';
    store_table_data (msg_num,1,check_status,'message','SCHEDULER$_EVENT_QTAB','SCHEDULER$_EVENT_QTAB', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  DBA_SCHEDULER_NOTIFICATIONS EMAIL Checks
    --
    --  Table DBA_SCHEDULER_NOTIFICATIONS does not exist in 11.1.
    --  The table does exist in 11.2 and 12c.
    --
    --*********************************************************
--  VLC fixed on 07/25/16  Added cursor logic to avoid future parsing errors for invalid identifiers or tables that don't exist
--  VLC fixed on 07/26/16  changed to dynamic sql to avoid the  errors  ORA-00904: "FILE_WATCHER_NAME": invalid identifier ORA-06550: for DB version 11
--  VLC modified on 8/14/16  updating logic per Susan.  Changed condition to report failure if no row returned.
--  VLC modified on 8/14/16  Changed pass and fail messages.
  WHEN p_check = 'DBA_SCHEDULER_NOTIFICATIONS_EMAIL' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_NOTIFICATIONS';
    l_bookmark := 'DBA_SCHEDULER_NOTIFICATIONS_DATA';
    check_status := 'INFO';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_fail := msg_str_fail || 'E-mail notifications are not configured for any jobs in this database.' || '[[NL]]';
    msg_str_pass := msg_str_pass || 'Job Notifications are configured. Verify that the SENDER and RECIPIENT email addresses are correct for each job.'||'[[NL]]';

    the_count_cursor := 'SELECT COUNT(*) FROM DBA_SCHEDULER_NOTIFICATIONS';
    the_data_cursor  := 'SELECT DISTINCT JOB_NAME, SENDER, RECIPIENT FROM DBA_SCHEDULER_NOTIFICATIONS';
    OPEN l_cursor FOR the_count_cursor;
    FETCH l_cursor
    INTO notifications_found;
    CLOSE l_cursor;
    IF (notifications_found > 0) THEN
    check_status := 'INFO';
    OPEN l_cursor FOR the_data_cursor;
    LOOP
      FETCH l_cursor INTO var1,var2,var3;
      EXIT WHEN l_cursor%notfound;
      msg_str_pass := msg_str_pass || 'The SENDER and RECIPIENT for '||var1 ||' are '||var2|| ' and ' ||var3|| ' respectively.'||'[[NL]]';
    END LOOP;
    CLOSE l_cursor;
    ELSE
      check_status := 'FAIL';
    END IF;
    store_table_data (msg_num,1,check_status,'message','DBA_SCHEDULER_NOTIFICATIONS_EMAIL','EMAIL NOTIFICATIONS IN THE DATABASE', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);

        --*********************************************************
    --
    --  DBA_SCHEDULER_NOTIFICATIONS FILTER Checks
    --
    --  Table DBA_SCHEDULER_NOTIFICATIONS does not exist in 11.1.
    --  The table does exist in 11.2 and 12c.
    --
    --*********************************************************
--  VLC modified on 8/14/16  added this check
  WHEN p_check = 'DBA_SCHEDULER_NOTIFICATIONS_FILTER' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_NOTIFICATIONS';
    l_bookmark := 'DBA_SCHEDULER_NOTIFICATIONS_DATA';
    check_status := 'INFO';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_fail := msg_str_fail || 'Only one filter conditions can be handled by email notifications.' || '[[NL]]';
    msg_str_pass := msg_str_pass || 'Job Notifications are configured. Verify that the filter conditions are met for the jobs.'||'[[NL]]';
    the_count_cursor := 'SELECT COUNT(*) FROM DBA_SCHEDULER_NOTIFICATIONS WHERE (FILTER_CONDITION LIKE ''%AND%'') OR (FILTER_CONDITION LIKE ''%OR%'')';
    the_data_cursor  := 'SELECT JOB_NAME, FILTER_CONDITION FROM DBA_SCHEDULER_NOTIFICATIONS';
    IF (notifications_found > 0) THEN
      OPEN l_cursor FOR the_count_cursor;
      FETCH l_cursor
      INTO item_found;
      CLOSE l_cursor;
      IF (item_found > 0) THEN
        check_status := 'FAIL';
        OPEN l_cursor FOR the_data_cursor;
        LOOP
          FETCH l_cursor INTO var1,var2;
          EXIT WHEN l_cursor%notfound;
          msg_str_fail := msg_str_fail || 'The filter condition for job '||var1 ||' is '||var2|| '.'||'[[NL]]';
        END LOOP;
        CLOSE l_cursor;
      ELSE
        check_status := 'INFO';
      END IF;
    END IF;
    store_table_data (msg_num,1,check_status,'message','DBA_SCHEDULER_NOTIFICATIONS_FILTER','FILTER NOTIFICATIONS IN THE DATABASE', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);

    --*********************************************************
    --
    --  USER_SCHEDULER_NOTIFICATIONS CHECK
    --  The table USER_SCHEDULER_NOTIFICATIONS doesn't exist in 11.1.
    --  The table does exist in 11.2 and 12c.
    --
    --*********************************************************
--VLC fixed on 11/8/16 The check is info only.  Removing the fail message.
	--  VLC 07/25/16  Causing error on 11
--  VLC 07/26/16 - to avoid the  errors  ORA-00904: "FILE_WATCHER_NAME": invalid identifier ORA-06550:
  WHEN p_check = 'USER_SCHEDULER_NOTIFICATIONS' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'USER_SCHEDULER_NOTIFICATIONS';
    l_bookmark := 'USER_SCHEDULER_NOTIFICATIONS_DATA';
    check_status := 'INFO';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    the_count_cursor := 'SELECT COUNT(*) FROM DBA_SCHEDULER_NOTIFICATIONS';
    OPEN l_cursor FOR the_count_cursor;
    FETCH l_cursor
    INTO item_found;
    CLOSE l_cursor;

    IF (item_found > 0) THEN
      msg_str_pass := msg_str_pass || 'There are '||item_found||' notifications configured in the database.  Click below to view the data. '||'[[NL]]';
    ELSE
      msg_str_pass := msg_str_pass || 'Scheduler notification is not configured in the database.'||'[[NL]]';
    END IF;
    store_table_data (msg_num,1,check_status,'message','USER_SCHEDULER_NOTIFICATIONS','USER_SCHEDULER_NOTIFICATIONS', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  USER_SCHEDULER_FILE_WATCHERS CHECK
    --
    --*********************************************************
--VLC fixed on 11/8/16 The check is info only.  Removed the fail message.
--  VLC 07/25/16  Causing error on 11
--  VLC 07/26/16 - to avoid the  errors  ORA-00904: "FILE_WATCHER_NAME": invalid identifier ORA-06550:
  WHEN p_check = 'USER_SCHEDULER_FILE_WATCHERS' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'USER_SCHEDULER_FILE_WATCHERS';
    l_bookmark := 'USER_SCHEDULER_FILE_WATCHERS_DATA';
    check_status := 'INFO';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    the_count_cursor := 'SELECT COUNT(*) FROM USER_SCHEDULER_FILE_WATCHERS';
    OPEN l_cursor FOR the_count_cursor;
    FETCH l_cursor
    INTO filewatcher_jobs_found;
    CLOSE l_cursor;

    IF (filewatcher_jobs_found >0) THEN
      msg_str_pass := msg_str_pass || 'There are '||filewatcher_jobs_found||' filewatcher jobs configured in the database. '||'[[NL]]';
    ELSE
      msg_str_pass := msg_str_pass || 'There are no filewatcher jobs configured in the database. '||'[[NL]]';
    END IF;
    store_table_data (msg_num,1,check_status,'message','USER_SCHEDULER_FILE_WATCHERS','USER_SCHEDULER_FILE_WATCHERS', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  ALL_SCHEDULER_EXTERNAL_DESTS CHECK
    --
    --*********************************************************
  WHEN p_check = 'ALL_SCHEDULER_EXTERNAL_DESTS' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'ALL_SCHEDULER_EXTERNAL_DESTS';
    l_bookmark := 'ALL_SCHEDULER_EXTERNAL_DESTS_DATA';
    check_status := 'INFO';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_pass := msg_str_pass || 'Click below to view the ALL_SCHEDULER_EXTERNAL_DESTS data.'||'[[NL]]';
    store_table_data (msg_num,1,check_status,'message','ALL_SCHEDULER_EXTERNAL_DESTS','ALL_SCHEDULER_EXTERNAL_DESTS', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  ALL_SCHEDULER_EXTERNAL_DESTS CHECK
    --
    --*********************************************************
--VLC fixed on 11/8/16 The check is info only.  Chaged pass message. Removed the fail message.
	WHEN p_check = 'USER_SCHEDULER_DESTS' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'USER_SCHEDULER_DESTS';
    l_bookmark := 'USER_SCHEDULER_DESTS_DATA';
    check_status := 'INFO';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_pass := msg_str_pass || 'Click below to view the user scheduler destinations.'||'[[NL]]';
    store_table_data (msg_num,1,check_status,'message','USER_SCHEDULER_DESTS','USER_SCHEDULER_DESTS', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);

    --*********************************************************
    --
    --  AQ_SRVNTFN_TABLE
    --
    -- No check needed here.  For information only
    --*********************************************************
--  VLC modified on 8/14/16  Removed fail status from logic.  Changed pass message.
--  VLC fixed on 8/11/16  moved the data collection for each AQ table to DBA_TABLES_DATA
--  VLC fixed on 8/11/16  modified pass and fail messages.  The pass message  display the list of tables with links to the data.
  WHEN p_check = 'AQ_SRVNTFN_TABLE' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_TABLES';
    l_bookmark := 'DBA_TABLES_DATA';
    check_status := 'PASS';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    IF (aq_srvntfn_table_found > 0) THEN
      check_status := 'PASS';
      msg_str_pass := msg_str_pass || 'There are no checks defined as of now. The data is available for Oracle support review and collaboration with the AQ team if required.' || '[[NL]]';
      msg_str_pass := msg_str_pass || 'Below is a list of AQ_SRVNTFN_TABLE% tables that exist.  Click on the table name to view the data from the table.' || '[[NL]]';
      msg_str_pass := msg_str_pass || aq_srvntfn_table_list;
    ELSE
      check_status := 'PASS';
      msg_str_pass := msg_str_pass || 'No AQ_SRVNTFN_TABLE% tables exist.' || '[[NL]]';
    END IF;
      store_table_data (msg_num,1,check_status,'message','DBA_TABLES','OTHER AQ RELATED CHECKS - DBA_TABLES', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);

    --*********************************************************
    --
    --  DBA_QUEUES Checks
    --
    --  No check here.  For information only.
    --*********************************************************
--  VLC modified on 8/14/16  Changed pass and fail message.
  WHEN p_check = 'DBA_QUEUES' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_QUEUES';
    l_bookmark := 'DBA_QUEUES_DATA';
    check_status := 'PASS';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_pass := msg_str_pass || 'Click the link below to view the AQ related data. There are no checks defined as of now. The data is available for Oracle support review and collaboration with the AQ team if required.' || '[[NL]]';
    store_table_data (msg_num,1,check_status,'message','DBA_QUEUES','OTHER AQ RELATED CHECKS - DBA_QUEUES', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);

    --*********************************************************
    --
    --  DBA_QUEUE_SUBSCRIBERS Checks
    --
    --  No check here.  For information only.
    --*********************************************************
--  VLC modified on 8/14/16  Per Susan.  Changed pass and fail message.
  WHEN p_check = 'DBA_QUEUE_SUBSCRIBERS' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_QUEUE_SUBSCRIBERS';
    l_bookmark := 'DBA_QUEUE_SUBSCRIBERS_DATA';
    check_status := 'PASS';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_pass := msg_str_pass || 'Click the link below to view the AQ related data. There are no checks defined as of now. The data is available for Oracle support review and collaboration with the AQ team if required.' || '[[NL]]';
    store_table_data (msg_num,1,check_status,'message','DBA_QUEUE_SUBSCRIBERS','OTHER AQ RELATED CHECKS - DBA_QUEUE_SUBSCRIBERS', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);

    --*********************************************************
    --
    --  DBA_SCHEDULER_JOB_LOG EXECUTED Checks
    --
    --*********************************************************
  WHEN p_check = 'DBA_SCHEDULER_JOB_LOG_EXECUTED' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_JOB_LOG';
    l_bookmark := 'DBA_SCHEDULER_JOB_LOG_DATA';
    check_status := 'PASS';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_fail := msg_str_fail || 'No rows found in DBA_SCHEDULER_JOB_LOG which indicates that the jobs executed during the last week.' || '[[NL]]';
    msg_str_pass := msg_str_pass || 'The jobs executed within the last week. No action is required.' || '[[NL]]';
	IF (chkVersion('10',db_version,1) = 'EQ') THEN
    SELECT COUNT(*)
    INTO item_found
    FROM DBA_SCHEDULER_JOB_LOG
    WHERE job_name IN ('AUTO_SPACE_ADVISOR_JOB','GATHER_STATS_JOB') AND LOG_DATE > sysdate-7;
	ELSIF ((chkVersion('11',db_version,1) = 'EQ') OR (chkVersion('12',db_version,1) = 'EQ')) THEN
	SELECT COUNT(*)
    INTO item_found
    FROM DBA_SCHEDULER_JOB_LOG
    WHERE JOB_NAME LIKE 'ORA$AT%' AND LOG_DATE > sysdate-7;
	END IF;
    IF (item_found = 0) THEN
      check_status := 'FAIL';
    END IF;
    store_table_data (msg_num,1,check_status,'message','DBA_SCHEDULER_JOB_LOG_EXECUTED','DBA_SCHEDULER_JOB_LOG EXECUTED','',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  DBA_SCHEDULER_JOB_LOG ADDITIONAL_INFO Check
    --
    --*********************************************************
  WHEN p_check = 'DBA_SCHEDULER_JOB_ADDITIONAL_INFO' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_JOB_LOG';
    l_bookmark := 'DBA_SCHEDULER_JOB_LOG_DATA';
    check_status := 'PASS';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_fail := msg_str_fail || 'Additional logging is turned off for one or more jobs.  Turn on additional logging for scheduler using the following commands: ' || '[[NL]]';
    msg_str_pass := msg_str_pass || 'Additional logging is turned on for the jobs.  No action is required.' || '[[NL]]';
    IF ((chkVersion('10',db_version,1) = 'EQ') and  (p_script_selected = 'JOB_AUTOTASK')) THEN
      SELECT COUNT(*)
      INTO item_found
      FROM DBA_SCHEDULER_JOB_LOG
      WHERE JOB_NAME IN ('AUTO_SPACE_ADVISOR_JOB','GATHER_STATS_JOB') AND ADDITIONAL_INFO IS NULL AND LOG_DATE > sysdate-7;
      IF (item_found > 0) THEN
        check_status := 'FAIL';
        FOR i IN
        (SELECT DISTINCT JOB_NAME
        FROM DBA_SCHEDULER_JOB_LOG
        WHERE JOB_NAME IN ('AUTO_SPACE_ADVISOR_JOB','GATHER_STATS_JOB') AND ADDITIONAL_INFO IS NULL AND LOG_DATE > sysdate-7
        )
        LOOP
          msg_str_fail := msg_str_fail || 'exec DBMS_SCHEDULER.SET_ATTRIBUTE ('''||i.JOB_NAME||''' , ''LOGGING_LEVEL'', DBMS_SCHEDULER.LOGGING_FULL );' || '[[NL]]';
        END LOOP;
      END IF;
    ELSIF (((chkVersion('11',db_version,1) = 'EQ') OR (chkVersion('12',db_version,1) = 'EQ')) and  (p_script_selected = 'JOB_AUTOTASK')) THEN
      SELECT COUNT(*)
      INTO item_found
      FROM DBA_SCHEDULER_JOB_LOG
      WHERE JOB_NAME LIKE 'ORA$AT%' AND ADDITIONAL_INFO IS NULL AND LOG_DATE > sysdate-7;
      IF (item_found > 0) THEN
        msg_str_fail := msg_str_fail || 'Capturing additional information can be enabled by recreating the maintenance jobs using: ' || '[[NL]]';
        msg_str_fail := msg_str_fail || '@?/rdbms/admin/catnomwn.sql  ' || '[[NL]]';
        msg_str_fail := msg_str_fail || '@?/rdbms/admin/catmwin.sql' || '[[NL]]';
      END IF;
    END IF;
    store_table_data (msg_num,1,check_status,'message','DBA_SCHEDULER_JOB_ADDITIONAL_INFO','DBA_SCHEDULER_JOB ADDITIONAL_INFO','',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);

    --*********************************************************
    --
    --  DBA_SCHEDULER_JOB_LOG PURGE Checks
    --
    --*********************************************************
  WHEN p_check = 'DBA_SCHEDULER_JOB_LOG_PURGE' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_JOB_LOG';
    l_bookmark := 'DBA_SCHEDULER_JOB_LOG_DATA';
    check_status := 'PASS';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_pass := msg_str_pass || 'There are no rows in DBA_SCHEDULER_JOB_LOG view which are older than 30 days.' || '[[NL]]';
	IF (chkVersion('10',db_version,1) = 'EQ') THEN
    SELECT COUNT(*)
    INTO item_found
    FROM DBA_SCHEDULER_JOB_LOG
    WHERE JOB_NAME IN ('AUTO_SPACE_ADVISOR_JOB','GATHER_STATS_JOB') AND LOG_DATE < sysdate-30 ;
	ELSIF ((chkVersion('11',db_version,1) = 'EQ') OR (chkVersion('12',db_version,1) = 'EQ')) THEN
	SELECT COUNT(*)
    INTO item_found
    FROM DBA_SCHEDULER_JOB_LOG
    WHERE JOB_NAME LIKE 'ORA$AT%' AND LOG_DATE < sysdate-30;
	END IF;
	IF (item_value < sysdate - 30) THEN
      check_status := 'FAIL';
      msg_str_fail := msg_str_fail || 'There are '||item_found||' rows in DBA_SCHEDULER_JOB_LOG view which are older than 30 days. To purge the log, refer to the steps explained in the document: ' || '[[NL]]';
      msg_str_fail := msg_str_fail || 'How To Purge DBA_SCHEDULER_JOB_LOG and DBA_SCHEDULER_WINDOW_LOG (Doc ID 443364.1)' || '[[NL]]';
    END IF;
    store_table_data (msg_num,1,check_status,'message','DBA_SCHEDULER_JOB_LOG_PURGE','DBA_SCHEDULER_JOB_LOG PURGE','',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);

    --*********************************************************
    --
    --  DBA_SCHEDULER_JOB_LOG STATUS STOPPED Check
    --
    --*********************************************************
--  VLC fixed on 8/9/16  modified the fail message
  WHEN p_check = 'DBA_SCHEDULER_JOB_LOG_STATUS_STOPPED' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_JOB_LOG';
    l_bookmark := 'DBA_SCHEDULER_JOB_LOG_DATA';
    check_status := 'PASS';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_fail := msg_str_fail || 'One or more jobs have been STOPPED.   Check each job to determine if it was interrupted manually or stopped at the end of the window. Increase the duration of the associated window if needed.' || '[[NL]]';
    msg_str_pass := msg_str_pass || 'There are no rows in DBA_SCHEDULER_JOB_LOG where the status is STOPPED.  No action required.' || '[[NL]]';
    IF (chkVersion('10',db_version,1) = 'EQ') THEN
    SELECT COUNT(*)
    INTO item_found
    FROM DBA_SCHEDULER_JOB_LOG
    WHERE job_name IN ('AUTO_SPACE_ADVISOR_JOB','GATHER_STATS_JOB') AND UPPER(STATUS) = 'STOPPED' ;
    IF (item_found > 0) THEN
      check_status := 'FAIL';
      FOR i IN (SELECT JOB_NAME, LOG_DATE FROM DBA_SCHEDULER_JOB_LOG WHERE job_name IN ('AUTO_SPACE_ADVISOR_JOB','GATHER_STATS_JOB') AND UPPER(STATUS) = 'STOPPED')
      LOOP
        msg_str_fail := msg_str_fail || 'Job '||i.JOB_NAME||' on '||i.LOG_DATE||' was STOPPED.' || '[[NL]]';
      END LOOP;
    END IF;
      ELSIF ((chkVersion('11',db_version,1) = 'EQ') OR (chkVersion('12',db_version,1) = 'EQ')) THEN
    SELECT COUNT(*)
    INTO item_found
    FROM DBA_SCHEDULER_JOB_LOG
    WHERE job_name LIKE 'ORA$AT%' AND UPPER(STATUS) = 'STOPPED' ;
    IF (item_found > 0) THEN
      check_status := 'FAIL';
      FOR i IN (SELECT JOB_NAME, LOG_DATE FROM DBA_SCHEDULER_JOB_LOG WHERE job_name LIKE 'ORA$AT%'  AND UPPER(STATUS) = 'STOPPED')
      LOOP
        msg_str_fail := msg_str_fail || 'Job '||i.JOB_NAME||' on '||i.LOG_DATE||' was STOPPED.' || '[[NL]]';
      END LOOP;
    END IF;
      END IF;
    store_table_data (msg_num,1,check_status,'message','DBA_SCHEDULER_JOB_LOG_STATUS_STOPPED','DBA_SCHEDULER_JOB_LOG STATUS STOPPED','',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);

    --*********************************************************
    --
    --  DBA_SCHEDULER_JOB_LOG STATUS CLOSED JOB Check
    --
    --*********************************************************
  WHEN p_check = 'DBA_SCHEDULER_JOB_LOG_STATUS_CLOSED_JOB' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_JOB_LOG';
    l_bookmark := 'DBA_SCHEDULER_JOB_LOG_DATA';
    check_status := 'PASS';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_pass := msg_str_pass || 'There are no rows in DBA_SCHEDULER_JOB_LOG where the status is STOPPED.  No action required.' || '[[NL]]';
      IF (chkVersion('10',db_version,1) = 'EQ') THEN
    SELECT COUNT(*)
    INTO item_found
    FROM DBA_SCHEDULER_JOB_LOG
    WHERE job_name IN ('AUTO_SPACE_ADVISOR_JOB','GATHER_STATS_JOB') AND UPPER(STATUS) NOT IN ('SUCCEEDED','RUNNING') AND ADDITIONAL_INFO LIKE '%REASON="Stop job called because associated window was closed"%';
    IF (item_found > 0) THEN
      check_status := 'FAIL';
      FOR i IN (SELECT JOB_NAME FROM DBA_SCHEDULER_JOB_LOG WHERE job_name IN ('AUTO_SPACE_ADVISOR_JOB','GATHER_STATS_JOB') AND UPPER(STATUS) NOT IN ('SUCCEEDED','RUNNING') AND ADDITIONAL_INFO LIKE '%REASON="Stop job called because associated window was closed"%')
		LOOP
      msg_str_fail := msg_str_fail || 'The job '|| i.JOB_NAME ||' was closed because the associated window was closed. Refer to the document:' || '[[NL]]';
      msg_str_fail := msg_str_fail || 'Auto Maintenance Jobs Were Stopped Because the Associated Window Closed (Doc ID 2096876.1)' || '[[NL]]';
		END LOOP;
    END IF;
      ELSIF ((chkVersion('11',db_version,1) = 'EQ') OR (chkVersion('12',db_version,1) = 'EQ')) THEN
    SELECT COUNT(*)
    INTO item_found
    FROM DBA_SCHEDULER_JOB_LOG
    WHERE job_name LIKE 'ORA$AT%' AND UPPER(STATUS) NOT IN ('SUCCEEDED','RUNNING') AND ADDITIONAL_INFO LIKE '%REASON="Stop job called because associated window was closed"%';
    IF (item_found > 0) THEN
      check_status := 'FAIL';
      FOR i IN (SELECT JOB_NAME FROM DBA_SCHEDULER_JOB_LOG WHERE job_name LIKE 'ORA$AT%' AND UPPER(STATUS) NOT IN ('SUCCEEDED','RUNNING') AND ADDITIONAL_INFO LIKE '%REASON="Stop job called because associated window was closed"%')
		LOOP
      msg_str_fail := msg_str_fail || 'The job '|| i.JOB_NAME ||' was closed because the associated window was closed. Refer to the document:' || '[[NL]]';
      msg_str_fail := msg_str_fail || 'Auto Maintenance Tasks Were Stopped Because the Associated Window Closed (Doc ID 2096930.1)' || '[[NL]]';
		END LOOP;
    END IF;
      END IF;
    store_table_data (msg_num,1,check_status,'message','DBA_SCHEDULER_JOB_LOG_STATUS_CLOSED_JOB','DBA_SCHEDULER_JOB_LOG CLOSED JOB','',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);

    --*********************************************************
    --
    --  DBA_SCHEDULER_JOB_LOG EXECUTION Check
    --
    --*********************************************************
--VLC fixed on 11/8/16  Changed the query to narrow down the results with "log_date > sysdate -7" in place of "ROWNUM < 100"
--VLC fixed on 11/8/16 The check is info only.  Removed the fail message.
	WHEN p_check = 'DBA_SCHEDULER_JOB_LOG_EXECUTION' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_JOB_LOG';
    l_bookmark := 'DBA_SCHEDULER_JOB_LOG_DATA';
    check_status := 'INFO';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_pass := msg_str_pass || 'Jobs that have executed.  No action required.' || '[[NL]]';
      FOR i IN (
	  --SELECT distinct OWNER, JOB_NAME FROM DBA_SCHEDULER_JOB_LOG WHERE JOB_NAME NOT LIKE '%AQ$_PLSQL_NTFN_%' and ROWNUM < 100 GROUP BY OWNER, JOB_NAME
	  SELECT distinct OWNER, JOB_NAME FROM DBA_SCHEDULER_JOB_LOG WHERE JOB_NAME NOT LIKE '%AQ$_PLSQL_NTFN_%' and log_date > sysdate -7 GROUP BY OWNER, JOB_NAME
 )
      LOOP
      msg_str_pass := msg_str_pass || 'Owner '||i.OWNER||'] Job Name: ['||i.JOB_NAME||']' || '[[NL]]';
      END LOOP;
    store_table_data (msg_num,1,check_status,'message','DBA_SCHEDULER_JOB_LOG_EXECUTION','DBA_SCHEDULER_JOB LOG EXECUTION','',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);

    --*********************************************************
    --
    -- DBA_SCHEDULER_JOB_RUN_DETAILS ERROR
    --
    --*********************************************************
  WHEN p_check = 'DBA_SCHEDULER_JOB_RUN_DETAILS_ERROR' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_JOB_RUN_DETAILS';
    l_bookmark := 'DBA_SCHEDULER_JOB_RUN_DETAILS_DATA';
    check_status := 'PASS';
    msg_num := msg_num + 1;
--  VLC fixed on 7/26/15 the msg_str_fail and msg_str_pass was not initialized to null.  So output was showing "Fail message not defined"
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_fail := msg_str_fail || 'An error occurred when executing one or more jobs.' || '[[NL]]';
    msg_str_pass := msg_str_pass || 'The jobs executed without an error. No action is required.' || '[[NL]]';
    IF ((chkVersion('10',db_version,1) = 'EQ') and (p_script_selected = 'JOB_AUTOTASK')) THEN
    FOR i IN
    ( SELECT * FROM DBA_SCHEDULER_JOB_RUN_DETAILS WHERE ((Error#!=0) and (Error# IS NOT NULL)) and job_name IN ('AUTO_SPACE_ADVISOR_JOB','GATHER_STATS_JOB') AND log_date > sysdate -7  order by log_date
    )
    LOOP
      check_status := 'FAIL';
      msg_str_fail := msg_str_fail || 'Job '||i.Job_name||' on '||i.actual_start_date||' failed with ORA- Error '||i.Error#|| '.' || '[[NL]]';
    END LOOP;
    ELSIF ( ((chkVersion('11',db_version,1) = 'EQ') OR (chkVersion('12',db_version,1) = 'EQ')) and (p_script_selected = 'JOB_AUTOTASK'))  THEN
        FOR i IN
    ( SELECT * FROM DBA_SCHEDULER_JOB_RUN_DETAILS WHERE ((Error#!=0) and (Error# IS NOT NULL)) and job_name like 'ORA$AT_%' AND log_date > sysdate -7  order by log_date
    )
    LOOP
      check_status := 'FAIL';
      msg_str_fail := msg_str_fail || 'Job '||i.Job_name||' on '||i.actual_start_date||' failed with ORA- Error '||i.Error#|| '.' || '[[NL]]';
    END LOOP;
    ELSE
        FOR i IN
    ( SELECT * FROM DBA_SCHEDULER_JOB_RUN_DETAILS WHERE ((Error#!=0) and (Error# IS NOT NULL)) AND log_date > sysdate -7  order by log_date
    )
    LOOP
      check_status := 'FAIL';
      msg_str_fail := msg_str_fail || 'Job '||i.Job_name||' on '||i.actual_start_date||' failed with ORA- Error '||i.Error#|| '.' || '[[NL]]';
	END LOOP;
    END IF;
    msg_str_fail := msg_str_fail || 'Contact Oracle Support for investigating this further.'|| '[[NL]]';
    store_table_data (msg_num,1,check_status,'message','DBA_SCHEDULER_JOB_RUN_DETAILS_ERROR','DBA_SCHEDULER_JOB_RUN_DETAILS ERROR', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);

    --*********************************************************
    --
    -- DBA_SCHEDULER_JOB_RUN_DETAILS JOB DELAY
    --
    --*********************************************************
--  VLC fixed on 10/2/16   Added cursor logic to avoid future parsing errors for invalid identifiers or tables that don't exist
--  VLC fixed on 10/2/16   Changed check to look for last 31 days instead of 7 days worth of data
--  VLC fixed on 7/26/15 the msg_str_fail and msg_str_pass was not initialized to null.  So output was showing "Fail message not defined"
  WHEN p_check = 'DBA_SCHEDULER_JOB_RUN_DETAILS_JOB_DELAY' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_JOB_RUN_DETAILS';
    l_bookmark := 'DBA_SCHEDULER_JOB_RUN_DETAILS_DATA';
    check_status := 'PASS';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_fail := msg_str_fail || 'The following job execution are delayed:' || '[[NL]]';
    msg_str_pass := msg_str_pass || 'The job execution is not delayed for any jobs. No action is required.' || '[[NL]]';

    IF ((chkVersion('10',db_version,1) = 'EQ') and (p_script_selected = 'JOB_AUTOTASK')) THEN
    the_count_cursor := 'SELECT COUNT(*) FROM DBA_SCHEDULER_JOB_RUN_DETAILS WHERE REQ_START_DATE != ACTUAL_START_DATE and job_name IN (''AUTO_SPACE_ADVISOR_JOB'',''GATHER_STATS_JOB'') AND log_date > sysdate -31  order by log_date';
    the_data_cursor  := 'SELECT JOB_NAME, REQ_START_DATE, ACTUAL_START_DATE FROM DBA_SCHEDULER_JOB_RUN_DETAILS WHERE REQ_START_DATE != ACTUAL_START_DATE and job_name IN (''AUTO_SPACE_ADVISOR_JOB'',''GATHER_STATS_JOB'') AND log_date > sysdate -31  order by log_date';
    ELSIF ( ((chkVersion('11',db_version,1) = 'EQ') OR (chkVersion('12',db_version,1) = 'EQ')) and (p_script_selected = 'JOB_AUTOTASK'))  THEN
    the_count_cursor := 'SELECT COUNT(*) FROM DBA_SCHEDULER_JOB_RUN_DETAILS WHERE REQ_START_DATE != ACTUAL_START_DATE and job_name like ''ORA$AT_%'' AND log_date > sysdate -31  order by log_date';
    the_data_cursor  := 'SELECT JOB_NAME, REQ_START_DATE, ACTUAL_START_DATE FROM DBA_SCHEDULER_JOB_RUN_DETAILS WHERE REQ_START_DATE != ACTUAL_START_DATE and job_name like ''ORA$AT_%'' AND log_date > sysdate -31  order by log_date';
    ELSE
    the_count_cursor := 'SELECT COUNT(*) FROM DBA_SCHEDULER_JOB_RUN_DETAILS WHERE REQ_START_DATE != ACTUAL_START_DATE AND log_date > sysdate -31  and rownum <100 order by log_date';
    the_data_cursor  := 'SELECT JOB_NAME, REQ_START_DATE, ACTUAL_START_DATE FROM DBA_SCHEDULER_JOB_RUN_DETAILS WHERE REQ_START_DATE != ACTUAL_START_DATE AND log_date > sysdate - 31  and rownum < 100 order by log_date';
    END IF;

    OPEN l_cursor FOR the_count_cursor;
    FETCH l_cursor
    INTO item_found;
    CLOSE l_cursor;
    IF (item_found > 0) THEN
    check_status := 'FAIL';
    OPEN l_cursor FOR the_data_cursor;
    LOOP
      FETCH l_cursor INTO var1,var2,var3;
      EXIT WHEN l_cursor%notfound;
      msg_str_fail := msg_str_fail || 'Job: ['||var1||  ']  Required Start Date:[' ||var2|| ']  Actual Start Date: ['|| var3 || ']' || '[[NL]]';
    END LOOP;
    CLOSE l_cursor;
    END IF;
    store_table_data (msg_num,1,check_status,'message','DBA_SCHEDULER_JOB_RUN_DETAILS_JOB_DELAY','DBA_SCHEDULER_JOB_RUN_DETAILS JOB DELAY', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);

    --*********************************************************
    --
    -- DBA_SCHEDULER_JOB_RUN_DETAILS_STATUS
    --
    --*********************************************************
--  VLC fixed on 7/26/15 the msg_str_fail and msg_str_pass was not initialized to null.  So output was showing "Fail message not defined"
  WHEN p_check = 'DBA_SCHEDULER_JOB_RUN_DETAILS_STATUS' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_JOB_RUN_DETAILS';
    l_bookmark := 'DBA_SCHEDULER_JOB_RUN_DETAILS_DATA';
    check_status := 'FAIL';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_fail := msg_str_fail || 'There were no Autotasks that executed successfully within the last 7 days:' || '[[NL]]';
    msg_str_pass := msg_str_pass || 'The following Autotasks executed successfully within the last 7 days. No action is required.' || '[[NL]]';
   IF (chkVersion('10',db_version,1) = 'EQ') THEN
    FOR i IN
    ( SELECT * FROM DBA_SCHEDULER_JOB_RUN_DETAILS WHERE upper(Status)= 'SUCCEEDED' and job_name IN ('AUTO_SPACE_ADVISOR_JOB','GATHER_STATS_JOB') AND log_date > sysdate -7  order by log_date
    )
    LOOP
      check_status := 'INFO';
      msg_str_pass := msg_str_pass || 'Job: ['||i.Job_name||  ']   Actual Start Date: ['|| i.ACTUAL_START_DATE || ']   Run Duration: [' ||i.run_duration||']' || '[[NL]]';
    END LOOP;
    ELSE
    FOR i IN
    ( SELECT * FROM DBA_SCHEDULER_JOB_RUN_DETAILS WHERE upper(Status)= 'SUCCEEDED' and job_name like 'ORA$AT_%' AND log_date > sysdate -7  order by log_date
    )
    LOOP
      check_status := 'INFO';
      msg_str_pass := msg_str_pass || 'Job: ['||i.Job_name||  ']   Actual Start Date: ['|| i.ACTUAL_START_DATE || ']   Run Duration: [' ||i.run_duration||']' || '[[NL]]';
    END LOOP;
    END IF;
    store_table_data (msg_num,1,check_status,'message','DBA_SCHEDULER_JOB_RUN_DETAILS_STATUS','DBA_SCHEDULER_JOB_RUN_DETAILS STATUS', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);

    --*********************************************************
    --
    --  DBA_SCHEDULER_JOB_RUN_DETAILS_DBA_SCHEDULER_JOBS_CHECK Checks
    --
    --*********************************************************
--  VLC fixed on 10/2/16   Changed message per Susan's suggestion
--  VLC fixed on 10/2/16   Changed status to be always be INFO
    WHEN p_check = 'DBA_SCHEDULER_JOB_RUN_DETAILS_DBA_SCHEDULER_JOBS_CHECK' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_SCHEDULER_JOB_RUN_DETAILS and DBA_SCHEDULER_JOBS';
    l_bookmark := 'DBA_SCHEDULER_JOB_RUN_DETAILS_DBA_SCHEDULER_JOBS_DATA';
    check_status := 'INFO';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_pass := msg_str_pass || 'Below is the scheduler job run details. Review the data.' || '[[NL]]';
    store_table_data (msg_num,1,check_status,'message','DBA_SCHEDULER_JOB_RUN_DETAILS_DBA_SCHEDULER_JOBS_CHECK','DBA_SCHEDULER_JOB_RUN_DETAILS and DBA_SCHEDULER_JOBS CHECK', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);

    --*********************************************************
    --
    --  11g,12c - DBA_AUTOTASK_TASK ENABLED Checks
    --
    --*********************************************************
--  VLC fixed on 9/19/16  Added cursor to eliminate error DBA_AUTOTASK_TASK does not exist in 10.x
  WHEN p_check = 'DBA_AUTOTASK_TASK_DATA_ENABLED' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_AUTOTASK_TASK';
    l_bookmark := 'DBA_AUTOTASK_TASK_DATA';
    check_status := 'PASS';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_fail := msg_str_fail || 'One or more autotask clients are disabled.  Enable the autotask client if it is not disabled intentionally. Use the bms_auto_task_admin.enable command to enable the tasks.' || '[[NL]]';
    msg_str_pass := msg_str_pass || 'The autotask clients are enabled. No action is required.' || '[[NL]]';
    the_data_cursor  := 'SELECT CLIENT_NAME FROM DBA_AUTOTASK_TASK WHERE STATUS != ''ENABLED''';
    OPEN l_cursor FOR the_data_cursor;
    LOOP
      FETCH l_cursor INTO var1;
      EXIT WHEN l_cursor%notfound;
      check_status := 'FAIL';
      msg_str_fail := msg_str_fail || 'exec dbms_auto_task_admin.enable('''||var1||''', null, null);' || '[[NL]]';
    END LOOP;
    CLOSE l_cursor;
    store_table_data (msg_num,1,check_status,'message','DBA_AUTOTASK_TASK_DATA_ENABLED','DBA_AUTOTASK_TASK_DATA ENABLED', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  11g,12c - DBA_AUTOTASK_TASK CURRENT_JOB_NAME Checks
    --
    --*********************************************************
--  VLC fixed on 9/19/16  Added cursor to eliminate error DBA_AUTOTASK_TASK does not exist in 10.x
  WHEN p_check = 'DBA_AUTOTASK_TASK_CURRENT_JOB_NAME' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_AUTOTASK_TASK';
    l_bookmark := 'DBA_AUTOTASK_TASK_DATA';
    check_status := 'PASS';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_fail := msg_str_fail || 'One or more autotask jobs are currently running. Details:  ' || '[[NL]]';
    msg_str_pass := msg_str_pass || 'No autotask jobs are not currently running. No action is required.' || '[[NL]]';
    the_data_cursor  := 'SELECT CURRENT_JOB_NAME, JOB_SCHEDULER_STATUS FROM DBA_AUTOTASK_TASK WHERE CURRENT_JOB_NAME IS NOT NULL';
    OPEN l_cursor FOR the_data_cursor;
    LOOP
      FETCH l_cursor INTO var1,var2;
      EXIT WHEN l_cursor%notfound;
      check_status := 'FAIL';
      msg_str_fail := msg_str_fail || 'job name : '||var1|| ' , status : '|| var2 || '[[NL]]';
    END LOOP;
    CLOSE l_cursor;
    store_table_data (msg_num,1,check_status,'message','DBA_AUTOTASK_TASK_CURRENT_JOB_NAME','DBA_AUTOTASK_TASK JOB RUNNING', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  11g,12c - DBA_AUTOTASK_TASK JOB_SCHEDULER_STATUS DISABLED Checks
    --
    --*********************************************************
--  VLC fixed on 10/2/16   Changed fail message per Susan's suggestion
--  VLC fixed on 9/19/16   Added cursor to eliminate error DBA_AUTOTASK_TASK does not exist in 10.x
  WHEN p_check = 'DBA_AUTOTASK_TASK_JOB_SCHEDULER_STATUS_DISABLED' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_AUTOTASK_TASK';
    l_bookmark := 'DBA_AUTOTASK_TASK_DATA';
    check_status := 'PASS';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_fail := msg_str_fail || 'One or more jobs are disabled. The jobs can be enabled by executing DBMS_AUTO_TASK_ADMIN.ENABLE()' || '[[NL]]';
    msg_str_pass := msg_str_pass || 'The jobs are enabled. No action is required.' || '[[NL]]';
    the_count_cursor := 'SELECT COUNT(*) FROM DBA_AUTOTASK_TASK WHERE JOB_SCHEDULER_STATUS = ''DISABLED''';
    the_data_cursor  := 'SELECT CLIENT_NAME FROM DBA_AUTOTASK_TASK WHERE JOB_SCHEDULER_STATUS = ''DISABLED''';
    OPEN l_cursor FOR the_count_cursor;
    FETCH l_cursor
    INTO item_found;
    CLOSE l_cursor;
    IF (item_found > 0) THEN
    check_status := 'FAIL';
    OPEN l_cursor FOR the_data_cursor;
    LOOP
      FETCH l_cursor INTO var1;
      EXIT WHEN l_cursor%notfound;
      msg_str_fail := msg_str_fail || 'exec DBMS_AUTO_TASK_ADMIN.enable (client_name => '''||var1||''',operation => null,window_name => NULL); ' || '[[NL]]';
    END LOOP;
    CLOSE l_cursor;
    END IF;
    store_table_data (msg_num,1,check_status,'message','DBA_AUTOTASK_TASK_JOB_SCHEDULER_STATUS_DISABLED','DBA_AUTOTASK_TASK JOB_SCHEDULER_STATUS DISABLED', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  11g,12c - DDBA_AUTOTASK_TASK JOB_SCHEDULER_STATUS SCHEDULED Checks
    --
    --*********************************************************
--  VLC fixed on 9/19/16  Added cursor to eliminate error DBA_AUTOTASK_TASK does not exist in 10.x
  WHEN p_check = 'DBA_AUTOTASK_TASK_JOB_SCHEDULER_STATUS_SCHEDULED' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_AUTOTASK_TASK';
    l_bookmark := 'DBA_AUTOTASK_TASK_DATA';
    check_status := 'PASS';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_fail := msg_str_fail || 'The following Autotask jobs are scheduled to be executed: ' || '[[NL]]';
    msg_str_pass := msg_str_pass || 'No Autotask jobs are scheduled to be executed. No action is required.' || '[[NL]]';
    the_data_cursor  := 'SELECT CLIENT_NAME FROM DBA_AUTOTASK_TASK WHERE JOB_SCHEDULER_STATUS = ''SCHEDULED''';
    OPEN l_cursor FOR the_data_cursor;
    LOOP
      FETCH l_cursor INTO var1;
      EXIT WHEN l_cursor%notfound;
      check_status := 'FAIL';
      msg_str_fail := msg_str_fail || 'The Autotask job '||var1|| ' is scheduled to be executed.' || '[[NL]]';
    END LOOP;
    CLOSE l_cursor;
    store_table_data (msg_num,1,check_status,'message','DBA_AUTOTASK_TASK_JOB_SCHEDULER_STATUS_SCHEDULED','DBA_AUTOTASK_TASK JOB_SCHEDULER_STATUS SCHEDULED', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  11g,12c - DBA_AUTOTASK_TASK JOB_SCHEDULER_STATUS RUNNING
    --
    --*********************************************************
--  VLC fixed on 9/19/16  Added cursor logic to avoid parsing error.  Table DBA_AUTOTASK_TASK does not exist in 10.x
  WHEN p_check = 'DBA_AUTOTASK_TASK_JOB_SCHEDULER_STATUS_RUNNING' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_AUTOTASK_TASK';
    l_bookmark := 'DBA_AUTOTASK_TASK_DATA';
    check_status := 'PASS';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_fail := msg_str_fail || 'One or more jobs are running. If this is not your maintenance window, consider stopping the following jobs:' || '[[NL]]';
    msg_str_pass := msg_str_pass || 'There are no jobs running. No action is required.' || '[[NL]]';
    the_data_cursor  := 'SELECT CLIENT_NAME FROM DBA_AUTOTASK_TASK WHERE JOB_SCHEDULER_STATUS = ''RUNNING''';
    OPEN l_cursor FOR the_data_cursor;
    LOOP
      FETCH l_cursor INTO var1;
      EXIT WHEN l_cursor%notfound;
      check_status := 'FAIL';
      msg_str_fail := msg_str_fail || 'The Autotask job '||var1|| ' is currently running.' || '[[NL]]' ;
    END LOOP;
    CLOSE l_cursor;
    store_table_data (msg_num,1,check_status,'message','DBA_AUTOTASK_TASK_JOB_SCHEDULER_STATUS_RUNNING','DBA_AUTOTASK_TASK JOB_SCHEDULER_STATUS RUNNING', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  11g,12c -DBA_AUTOTASK_TASK JOB_SCHEDULER_STATUS COMPLETED Check
    --
    --*********************************************************
--  VLC fixed on 9/19/16  Added cursor logic to avoid parsing error.  Table DBA_AUTOTASK_TASK does not exist in 10.x
  WHEN p_check = 'DBA_AUTOTASK_TASK_JOB_SCHEDULER_STATUS_COMPLETED' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_AUTOTASK_TASK';
    l_bookmark := 'DBA_AUTOTASK_TASK_DATA';
    check_status := 'PASS';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_fail := msg_str_fail || 'The following Autotask job(s) have completed and are not scheduled to run again. Check the Next date and try to reschedule the job(s). Verify if the job reached maximum run.' || '[[NL]]';
    msg_str_pass := msg_str_pass || 'The Autotask job(s) that have completed and are scheduled to run again. No action is required.' || '[[NL]]';
    the_data_cursor  := 'SELECT CLIENT_NAME FROM DBA_AUTOTASK_TASK WHERE JOB_SCHEDULER_STATUS = ''COMPLETED''';
    OPEN l_cursor FOR the_data_cursor;
    LOOP
      FETCH l_cursor INTO var1;
      EXIT WHEN l_cursor%notfound;
      check_status := 'FAIL';
      msg_str_fail := msg_str_fail || 'The Autotask job '||var1|| ' has completed.' || '[[NL]]' ;
    END LOOP;
    CLOSE l_cursor;
    store_table_data (msg_num,1,check_status,'message','DBA_AUTOTASK_TASK_JOB_SCHEDULER_STATUS_COMPLETED','DBA_AUTOTASK_TASK JOB_SCHEDULER_STATUS COMPLETED', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  11g,12c - DBA_AUTOTASK_CLIENT CLIENT MISSING Check
    --
    --*********************************************************
--  VLC fixed on 9/19/16  Added cursor logic to avoid parsing error.  Table DBA_AUTOTASK_CLIENT does not exist in 10.x
  WHEN p_check = 'DBA_AUTOTASK_CLIENT_EXIST' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_AUTOTASK_CLIENT';
    l_bookmark := 'DBA_AUTOTASK_CLIENT_DATA';
    check_status := 'PASS';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_fail := msg_str_fail || 'The automated maintenance tasks are not created properly. Recreate them using the script ?/rdbms/admin/catproc.sql' || '[[NL]]';
    msg_str_pass := msg_str_pass || 'The automated maintenance tasks are created properly. No action is required.' || '[[NL]]';
    the_count_cursor := 'SELECT COUNT(*) FROM DBA_AUTOTASK_CLIENT WHERE upper(CLIENT_NAME) = ''AUTO OPTIMIZER STATS COLLECTION''';
    OPEN l_cursor FOR the_count_cursor;
    FETCH l_cursor
    INTO a_cl_optimizer_found;
    CLOSE l_cursor;
    the_count_cursor := 'SELECT COUNT(*) FROM DBA_AUTOTASK_CLIENT WHERE upper(CLIENT_NAME) = ''AUTO SPACE ADVISOR''';
    OPEN l_cursor FOR the_count_cursor;
    FETCH l_cursor
    INTO a_cl_space_found;
    CLOSE l_cursor;
    the_count_cursor := 'SELECT COUNT(*) FROM DBA_AUTOTASK_CLIENT WHERE upper(CLIENT_NAME) = ''SQL TUNING ADVISOR''';
    OPEN l_cursor FOR the_count_cursor;
    FETCH l_cursor
    INTO a_cl_sql_tuning_found;
    CLOSE l_cursor;

    IF (a_cl_optimizer_found = 0) THEN
      check_status := 'FAIL';
      msg_str_fail := msg_str_fail ||'The ''auto optimizer stats collection'' maintenace task is missing.' || '[[NL]]';
    END IF;
    IF (a_cl_space_found = 0) THEN
      check_status := 'FAIL';
      msg_str_fail := msg_str_fail ||'The ''auto space advisor'' maintenace task is missing.' || '[[NL]]';
    END IF;
    IF (a_cl_sql_tuning_found = 0) THEN
      check_status := 'FAIL';
      msg_str_fail := msg_str_fail ||'The ''sql tuning advisor'' maintenace task is missing.' || '[[NL]]';
    END IF;
    store_table_data (msg_num,1,check_status,'message','DBA_AUTOTASK_CLIENT_EXIST','DBA_AUTOTASK_CLIENT CLIENT MISSING', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  11g,12c - DBA_AUTOTASK_CLIENT_DATA STATUS Check
    --
    --*********************************************************
--  VLC fixed on 9/19/16  Added cursor logic to avoid parsing error.  Table DBA_AUTOTASK_CLIENT does not exist in 10.x
  WHEN p_check = 'DBA_AUTOTASK_CLIENT_DATA_STATUS' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_AUTOTASK_CLIENT';
    l_bookmark := 'DBA_AUTOTASK_CLIENT_DATA';
    check_status := 'PASS';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_fail := msg_str_fail || 'One or more autotask clients are not enabled.' || '[[NL]]';
    msg_str_fail := msg_str_fail || 'Suggestion: enable the autotask client, if its not disabled intentionally. DBMS_AUTO_TASK_ADMIN.ENABLE() will enable the tasks.' || '[[NL]]';
    msg_str_pass := msg_str_pass || 'The autotask clients are enabled. No action is required.' || '[[NL]]';
    the_data_cursor  := 'SELECT CLIENT_NAME FROM DBA_AUTOTASK_CLIENT';
    OPEN l_cursor FOR the_data_cursor;
    LOOP
      FETCH l_cursor INTO var1;
      EXIT WHEN l_cursor%notfound;
      check_status := 'FAIL';
      msg_str_fail := msg_str_fail || 'exec DBMS_AUTO_TASK_ADMIN.ENABLE('''||var1||''', null, null);' || '[[NL]]';
    END LOOP;
    CLOSE l_cursor;
    store_table_data (msg_num,1,check_status,'message','DBA_AUTOTASK_CLIENT_DATA_STATUS','DBA_AUTOTASK_CLIENT_DATA STATUS ENABLED', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  11g,12c - DBA_AUTOTASK_CLIENT_JOB EXIST Checks
    --
    --*********************************************************
--  VLC fixed on 9/19/16  Added cursor logic to parsing avoid error.  Table DBA_AUTOTASK_CLIENT_JOB does not exist in 10.x
  WHEN p_check = 'DBA_AUTOTASK_CLIENT_JOB_EXIST' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_AUTOTASK_CLIENT_JOB';
    l_bookmark := 'DBA_AUTOTASK_CLIENT_JOB_DATA';
    check_status := 'PASS';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_fail := msg_str_fail || 'There are maintenance jobs currently running for:' || '[[NL]]';
    msg_str_pass := msg_str_pass || 'There are no maintenance jobs currently running. No action is required.' || '[[NL]]';
    the_data_cursor  := 'SELECT CLIENT_NAME,JOB_NAME,JOB_SCHEDULER_STATUS,TASK_PRIORITY FROM DBA_AUTOTASK_CLIENT_JOB';
    OPEN l_cursor FOR the_data_cursor;
    LOOP
      FETCH l_cursor INTO var1,var2,var3,var4;
      EXIT WHEN l_cursor%notfound;
      IF (upper(var1) = 'AUTO OPTIMIZER STATS COLLECTION') THEN
        check_status := 'FAIL';
        msg_str_fail := msg_str_fail || var1||', '|| var2||', '||var3||', '||var4 || '[[NL]]';
      ELSIF (upper(var1) = 'AUTO SPACE ADVISOR') THEN
        check_status := 'FAIL';
        msg_str_fail := msg_str_fail || var1||', '|| var2||', '||var3||', '||var4 || '[[NL]]';
      ELSIF (upper(var1) = 'SQL TUNING ADVISOR') THEN
        check_status := 'FAIL';
        msg_str_fail := msg_str_fail || var1||', '|| var2||', '||var3||', '||var4 || '[[NL]]';
      END IF;
    END LOOP;
    CLOSE l_cursor;
    store_table_data (msg_num,1,'PASS','message','DBA_AUTOTASK_CLIENT_JOB_EXIST','DBA_AUTOTASK_CLIENT_JOB RUNNING', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  11g,12c - DBA_AUTOTASK_JOB_HISTORY JOB ERROR Checks
    --
    --*********************************************************
--  VLC fixed on 9/19/16  Added cursor logic to parsing avoid error.  Table DBA_AUTOTASK_JOB_HISTORY does not exist in 10.x
  WHEN p_check = 'DBA_AUTOTASK_JOB_HISTORY_JOB_ERROR' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_AUTOTASK_JOB_HISTORY';
    l_bookmark := 'DBA_AUTOTASK_JOB_HISTORY_DATA';
    check_status := 'PASS';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_fail := msg_str_fail || 'One or more jobs have failed.  Click the link below to view the failed jobs.' || '[[NL]]';
    msg_str_pass := msg_str_pass || 'There are no errors reported. Click the link below to view the last 10 successful cases: '|| '[[NL]]';
    the_count_cursor := 'SELECT COUNT(*) FROM dba_autotask_job_history WHERE JOB_ERROR != 0';
    OPEN l_cursor FOR the_count_cursor;
    FETCH l_cursor
    INTO item_found;
    CLOSE l_cursor;
    IF (item_found >0) THEN
    check_status := 'FAIL';
    END IF;
    store_table_data (msg_num,1,check_status,'message','DBA_AUTOTASK_JOB_HISTORY_JOB_ERROR','DBA_AUTOTASK_JOB_HISTORY FAILED JOBS', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  11g,12c - DBA_AUTOTASK_WINDOW_CLIENTS WINDOW_ACTIVE Checks
    --
    --*********************************************************
--  VLC fixed on 9/19/16  Added cursor logic to avoid parsing error.  Table DBA_AUTOTASK_WINDOW_CLIENTS does not exist in 10.x
  WHEN p_check = 'DBA_AUTOTASK_WINDOW_CLIENTS_WINDOW_ACTIVE' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_AUTOTASK_WINDOW_CLIENTS';
    l_bookmark := 'DBA_AUTOTASK_WINDOW_CLIENTS_DATA';
    check_status := 'PASS';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_fail := msg_str_fail || 'One or more client windows are currently active. If this is not expected,  please close the window manually using the following command:' || '[[NL]]';
    msg_str_pass := msg_str_pass || 'No maintenance windows are currently open.  No action is required.' || '[[NL]]';
    the_count_cursor := 'SELECT COUNT(*) FROM DBA_AUTOTASK_WINDOW_CLIENTS WHERE upper(WINDOW_ACTIVE) = ''TRUE''';
    the_data_cursor  := 'SELECT WINDOW_NAME FROM DBA_AUTOTASK_WINDOW_CLIENTS WHERE upper(WINDOW_ACTIVE) = ''TRUE''';
    OPEN l_cursor FOR the_count_cursor;
    FETCH l_cursor
    INTO item_found;
    CLOSE l_cursor;
    IF (item_found > 0) THEN
    check_status := 'FAIL';
    OPEN l_cursor FOR the_data_cursor;
    LOOP
      FETCH l_cursor INTO var1;
      EXIT WHEN l_cursor%notfound;
      msg_str_fail := msg_str_fail || 'EXECUTE DBMS_SCHEDULER.CLOSE_WINDOW ('''||var1||''');' || '[[NL]]';
    END LOOP;
    CLOSE l_cursor;
    END IF;
    store_table_data (msg_num,1,check_status,'message','DBA_AUTOTASK_WINDOW_CLIENTS_WINDOW_ACTIVE','ACTIVE CLIENT WINDOWS', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  11g,12c - DBA_AUTOTASK_WINDOW_CLIENTS WINDOW_NEXT_TIME Checks
    --
    --*********************************************************
--  VLC fixed on 9/19/16  Added cursor logic to avoid parsing error.  Table DBA_AUTOTASK_WINDOW_CLIENTS does not exist in 10.x
  WHEN p_check = 'DBA_AUTOTASK_WINDOW_CLIENTS_WINDOW_NEXT_TIME' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_AUTOTASK_WINDOW_CLIENTS';
    l_bookmark := 'DBA_AUTOTASK_WINDOW_CLIENTS_DATA';
    check_status := 'PASS';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_fail := msg_str_fail || 'One or more windows have a WINDOW_NEXT_TIME older than the current date.  Run the following scripts to correct the issue:' || '[[NL]]';
    msg_str_fail := msg_str_fail || '@?/rdbms/admin/catnomwn.sql' || '[[NL]]';
    msg_str_fail := msg_str_fail || '@?/rdbms/admin/catmwin.sql' || '[[NL]]';
    msg_str_fail := msg_str_fail || '[[NL]]';
    msg_str_fail := msg_str_fail || 'The following windows have an old WINDOW_NEXT_TIME:' || '[[NL]]';
    msg_str_pass := msg_str_pass || 'The  WINDOW_NEXT_TIME is current for all windows clients. No action is required.' || '[[NL]]';
    the_count_cursor := 'SELECT COUNT(*) FROM DBA_AUTOTASK_WINDOW_CLIENTS WHERE (to_timestamp_tz(WINDOW_NEXT_TIME,''DD-MON-YY HH:MI:SS:FF6 PM  TZR'') at TIME zone ''GMT'') < '''||cur_systimestamp||'''';
    the_data_cursor  := 'SELECT WINDOW_NAME FROM DBA_AUTOTASK_WINDOW_CLIENTS WHERE (to_timestamp_tz(WINDOW_NEXT_TIME,''DD-MON-YY HH:MI:SS:FF6 PM  TZR'') at TIME zone ''GMT'') < '''||cur_systimestamp||'''';
    OPEN l_cursor FOR the_count_cursor;
    FETCH l_cursor
    INTO item_found;
    CLOSE l_cursor;
    IF (item_found > 0) THEN
    check_status := 'FAIL';
    OPEN l_cursor FOR the_data_cursor;
    LOOP
      FETCH l_cursor INTO var1;
      EXIT WHEN l_cursor%notfound;
      msg_str_fail := msg_str_fail || var1 || '[[NL]]';
    END LOOP;
    CLOSE l_cursor;
    END IF;
    store_table_data (msg_num,1,check_status,'message','DBA_AUTOTASK_WINDOW_CLIENTS_WINDOW_NEXT_TIME','NEXT SCHEDULED WINDOW TIME IS OLDER THAN THE CURRENT DATE','',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);

    --*********************************************************
    --
    --  11g,12c - DBA_AUTOTASK_WINDOW_CLIENTS AUTOTASK_STATUS Checks
    --
    --*********************************************************
--  VLC fixed on 9/19/16  Added cursor logic to avoid parsing error.  Table DBA_AUTOTASK_WINDOW_CLIENTS does not exist in 10.x
  WHEN p_check = 'DBA_AUTOTASK_WINDOW_CLIENTS_AUTOTASK_STATUS' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_AUTOTASK_WINDOW_CLIENTS';
    l_bookmark := 'DBA_AUTOTASK_WINDOW_CLIENTS_DATA';
    check_status := 'PASS';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_fail := msg_str_fail || 'Automated maintenance task subsystem is disabled for the following:' || '[[NL]]';
    msg_str_pass := msg_str_pass || 'Automated maintenance task subsystem is enabled for all windows clients. No action is required.' || '[[NL]]';
    the_count_cursor := 'SELECT COUNT(*) FROM DBA_AUTOTASK_WINDOW_CLIENTS WHERE upper(AUTOTASK_STATUS) = ''DISABLED''';
    the_data_cursor  := 'SELECT WINDOW_NAME FROM DBA_AUTOTASK_WINDOW_CLIENTS WHERE upper(AUTOTASK_STATUS) = ''DISABLED''';
    OPEN l_cursor FOR the_count_cursor;
    FETCH l_cursor
    INTO item_found;
    CLOSE l_cursor;
    IF (item_found > 0) THEN
    check_status := 'FAIL';
    OPEN l_cursor FOR the_data_cursor;
    LOOP
      FETCH l_cursor INTO var1;
      EXIT WHEN l_cursor%notfound;
      msg_str_fail := msg_str_fail || var1 || '[[NL]]';
    END LOOP;
    CLOSE l_cursor;
    END IF;
    store_table_data (msg_num,1,check_status,'message','DBA_AUTOTASK_WINDOW_CLIENTS_AUTOTASK_STATUS','DBA_AUTOTASK_WINDOW_CLIENTS AUTOTASK STATUS', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  11g,12c - DBA_AUTOTASK_WINDOW_CLIENTS OPTIMIZER_STATS Checks
    --
    --*********************************************************
--  VLC fixed on 9/19/16  Added cursor logic to avoid parsing error.  Table DBA_AUTOTASK_WINDOW_CLIENTS does not exist in 10.x
  WHEN p_check = 'DBA_AUTOTASK_WINDOW_CLIENTS_OPTIMIZER_STATS' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_AUTOTASK_WINDOW_CLIENTS';
    l_bookmark := 'DBA_AUTOTASK_WINDOW_CLIENTS_DATA';
    check_status := 'PASS';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_fail := msg_str_fail || 'Optimizer statistics gathering is disabled for the following:' || '[[NL]]';
    msg_str_pass := msg_str_pass || 'Optimizer statistics gathering is enabled for all windows clients. No action is required.' || '[[NL]]';
    the_count_cursor := 'SELECT COUNT(*) FROM DBA_AUTOTASK_WINDOW_CLIENTS WHERE upper(OPTIMIZER_STATS) = ''DISABLED''';
    the_data_cursor  := 'SELECT WINDOW_NAME FROM DBA_AUTOTASK_WINDOW_CLIENTS WHERE upper(OPTIMIZER_STATS) = ''DISABLED''';
    OPEN l_cursor FOR the_count_cursor;
    FETCH l_cursor
    INTO item_found;
    CLOSE l_cursor;
    IF (item_found > 0) THEN
      check_status := 'FAIL';
      OPEN l_cursor FOR the_data_cursor;
      LOOP
        FETCH l_cursor INTO var1;
        EXIT WHEN l_cursor%notfound;
        msg_str_fail := msg_str_fail || var1 || '[[NL]]';
      END LOOP;
      CLOSE l_cursor;
    END IF;
    store_table_data (msg_num,1,check_status,'message','DBA_AUTOTASK_WINDOW_CLIENTS_OPTIMIZER_STATS','WINDOW CLIENT OPTIMIZER STATS', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  11g,12c - DBA_AUTOTASK_WINDOW_CLIENTS SEGMENT_ADVISOR Checks
    --
    --*********************************************************
--  VLC fixed on 9/19/16  Added cursor logic to avoid parsing error.  Table DBA_AUTOTASK_WINDOW_CLIENTS does not exist in 10.x
  WHEN p_check = 'DBA_AUTOTASK_WINDOW_CLIENTS_SEGMENT_ADVISOR' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_AUTOTASK_WINDOW_CLIENTS';
    l_bookmark := 'DBA_AUTOTASK_WINDOW_CLIENTS_DATA';
    check_status := 'PASS';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_fail := msg_str_fail || 'Segment Advisor is disabled for the following:' || '[[NL]]';
    msg_str_pass := msg_str_pass || 'Segment Advisor is enabled for all windows clients. No action is required.' || '[[NL]]';
    the_count_cursor := 'SELECT COUNT(*) FROM DBA_AUTOTASK_WINDOW_CLIENTS WHERE upper(SEGMENT_ADVISOR) = ''DISABLED''';
    the_data_cursor  := 'SELECT WINDOW_NAME FROM DBA_AUTOTASK_WINDOW_CLIENTS WHERE upper(SEGMENT_ADVISOR) = ''DISABLED''';
    OPEN l_cursor FOR the_count_cursor;
    FETCH l_cursor
    INTO item_found;
    CLOSE l_cursor;
    IF (item_found > 0) THEN
      check_status := 'FAIL';
      OPEN l_cursor FOR the_data_cursor;
      LOOP
        FETCH l_cursor INTO var1;
        EXIT WHEN l_cursor%notfound;
        msg_str_fail := msg_str_fail || var1 || '[[NL]]';
      END LOOP;
      CLOSE l_cursor;
    END IF;
    store_table_data (msg_num,1,check_status,'message','DBA_AUTOTASK_WINDOW_CLIENTS_SEGMENT_ADVISOR','WINDOW CLIENT SEGMENT ADVISOR', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  11g,12c - DBA_AUTOTASK_WINDOW_CLIENTS SQL_TUNE_ADVISOR Checks
    --
    --*********************************************************
--  VLC fixed on 9/19/16  Added cursor logic to avoid parsing error.  Table DBA_AUTOTASK_WINDOW_CLIENTS does not exist in 10.x
  WHEN p_check = 'DBA_AUTOTASK_WINDOW_CLIENTS_SQL_TUNE_ADVISOR' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_AUTOTASK_WINDOW_CLIENTS';
    l_bookmark := 'DBA_AUTOTASK_WINDOW_CLIENTS_DATA';
    check_status := 'PASS';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_fail := msg_str_fail || 'SQL Tuning Advisor is disabled for the following:' || '[[NL]]';
    msg_str_pass := msg_str_pass || 'SQL Tuning Advisor is enabled for all windows clients. No action is required.' || '[[NL]]';
    the_count_cursor := 'SELECT COUNT(*) FROM DBA_AUTOTASK_WINDOW_CLIENTS WHERE upper(SQL_TUNE_ADVISOR) = ''DISABLED''';
    the_data_cursor  := 'SELECT WINDOW_NAME FROM DBA_AUTOTASK_WINDOW_CLIENTS WHERE upper(SQL_TUNE_ADVISOR) = ''DISABLED''';
    OPEN l_cursor FOR the_count_cursor;
    FETCH l_cursor
    INTO item_found;
    CLOSE l_cursor;
    IF (item_found > 0) THEN
      check_status := 'FAIL';
      OPEN l_cursor FOR the_data_cursor;
      LOOP
        FETCH l_cursor INTO var1;
        EXIT WHEN l_cursor%notfound;
        msg_str_fail := msg_str_fail || var1 || '[[NL]]';
      END LOOP;
      CLOSE l_cursor;
    END IF;
    store_table_data (msg_num,1,check_status,'message','DBA_AUTOTASK_WINDOW_CLIENTS_SQL_TUNE_ADVISOR','DBA_AUTOTASK_WINDOW_CLIENTS SQL TUNE ADVISOR', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  11g,12c - DBA_AUTOTASK_WINDOW_CLIENTS HEALTH_MONITOR Checks
    --
    --*********************************************************
--  VLC fixed on 9/19/16  Added cursor logic to avoid parsing error.  Table DBA_AUTOTASK_WINDOW_CLIENTS does not exist in 10.x
  WHEN p_check = 'DBA_AUTOTASK_WINDOW_CLIENTS_HEALTH_MONITOR' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_AUTOTASK_WINDOW_CLIENTS';
    l_bookmark := 'DBA_AUTOTASK_WINDOW_CLIENTS_DATA';
    check_status := 'PASS';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_fail := msg_str_fail || 'Health Monitor is disabled for the following:' || '[[NL]]';
    msg_str_pass := msg_str_pass || 'Health Monitor is enabled for all windows clients. No action is required.' || '[[NL]]';
    the_count_cursor := 'SELECT COUNT(*) FROM DBA_AUTOTASK_WINDOW_CLIENTS WHERE upper(HEALTH_MONITOR) = ''DISABLED''';
    the_data_cursor  := 'SELECT WINDOW_NAME FROM DBA_AUTOTASK_WINDOW_CLIENTS WHERE upper(HEALTH_MONITOR) = ''DISABLED''';
    OPEN l_cursor FOR the_count_cursor;
    FETCH l_cursor
    INTO item_found;
    CLOSE l_cursor;
    IF (item_found > 0) THEN
      check_status := 'FAIL';
      OPEN l_cursor FOR the_data_cursor;
      LOOP
        FETCH l_cursor INTO var1;
        EXIT WHEN l_cursor%notfound;
        msg_str_fail := msg_str_fail || var1 || '[[NL]]';
      END LOOP;
      CLOSE l_cursor;
    END IF;
    store_table_data (msg_num,1,check_status,'message','DBA_AUTOTASK_WINDOW_CLIENTS_HEALTH_MONITOR','DBA_AUTOTASK_WINDOW_CLIENTS HEALTH MONITOR', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);
   --*********************************************************
    --
    --  11g,12c - DBA_AUTOTASK_OPERATION Checks
    --
    --  No check here.  For information only.
    --*********************************************************
    WHEN p_check = 'DBA_AUTOTASK_OPERATION' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_AUTOTASK_OPERATION';
    l_bookmark := 'DBA_AUTOTASK_OPERATION_DATA';
    check_status := 'PASS';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_fail := msg_str_fail || 'Fail message not defined.' || '[[NL]]';
    msg_str_pass := msg_str_pass || 'Click the link below to review the operations data.' || '[[NL]]';
    store_table_data (msg_num,1,check_status,'message','DBA_AUTOTASK_OPERATION','DBA AUTOTASK OPERATION', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  11g,12c - DBA_AUTOTASK_SCHEDULE Checks
    --
    --*********************************************************
--  VLC fixed on 9/19/16  Added cursor logic to avoid parsing error.  Table DBA_AUTOTASK_SCHEDULE does not exist in 10.x
--  VLC fixed on 08/07/16  moved the store_table_data call to the bottom
  WHEN p_check = 'DBA_AUTOTASK_SCHEDULE' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_AUTOTASK_SCHEDULE';
    l_bookmark := 'DBA_AUTOTASK_SCHEDULE_DATA';
    check_status := 'PASS';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_fail := msg_str_fail || 'One of more weekday windows have a duration of less than 4 hours. Consider increasing the duration using the following commands: ' || '[[NL]]';
    msg_str_pass := msg_str_pass || 'All Weekday Windows have a duration greater than 4 hours and all Weekend Windows have a duration greater than 20 hours..  Review the window duration and ensure its enough to complete the tasks.' || '[[NL]]';
    the_data_cursor  := 'SELECT WINDOW_NAME,DURATION FROM DBA_AUTOTASK_SCHEDULE WHERE start_time IN (SELECT MAX(start_time) FROM DBA_AUTOTASK_SCHEDULE GROUP BY window_name)';
    OPEN l_cursor FOR the_data_cursor;
    LOOP
      FETCH l_cursor INTO var1,date1;
      EXIT WHEN l_cursor%notfound;
      IF ((var1 = 'SATURDAY_WINDOW') OR (var1 = 'SUNDAY_WINDOW')) THEN
        IF ((extract(DAY FROM date1)*24*60+extract(hour FROM date1)*60+ extract(minute FROM date1)) < 1200) THEN
          check_status := 'FAIL';
          msg_str_fail := msg_str_fail || 'exec dbms_scheduler.set_attribute('''||var1||''',''DURATION'',''+000 04:00:00'');' || '[[NL]]';
        END IF;
      ELSE
        IF ((extract(DAY FROM date1)*24*60+extract(hour FROM date1)*60+ extract(minute FROM date1)) < 240) THEN
          check_status := 'FAIL';
          msg_str_fail := msg_str_fail || 'exec dbms_scheduler.set_attribute('''||var1||''',''DURATION'',''+000 04:00:00'');' || '[[NL]]';
        END IF;
      END IF;
    END LOOP;
    CLOSE l_cursor;
    store_table_data (msg_num,1,'PASS','message','WINDOW_DURATION','WINDOW DURATION LESS THAN RECOMMENDED TIME', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);

    --*********************************************************
    --
    --  11g,12c - DBA_AUTOTASK_WINDOW_HISTORY BUG_12629687 Checks
    --
    --*********************************************************
--  VLC fixed on 9/19/16  Added cursor logic to avoid parsing error.  Table DBA_AUTOTASK_WINDOW_HISTORY does not exist in 10.x
  WHEN p_check = 'DBA_AUTOTASK_WINDOW_HISTORY_BUG_12629687' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_AUTOTASK_WINDOW_HISTORY';
    l_bookmark := 'DBA_AUTOTASK_WINDOW_HISTORY_DATA';
    check_status := 'PASS';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_fail := msg_str_fail || 'The WINDOW_END_TIME is the same as SYSDATE '||cur_systimestamp||' for one or more window history records. This symptom matches Bug 12629687.' || '[[NL]]';
    msg_str_pass := msg_str_pass || 'The WINDOW_END_TIME is correct for the window history records. No action is required.' || '[[NL]]';
    the_count_cursor   := 'SELECT COUNT(*) FROM DBA_AUTOTASK_WINDOW_HISTORY WHERE (to_timestamp_tz(WINDOW_END_TIME,''DD-MON-YY HH:MI:SS:FF6 PM  TZR'') at TIME zone ''GMT'') = '''||cur_systimestamp||'''';
    OPEN l_cursor FOR the_count_cursor;
    FETCH l_cursor
    INTO item_found;
    CLOSE l_cursor;
    IF ((chkVersion(db_version,'11.2.0.4',4) = 'LT') AND (item_found > 0))THEN
      --      IF ((to_timestamp_tz(i.WINDOW_END_TIME,'DD-MON-YY HH:MI:SS:FF6 PM  TZR') at TIME zone 'GMT') = cur_systimestamp) THEN
      check_status := 'FAIL';
    END IF;
    store_table_data (msg_num,1,check_status,'message','DBA_AUTOTASK_WINDOW_HISTORY_BUG_12629687','BUG 12629687', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);

    --*********************************************************
    --
    --  11g,12c - DBA_AUTOTASK_WINDOW_HISTORY BUG_19853235 Checks
    --
    --*********************************************************
--  VLC fixed on 8/8/16  Added pass message as placeholder
  WHEN p_check = 'DBA_AUTOTASK_WINDOW_HISTORY_BUG_19853235' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_AUTOTASK_WINDOW_HISTORY';
    l_bookmark := 'DBA_AUTOTASK_WINDOW_HISTORY_DATA';
    check_status := 'FAIL';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_pass := msg_str_pass || 'No pass message.';
    msg_str_fail := msg_str_fail || 'Examine the historical data below.  If the WINDOW_START_TIME and WINDOW_END_TIME are not correct, you could be encountering Bug 19853235' || '[[NL]]';
    msg_str_fail := msg_str_fail || 'Historical Information for Automated Maintenance Task Windows' || '[[NL]]';
    store_table_data (msg_num,1,check_status,'message','DBA_AUTOTASK_WINDOW_HISTORY_BUG_19853235','BUG 19853235', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  11g,12c - V_SESSION_DATA BUG_19062639 Checks
    --
    --*********************************************************
  WHEN p_check = 'V_SESSION_DATA_BUG_19062639' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'V$SESSION';
    l_bookmark := 'V$SESSION_DATA';
    check_status := 'PASS';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_fail := msg_str_fail || 'There are user sessions waiting on event ''resmgr:cpu quantum''. This could be Bug 19062639.  Review Bug 19062639 and the AWR reports for further analysis.' || '[[NL]]';
    msg_str_fail := msg_str_fail || 'The sessions can be identified with the following query: ' || '[[NL]]';
    msg_str_fail := msg_str_fail || 'SELECT COUNT * FROM v$session WHERE event = ''resmgr:cpu quantum'';' || '[[NL]]';
    msg_str_pass := msg_str_pass || 'There are no user sessions waiting on event ''resmgr:cpu quantum''. No action is required.' || '[[NL]]';
    SELECT COUNT(*)
    INTO item_found
    FROM v$session
    WHERE event = 'resmgr:cpu quantum';
    IF (item_found > 0) THEN
      check_status := 'FAIL';
    END IF;
    store_table_data (msg_num,1,check_status,'message','BUG_19062639','BUG 19062639','',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  11g,12c - DBA_RSRC_PLANS Checks
    --
    --  There is no check to perform against the DBA_RSRC_PLANS.  Information Only.
    --*********************************************************
  WHEN p_check = 'DBA_RSRC_PLANS' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_RSRC_PLANS';
    l_bookmark := 'DBA_RSRC_PLANS_DATA';
    check_status := 'PASS';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_pass := msg_str_pass || 'Details of the resource plan used by maintenance jobs:' || '[[NL]]';
    store_table_data (msg_num,1,check_status,'message','DBA_RSRC_PLANS','RESOURCE PLAN USED BY MAINTENANCE JOBS', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);
    --*********************************************************
    --
    --  11g,12c - DBA_RSRC_PLAN_DIRECTIVES Checks
    --
    --  There is no check to perform against DBA_RSRC_PLAN_DIRECTIVES.  For information only.
    --*********************************************************

  WHEN p_check = 'DBA_RSRC_PLAN_DIRECTIVES' THEN
--    dbms_output.put_line('DEBUG:  Running Check '||p_check);
    l_cur_table := 'DBA_RSRC_PLAN_DIRECTIVES';
    l_bookmark := 'DBA_RSRC_PLAN_DIRECTIVES_DATA';
    check_status := 'PASS';
    msg_num := msg_num + 1;
    msg_str_fail := '';
    msg_str_pass := '';
    msg_str_pass := msg_str_pass || 'Details of the resource plan directives used by maintenance jobs:' || '[[NL]]';
    store_table_data (msg_num,1,check_status,'message','DBA_RSRC_PLAN_DIRECTIVES','RESOURCE PLAN DIRECTIVES USED BY MAINTENANCE JOBS', '',msg_str_fail,msg_str_pass,'','','','',l_cur_table,l_bookmark);

  ELSE
    dbms_output.put_line('Undefined Check for check_logic: '||p_check);
  END CASE;
END check_logic;
--*********************************************************
--
--  JOB CONFIG SCRIPT
--
--*********************************************************
PROCEDURE job_config_script(
    duration IN NUMBER)
IS
BEGIN
--dbms_output.put_line('DEBUG:  job_config_script:  IN');
  check_data('V_PARAMETER_DATA',script_selected);
  check_logic('DATABASE_PARAMETERS',script_selected);
  check_data('DBA_JOBS_DATA',script_selected);
  check_logic('DBA_JOBS_DBMS_JOB',script_selected);
  IF (dba_jobs_found >0) THEN
    check_logic('DBA_JOBS_BROKEN',script_selected);
    check_logic('DBA_JOBS_INSTANCE',script_selected);
    check_logic('DBA_JOBS_NEXT_DATE',script_selected);
    check_logic('DBA_JOBS_NLS_ENV_MISC_ENV',script_selected);
  END IF;
  IF ((chkVersion(db_version, '10.1',2) = 'EQ') OR (chkVersion(db_version, '10.1',2) = 'GT')) THEN
--    dbms_output.put_line( 'DEBUG:  job_config_script:  Inside 10.1 check' );
    check_data('SESSIONTIMEZONE_DATA',script_selected);
    check_data('DBMS_SCHEDULER_STIME_DATA',script_selected);
    check_logic('DBMS_SCHEDULER_STIME',script_selected);
    check_data('DBA_SCHEDULER_GLOBAL_ATTRIBUTE_DATA',script_selected);
    check_logic('DBA_SCHEDULER_GLOBAL_ATTRIBUTE_SCHEDULER_DISABLED',script_selected);
    check_logic('DBA_SCHEDULER_GLOBAL_ATTRIBUTE_CURRENT_OPEN_WINDOW',script_selected);
    check_logic('DBA_SCHEDULER_GLOBAL_ATTRIBUTE_DEFAULT_TIMEZONE',script_selected);
    check_logic('DBA_SCHEDULER_GLOBAL_ATTRIBUTE_LOG_HISTORY',script_selected);
    check_logic('DBA_SCHEDULER_GLOBAL_ATTRIBUTE_EMAIL_SERVER',script_selected);
    check_logic('DBA_SCHEDULER_GLOBAL_ATTRIBUTE_EMAIL_SENDER',script_selected);
    check_data('DBA_OBJECTS_DBMS_SCHEDULER_DATA',script_selected);
    check_logic('DBA_OBJECTS_DBMS_SCHEDULER',script_selected);
    check_data('DBA_SCHEDULER_RUNNING_JOBS_DATA',script_selected);
    check_logic('DBA_SCHEDULER_RUNNING_JOBS',script_selected);
    check_data('DBA_SCHEDULER_JOBS_DATA',script_selected);
    check_logic('DBA_SCHEDULER_JOBS_SCHEDULED',script_selected);
    IF (scheduler_jobs_found >0) THEN
--  VLC fixed on 8/9/16  Added call to DBA_SCHEDULER_JOBS_PROGRAM_NAME  as it was left out.
      check_data('DBA_SCHEDULER_JOBS_DBA_SCHEDULER_PROGRAMS_DATA',script_selected);
      check_logic('DBA_SCHEDULER_JOBS_PROGRAM_NAME',script_selected);
      check_logic('DBA_SCHEDULER_JOBS_SCHEDULE_NAME',script_selected);
      check_logic('DBA_SCHEDULER_JOBS_STYLE',script_selected);
      check_logic('DBA_SCHEDULER_JOBS_TYPE',script_selected);
      check_logic('DBA_SCHEDULER_JOBS_ENABLED',script_selected);
      check_logic('DBA_SCHEDULER_JOBS_STATE_DISABLED',script_selected);
      check_logic('DBA_SCHEDULER_JOBS_STATE_SCHEDULED',script_selected);
      check_logic('DBA_SCHEDULER_JOBS_STATE_RUNNING',script_selected);
      check_logic('DBA_SCHEDULER_JOBS_STATE_COMPLETED',script_selected);
      check_logic('DBA_SCHEDULER_JOBS_STATE_STOPPED',script_selected);
      check_logic('DBA_SCHEDULER_JOBS_STATE_BROKEN',script_selected);
      check_logic('DBA_SCHEDULER_JOBS_STATE_FAILED',script_selected);
      check_logic('DBA_SCHEDULER_JOBS_STATE_RETRY_SCHEDULED',script_selected);
      check_logic('DBA_SCHEDULER_JOBS_STATE_SUCCEEDED',script_selected);
    END IF;
    check_data('DBA_SCHEDULER_WINDOW_GROUPS_DATA',script_selected);
    check_logic('DBA_SCHEDULER_WINDOW_GROUPS_CHK',script_selected);
    check_data('DBA_SCHEDULER_WINGROUP_MEMBERS_DATA',script_selected);
    check_logic('DBA_SCHEDULER_WINGROUP_MEMBERS',script_selected);
    check_data('DBA_SCHEDULER_WINDOWS_DATA',script_selected);
    check_logic('DBA_SCHEDULER_WINDOWS',script_selected);
    check_data('DBA_SCHEDULER_JOB_CLASSES_DATA',script_selected);
    check_logic('DBA_SCHEDULER_JOB_CLASSES',script_selected);
    check_data('DBA_SCHEDULER_JOBS_AND_DBA_SCHEDULER_JOB_CLASSES_DATA',script_selected);
    check_logic('DBA_SCHEDULER_JOBS_AND_DBA_SCHEDULER_JOB_CLASSES',script_selected);
    check_data('DBA_SCHEDULER_RUNNING_JOBS_SLAVE_OS_PROCESS_ID_DATA',script_selected);
    check_logic('DBA_SCHEDULER_RUNNING_JOBS_SLAVE_OS_PROCESS_ID',script_selected);
    check_data('DBA_PROFILES_DATA',script_selected);
    check_logic('DBA_PROFILES',script_selected);
  END IF;
  IF ((chkVersion(db_version, '10.2',2) = 'EQ') OR (chkVersion(db_version, '10.2',2) = 'GT')) THEN
    check_data('DBA_SCHEDULER_CHAINS_DATA',script_selected);
    check_logic('DBA_SCHEDULER_CHAINS',script_selected);
    IF (scheduler_chains_found >0) THEN
      check_data('DBA_SCHEDULER_CHAIN_STEPS_DATA',script_selected);
      check_logic('DBA_SCHEDULER_CHAIN_STEPS',script_selected);
      check_data('DBA_SCHEDULER_CHAIN_RULES_DATA',script_selected);
      check_logic('DBA_SCHEDULER_CHAIN_RULES',script_selected);
      check_data('DBA_SCHEDULER_RUNNING_CHAINS_DATA',script_selected);
      check_logic('DBA_SCHEDULER_RUNNING_CHAINS',script_selected);
      check_data('AQ$SCHEDULER$_EVENT_QTAB_DATA',script_selected);
      check_logic('AQ$SCHEDULER$_EVENT_QTAB',script_selected);
      check_data('SCHEDULER$_EVENT_QTAB_DATA',script_selected);
      check_logic('SCHEDULER$_EVENT_QTAB',script_selected);
    END IF;
  END IF;
  IF ((chkVersion(db_version, '11.2',2) = 'EQ') OR (chkVersion(db_version, '11.2',2) = 'GT')) THEN
--  VLC fixed on 8/1/16  USER_SCHEDULER_NOTIFICATIONS_DATA Commented out by mistake in version 28
    check_data('USER_SCHEDULER_NOTIFICATIONS_DATA',script_selected);
    check_logic('USER_SCHEDULER_NOTIFICATIONS',script_selected);
    check_data('USER_SCHEDULER_FILE_WATCHERS_DATA',script_selected);
    check_logic('USER_SCHEDULER_FILE_WATCHERS',script_selected);
    IF (filewatcher_jobs_found > 0) THEN
      check_data('ALL_SCHEDULER_EXTERNAL_DESTS_DATA',script_selected);
      check_logic('ALL_SCHEDULER_EXTERNAL_DESTS',script_selected);
      check_data('USER_SCHEDULER_DESTS_DATA',script_selected);
      check_logic('USER_SCHEDULER_DESTS',script_selected);
    END IF;
    IF (scheduler_jobs_found >0) THEN
--  VLC fixed on 07/26/16 - to avoid the  errors  ORA-00904: "FILE_WATCHER_NAME": invalid identifier ORA-06550
--  Moved here so will only run for 11.2 and 12c.
    check_logic('DBA_SCHEDULER_JOBS_FILE_WATCHER_NAME',script_selected);
    END IF;
  END IF;
END job_config_script;
--*********************************************************
--
--  AUTOTASK SCRIPT
--
--*********************************************************
PROCEDURE autotask_script(
    duration IN NUMBER)
IS
BEGIN
--dbms_output.put_line('DEBUG:  autotask_script:  IN');
  IF (chkVersion('10',db_version,1) = 'EQ') THEN
    check_data('V_PARAMETER_DATA',script_selected);
    check_logic('DATABASE_PARAMETERS_STATISTICS_LEVEL',script_selected);
    IF (upper(statistic_level_param) != 'BASIC') THEN
      check_data('DBA_OBJECTS_JOB_DATA',script_selected);
      check_logic('DBA_OBJECTS_JOB',script_selected);
      IF (dba_objects_job_found >=2) THEN
        check_data('DBA_SCHEDULER_JOBS_DATA',script_selected);
        check_logic('DBA_SCHEDULER_JOBS_ENABLED',script_selected);
        check_logic('DBA_SCHEDULER_JOBS_STATE_DISABLED',script_selected);
        check_logic('DBA_SCHEDULER_JOBS_STATE_SCHEDULED',script_selected);
        check_logic('DBA_SCHEDULER_JOBS_STATE_RUNNING',script_selected);
        check_logic('DBA_SCHEDULER_JOBS_STATE_COMPLETED',script_selected);
        check_logic('DBA_SCHEDULER_JOBS_STATE_STOPPED',script_selected);
        check_logic('DBA_SCHEDULER_JOBS_STATE_BROKEN',script_selected);
        check_logic('DBA_SCHEDULER_JOBS_STATE_FAILED',script_selected);
        check_logic('DBA_SCHEDULER_JOBS_STATE_RETRY_SCHEDULED',script_selected);
        check_logic('DBA_SCHEDULER_JOBS_STATE_SUCCEEDED',script_selected);
        check_data('DBA_SCHEDULER_JOB_LOG_DATA',script_selected);
        check_logic('DBA_SCHEDULER_JOB_LOG_EXECUTED',script_selected);
        check_logic('DBA_SCHEDULER_JOB_LOG_PURGE',script_selected);
        check_logic('DBA_SCHEDULER_JOB_LOG_STATUS_STOPPED',script_selected);
        check_logic('DBA_SCHEDULER_JOB_LOG_STATUS_CLOSED_JOB',script_selected);
        check_logic('DBA_SCHEDULER_JOB_ADDITIONAL_INFO',script_selected);
        check_data('DBA_SCHEDULER_JOB_RUN_DETAILS_DATA',script_selected);
        check_logic('DBA_SCHEDULER_JOB_RUN_DETAILS_ERROR',script_selected);
        check_logic('DBA_SCHEDULER_JOB_RUN_DETAILS_JOB_DELAY',script_selected);
        check_logic('DBA_SCHEDULER_JOB_RUN_DETAILS_STATUS',script_selected);
        check_data('DBA_SCHEDULER_WINDOWS_DATA',script_selected);
        check_logic('DBA_SCHEDULER_WINDOWS_EXIST',script_selected);
        IF (weeknight_window_found > 0) OR ( weekend_window_found>0 ) THEN
          check_logic('DBA_SCHEDULER_WINDOWS_ENABLED',script_selected);
          check_logic('DBA_SCHEDULER_WINDOWS_NEXT_START_DATE',script_selected);
          check_logic('DBA_SCHEDULER_WINDOWS_ACTIVE',script_selected);
        END IF;
        check_data('DBA_SCHEDULER_WINGROUP_MEMBERS_DATA',script_selected);
        check_logic('DBA_SCHEDULER_WINGROUP_MEMBERS',script_selected);
        check_data('DBA_SCHEDULER_JOBS_AND_DBA_SCHEDULER_JOB_CLASSES_DATA',script_selected);
        check_logic('DBA_SCHEDULER_JOBS_AND_DBA_SCHEDULER_JOB_CLASSES',script_selected);
      END IF;
    END IF;
  ELSIF ((chkVersion('11',db_version,1) = 'EQ') OR (chkVersion('12',db_version,1) = 'EQ')) THEN
    check_data('DBA_AUTOTASK_TASK_DATA',script_selected);
    check_logic('DBA_AUTOTASK_TASK_DATA_ENABLED',script_selected);
    check_logic('DBA_AUTOTASK_TASK_CURRENT_JOB_NAME',script_selected);
    check_logic('DBA_AUTOTASK_TASK_JOB_SCHEDULER_STATUS_DISABLED',script_selected);
    check_logic('DBA_AUTOTASK_TASK_JOB_SCHEDULER_STATUS_SCHEDULED',script_selected);
    check_logic('DBA_AUTOTASK_TASK_JOB_SCHEDULER_STATUS_RUNNING',script_selected);
    check_logic('DBA_AUTOTASK_TASK_JOB_SCHEDULER_STATUS_COMPLETED',script_selected);
    check_data('DBA_AUTOTASK_CLIENT_DATA',script_selected);
    check_logic('DBA_AUTOTASK_CLIENT_EXIST',script_selected);
    check_logic('DBA_AUTOTASK_CLIENT_DATA_STATUS',script_selected);
    check_data('DBA_AUTOTASK_CLIENT_JOB_DATA',script_selected);
    check_logic('DBA_AUTOTASK_CLIENT_JOB_EXIST',script_selected);
    check_data('DBA_AUTOTASK_JOB_HISTORY_DATA',script_selected);
    check_logic('DBA_AUTOTASK_JOB_HISTORY_JOB_ERROR',script_selected);
    check_data('DBA_AUTOTASK_WINDOW_CLIENTS_DATA',script_selected);
    check_logic('DBA_AUTOTASK_WINDOW_CLIENTS_WINDOW_ACTIVE',script_selected);
    check_logic('DBA_AUTOTASK_WINDOW_CLIENTS_WINDOW_NEXT_TIME',script_selected);
    check_logic('DBA_AUTOTASK_WINDOW_CLIENTS_AUTOTASK_STATUS',script_selected);
    check_logic('DBA_AUTOTASK_WINDOW_CLIENTS_OPTIMIZER_STATS',script_selected);
    check_logic('DBA_AUTOTASK_WINDOW_CLIENTS_SEGMENT_ADVISOR',script_selected);
    check_logic('DBA_AUTOTASK_WINDOW_CLIENTS_SQL_TUNE_ADVISOR',script_selected);
    check_logic('DBA_AUTOTASK_WINDOW_CLIENTS_HEALTH_MONITOR',script_selected);
    check_data('DBA_AUTOTASK_OPERATION_DATA',script_selected);
    check_logic('DBA_AUTOTASK_OPERATION',script_selected);
    check_data('DBA_AUTOTASK_SCHEDULE_DATA',script_selected);
    check_logic('DBA_AUTOTASK_SCHEDULE',script_selected);
    check_data('DBA_AUTOTASK_WINDOW_HISTORY_DATA',script_selected);
    check_logic('DBA_AUTOTASK_WINDOW_HISTORY_BUG_12629687',script_selected);
    check_logic('DBA_AUTOTASK_WINDOW_HISTORY_BUG_19853235',script_selected);
    check_data('DBA_SCHEDULER_JOB_LOG_DATA',script_selected);
    check_logic('DBA_SCHEDULER_JOB_LOG_EXECUTED',script_selected);
    check_logic('DBA_SCHEDULER_JOB_LOG_PURGE',script_selected);
    check_logic('DBA_SCHEDULER_JOB_LOG_STATUS_STOPPED',script_selected);
    check_logic('DBA_SCHEDULER_JOB_LOG_STATUS_CLOSED_JOB',script_selected);
    check_data('DBA_SCHEDULER_JOB_RUN_DETAILS_DATA',script_selected);
    check_logic('DBA_SCHEDULER_JOB_RUN_DETAILS_ERROR',script_selected);
    check_logic('DBA_SCHEDULER_JOB_RUN_DETAILS_JOB_DELAY',script_selected);
    check_logic('DBA_SCHEDULER_JOB_RUN_DETAILS_STATUS',script_selected);
    check_data('DBA_SCHEDULER_WINDOWS_DATA',script_selected);
    check_logic('DBA_SCHEDULER_WINDOWS_EXIST',script_selected);
    check_logic('DBA_SCHEDULER_WINDOWS_ENABLED',script_selected);
    check_logic('DBA_SCHEDULER_WINDOWS_NEXT_START_DATE',script_selected);
    check_logic('DBA_SCHEDULER_WINDOWS_ACTIVE',script_selected);
    check_logic('DBA_SCHEDULER_WINDOWS_RESOURCE_PLAN',script_selected);
    check_data('DBA_SCHEDULER_WINDOW_GROUPS_DATA',script_selected);  --causes error ORA-972 identifier is too long
    check_logic('DBA_SCHEDULER_WINDOW_GROUPS_NEXT_START_DATE',script_selected);
    check_logic('DBA_SCHEDULER_WINDOW_GROUPS_ENABLED',script_selected);
    check_logic('DATABASE_PARAMETERS_RESOURCE_MANAGER_PLAN',script_selected);
    IF (upper(resource_manager_plan_param) = 'DEFAULT_MAINTENANCE_PLAN') THEN
      check_data('V_SESSION_DATA',script_selected);
      check_logic('V_SESSION_DATA_BUG_19062639',script_selected);
    END IF;
    check_data('DBA_RSRC_PLANS_DATA',script_selected);
    check_logic('DBA_RSRC_PLANS',script_selected);
    check_data('DBA_RSRC_PLAN_DIRECTIVES_DATA',script_selected);
    check_logic('DBA_RSRC_PLAN_DIRECTIVES',script_selected);
  END IF;

END autotask_script;
--*********************************************************
--
--  NOTIFICATION SCRIPT
--
--*********************************************************
PROCEDURE notification_script(
    duration IN NUMBER)
IS
BEGIN
--dbms_output.put_line('DEBUG:  notification_script:  IN');
  check_data('V_INSTANCE_DATA',script_selected);
  check_logic('DB_VERSION',script_selected);
  IF ((chkVersion(db_version, '11.2',2) = 'EQ') OR (chkVersion('12',db_version,1) = 'EQ')) THEN
    check_data('V_PARAMETER_DATA',script_selected);
    check_logic('DATABASE_PARAMETERS_AQ_TM_PROCESS',script_selected);
    check_data('DBA_SCHEDULER_GLOBAL_ATTRIBUTE_DATA',script_selected);
    check_logic('DBA_SCHEDULER_GLOBAL_ATTRIBUTE_EMAIL_SERVER',script_selected);
    check_logic('DBA_SCHEDULER_GLOBAL_ATTRIBUTE_EMAIL_SENDER',script_selected);
    check_data('DBA_SCHEDULER_JOBS_AQ_JOBS_DATA',script_selected);
    check_logic('DBA_SCHEDULER_JOBS_AQ_JOBS',script_selected);
    check_data('DBA_SUBSCR_REGISTRATIONS_DBA_USERS_DATA',script_selected);
    check_logic('DBA_SUBSCR_REGISTRATIONS_DBA_USERS',script_selected);
    check_data('AQ$SCHEDULER$_EVENT_QTAB_DATA',script_selected);
    check_logic('AQ$SCHEDULER$_EVENT_QTAB',script_selected);
    check_data('DBA_TABLES_DATA',script_selected);
    check_logic('AQ_SRVNTFN_TABLE',script_selected);
    check_data('DBA_QUEUES_DATA',script_selected);
    check_logic('DBA_QUEUES',script_selected);
    check_data('DBA_QUEUE_SUBSCRIBERS_DATA',script_selected);
    check_logic('DBA_QUEUE_SUBSCRIBERS',script_selected);
    check_data('DBA_SCHEDULER_JOBS_DBA_SCHEDULER_NOTIFICATIONS_DATA',script_selected);
    check_logic('DBA_SCHEDULER_JOBS_DBA_SCHEDULER_NOTIFICATIONS',script_selected);
    check_data('DBA_SCHEDULER_NOTIFICATIONS_DATA',script_selected);
    check_logic('DBA_SCHEDULER_NOTIFICATIONS_EMAIL',script_selected);
    check_logic('DBA_SCHEDULER_NOTIFICATIONS_FILTER',script_selected);
  END IF;
END notification_script;

--*********************************************************
--
--  JOB EXECUTION SCRIPT
--
--*********************************************************
PROCEDURE job_execution_script(
    duration IN NUMBER)
IS
BEGIN
--dbms_output.put_line('DEBUG:  job_execution_script:  IN');
  IF ((chkVersion('10',db_version,1) = 'EQ') OR (chkVersion('11',db_version,1) = 'EQ') OR (chkVersion('12',db_version,1) = 'EQ')) THEN
  check_data('V_PARAMETER_DATA',script_selected);
  check_logic('DATABASE_PARAMETERS',script_selected);
  check_data('DBA_SCHEDULER_GLOBAL_ATTRIBUTE_DATA',script_selected);
  check_logic('DBA_SCHEDULER_GLOBAL_ATTRIBUTE_SCHEDULER_DISABLED',script_selected);
  check_logic('DBA_SCHEDULER_GLOBAL_ATTRIBUTE_CURRENT_OPEN_WINDOW',script_selected);
  check_logic('DBA_SCHEDULER_GLOBAL_ATTRIBUTE_DEFAULT_TIMEZONE',script_selected);
  check_logic('DBA_SCHEDULER_GLOBAL_ATTRIBUTE_LOG_HISTORY',script_selected);
  check_logic('DBA_SCHEDULER_GLOBAL_ATTRIBUTE_EMAIL_SERVER',script_selected);
  check_logic('DBA_SCHEDULER_GLOBAL_ATTRIBUTE_EMAIL_SENDER',script_selected);
  check_data('DBA_SCHEDULER_RUNNING_JOBS_DATA',script_selected);
  check_logic('DBA_SCHEDULER_RUNNING_JOBS',script_selected);
  check_logic('DBA_SCHEDULER_RUNNING_JOBS_JOB_NAME',script_selected);
  check_data('DBA_SCHEDULER_RUNNING_CHAINS_DATA',script_selected);
  check_logic('DBA_SCHEDULER_RUNNING_CHAINS',script_selected);
  check_data('DBA_SCHEDULER_JOBS_DATA',script_selected);
  check_data('DBA_SCHEDULER_JOB_RUN_DETAILS_DATA',script_selected);
  check_logic('DBA_SCHEDULER_JOB_RUN_DETAILS_ERROR',script_selected);
  check_logic('DBA_SCHEDULER_JOB_RUN_DETAILS_JOB_DELAY',script_selected);
  check_data('DBA_SCHEDULER_JOB_LOG_DATA',script_selected);
  check_data('DBA_SCHEDULER_JOB_RUN_DETAILS_LATEST_EXECUTION_DATA',script_selected);
  check_logic('DBA_SCHEDULER_JOB_LOG_EXECUTION',script_selected);
  check_data('DBA_SCHEDULER_WINDOWS_DATA',script_selected);
  check_logic('DBA_SCHEDULER_WINDOWS',script_selected);
  check_data('DBA_SCHEDULER_WINDOW_LOG_DATA',script_selected);
  check_logic('DBA_SCHEDULER_WINDOW_LOG_CHK',script_selected);
  check_data('DBA_SCHEDULER_WINDOW_GROUPS_DATA',script_selected);
  check_logic('DBA_SCHEDULER_WINDOW_GROUPS_CHK',script_selected);
  check_data('ALL_SCHEDULER_WINDOW_DETAILS_DATA',script_selected);
  check_logic('ALL_SCHEDULER_WINDOW_DETAILS_CHK',script_selected);
  check_data('DBA_JOBS_DATA',script_selected);
  check_logic('DBA_JOBS_DBMS_JOB',script_selected);
-- VLC fixed on 8/12/16  Theck check for the dba_jobs count was commented out and shouldn't have been.
IF (dba_jobs_found > 0) THEN
  check_logic('DBA_JOBS_BROKEN',script_selected);
  check_logic('DBA_JOBS_INSTANCE',script_selected);
  check_logic('DBA_JOBS_NEXT_DATE',script_selected);
  check_logic('DBA_JOBS_NLS_ENV_MISC_ENV',script_selected);
END IF;
  check_data('DBA_JOBS_RUNNING_DATA',script_selected);
  check_logic('DBA_JOBS_RUNNING_CHK',script_selected);
 END IF;

END job_execution_script;

--*********************************************************
--
--  EXTERNAL JOBS SCRIPT
--
--*********************************************************
PROCEDURE external_jobs_script(
    duration IN NUMBER)
IS
BEGIN
--dbms_output.put_line('DEBUG:  external_jobs_script:  IN');
  IF ((chkVersion('10',db_version,1) = 'EQ') OR (chkVersion('11',db_version,1) = 'EQ') OR (chkVersion('12',db_version,1) = 'EQ')) THEN
  check_data('DBA_SCHEDULER_JOBS_DATA',script_selected);
  check_logic('DBA_SCHEDULER_JOBS_CREDENTIAL_NAME',script_selected);
  check_logic('DBA_SCHEDULER_JOBS_PERMISSION',script_selected);
  check_logic('DBA_SCHEDULER_JOBS_JOB_ACTION',script_selected);
  check_logic('DBA_SCHEDULER_JOBS_STATE_DISABLED',script_selected);
  check_logic('DBA_SCHEDULER_JOBS_STATE_SCHEDULED',script_selected);
  check_logic('DBA_SCHEDULER_JOBS_STATE_RUNNING',script_selected);
  check_logic('DBA_SCHEDULER_JOBS_STATE_COMPLETED',script_selected);
  check_logic('DBA_SCHEDULER_JOBS_STATE_STOPPED',script_selected);
  check_logic('DBA_SCHEDULER_JOBS_STATE_BROKEN',script_selected);
  check_logic('DBA_SCHEDULER_JOBS_STATE_FAILED',script_selected);
  check_logic('DBA_SCHEDULER_JOBS_STATE_RETRY_SCHEDULED',script_selected);
  check_logic('DBA_SCHEDULER_JOBS_STATE_SUCCEEDED',script_selected);
  check_data('DBA_SCHEDULER_CREDENTIALS_DBA_SCHEDULER_JOBS_DATA',script_selected);
  check_logic('DBA_SCHEDULER_CREDENTIALS_OWNER',script_selected);
--  VLC fixed on 8/1/16  Name of check was wrong in version 28.  Instead of DBA_SCHEDULER_RUN_DEETAILS_DBA_SCHEDULER_JOBS_DATA it should be DBA_SCHEDULER_JOB_RUN_DETAILS_DBA_SCHEDULER_JOBS_DATA
  check_data('DBA_SCHEDULER_JOB_RUN_DETAILS_DBA_SCHEDULER_JOBS_DATA',script_selected);
  check_logic('DBA_SCHEDULER_JOB_RUN_DETAILS_DBA_SCHEDULER_JOBS_CHECK',script_selected);
 END IF;
END external_jobs_script;
--*********************************************************
--
--  DBMS JOBS SCRIPT
--
--*********************************************************
PROCEDURE dbms_jobs_script(
    duration IN NUMBER)
IS
BEGIN
--dbms_output.put_line('DEBUG:  dbms_jobs_script:  IN');
  IF ((chkVersion('10',db_version,1) = 'EQ') OR (chkVersion('11',db_version,1) = 'EQ') OR (chkVersion('12',db_version,1) = 'EQ')) THEN
  check_data('V_PARAMETER_DATA',script_selected);
  check_logic('DATABASE_PARAMETERS',script_selected);
  check_data('DBA_JOBS_DATA',script_selected);
  check_logic('DBA_JOBS_DBMS_JOB',script_selected);
  check_logic('DBA_JOBS_BROKEN',script_selected);
  check_logic('DBA_JOBS_INSTANCE',script_selected);
  check_logic('DBA_JOBS_NEXT_DATE',script_selected);
  check_logic('DBA_JOBS_NLS_ENV_MISC_ENV',script_selected);
  check_data('DBA_JOBS_RUNNING_DATA',script_selected);
  check_logic('DBA_JOBS_RUNNING_CHK',script_selected);
  END IF;
END dbms_jobs_script;
--*********************************************************
--
--  BEGIN CHECKS
--  This version works in 12c, 11.2 and 11.1.
--
--*********************************************************
BEGIN
  -- Set DBMS_OUTPUT.ENABLE to avoid the following error
  -- ORA-20000: ORU-10027: buffer overflow, limit of 1000000 bytes
  -- ORA-06512: at "SYS.DBMS_OUTPUT", line 32
  -- 20000. 00000 -  "%s"
  -- *Cause:    The stored procedure 'raise_application_error
--            was called which causes this error to be generated.
-- *Action:   Correct the problem as described in the error message or contact
--            the application administrator or DBA for more information.
--dbms_output.enable(1000000);
DBMS_OUTPUT.ENABLE (buffer_size => NULL);
common_msg_num := common_msg_num + 1;
t_common_message(common_msg_num).msg_name := 'fix_windows_jobs';
t_common_message(common_msg_num).msg_type := 'MESSAGE';
t_common_message(common_msg_num).msg_title := 'FIX WINDOWS JOBS';
t_common_message(common_msg_num).msg_body := t_common_message(common_msg_num).msg_body || 'CONNECT AS sysdba' || '[[NL]]';
t_common_message(common_msg_num).msg_body := t_common_message(common_msg_num).msg_body || '@ $ORACLE_HOME/rdbms/admin/catnomwn.sql' || '[[NL]]';
t_common_message(common_msg_num).msg_body := t_common_message(common_msg_num).msg_body || '@ $ORACLE_HOME/rdbms/admin/catmwin.sql' || '[[NL]]';
t_common_message(common_msg_num).msg_body := t_common_message(common_msg_num).msg_body || 'EXEC dbms_scheduler.add_window_group_member(''MAINTENANCE_WINDOW_GROUP'', ''WEEKNIGHT_WINDOW'');' || '[[NL]]';
t_common_message(common_msg_num).msg_body := t_common_message(common_msg_num).msg_body || 'EXEC dbms_scheduler.add_window_group_member(''MAINTENANCE_WINDOW_GROUP'',''WEEKEND_WINDOW'');' || '[[NL]]';
--*********************************************************
--
--  REPORT INFORMATION
--
--*********************************************************

SELECT systimestamp AT TIME ZONE 'GMT'
INTO cur_systimestamp
FROM dual;
  l_cur_table := 'CHECK: V$INSTANCE';
  SELECT instance_name, host_name, version, SUBSTR(version,1,2), TO_CHAR(sysdate,'YYYYMMDD_HH24MISS'),
    TO_CHAR(startup_time, 'DD-MON-YY HH:MI:SS AM'), TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS')
  INTO instance_name, host_name, db_version, db_version_short, cur_date, startup_time, report_time
  FROM v$instance;
l_cur_table := 'CHECK: V$DATABASE';
SELECT name INTO db_name FROM v$database;
msg_num := msg_num + 1;
msg_str_pass := 'Report Name: ' || v_SRDCSPOOLNAME || '[[NL]]';
msg_str_pass := msg_str_pass || 'Report Run TIME: '|| report_time ||'[[NL]]';
msg_str_pass := msg_str_pass || 'Startup TIME: '|| startup_time ||'[[NL]]';
msg_str_pass := msg_str_pass || 'Machine: '||host_name || '[[NL]]';
msg_str_pass := msg_str_pass || 'Version: '||db_version || '[[NL]]';
msg_str_pass := msg_str_pass || 'DBName: '||db_name || '[[NL]]';
msg_str_pass := msg_str_pass || 'Instance: '||instance_name || '[[NL]]' ;
IF ((script_selected = 'DBMS_JOBS') AND ((chkVersion('10',db_version,1) = 'EQ') OR (chkVersion('11',db_version,1) = 'EQ') OR (chkVersion('12',db_version,1) = 'EQ'))) THEN
msg_str_pass := msg_str_pass || 'NOTE:  These script results contains the details of the jobs scheduled using DBMS_JOB package only. Check for the jobs scheduled using DBMS_SCHEDULER as well.' || '[[NL]]' ;
END IF;
store_table_data (msg_num,1,'NA','rpt_info','Report_Header','Report Info', msg_str_pass,'','','','','','',l_cur_table,l_bookmark);

--*********************************************************
--
--  BANNER
--
--*********************************************************
msg_num := msg_num + 1;
msg_str_pass := '';
store_table_data (msg_num,1,'NA','rpt_info','banner','BANNER', msg_str_pass,'','','','','','',l_cur_table,l_bookmark);
l_cur_table := 'V$VERSION';
FOR i IN
( SELECT * FROM v$version
)
LOOP
t_message(msg_num).msg_body := t_message(msg_num).msg_body || i.banner ||'[[NL]]';
END LOOP;
-- ***************************************************************
--
--   LOGIC FOR JOB CONFIGURATION SCHEDULER
--
-- ***************************************************************
IF ((chkVersion(db_version,'11',1) = 'EQ') or (chkVersion(db_version,'12',1) = 'EQ')) THEN
CASE
WHEN script_selected = 'JOB_AUTOTASK' THEN
autotask_script(1);
WHEN script_selected = 'JOB_NOTIFICATION' THEN
notification_script(1);
WHEN script_selected = 'JOB_CONFIGURATION' THEN
job_config_script(1);
WHEN script_selected = 'JOB_EXECUTION' THEN
job_execution_script(1);
WHEN script_selected = 'EXTERNAL_JOBS' THEN
external_jobs_script(1);
WHEN script_selected = 'DBMS_JOBS' THEN
dbms_jobs_script(1);
ELSE
dbms_output.put_line('Undefined Script: '||script_selected);
END CASE;
--*********************************************************
--
--  CHECKS COMPLETE - NOW PRINT RESULTS
--
--*********************************************************
item_found :=0;
write_html_hdr(v_SRDCSPOOLNAME);
write_html_msg(msg_num,full_result_msg);
write_html_query_output(msg_num);
write_xml(msg_num);
write_html_end;
:the_results := REPLACE(full_result_msg,'[[NL]]',chr(13) || chr( 10));

ELSE
full_result_msg := 'This script is intended for database version 11g and 12c.  Refer to the SRDC for the instructions for database version '||db_version||'.';
dbms_output.put_line(full_result_msg);
:the_results := REPLACE(full_result_msg,'[[NL]]',chr(13) || chr( 10));
END IF;


EXCEPTION
WHEN NO_DATA_FOUND THEN
DBMS_OUTPUT.put_line('No data found FOR the query against the following TABLE:  ' || l_cur_table);
WHEN OTHERS THEN -- handles all other errors
IF SQLCODE = -10027 THEN
DBMS_OUTPUT.put_line('Buffer Overflow : [' || l_cur_table ||']');
ELSIF SQLCODE = -00942 THEN
DBMS_OUTPUT.put_line('TABLE OR VIEW does NOT exist : [' || l_cur_table ||']');
ELSE
DBMS_OUTPUT.put_line('Other Error : Check with error: ['|| p_check_name ||']  Table used by check: [' || l_cur_table ||']');
DBMS_OUTPUT.put_line('SQLCODE : [' || SQLCODE ||']');
DBMS_OUTPUT.put_line('MESSAGE : [' || SQLERRM ||']');
END IF;

END;
/
spool OFF
SET sqlprompt "SQL> " term ON echo OFF
PROMPT
PROMPT THE RESULTS
PRINT the_results
PROMPT
PROMPT REPORT GENERATED : &SRDCSPOOLNAME..htm
SET verify ON
