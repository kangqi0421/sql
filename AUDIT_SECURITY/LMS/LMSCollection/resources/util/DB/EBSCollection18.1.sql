SET ECHO OFF
SET PAUSE OFF
SET TERMOUT OFF
REM     ORACLE - License Management Services - EBS Collection Script
REM
REM     Change History
REM     ---------------------------------
REM     Date        Release Author
REM     ----------- ------- ---------------
REM     2017-03-20  18.1    tstoenes sserban

define LMSCT_V=18.1

SET DEFINE ON
SET MARKUP HTML OFF
SET COLSEP ' '

-- Settings for customized functionality - the last definition of each parameter will dictate the customization
-- Set SCRIPT_OO to collect all information or options only
define SCRIPT_OO=_OO_IGNORE_THIS_ERR  -- collect only options information
define SCRIPT_OO=''                   -- collect all information [default behavior]
-- Set SCRIPT_TS to generate filenames with or without timestamp
define SCRIPT_TS=_TS_IGNORE_THIS_ERR  -- include timestamp in names of the output directory and output files: YYYY.MM.DD.HH24.MI.SS
define SCRIPT_TS=''                   -- standard names for output directory and output files [default behavior]

-- Set SCRIPT_LA set license agreement prompt behavior
define SCRIPT_LA=_LA_IGNORE_THIS_ERR  -- script does not prompt for license agreement
define SCRIPT_LA=''                   -- script prompts for license agreement [default behavior]
-- Set SCRIPT_SI to run in interactive or in silent mode
define SCRIPT_SI=_SI_IGNORE_THIS_ERR  -- script does not prompt for privilege check confirmation
define SCRIPT_SI=''                   -- script prompts for privilege check confirmation [default behavior]
-- Set SCRIPT_SD to create output subdirectory
define SCRIPT_SD=EBS                  -- create output subdirectory
--#<LMSCT>#define SCRIPT_SD=''                   -- no output subdirectory



-- PREPARE AND DISPLAY LICENSE AGREEMENT

SPOOL&SCRIPT_LA lms_license_agreement.txt
PROMPT ===============================================================
PROMPT For reading LICENSE AGREEMENT use:
PROMPT <SPACE>  to display next page
PROMPT <RETURN> to display next line
PROMPT ===============================================================
PROMPT
PROMPT Terms for Oracle License Management Services ("LMS") Software
PROMPT
PROMPT If you have an Oracle license agreement for your use of the Oracle software programs that are under review or audit by Oracle and/or that you wish to measure, monitor, or manage (collectively, "Programs") - such as an Oracle Master Agreement, Oracle License and Services Agreement, Oracle PartnerNetwork Agreement, Oracle distribution agreement, or other Oracle license agreement for the Programs (each a "Master Agreement") - then the Master Agreement applies to your use of the Oracle software provided with these terms ("Software") and the License Agreement displayed below does not apply to you.  When a Master Agreement applies, (a) notwithstanding anything to the contrary in the Master Agreement, your use of the Software shall be limited to measuring, monitoring and/or managing your usage of the Programs and Oracle's liability for the Software shall be no more than the amount that applies under the Master Agreement for the Programs; and (b) you acknowledge that using the Software, in and of itself, does not constitute an audit under the terms of your Master Agreement.
PROMPT
PROMPT If a Master Agreement does not apply then the License Agreement displayed below applies to your use of the Software.
PROMPT
PROMPT By selecting "Accept License Agreement" (or the equivalent) or by typing the required acceptance text you indicate your acceptance of these terms and your agreement, as an authorized representative of your company or organization (if being acquired for use by an entity) or as an individual, to comply with the license terms that apply to the Software.  If you are not willing to be bound by these terms, do not indicate your acceptance and do not download, install, or use the Software.
PROMPT
PROMPT
PROMPT License Agreement
PROMPT
PROMPT PLEASE SCROLL DOWN AND READ ALL OF THE FOLLOWING TERMS AND CONDITIONS OF THIS LICENSE AGREEMENT ("Agreement") CAREFULLY.  THIS AGREEMENT IS A LEGALLY BINDING CONTRACT BETWEEN YOU AND ORACLE AMERICA, INC. THAT SETS FORTH THE TERMS AND CONDITIONS THAT GOVERN YOUR USE OF THE SOFTWARE.
PROMPT
PROMPT YOU MUST ACCEPT AND ABIDE BY THESE TERMS AND CONDITIONS AS PRESENTED TO YOU - ANY CHANGES, ADDITIONS OR DELETIONS BY YOU TO THESE TERMS AND CONDITIONS WILL NOT BE ACCEPTED BY US AND WILL NOT MAKE PART OF THIS AGREEMENT.
PROMPT
PROMPT Definitions
PROMPT "We," "Us," and "Our" refers to Oracle America, Inc.  "Oracle" refers to Oracle Corporation and its affiliates.
PROMPT
PROMPT "You" and "Your" refers to the individual or entity that wishes to use the Software (as defined below) provided by Oracle.
PROMPT
PROMPT "Software" refers to the tool(s), script(s) and/or software product(s) and any applicable documentation provided to You by Oracle which You wish to access and use to measure, monitor and/or manage Your usage of separately-licensed Oracle software.
PROMPT
PROMPT Rights Granted
PROMPT We grant You a non-exclusive, non-transferable limited right to use the Software, subject to the terms of this Agreement, for the limited purpose of measuring, monitoring and/or managing Your usage of separately-licensed Oracle software.  You may allow Your agents and contractors (including, without limitation, outsourcers) to use the Software for this purpose and You are responsible for their compliance with this Agreement in such use.  You (including Your agents, contractors and/or outsourcers) may not use the Software for any other purpose.  You acknowledge that using the Software, in and of itself, does not constitute an audit under the terms of any other agreement that you may have with Oracle.
PROMPT
PROMPT Ownership and Restrictions
PROMPT Oracle and Oracle's licensors retain all ownership and intellectual property rights to the Software. The Software may be installed on one or more servers; provided, however, that You may only make one copy of the Software for backup or archival purposes.
PROMPT
PROMPT Third party technology that may be appropriate or necessary for use with the Software is specified in the Software documentation, notice files or readme files.  Such third party technology is licensed to You under the terms of the third party technology license agreement specified in the Software documentation, notice files or readme files and not under the terms of this Agreement.
PROMPT
PROMPT You may not:
PROMPT -  use the Software for Your own internal data processing or for any commercial or production purposes, or use the Software for any purpose except the purpose stated herein;
PROMPT -  remove or modify any Software markings or any notice of Oracle's or Oracle's licensors' proprietary rights;
PROMPT -  make the Software available in any manner to any third party for use in the third party's business operations, without Our prior written consent ;
PROMPT -  use the Software to provide third party training or rent or lease the Software or use the Software for commercial time sharing or service bureau use;
PROMPT -  assign this Agreement or give or transfer the Software or an interest in them to another individual or entity;
PROMPT -  cause or permit reverse engineering (unless required by law for interoperability), disassembly or decompilation of the Software (the foregoing prohibition includes but is not limited to review of data structures or similar materials produced by Software);
PROMPT -  disclose results of any Software benchmark tests without Our prior written consent;
PROMPT -  use any Oracle name, trademark or logo without Our prior written consent .
PROMPT
PROMPT Disclaimer of Warranty
PROMPT ORACLE DOES NOT GUARANTEE THAT THE SOFTWARE WILL PERFORM ERROR-FREE OR UNINTERRUPTED.   TO THE EXTENT NOT PROHIBITED BY LAW, THE SOFTWARE ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND AND THERE ARE NO WARRANTIES, EXPRESS OR IMPLIED, OR CONDITIONS, INCLUDING WITHOUT LIMITATION, WARRANTIES OR CONDITIONS OF MERCHANTABILITY, NONINFRINGEMENT OR FITNESS FOR A PARTICULAR PURPOSE, THAT APPLY TO THE SOFTWARE.
PROMPT
PROMPT No Right to Technical Support
PROMPT You acknowledge and agree that Oracle's technical support organization will not provide You with technical support for the Software licensed under this Agreement.
PROMPT
PROMPT End of Agreement
PROMPT You may terminate this Agreement by destroying all copies of the Software. We have the right to terminate Your right to use the Software at any time upon notice to You, in which case You shall destroy all copies of the Software.
PROMPT
PROMPT Entire Agreement
PROMPT You agree that this Agreement is the complete agreement for the Software and supersedes all prior or contemporaneous agreements or representations, written or oral, regarding such Software. If any term of this Agreement is found to be invalid or unenforceable, the remaining provisions will remain effective and such term shall be replaced with a term consistent with the purpose and intent of this Agreement.
PROMPT
PROMPT Limitation of Liability
PROMPT IN NO EVENT SHALL ORACLE BE LIABLE FOR ANY INDIRECT, INCIDENTAL, SPECIAL, PUNITIVE OR CONSEQUENTIAL DAMAGES, OR ANY LOSS OF PROFITS, REVENUE, DATA OR DATA USE, INCURRED BY YOU OR ANY THIRD PARTY.  ORACLE'S ENTIRE LIABILITY FOR DAMAGES ARISING OUT OF OR RELATED TO THIS AGREEMENT, WHETHER IN CONTRACT OR TORT OR OTHERWISE, SHALL IN NO EVENT EXCEED ONE THOUSAND U.S. DOLLARS (U.S. $1,000).
PROMPT
PROMPT Export
PROMPT Export laws and regulations of the United States and any other relevant local export laws and regulations apply to the Software.  You agree that such export control laws govern Your use of the Software (including technical data) provided under this Agreement, and You agree to comply with all such export laws and regulations (including "deemed export" and "deemed re-export" regulations).  You agree that no data, information, and/or Software (or direct product thereof) will be exported, directly or indirectly, in violation of any export laws, nor will they be used for any purpose prohibited by these laws including, without limitation, nuclear, chemical, or biological weapons proliferation, or development of missile technology.
PROMPT
PROMPT Other
PROMPT 1. This Agreement is governed by the substantive and procedural laws of the State of California, USA. You and We agree to submit to the exclusive jurisdiction of, and venue in, the courts of San Francisco or Santa Clara counties in California in any dispute arising out of or relating to this Agreement.
PROMPT
PROMPT 2. You may not assign this Agreement or give or transfer the Software or an interest in them to another individual or entity.  If You grant a security interest in the Software, the secured party has no right to use or transfer the Software.
PROMPT
PROMPT 3. Except for actions for breach of Oracle's proprietary rights, no action, regardless of form, arising out of or relating to this Agreement may be brought by either party more than two years after the cause of action has accrued.
PROMPT
PROMPT 4. Oracle may audit Your use of the Software.  You agree to cooperate with Oracle's audit and provide reasonable assistance and access to information.  Any such audit shall not unreasonably interfere with Your normal business operations.  You agree that Oracle shall not be responsible for any of Your costs incurred in cooperating with the audit.
PROMPT
PROMPT 5. The relationship between You and Us is that of licensee/licensor. Nothing in this Agreement shall be construed to create a partnership, joint venture, agency, or employment relationship between the parties.  The parties agree that they are acting solely as independent contractors hereunder and agree that the parties have no fiduciary duty to one another or any other special or implied duties that are not expressly stated herein.  Neither party has any authority to act as agent for, or to incur any obligations on behalf of or in the name of the other.
PROMPT
PROMPT 6. This Agreement may not be modified and the rights and restrictions may not be altered or waived except in a writing signed by authorized representatives of You and of Us.
PROMPT
PROMPT 7. Any notice required under this Agreement shall be provided to the other party in writing.
PROMPT
PROMPT 8. In order to assist You with the measurement, monitoring or management of Your usage of separately-licensed Oracle software, Oracle may have access to and collect Your information, which may include personal information, and data residing on Oracle, customer or third-party systems on which the Software are used and/or to which Oracle is provided access to perform any associated services.  Oracle treats such information and data in accordance with the terms of the Oracle Services Privacy Policy, which is available at http://www.oracle.com/html/services-privacy-policy.html, and treats such data as confidential in accordance with the terms of your Oracle master agreement.  The Services Privacy Policy is subject to change at Oracle's discretion; however, Oracle will not materially reduce the level of protection specified in the Services Privacy Policy in effect at the time the information was collected during the period that Oracle retains such information.
PROMPT
PROMPT Contact Information
PROMPT Should You have any questions concerning Your use of the Software or this Agreement, please contact Oracle License Management Services at: http://www.oracle.com/us/corporate/license-management-services/index.html
PROMPT
PROMPT Oracle America, Inc.
PROMPT 500 Oracle Parkway,
PROMPT Redwood City, CA 94065
PROMPT
PROMPT Last updated 21 December 2015
PROMPT
PROMPT ===============================================================

SPOOL OFF

HOST&SCRIPT_LA more lms_license_agreement.txt   2> fii_err.txt

-- PROMT FOR LICENSE AGREEMENT ACCEPTANCE
DEFINE LANSWER=N
SET TERMOUT ON
ACCEPT&SCRIPT_LA LANSWER FORMAT A1 PROMPT 'Accept License Agreement? (y\n): '

HOST&SCRIPT_LA rm   lms_license_agreement.txt   2> fii_err.txt
HOST&SCRIPT_LA del  lms_license_agreement.txt   2> fii_err.txt

SET TERMOUT OFF
WHENEVER SQLERROR EXIT
SET TERMOUT ON
prompt Checking agreement acceptance ...
SET TERMOUT OFF
-- FORCE "divisor is equal to zero" AND SQLERROR EXIT IF NOT ACCEPTED
-- WILL ALSO CONTINUE IF SCRIPT_LA SUBSTITUTION VARIABLE IS NOT NULL
select 1/decode('&LANSWER', 'Y', null, 'y', null, decode('&SCRIPT_LA', null, 0, null)) as " " from DUAL;
WHENEVER SQLERROR CONTINUE
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
define INSTANCE_NAME_0=&INSTANCE_NAME
select '&&INSTANCE_NAME' || decode(VALUE, 'TRUE', '~' || replace(sys_context('USERENV', 'CON_NAME'), '$', '_'), '') C1
  from V$PARAMETER where name = 'enable_pluggable_database';



SET FEEDBACK ON
SET VERIFY ON



-- Get SYSDATE
define SYSDATE_START=UNKNOWN
col C0 new_val SYSDATE_START
select SYSDATE C0 from dual;

-- Set output location
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
SET TERMOUT OFF
@psep.sql
SET TERMOUT ON
-- Cleanup
host &RMDEL psep.sql   2> fii_err.txt
--}

HOST mkdir &SCRIPT_SD   2> fii_err.txt

define OUTPUT_PATH_SD=***
col C3 new_val OUTPUT_PATH_SD
select decode('&&SCRIPT_SD', null, '&&OUTPUT_PATH', '&&SCRIPT_SD&&PSEP&&OUTPUT_PATH') C3 from DUAL;

HOST mkdir &&OUTPUT_PATH_SD

define OUTPUT_PATH_ROOT=***
col C3 new_val OUTPUT_PATH_ROOT
select decode(instr('&&OUTPUT_PATH_SD', '&&PSEP', -1),
              length('&&OUTPUT_PATH_SD'), '&&OUTPUT_PATH_SD',   -- if terminated by path separator, do noting
                                          '&&OUTPUT_PATH_SD&&PSEP') as C3
  from dual;
col C3 clear

SET VERIFY OFF
SET TERMOUT ON

ALTER SESSION SET CURRENT_SCHEMA = APPS;

SPOOL &&OUTPUT_PATH_ROOT.export_log_01.txt

PROMPT LMS Collection Tool version &&LMSCT_V
PROMPT
PROMPT ***** Collecting audit tables *****
PROMPT
REM    *** FND_APPLICATION
PROMPT ======================================================================

WHENEVER SQLERROR CONTINUE

SET HEADING OFF
SELECT 'FND_APPLICATION: Exporting '||COUNT(*)||' rows' FROM FND_APPLICATION;

SPOOL OFF

SPOOL &&OUTPUT_PATH_ROOT.FND_APPLICATION.csv

SET TERMOUT OFF
SET HEADING ON
SET PAGESIZE 50000
SET LINESIZE 1000

SELECT  CHR(35)||'^~*~^'||APPLICATION_ID||'^~*~^'||','||
        '^~*~^'||APPLICATION_SHORT_NAME||'^~*~^'||','||
        '^~*~^'||TO_CHAR(CREATION_DATE,'mm/dd/yyyy hh:mi:ss AM')||'^~*~^'||','||
        '^~*~^'||TO_CHAR(LAST_UPDATE_DATE,'mm/dd/yyyy hh:mi:ss AM')||'^~*~^'||','||
        '^~*~^'||TO_CHAR(SYSDATE, 'MM/DD/YYYY HH24:MI')||'^~*~^'
FROM    FND_APPLICATION;

SPOOL OFF
SET TERMOUT ON

SPOOL &&OUTPUT_PATH_ROOT.export_log_02.txt

PROMPT
REM    *** FND_APPLICATION_TL
PROMPT ======================================================================

SET HEADING OFF
SELECT 'FND_APPLICATION_TL: Exporting '||COUNT(*)||' rows' FROM FND_APPLICATION_TL;

SPOOL OFF

SPOOL &&OUTPUT_PATH_ROOT.FND_APPLICATION_TL.csv

SET TERMOUT OFF
SET HEADING ON

SELECT  CHR(35)||'^~*~^'||APPLICATION_ID||'^~*~^'||','||
        '^~*~^'||LANGUAGE||'^~*~^'||','||
        '^~*~^'||APPLICATION_NAME||'^~*~^'||','||
        '^~*~^'||REPLACE(REPLACE(DESCRIPTION, CHR(10)), CHR(13))||'^~*~^'||','||
        '^~*~^'||TO_CHAR(CREATION_DATE,'mm/dd/yyyy hh:mi:ss AM')||'^~*~^'||','||
        '^~*~^'||TO_CHAR(LAST_UPDATE_DATE,'mm/dd/yyyy hh:mi:ss AM')||'^~*~^'||','||
        '^~*~^'||TO_CHAR(SYSDATE, 'MM/DD/YYYY HH24:MI')||'^~*~^'
FROM    FND_APPLICATION_TL;

SPOOL OFF
SET TERMOUT ON

SPOOL &&OUTPUT_PATH_ROOT.export_log_03.txt

PROMPT
REM    *** FND_RESPONSIBILITY
PROMPT ======================================================================

SET HEADING OFF
SELECT 'FND_RESPONSIBILITY: Exporting '||COUNT(*)||' rows' FROM FND_RESPONSIBILITY;

SPOOL OFF

SPOOL &&OUTPUT_PATH_ROOT.FND_RESPONSIBILITY.csv

SET TERMOUT OFF
SET HEADING ON

SELECT  CHR(35)||'^~*~^'||APPLICATION_ID||'^~*~^'||','||
        '^~*~^'||RESPONSIBILITY_ID||'^~*~^'||','||
        '^~*~^'||MENU_ID||'^~*~^'||','||
        '^~*~^'||TO_CHAR(START_DATE, 'MM/DD/YYYY')||'^~*~^'||','||
        '^~*~^'||TO_CHAR(END_DATE, 'MM/DD/YYYY')||'^~*~^'||','||
        '^~*~^'||VERSION||'^~*~^'||','||
        '^~*~^'||RESPONSIBILITY_KEY||'^~*~^'||','||
        '^~*~^'||TO_CHAR(CREATION_DATE,'mm/dd/yyyy hh:mi:ss AM')||'^~*~^'||','||
        '^~*~^'||TO_CHAR(LAST_UPDATE_DATE,'mm/dd/yyyy hh:mi:ss AM')||'^~*~^'||','||
        '^~*~^'||TO_CHAR(SYSDATE, 'MM/DD/YYYY HH24:MI')||'^~*~^'
FROM    FND_RESPONSIBILITY;

SPOOL OFF
SET TERMOUT ON

SPOOL &&OUTPUT_PATH_ROOT.export_log_04.txt

PROMPT
REM    *** FND_RESPONSIBILITY_TL
PROMPT ======================================================================

SET HEADING OFF
SELECT 'FND_RESPONSIBILITY_TL: Exporting '||COUNT(*)||' rows' FROM FND_RESPONSIBILITY_TL;

SPOOL OFF

SPOOL &&OUTPUT_PATH_ROOT.FND_RESPONSIBILITY_TL.csv

SET TERMOUT OFF
SET HEADING ON

SELECT  CHR(35)||'^~*~^'||APPLICATION_ID||'^~*~^'||','||
        '^~*~^'||RESPONSIBILITY_ID||'^~*~^'||','||
        '^~*~^'||LANGUAGE||'^~*~^'||','||
        '^~*~^'||RESPONSIBILITY_NAME||'^~*~^'||','||
        '^~*~^'||REPLACE(REPLACE(DESCRIPTION, CHR(10)), CHR(13))||'^~*~^'||','||
        '^~*~^'||TO_CHAR(CREATION_DATE,'mm/dd/yyyy hh:mi:ss AM')||'^~*~^'||','||
        '^~*~^'||TO_CHAR(LAST_UPDATE_DATE,'mm/dd/yyyy hh:mi:ss AM')||'^~*~^'||','||
        '^~*~^'||TO_CHAR(SYSDATE, 'MM/DD/YYYY HH24:MI')||'^~*~^'
FROM    FND_RESPONSIBILITY_TL;

SPOOL OFF
SET TERMOUT ON

SPOOL &&OUTPUT_PATH_ROOT.export_log_05.txt

PROMPT
REM    *** FND_USER
PROMPT ======================================================================

SET HEADING OFF
SELECT 'FND_USER: Exporting '||COUNT(*)||' rows' FROM FND_USER;

SPOOL OFF

SPOOL &&OUTPUT_PATH_ROOT.FND_USER.csv

SET TERMOUT OFF
SET HEADING ON

SELECT  CHR(35)||'^~*~^'||USER_ID ||'^~*~^'||','||
        '^~*~^'||USER_NAME ||'^~*~^'||','||
        '^~*~^'||''||'^~*~^'||','||
        '^~*~^'||REPLACE(REPLACE(DECODE(INSTR(email_Address,'@'),0,NULL,SUBSTR(email_address,INSTR(email_address,'@'))), CHR(10)), CHR(13))||'^~*~^'||','||
        '^~*~^'||TO_CHAR(START_DATE, 'MM/DD/YYYY')||'^~*~^'||','||
        '^~*~^'||TO_CHAR(END_DATE, 'MM/DD/YYYY')||'^~*~^'||','||
        '^~*~^'||TO_CHAR(LAST_LOGON_DATE, 'MM/DD/YYYY')||'^~*~^'||','||
        '^~*~^'||TO_CHAR(CREATION_DATE,'mm/dd/yyyy hh:mi:ss AM')||'^~*~^'||','||
        '^~*~^'||TO_CHAR(LAST_UPDATE_DATE,'mm/dd/yyyy hh:mi:ss AM')||'^~*~^'||','||
        '^~*~^'||EMPLOYEE_ID||'^~*~^'||','||
        '^~*~^'||CUSTOMER_ID||'^~*~^'||','||
        '^~*~^'||SUPPLIER_ID||'^~*~^'||','||
        '^~*~^'||TO_CHAR(SYSDATE, 'MM/DD/YYYY')||'^~*~^'
FROM    FND_USER;

SPOOL OFF
SET TERMOUT ON

SPOOL &&OUTPUT_PATH_ROOT.export_log_06.txt

PROMPT
REM    *** FND_LOGINS
PROMPT ======================================================================

SET HEADING OFF
SELECT 'FND_LOGINS: Exporting '||COUNT(*)||' rows' FROM FND_LOGINS WHERE start_time BETWEEN TRUNC(ADD_MONTHS(SYSDATE,-6),'mm') AND SYSDATE
AND (terminal_id != 'Concurrent' OR terminal_id IS NULL);

SPOOL OFF

SPOOL &&OUTPUT_PATH_ROOT.FND_LOGINS.csv

SET TERMOUT OFF
SET HEADING ON

SELECT  CHR(35)||'^~*~^'||LOGIN_ID||'^~*~^'||','||
        '^~*~^'||USER_ID||'^~*~^'||','||
        '^~*~^'||TO_CHAR(START_TIME, 'MM/DD/YYYY HH:MI:SS AM')||'^~*~^'||','||
        '^~*~^'||TO_CHAR(END_TIME, 'MM/DD/YYYY HH:MI:SS AM')||'^~*~^'||','||
        '^~*~^'||TO_CHAR(SYSDATE, 'MM/DD/YYYY HH24:MI')||'^~*~^'
FROM    FND_LOGINS
WHERE   START_TIME BETWEEN TRUNC(ADD_MONTHS(SYSDATE,-6),'mm') AND SYSDATE
AND     (terminal_id != 'Concurrent' OR terminal_id IS NULL);

SPOOL OFF
SET TERMOUT ON

SPOOL &&OUTPUT_PATH_ROOT.export_log_07.txt

PROMPT
REM    *** FND_LOGIN_RESPONSIBILITIES
PROMPT ======================================================================

SET HEADING OFF
SELECT 'FND_LOGIN_RESPONSIBILITIES: Exporting '||COUNT(*)||' rows' FROM FND_LOGIN_RESPONSIBILITIES;

SPOOL OFF

SPOOL &&OUTPUT_PATH_ROOT.FND_LOGIN_RESPONSIBILITIES.csv

SET TERMOUT OFF
SET HEADING ON

SELECT  CHR(35)||'^~*~^'||LOGIN_ID||'^~*~^'||','||
        '^~*~^'||LOGIN_RESP_ID||'^~*~^'||','||
        '^~*~^'||RESP_APPL_ID||'^~*~^'||','||
        '^~*~^'||RESPONSIBILITY_ID||'^~*~^'||','||
        '^~*~^'||TO_CHAR(START_TIME,'mm/dd/yyyy hh:mi:ss AM')||'^~*~^'||','||
        '^~*~^'||TO_CHAR(END_TIME,'mm/dd/yyyy hh:mi:ss AM')||'^~*~^'||','||
        '^~*~^'||TO_CHAR(SYSDATE, 'MM/DD/YYYY HH24:MI')||'^~*~^'
FROM    FND_LOGIN_RESPONSIBILITIES
WHERE   START_TIME BETWEEN TRUNC(ADD_MONTHS(SYSDATE,-6),'MM') AND SYSDATE;

SPOOL OFF
SET TERMOUT ON

SPOOL &&OUTPUT_PATH_ROOT.export_log_08.txt

PROMPT
REM    *** WF_LOCAL_USER_ROLES
PROMPT ======================================================================

SET HEADING OFF
SELECT 'WF_LOCAL_USER_ROLES: Exporting '||COUNT(*)||' rows' FROM WF_LOCAL_USER_ROLES WHERE ROLE_ORIG_SYSTEM = 'FND_RESP';

SPOOL OFF

SPOOL &&OUTPUT_PATH_ROOT.WF_LOCAL_USER_ROLES.csv

SET TERMOUT OFF
SET HEADING ON

SELECT  CHR(35)||'^~*~^'||ROLE_NAME||'^~*~^'||','||
        '^~*~^'||USER_NAME||'^~*~^'||','||
        '^~*~^'||USER_ORIG_SYSTEM||'^~*~^'||','||
        '^~*~^'||USER_ORIG_SYSTEM_ID||'^~*~^'||','||
        '^~*~^'||ROLE_ORIG_SYSTEM||'^~*~^'||','||
        '^~*~^'||ROLE_ORIG_SYSTEM_ID||'^~*~^'||','||
        '^~*~^'||TO_CHAR(START_DATE, 'MM/DD/YYYY')||'^~*~^'||','||
        '^~*~^'||TO_CHAR(EXPIRATION_DATE, 'MM/DD/YYYY')||'^~*~^'||','||
        '^~*~^'||SECURITY_GROUP_ID||'^~*~^'||','||
        '^~*~^'||PARTITION_ID||'^~*~^'||','||
        '^~*~^'||ASSIGNMENT_TYPE||'^~*~^'||','||
        '^~*~^'||CREATED_BY||'^~*~^'||','||
        '^~*~^'||TO_CHAR(CREATION_DATE,'mm/dd/yyyy hh:mi:ss AM')||'^~*~^'||','||
        '^~*~^'||LAST_UPDATED_BY||'^~*~^'||',' ||
        '^~*~^'||TO_CHAR(LAST_UPDATE_DATE,'mm/dd/yyyy hh:mi:ss AM')||'^~*~^'||','||
        '^~*~^'||LAST_UPDATE_LOGIN||'^~*~^'||','||
        '^~*~^'||OWNER_TAG||'^~*~^'||','||
        '^~*~^'||PARENT_ORIG_SYSTEM||'^~*~^'||','||
        '^~*~^'||PARENT_ORIG_SYSTEM_ID||'^~*~^'||','||
        '^~*~^'||TO_CHAR(ROLE_END_DATE, 'MM/DD/YYYY')||'^~*~^'||','||
        '^~*~^'||TO_CHAR(ROLE_START_DATE, 'MM/DD/YYYY')||'^~*~^'||','||
        '^~*~^'||TO_CHAR(USER_END_DATE, 'MM/DD/YYYY')||'^~*~^'||','||
        '^~*~^'||TO_CHAR(USER_START_DATE, 'MM/DD/YYYY')||'^~*~^'|| ','||
        '^~*~^'||TO_CHAR(EFFECTIVE_START_DATE, 'MM/DD/YYYY')||'^~*~^'||','||
        '^~*~^'||TO_CHAR(EFFECTIVE_END_DATE, 'MM/DD/YYYY')||'^~*~^'||','||
        '^~*~^'||TO_CHAR(SYSDATE, 'MM/DD/YYYY HH24:MI')||'^~*~^'
FROM    WF_LOCAL_USER_ROLES
WHERE   ROLE_ORIG_SYSTEM = 'FND_RESP';

SPOOL OFF
SET TERMOUT ON

SPOOL &&OUTPUT_PATH_ROOT.export_log_09.txt

PROMPT
REM    *** WF_USER_ROLE_ASSIGNMENTS
PROMPT ======================================================================

SET HEADING OFF
SELECT 'WF_USER_ROLE_ASSIGNMENTS: Exporting '||COUNT(*)||' rows' FROM WF_USER_ROLE_ASSIGNMENTS WHERE ROLE_NAME LIKE 'FND_RESP|%';

SPOOL OFF

SPOOL &&OUTPUT_PATH_ROOT.WF_USER_ROLE_ASSIGNMENTS.csv

SET TERMOUT OFF
SET HEADING ON

SELECT  CHR(35)||'^~*~^'||ROLE_NAME||'^~*~^'||','||
        '^~*~^'||USER_NAME||'^~*~^'||','||
        '^~*~^'||RELATIONSHIP_ID||'^~*~^'||','||
        '^~*~^'||ASSIGNING_ROLE||'^~*~^'||','||
        '^~*~^'||TO_CHAR(START_DATE, 'MM/DD/YYYY')||'^~*~^'||','||
        '^~*~^'||TO_CHAR(END_DATE, 'MM/DD/YYYY')||'^~*~^'||','||
        '^~*~^'||CREATED_BY||'^~*~^'||','||
        '^~*~^'||TO_CHAR(CREATION_DATE, 'MM/DD/YYYY')||'^~*~^'||','||
        '^~*~^'||LAST_UPDATED_BY||'^~*~^'||','||
        '^~*~^'||TO_CHAR(LAST_UPDATE_DATE, 'MM/DD/YYYY')||'^~*~^'||','||
        '^~*~^'||LAST_UPDATE_LOGIN||'^~*~^'||','||
        '^~*~^'||TO_CHAR(USER_START_DATE, 'MM/DD/YYYY')||'^~*~^'||','||
        '^~*~^'||TO_CHAR(ROLE_START_DATE, 'MM/DD/YYYY')||'^~*~^'||','||
        '^~*~^'||TO_CHAR(ASSIGNING_ROLE_START_DATE, 'MM/DD/YYYY') ||'^~*~^'||','||
        '^~*~^'||TO_CHAR(USER_END_DATE, 'MM/DD/YYYY')||'^~*~^'||','||
        '^~*~^'||TO_CHAR(ROLE_END_DATE, 'MM/DD/YYYY')||'^~*~^'||','||
        '^~*~^'||TO_CHAR(ASSIGNING_ROLE_END_DATE, 'MM/DD/YYYY')||'^~*~^'||','||
        '^~*~^'||PARTITION_ID||'^~*~^'||','||
        '^~*~^'||TO_CHAR(EFFECTIVE_START_DATE, 'MM/DD/YYYY')||'^~*~^'||','||
        '^~*~^'||TO_CHAR(EFFECTIVE_END_DATE, 'MM/DD/YYYY')||'^~*~^'||','||
        '^~*~^'||TO_CHAR(SYSDATE, 'MM/DD/YYYY HH24:MI')||'^~*~^'
FROM    WF_USER_ROLE_ASSIGNMENTS
WHERE   ROLE_NAME LIKE 'FND_RESP|%';

SPOOL OFF
SET TERMOUT ON

SPOOL &&OUTPUT_PATH_ROOT.export_log_10.txt

PROMPT
REM    *** FND_PRODUCT_INSTALLATIONS
PROMPT ======================================================================

SET HEADING OFF
SELECT 'FND_PRODUCT_INSTALLATIONS: Exporting '||COUNT(*)||' rows' FROM FND_PRODUCT_INSTALLATIONS;

SPOOL OFF

SPOOL &&OUTPUT_PATH_ROOT.FND_PRODUCT_INSTALLATIONS.csv

SET TERMOUT OFF
SET HEADING ON

SELECT  CHR(35)||'^~*~^'||APPLICATION_ID||'^~*~^'||','||
        '^~*~^'||PRODUCT_VERSION||'^~*~^'||','||
        '^~*~^'||STATUS||'^~*~^'||','||
        '^~*~^'||PATCH_LEVEL||'^~*~^'||','||
        '^~*~^'||TO_CHAR(CREATION_DATE,'mm/dd/yyyy hh:mi:ss AM')||'^~*~^'||','||
        '^~*~^'||TO_CHAR(LAST_UPDATE_DATE,'mm/dd/yyyy hh:mi:ss AM')||'^~*~^'||','||
        '^~*~^'||TO_CHAR(SYSDATE, 'MM/DD/YYYY HH24:MI')||'^~*~^'
FROM    FND_PRODUCT_INSTALLATIONS;

SPOOL OFF
SET TERMOUT ON

SPOOL &&OUTPUT_PATH_ROOT.export_log_11.txt

PROMPT
REM    *** FND_SECURITY_GROUPS
PROMPT ======================================================================

SET HEADING OFF
SELECT 'FND_SECURITY_GROUPS: Exporting '||COUNT(*)||' rows' FROM FND_SECURITY_GROUPS;

SPOOL OFF

SPOOL &&OUTPUT_PATH_ROOT.FND_SECURITY_GROUPS.csv

SET TERMOUT OFF
SET HEADING ON

SELECT  CHR(35)||'^~*~^'||SECURITY_GROUP_ID||'^~*~^'||','||
        '^~*~^'||SECURITY_GROUP_KEY||'^~*~^'||','||
        '^~*~^'||CREATED_BY||'^~*~^'||','||
        '^~*~^'||TO_CHAR(CREATION_DATE, 'MM/DD/YYYY HH24:MI')||'^~*~^'||','||
        '^~*~^'||LAST_UPDATED_BY||'^~*~^'||','||
        '^~*~^'||TO_CHAR(LAST_UPDATE_DATE, 'MM/DD/YYYY HH24:MI')||'^~*~^'||','||
        '^~*~^'||LAST_UPDATE_LOGIN||'^~*~^'||','||
        '^~*~^'||TO_CHAR(SYSDATE, 'MM/DD/YYYY HH24:MI')||'^~*~^'
FROM    FND_SECURITY_GROUPS;

SPOOL OFF
SET TERMOUT ON

SPOOL &&OUTPUT_PATH_ROOT.export_log_12.txt

PROMPT
REM    *** FND_FORM_FUNCTIONS
PROMPT ======================================================================

SET HEADING OFF
SELECT 'FND_FORM_FUNCTIONS: Exporting '||COUNT(*)||' rows' FROM FND_FORM_FUNCTIONS;

SPOOL OFF

SPOOL &&OUTPUT_PATH_ROOT.FND_FORM_FUNCTIONS.csv

SET TERMOUT OFF
SET HEADING ON

SELECT  CHR(35)||'^~*~^'||FUNCTION_ID||'^~*~^'||','||
		'^~*~^'||FUNCTION_NAME||'^~*~^'|| ',' ||
        '^~*~^'||REPLACE(REPLACE(TYPE, CHR(10)), CHR(13))||'^~*~^'|| ',' ||
        '^~*~^'||REPLACE(REPLACE(PARAMETERS, CHR(10)), CHR(13))||'^~*~^'||','||
        '^~*~^'||TO_CHAR(CREATION_DATE,'mm/dd/yyyy hh:mi:ss AM')||'^~*~^'||','||
        '^~*~^'||TO_CHAR(LAST_UPDATE_DATE,'mm/dd/yyyy hh:mi:ss AM')||'^~*~^'||','||
        '^~*~^'||TO_CHAR(SYSDATE, 'MM/DD/YYYY HH24:MI')||'^~*~^'
FROM    FND_FORM_FUNCTIONS;

SPOOL OFF
SET TERMOUT ON

SPOOL &&OUTPUT_PATH_ROOT.export_log_13.txt

PROMPT
REM    *** FND_FORM_FUNCTIONS_TL
PROMPT ======================================================================

SET HEADING OFF
SELECT 'FND_FORM_FUNCTIONS_TL: Exporting '||COUNT(*)||' rows' FROM FND_FORM_FUNCTIONS_TL;

SPOOL OFF

SPOOL &&OUTPUT_PATH_ROOT.FND_FORM_FUNCTIONS_TL.csv

SET TERMOUT OFF
SET HEADING ON

SELECT  CHR(35)||'^~*~^'||LANGUAGE||'^~*~^'||','||
        '^~*~^'||FUNCTION_ID||'^~*~^'||','||
        '^~*~^'||REPLACE(REPLACE(user_function_name,CHR(10),''),CHR(13),'')||'^~*~^'||','||
        '^~*~^'||TO_CHAR(CREATION_DATE,'mm/dd/yyyy hh:mi:ss AM')||'^~*~^'||','||
        '^~*~^'||CREATED_BY||'^~*~^'||','||
        '^~*~^'||TO_CHAR(LAST_UPDATE_DATE,'mm/dd/yyyy hh:mi:ss AM')||'^~*~^'||','||
        '^~*~^'||LAST_UPDATED_BY||'^~*~^'||','||
        '^~*~^'||LAST_UPDATE_LOGIN||'^~*~^'||','||
        '^~*~^'||REPLACE(REPLACE(DESCRIPTION,CHR(10),''),CHR(13),'')||'^~*~^'||','||
        '^~*~^'||SOURCE_LANG||'^~*~^'||','||
        '^~*~^'||TO_CHAR(SYSDATE, 'MM/DD/YYYY HH24:MI')||'^~*~^'
FROM    FND_FORM_FUNCTIONS_TL;

SPOOL OFF
SET TERMOUT ON

SPOOL &&OUTPUT_PATH_ROOT.export_log_14.txt

PROMPT
REM    *** FND_MENU_ENTRIES
PROMPT ======================================================================

SET HEADING OFF
SELECT 'FND_MENU_ENTRIES: Exporting '||COUNT(*)||' rows' FROM FND_MENU_ENTRIES;

SPOOL OFF

SPOOL &&OUTPUT_PATH_ROOT.FND_MENU_ENTRIES.csv

SET TERMOUT OFF
SET HEADING ON

SELECT  CHR(35)||'^~*~^'||MENU_ID||'^~*~^'||','||
        '^~*~^'||ENTRY_SEQUENCE||'^~*~^'||','||
        '^~*~^'||SUB_MENU_ID||'^~*~^'||','||
        '^~*~^'||FUNCTION_ID||'^~*~^'||','||
        '^~*~^'||TO_CHAR(CREATION_DATE,'mm/dd/yyyy hh:mi:ss AM')||'^~*~^'||','||
        '^~*~^'||TO_CHAR(LAST_UPDATE_DATE,'mm/dd/yyyy hh:mi:ss AM')||'^~*~^'||','||
        '^~*~^'||TO_CHAR(SYSDATE, 'MM/DD/YYYY HH24:MI')||'^~*~^'
FROM    FND_MENU_ENTRIES;

SPOOL OFF
SET TERMOUT ON

SPOOL &&OUTPUT_PATH_ROOT.export_log_15.txt

PROMPT
REM    *** FND_MENU_ENTRIES_TL
PROMPT ======================================================================

SET HEADING OFF
SELECT 'FND_MENU_ENTRIES_TL: Exporting '||COUNT(*)||' rows' FROM FND_MENU_ENTRIES_TL;

SPOOL OFF

SPOOL &&OUTPUT_PATH_ROOT.FND_MENU_ENTRIES_TL.csv

SET TERMOUT OFF
SET HEADING ON

SELECT  CHR(35)||'^~*~^'||MENU_ID||'^~*~^'||','||
        '^~*~^'||ENTRY_SEQUENCE||'^~*~^'||','||
        '^~*~^'||REPLACE(REPLACE(PROMPT, CHR(10)), CHR(13))||'^~*~^'||','||
        '^~*~^'||REPLACE(REPLACE(DESCRIPTION, CHR(10)), CHR(13))||'^~*~^'||','||
        '^~*~^'||TO_CHAR(CREATION_DATE,'mm/dd/yyyy hh:mi:ss AM')||'^~*~^'||','||
        '^~*~^'||TO_CHAR(LAST_UPDATE_DATE,'mm/dd/yyyy hh:mi:ss AM')||'^~*~^'||','||
        '^~*~^'||TO_CHAR(SYSDATE, 'MM/DD/YYYY HH24:MI')||'^~*~^'
FROM    FND_MENU_ENTRIES_TL;

SPOOL OFF
SET TERMOUT ON

SPOOL &&OUTPUT_PATH_ROOT.export_log_16.txt

PROMPT
REM    *** FND_MENUS
PROMPT ======================================================================

SET HEADING OFF
SELECT 'FND_MENUS: Exporting '||COUNT(*)||' rows' FROM FND_MENUS;

SPOOL OFF

SPOOL &&OUTPUT_PATH_ROOT.FND_MENUS.csv

SET TERMOUT OFF
SET HEADING ON

SELECT  CHR(35)||'^~*~^'||MENU_ID||'^~*~^'||','||
        '^~*~^'||MENU_NAME||'^~*~^'||','||
        '^~*~^'||TO_CHAR(LAST_UPDATE_DATE,'mm/dd/yyyy hh:mi:ss AM')||'^~*~^'||','||
        '^~*~^'||LAST_UPDATED_BY||'^~*~^'||','||
        '^~*~^'||LAST_UPDATE_LOGIN||'^~*~^'||','||
        '^~*~^'||TO_CHAR(CREATION_DATE,'mm/dd/yyyy hh:mi:ss AM')||'^~*~^'||','||
        '^~*~^'||CREATED_BY||'^~*~^'||','||
        '^~*~^'||TYPE||'^~*~^'||','||
        '^~*~^'||TO_CHAR(SYSDATE, 'MM/DD/YYYY HH24:MI')||'^~*~^'
FROM    FND_MENUS t;

SPOOL OFF
SET TERMOUT ON

SPOOL &&OUTPUT_PATH_ROOT.export_log_17.txt

PROMPT
REM    *** FND_MENUS_TL
PROMPT ======================================================================

SET HEADING OFF
SELECT 'FND_MENUS_TL: Exporting '||COUNT(*)||' rows' FROM FND_MENUS_TL;

SPOOL OFF

SPOOL &&OUTPUT_PATH_ROOT.FND_MENUS_TL.csv

SET TERMOUT OFF
SET HEADING ON

SELECT  CHR(35)||'^~*~^'||LANGUAGE||'^~*~^'||','||
        '^~*~^'||MENU_ID||'^~*~^'||','||
        '^~*~^'||REPLACE(REPLACE(USER_MENU_NAME,CHR(10),''),CHR(13),'')||'^~*~^'||','||
        '^~*~^'||TO_CHAR(LAST_UPDATE_DATE,'mm/dd/yyyy hh:mi:ss AM')||'^~*~^'||','||
        '^~*~^'||LAST_UPDATED_BY||'^~*~^'||','||
        '^~*~^'||LAST_UPDATE_LOGIN||'^~*~^'||','||
        '^~*~^'||TO_CHAR(CREATION_DATE,'mm/dd/yyyy hh:mi:ss AM')||'^~*~^'||','||
        '^~*~^'||CREATED_BY||'^~*~^'||','||
        '^~*~^'||REPLACE(REPLACE(DESCRIPTION,CHR(10),''),CHR(13),'')||'^~*~^'||','||
        '^~*~^'||SOURCE_LANG||'^~*~^'||','||
        '^~*~^'||TO_CHAR(SYSDATE, 'MM/DD/YYYY HH24:MI')||'^~*~^'
FROM    FND_MENUS_TL;

SPOOL OFF
SET TERMOUT ON

SPOOL &&OUTPUT_PATH_ROOT.export_log_18.txt

PROMPT
REM    *** ICX_SESSIONS
PROMPT ======================================================================

SET HEADING OFF
SELECT 'ICX_SESSIONS: Exporting '||COUNT(*)||' rows' FROM ICX_SESSIONS WHERE creation_date>=SYSDATE-365;

SPOOL OFF

SPOOL &&OUTPUT_PATH_ROOT.ICX_SESSIONS.csv

SET TERMOUT OFF
SET HEADING ON

SELECT  CHR(35)||'^~*~^'||SESSION_ID||'^~*~^'||','||
        '^~*~^'||USER_ID||'^~*~^'||','||
        '^~*~^'||RESPONSIBILITY_ID||'^~*~^'||','||
        '^~*~^'||TO_CHAR(FIRST_CONNECT,'MM/DD/YYYY HH24:MI:SS')||'^~*~^'||','||
        '^~*~^'||TO_CHAR(LAST_CONNECT,'MM/DD/YYYY HH24:MI:SS')||'^~*~^'||','||
        '^~*~^'||DISABLED_FLAG||'^~*~^'||','||
        '^~*~^'||RESPONSIBILITY_APPLICATION_ID||'^~*~^'||','||
        '^~*~^'||LOGIN_ID||'^~*~^'||','||
        '^~*~^'||TO_CHAR(CREATION_DATE,'mm/dd/yyyy hh:mi:ss AM')||'^~*~^'||','||
        '^~*~^'||TO_CHAR(LAST_UPDATE_DATE,'mm/dd/yyyy hh:mi:ss AM')||'^~*~^'||','||
        '^~*~^'||TO_CHAR(SYSDATE, 'MM/DD/YYYY HH24:MI')||'^~*~^'
FROM    ICX_SESSIONS
WHERE   creation_date>=SYSDATE-365;

SPOOL OFF
SET TERMOUT ON

SPOOL &&OUTPUT_PATH_ROOT.export_log_19.txt

PROMPT
REM    *** FND_USER_RESPONSIBILITY
PROMPT ======================================================================

SET HEADING OFF
SELECT 'FND_USER_RESPONSIBILITY: Exporting '||COUNT(*)||' rows' FROM FND_USER_RESPONSIBILITY;

SPOOL OFF

SPOOL &&OUTPUT_PATH_ROOT.FND_USER_RESPONSIBILITY.csv

SET TERMOUT OFF
SET HEADING ON

SELECT  CHR(35)||'^~*~^'||USER_ID||'^~*~^'||','||
        '^~*~^'||APPLICATION_ID||'^~*~^'||','||
        '^~*~^'||RESPONSIBILITY_ID||'^~*~^'||','||
        '^~*~^'||TO_CHAR(START_DATE, 'MM/DD/YYYY')||'^~*~^'||','||
        '^~*~^'||TO_CHAR(END_DATE, 'MM/DD/YYYY')||'^~*~^'||','||
        '^~*~^'||TO_CHAR(CREATION_DATE,'mm/dd/yyyy hh:mi:ss AM')||'^~*~^'||','||
        '^~*~^'||TO_CHAR(LAST_UPDATE_DATE,'mm/dd/yyyy hh:mi:ss AM')||'^~*~^'||','||
        '^~*~^'||TO_CHAR(SYSDATE, 'MM/DD/YYYY HH24:MI')||'^~*~^'
FROM    FND_USER_RESPONSIBILITY;

SPOOL OFF
SET TERMOUT ON

SPOOL &&OUTPUT_PATH_ROOT.export_log_20.txt

PROMPT
REM    *** FND_USER_RESP_GROUPS_ALL
PROMPT ======================================================================

SET HEADING OFF
SELECT 'FND_USER_RESP_GROUPS_ALL: Exporting '||COUNT(*)||' rows' FROM FND_USER_RESP_GROUPS_ALL;

SPOOL OFF

SPOOL &&OUTPUT_PATH_ROOT.FND_USER_RESP_GROUPS_ALL.csv

SET TERMOUT OFF
SET HEADING ON

SELECT  CHR(35)||'^~*~^'||USER_ID||'^~*~^'||','||
        '^~*~^'||RESPONSIBILITY_ID||'^~*~^'||','||
        '^~*~^'||RESPONSIBILITY_APPLICATION_ID||'^~*~^'||','||
        '^~*~^'||SECURITY_GROUP_ID||'^~*~^'||','||
        '^~*~^'||TO_CHAR(START_DATE, 'MM/DD/YYYY')||'^~*~^'||','||
        '^~*~^'||TO_CHAR(END_DATE, 'MM/DD/YYYY')||'^~*~^'||','||
        '^~*~^'||CREATED_BY||'^~*~^'||','||
        '^~*~^'||TO_CHAR(CREATION_DATE, 'MM/DD/YYYY HH24:MI:SS')||'^~*~^'||','||
        '^~*~^'||LAST_UPDATED_BY||'^~*~^'||','||
        '^~*~^'||TO_CHAR(LAST_UPDATE_DATE, 'MM/DD/YYYY HH24:MI:SS')||'^~*~^'||','||
        '^~*~^'||LAST_UPDATE_LOGIN||'^~*~^'||','||
        '^~*~^'||TO_CHAR(SYSDATE, 'MM/DD/YYYY HH24:MI')||'^~*~^'
FROM    FND_USER_RESP_GROUPS_ALL;

SPOOL OFF
SET TERMOUT ON

SPOOL &&OUTPUT_PATH_ROOT.export_log_21.txt

PROMPT
REM    *** FND_USER_RESP_GROUPS
PROMPT ======================================================================

SET HEADING OFF
SELECT 'FND_USER_RESP_GROUPS: Exporting '||COUNT(*)||' rows' FROM FND_USER_RESP_GROUPS;

SPOOL OFF

SPOOL &&OUTPUT_PATH_ROOT.FND_USER_RESP_GROUPS.csv

SET TERMOUT OFF
SET HEADING ON

SELECT  CHR(35)||'^~*~^'||USER_ID||'^~*~^'||','||
        '^~*~^'||RESPONSIBILITY_ID||'^~*~^'||','||
        '^~*~^'||RESPONSIBILITY_APPLICATION_ID||'^~*~^'||','||
        '^~*~^'||TO_CHAR(START_DATE, 'MM/DD/YYYY')||'^~*~^'||','||
        '^~*~^'||TO_CHAR(END_DATE, 'MM/DD/YYYY')||'^~*~^'||','||
        '^~*~^'||REPLACE(REPLACE(DESCRIPTION, CHR(10)), CHR(13))||'^~*~^'||','||
        '^~*~^'||TO_CHAR(CREATION_DATE,'mm/dd/yyyy hh:mi:ss AM')||'^~*~^'||','||
        '^~*~^'||TO_CHAR(LAST_UPDATE_DATE,'mm/dd/yyyy hh:mi:ss AM')||'^~*~^'||','||
        '^~*~^'||TO_CHAR(SYSDATE, 'MM/DD/YYYY HH24:MI')||'^~*~^'
FROM    FND_USER_RESP_GROUPS;

SPOOL OFF
SET TERMOUT ON

SPOOL &&OUTPUT_PATH_ROOT.export_log_22.txt

PROMPT
REM    *** FND_RESP_FUNCTIONS
PROMPT ======================================================================

SET HEADING OFF
SELECT 'FND_RESP_FUNCTIONS: Exporting '||COUNT(*)||' rows' FROM FND_RESP_FUNCTIONS;

SPOOL OFF

SPOOL &&OUTPUT_PATH_ROOT.FND_RESP_FUNCTIONS.csv

SET TERMOUT OFF
SET HEADING ON

SELECT  CHR(35)||'^~*~^'||ACTION_ID||'^~*~^'||','||
        '^~*~^'||RESPONSIBILITY_ID||'^~*~^'||','||
        '^~*~^'||APPLICATION_ID||'^~*~^'||','||
        '^~*~^'||RULE_TYPE||'^~*~^'||','||
        '^~*~^'||TO_CHAR(CREATION_DATE,'mm/dd/yyyy hh:mi:ss AM')||'^~*~^'||','||
        '^~*~^'||TO_CHAR(LAST_UPDATE_DATE,'mm/dd/yyyy hh:mi:ss AM')||'^~*~^'||','||
        '^~*~^'||TO_CHAR(SYSDATE, 'MM/DD/YYYY HH24:MI')||'^~*~^'
FROM    FND_RESP_FUNCTIONS;

SPOOL OFF

define min_header=0
define max_header=0
define max_line=0
define max_date=sysdate

col max_date new_val max_date
SELECT max(creation_date) max_date FROM oe_order_headers_all;

col max_header new_val max_header
SELECT max(header_id) max_header FROM oe_order_headers_all;

col min_header new_val min_header
SELECT NVL(MIN(header_id),&max_header+1) min_header FROM oe_order_headers_all
WHERE creation_date>=(to_date('&max_date')-730);

col max_line new_val max_line
SELECT NVL(MAX(line_id),&max_line+1) max_line FROM oe_order_lines_all;

SET TERMOUT ON

SPOOL &&OUTPUT_PATH_ROOT.export_log_23.txt

PROMPT
REM    *** OE_ORDER_LINES_ALL
PROMPT ======================================================================

SET HEADING OFF

SELECT 'OE_ORDER_LINES_ALL: '||DECODE(COUNT(*),0,'No rows to export','Exporting '||COUNT(*)|| ' rows') FROM OE_ORDER_LINES_ALL WHERE header_id>=&min_header AND line_id<=&max_line;


SET TERMOUT OFF

SPOOL OFF

SPOOL &&OUTPUT_PATH_ROOT.OE_ORDER_LINES_ALL.csv

SET HEADING ON

SELECT  CHR(35)||'^~*~^'||LINE_ID||'^~*~^'||','||
        '^~*~^'||ORG_ID||'^~*~^'||','||
        '^~*~^'||HEADER_ID||'^~*~^'||','||
        '^~*~^'||LINE_TYPE_ID||'^~*~^'||','||
        '^~*~^'||LINE_NUMBER||'^~*~^'||','||
        '^~*~^'||PRICING_QUANTITY||'^~*~^'||','||
        '^~*~^'||SHIPPED_QUANTITY||'^~*~^'||','||
        '^~*~^'||ORDERED_QUANTITY||'^~*~^'||','||
        '^~*~^'||FULFILLED_QUANTITY||'^~*~^'||','||
        '^~*~^'||SHIPPING_QUANTITY||'^~*~^'||','||
        '^~*~^'||SHIP_FROM_ORG_ID||'^~*~^'||','||
        '^~*~^'||SHIP_TO_ORG_ID||'^~*~^'||','||
        '^~*~^'||SOLD_FROM_ORG_ID||'^~*~^'||','||
        '^~*~^'||SOLD_TO_ORG_ID||'^~*~^'||','||
        '^~*~^'||CUST_PO_NUMBER||'^~*~^'||','||
        '^~*~^'||SHIPMENT_NUMBER||'^~*~^'||','||
        '^~*~^'||ORIG_SYS_LINE_REF||'^~*~^'||','||
        '^~*~^'||SOURCE_DOCUMENT_LINE_ID||'^~*~^'||','||
        '^~*~^'||REFERENCE_LINE_ID||'^~*~^'||','||
        '^~*~^'||REFERENCE_TYPE||'^~*~^'||','||
        '^~*~^'||REFERENCE_HEADER_ID||'^~*~^'||','||
        '^~*~^'||LINK_TO_LINE_ID||'^~*~^'||','||
        '^~*~^'||ITEM_TYPE_CODE||'^~*~^'||','||
        '^~*~^'||LINE_CATEGORY_CODE||'^~*~^'||','||
        '^~*~^'||SOURCE_TYPE_CODE||'^~*~^'||','||
        '^~*~^'||SPLIT_FROM_LINE_ID||'^~*~^'||','||
        '^~*~^'||ORDER_SOURCE_ID||'^~*~^'||','||
        '^~*~^'||ORIG_SYS_DOCUMENT_REF||'^~*~^'||','||
        '^~*~^'||CALCULATE_PRICE_FLAG||'^~*~^'||','||
        '^~*~^'||DROP_SHIP_FLAG||'^~*~^'||','||
        '^~*~^'||SPLIT_BY||'^~*~^'||','||
        '^~*~^'||LINE_SET_ID||'^~*~^'||','||
        '^~*~^'||TO_CHAR(CREATION_DATE,'mm/dd/yyyy hh:mi:ss AM')||'^~*~^'||','||
        '^~*~^'||TO_CHAR(LAST_UPDATE_DATE,'mm/dd/yyyy hh:mi:ss AM')||'^~*~^'||','||
        '^~*~^'||TO_CHAR(SYSDATE, 'MM/DD/YYYY HH24:MI')||'^~*~^'
FROM    OE_ORDER_LINES_ALL
WHERE   header_id>=&min_header
AND     line_id<=&max_line;


SPOOL OFF
SET TERMOUT ON

SPOOL &&OUTPUT_PATH_ROOT.export_log_24.txt

PROMPT
REM    *** OE_ORDER_SOURCES
PROMPT ======================================================================

SET HEADING OFF
SELECT 'OE_ORDER_SOURCES: Exporting '||COUNT(*)||' rows' FROM OE_ORDER_SOURCES;

SPOOL OFF

SPOOL &&OUTPUT_PATH_ROOT.OE_ORDER_SOURCES.csv

SET TERMOUT OFF
SET HEADING ON

SELECT  CHR(35)||'^~*~^'||ORDER_SOURCE_ID||'^~*~^'||','||
        '^~*~^'||REPLACE(REPLACE(NAME,CHR(10),''),CHR(13),'')||'^~*~^'||','||
        '^~*~^'||REPLACE(REPLACE(DESCRIPTION,CHR(10),''),CHR(13),'')||'^~*~^'||','||
        '^~*~^'||ENABLED_FLAG||'^~*~^'||','||
        '^~*~^'||TO_CHAR(CREATION_DATE,'mm/dd/yyyy hh:mi:ss AM')||'^~*~^'||','||
        '^~*~^'||TO_CHAR(LAST_UPDATE_DATE,'mm/dd/yyyy hh:mi:ss AM')||'^~*~^'||','||
        '^~*~^'||TO_CHAR(SYSDATE, 'MM/DD/YYYY HH24:MI')||'^~*~^'
FROM    OE_ORDER_SOURCES;


SPOOL OFF
SET TERMOUT ON

SPOOL &&OUTPUT_PATH_ROOT.export_log_25.txt

PROMPT
REM    *** OE_ORDER_HEADERS_ALL
PROMPT ======================================================================

SET HEADING OFF

SELECT 'OE_ORDER_HEADERS_ALL: '||DECODE(COUNT(*),0,'No rows to export','Exporting '||COUNT(*)|| ' rows') FROM OE_ORDER_HEADERS_ALL WHERE header_id>=&min_header;


SPOOL OFF

SPOOL &&OUTPUT_PATH_ROOT.OE_ORDER_HEADERS_ALL.csv

SET TERMOUT OFF
SET HEADING ON

SELECT  CHR(35)||'^~*~^'||HEADER_ID||'^~*~^'||','||
        '^~*~^'||ORG_ID||'^~*~^'||','||
        '^~*~^'||ORDER_TYPE_ID||'^~*~^'||','||
        '^~*~^'||ORDER_NUMBER||'^~*~^'||','||
        '^~*~^'||ORDER_SOURCE_ID||'^~*~^'||','||
        '^~*~^'||SOURCE_DOCUMENT_TYPE_ID||'^~*~^'||','||
        '^~*~^'||ORIG_SYS_DOCUMENT_REF||'^~*~^'||','||
        '^~*~^'||SOURCE_DOCUMENT_ID||'^~*~^'||','||
        '^~*~^'||PARTIAL_SHIPMENTS_ALLOWED||'^~*~^'||','||
        '^~*~^'||CUST_PO_NUMBER||'^~*~^'||','||
        '^~*~^'||SOLD_FROM_ORG_ID||'^~*~^'||','||
        '^~*~^'||SOLD_TO_ORG_ID||'^~*~^'||','||
        '^~*~^'||SHIP_FROM_ORG_ID||'^~*~^'||','||
        '^~*~^'||SHIP_TO_ORG_ID||'^~*~^'||','||
        '^~*~^'||INVOICE_TO_ORG_ID||'^~*~^'||','||
        '^~*~^'||DELIVER_TO_ORG_ID||'^~*~^'||','||
        '^~*~^'||ORDER_CATEGORY_CODE||'^~*~^'||','||
        '^~*~^'||DROP_SHIP_FLAG||'^~*~^'||','||
        '^~*~^'||TO_CHAR(CREATION_DATE,'mm/dd/yyyy hh:mi:ss AM')||'^~*~^'||','||
        '^~*~^'||TO_CHAR(LAST_UPDATE_DATE,'mm/dd/yyyy hh:mi:ss AM')||'^~*~^'||','||
        '^~*~^'||TO_CHAR(SYSDATE, 'MM/DD/YYYY HH24:MI')||'^~*~^'
FROM    OE_ORDER_HEADERS_ALL
WHERE   HEADER_ID>=&min_header;

SPOOL OFF
SET TERMOUT ON


/*
SPOOL &&OUTPUT_PATH_ROOT.export_log_26.txt

PROMPT
PROMPT *** FND_LOOKUP_VALUES
PROMPT ======================================================================

SET HEADING OFF
SELECT 'Exporting '||COUNT(*)||' rows' FROM FND_LOOKUP_VALUES;

SPOOL OFF

SPOOL &&OUTPUT_PATH_ROOT.FND_LOOKUP_VALUES.csv

SET TERMOUT OFF
SET HEADING ON

SELECT  CHR(35)||'^~*~^'||LOOKUP_TYPE||'^~*~^'||','||
        '^~*~^'||LANGUAGE||'^~*~^'||','||
        '^~*~^'||LOOKUP_CODE||'^~*~^'||','||
        '^~*~^'||REPLACE(REPLACE(MEANING,CHR(10),''),CHR(13),'')||'^~*~^'||','||
        '^~*~^'||REPLACE(REPLACE(DESCRIPTION,CHR(10),''),CHR(13),'')||'^~*~^'||','||
        '^~*~^'||ENABLED_FLAG||'^~*~^'||','||
        '^~*~^'||START_DATE_ACTIVE||'^~*~^'||','||
        '^~*~^'||END_DATE_ACTIVE||'^~*~^'||','||
        '^~*~^'||TO_CHAR(CREATION_DATE,'mm/dd/yyyy hh:mi:ss AM')||'^~*~^'||','||
        '^~*~^'||SOURCE_LANG||'^~*~^'||','||
        '^~*~^'||SECURITY_GROUP_ID||'^~*~^'||','||
        '^~*~^'||VIEW_APPLICATION_ID||'^~*~^'
FROM    FND_LOOKUP_VALUES;

SPOOL OFF
*/

PROMPT *** Collecting DDL for view FND_USER_RESP_GROUPS_ALL
PROMPT ======================================================================

SET TERMOUT OFF
set heading off;
set echo off;
Set pages 999;
set long 90000;

spool &&OUTPUT_PATH_ROOT.FND_USER_RESP_GROUPS_ALL.ddl

SELECT dbms_metadata.get_ddl('VIEW','FND_USER_RESP_GROUPS_ALL','APPS') FROM dual;

spool off;

SET TERMOUT ON

PROMPT *** Collecting DDL for view FND_USER_RESP_GROUPS
PROMPT ======================================================================

SET TERMOUT OFF
set heading off;
set echo off;
Set pages 999;
set long 90000;

spool &&OUTPUT_PATH_ROOT.FND_USER_RESP_GROUPS.ddl

SELECT dbms_metadata.get_ddl('VIEW','FND_USER_RESP_GROUPS','APPS') FROM dual;

spool off;

SET TERMOUT ON

PROMPT *** Collecting DDL for view FND_USER_RESP_GROUPS_ALL
PROMPT ======================================================================

SET TERMOUT OFF
set heading off;
set echo off;
Set pages 999;
set long 90000;

spool &&OUTPUT_PATH_ROOT.FND_USER_RESP_GROUPS_ALL.ddl

SELECT dbms_metadata.get_ddl('VIEW','FND_USER_RESP_GROUPS_ALL','APPS') FROM dual;

spool off;

SET TERMOUT ON

PROMPT *** Collecting DDL for view WF_ALL_USER_ROLE_ASSIGNMENTS
PROMPT ======================================================================

SET TERMOUT OFF
set heading off;
set echo off;
Set pages 999;
set long 90000;

spool &&OUTPUT_PATH_ROOT.WF_ALL_USER_ROLE_ASSIGNMENTS.ddl

SELECT dbms_metadata.get_ddl('VIEW','WF_ALL_USER_ROLE_ASSIGNMENTS','APPS') FROM dual;

spool off;

SET TERMOUT ON

PROMPT *** Collecting DDL for view WF_USER_ROLE_ASSIGNMENTS_V
PROMPT ======================================================================

SET TERMOUT OFF
set heading off;
set echo off;
Set pages 999;
set long 90000;

spool &&OUTPUT_PATH_ROOT.WF_USER_ROLE_ASSIGNMENTS_V.ddl

SELECT dbms_metadata.get_ddl('VIEW','WF_USER_ROLE_ASSIGNMENTS_V','APPS') FROM dual;

spool off;

SET TERMOUT ON

PROMPT *** Collecting DDL for view WF_USER_ROLES
PROMPT ======================================================================

SET TERMOUT OFF
set heading off;
set echo off;
Set pages 999;
set long 90000;

spool &&OUTPUT_PATH_ROOT.WF_USER_ROLES.ddl

SELECT dbms_metadata.get_ddl('VIEW','WF_USER_ROLES','APPS') FROM dual;

spool off;

SET TERMOUT ON



PROMPT *** USAGE BASED
PROMPT ======================================================================

set pagesize 5000
set linesize 500

set lines 500
set pages 50000
set serveroutput on size 1000000

show user

set time off
set timi off

set termout on
set heading off
set feedback off
set verify off

col ts new_value ts
SELECT TO_CHAR(SYSDATE,'yyyy-mm-dd__hh-mm-ss') as ts FROM dual;

spool &&OUTPUT_PATH_ROOT.lst_usage_based.txt

prompt ================Usage Based Query =====================================
prompt =======================Disclaimer======================================

prompt *** The Usage Based Query is a standard tool and is not customized
prompt to only have certain scripts for a specific review. Therefore, only
prompt script results that are relevant will be considered.
prompt
prompt *** Some version specific scripts will generate an error when ran in
prompt a different version of E-Business Suite. This does not affect the
prompt output and should be ignored.

prompt =======================================================================


COL EBS_version format a15
COL HOST_NAME     format a40 wrap
COL Instance_name format a15

prompt
prompt
prompt ==============
prompt ***E-Business Suite Version

col C0 new_val EBS_version
SELECT release_name C0 FROM apps.fnd_product_groups;

prompt
prompt
prompt ==============
prompt ***Instance name and Host name

-- Get host_name and instance_name
col C1 new_val INSTANCE_NAME
col C2 new_val HOST_NAME
-- Oracle7
SELECT name    C1 FROM v$database;
SELECT MIN(machine) C2 FROM v$session WHERE type = 'BACKGROUND';
-- Oracle8 and higher
SELECT instance_name C1, host_name C2 FROM v$instance;

col C3 new_val GREP_PREFIX noprint
--SELECT 'GREP'||'ME>>,&&HOST_NAME.,&&INSTANCE_NAME.,'||name as C3 FROM v$database;
SELECT 'GREP'||'ME>>' as C3 FROM dual;

prompt
prompt
prompt ==============
prompt ***E-Business Suite Application Servers

-- Get the list of E-Business Suite Application Servers related with the current EBS underlying database
-- All versions
SELECT 'NODE_NAME:'||node_name||'|HOST:'||host||'|DOMAIN:'||domain||'|WEBHOST:'||webhost FROM fnd_nodes WHERE node_name!='AUTHENTICATION';

prompt
prompt
prompt ==============
prompt ***Database Version

SELECT BANNER FROM V$VERSION;


prompt
prompt
prompt ==============
prompt ***LMS Collection Tool version

define USAGE_QUERY=LMSCT_V

SELECT
    '&&GREP_PREFIX.,&USAGE_QUERY.,'     ||
    '&&LMSCT_V'             ||','
FROM
    dual;


REM   *************************************************************************************************
REM
REM   Script Name: Advanced Pricing
REM
REM   DESCRIPTION: This script shows the status of Advanced Pricing installation
REM

prompt
prompt
prompt ==============
prompt ***Advanced Pricing installation status

define USAGE_QUERY=ADVANCED_PRICING

SELECT
    '&&GREP_PREFIX.,&USAGE_QUERY.,'     ||
    qp_util.get_qp_status           ||','
FROM
    dual;


set time on
set timi on


REM   *************************************************************************************************
REM
REM   Script Name: Incentive Compensation
REM
REM   DESCRIPTION: This script shows the number of Compensated Individuals,
REM                according with COMPENSATED INDIVIDUAL metric.
REM

prompt
prompt
prompt ==============
prompt ***Total number of Compensated Individuals, measured for Incentive Compensation product

define USAGE_QUERY=INCENTIVE_COMPENSATION

SELECT
    '&&GREP_PREFIX.,&USAGE_QUERY.,'     ||
    COUNT(DISTINCT salesrep_id)     ||','
FROM
    cn_srp_plan_assigns_all
WHERE
    end_date IS NULL OR end_date > SYSDATE;



REM   *************************************************************************************************
REM
REM   Script Name: iEXPENSES
REM
REM   DESCRIPTION: This script counts the total number of expense
REM                reports processed by Internet Expense for each date.
REM                The default date format is DD-MON-YY.
REM

prompt
prompt
prompt ==============
prompt ***Total number of Expense Reports processed by Internet Expenses for each month (last 24 months of usage)

define USAGE_QUERY=EXPENSE_REPORTS

SELECT
    '&&GREP_PREFIX.,&USAGE_QUERY.,'     ||
    TO_CHAR(creation_date,'YYYY-MM')    ||','||
    COUNT(invoice_id)           ||','
FROM
    ap_invoices_all
WHERE
    invoice_type_lookup_code='EXPENSE REPORT'
    AND source='SelfService'
    AND (SELECT max(creation_date) FROM ap_invoices_all
            WHERE invoice_type_lookup_code='EXPENSE REPORT'
            AND source='SelfService') <= 730 + creation_date
GROUP BY TO_CHAR(creation_date,'YYYY-MM')
ORDER BY TO_CHAR(creation_date,'YYYY-MM');



REM   *************************************************************************************************
REM
REM   Script Name: iPROCUREMENT
REM
REM   DESCRIPTION: This script counts the total number of purchase line items processed by
REM   iProcurement, for each year.
REM

prompt
prompt
prompt ==============
prompt ***Total number of purchase line items processed by iProcurement, for each month (last 24 months of usage)

define USAGE_QUERY=IPROCUREMENT

SELECT
    '&&GREP_PREFIX.,&USAGE_QUERY.,'     ||
    TO_CHAR(b.creation_date,'YYYY-MM')  ||','||
    COUNT(b.line_num)           ||','
FROM
    po_requisition_headers_all a,
    po_requisition_lines_all b
WHERE
    a.requisition_header_id=b.requisition_header_id
    AND apps_source_code='POR' AND a.authorization_status='APPROVED'
    AND (SELECT max(creation_date) FROM po_requisition_lines_all
            WHERE apps_source_code='POR' AND authorization_status='APPROVED') <= 730 + b.creation_date
GROUP BY TO_CHAR(b.creation_date,'YYYY-MM')
ORDER BY TO_CHAR(b.creation_date,'YYYY-MM');



REM   ****************************************************************************************************
REM
REM   Script Name: PURCHINT
REM
REM   DESCRIPTION:          This script counts the total number of purchase line items processed by
REM                         the Purchasing Intelligence application.
REM
REM   METRIC DEFINITION:    Purchase Line: is defined as the total number of purchase line items processed by
REM                         the application during a 12 month period. Multiple purchase lines may be created
REM                         on either a requisition or purchase order or may be automatically generated by
REM                         other Oracle Application program.
REM                         For Purchasing Intelligence, Purchase Lines are counted as the line items on
REM                         purchase orders processed through this application. This does not include
REM                         communication on the same P.O.
REM

prompt
prompt
prompt ==============
prompt ***Total number of purchase line items processed by the Purchasing Intelligence application, during last 12 months, measured for version >= 11i

define USAGE_QUERY=PURCHINT_11i

SELECT
    '&&GREP_PREFIX.,&USAGE_QUERY.,'     ||
    COUNT(distinct INSTANCE_FK_KEY||po_line_id)
FROM
    poa_edw_po_dist_f
WHERE
    (SELECT max(creation_date) FROM poa_edw_po_dist_f) <= 365 + creation_date;



REM   *************************************************************************************************
REM
REM   Script Name: OTL
REM
REM   DESCRIPTION: This script counts the total number of persons recorded by the Oracle Time & Labor system.
REM                Persons include only active employees and contractors registered in HR.
REM
REM   Person metric definition: For Time and Labor, a person is defined as an employee or contractor
REM                             whose time or labor (piece work) or absences are managed by the system
REM

prompt
prompt
prompt ==============
prompt ***Total number of active employees and contractors, recorded by the OTL system, measured for version > 11.5

define USAGE_QUERY=OTL

SELECT
    '&&GREP_PREFIX.,&USAGE_QUERY.,'     ||
    'OTL active employees and contractors: '||
    (SELECT COUNT(DISTINCT paf.party_id)
    FROM hxc_timecard_summary ts, hxc_time_building_blocks tb,
    --apply WHERE condition to have resource_id within active employees and contractors records set
    (SELECT DISTINCT party_id, person_id
       FROM per_all_people_f
       WHERE
         (upper(current_employee_flag)='Y' OR upper(current_npw_flag)='Y')
         AND effective_start_date < SYSDATE
         AND SYSDATE < effective_end_date
    ) paf
    WHERE ts.resource_id = tb.resource_id
    AND tb.scope = 'TIMECARD'
    AND ts.resource_id = paf.person_id) ||','
FROM dual;



REM   *************************************************************************************************
REM
REM   Script Name: OTA
REM
REM   DESCRIPTION: This script counts the total number of trainees recorded by the system.
REM                Trainees include internal trainees (active employees only) and external trainees.
REM                This script counts also the cancelled enrollments.
REM                If one person is doing a training and in the same time is sponsor (signs for other persons),
REM                that person will be counted twice.
REM

prompt
prompt
prompt ==============
prompt ***Total number of trainees, both internal and external, recorded by the system

define USAGE_QUERY=OTA

SELECT
    '&&GREP_PREFIX.,&USAGE_QUERY.,'     ||
    'Internal learners: '||
    (SELECT COUNT(DISTINCT trainee) trainee
        FROM
        (SELECT    DISTINCT NVL(b.delegate_person_id, b.sponsor_person_id) trainee
           FROM      ota.ota_delegate_bookings b
           WHERE     (b.delegate_person_id IS NOT NULL OR b.sponsor_person_id IS NOT NULL)
           --apply WHERE condition to have delegate_person_id within active employees records set
       AND b.delegate_person_id in
       (SELECT distinct person_id employee
           FROM per_all_people_f
           WHERE
              (upper(current_employee_flag)='Y' or upper(current_npw_flag)='Y' or upper(current_applicant_flag)='Y')
              AND effective_start_date < SYSDATE AND SYSDATE < effective_end_date)
        ))                  ||','||
    ', External learners: '||
    (SELECT COUNT(DISTINCT trainee) trainee
        FROM
        (SELECT    DISTINCT NVL(b.delegate_contact_id, b.contact_id) trainee
           FROM      ota.ota_delegate_bookings b
           WHERE     (b.delegate_contact_id IS NOT NULL OR b.contact_id IS NOT NULL)
    ))                  ||','
FROM dual;



REM   *************************************************************************************************
REM
REM   Script Name: HR Employee
REM
REM   DESCRIPTION: This script counts the number of licenses needed for the Employee
REM                metric. The first section SELECTs all employees, while the seconds
REM                counts all contractors. Counting distinct Party_ID eliminates
REM                double counting the same person across different Business group.
REM
REM   EMPLOYEE metric: is defined as all of your full-time, part-time, temporary employees
REM                    and all of your agents, contractors and consultants. The quantity of the
REM                    licenses required is determined by the number of Employees and not the actual
REM                    number of users. In addition, if you elect to outsource any business function(s)
REM                    to another company, all of the company's full-time, part-time,temporary
REM                    employees and agents, contractors and consultants that are providing the
REM                    outsourcing services for you must be counted for the purposes of determining
REM                    the number of Employees.
REM

prompt
prompt
prompt ==============
prompt ***Total number of employees, measured for version 10.7

define USAGE_QUERY=HR_E_107

SELECT
    '&&GREP_PREFIX.,&USAGE_QUERY.,'     ||
    COUNT(DISTINCT person_id)       ||','
FROM
    PER_ALL_PEOPLE_F P
WHERE
    P.EFFECTIVE_START_DATE < SYSDATE AND SYSDATE < P.EFFECTIVE_END_DATE
    AND current_employee_flag = 'Y';

prompt
prompt
prompt ==============
prompt ***Total number of employees, measured for version 11.0 AND 11i(< 11.5.7)


define USAGE_QUERY=HR_E_11.0_and_11i(<11.5.7)

SELECT
    '&&GREP_PREFIX.,&USAGE_QUERY.,'     ||
    COUNT(*)                ||','
FROM
    (SELECT DISTINCT party_id
    FROM PER_ALL_PEOPLE_F P
    WHERE P.EFFECTIVE_START_DATE < SYSDATE AND SYSDATE < P.EFFECTIVE_END_DATE
        AND current_employee_flag = 'Y'
    UNION
    SELECT distinct p.party_id
    FROM per_all_people_f p,
        per_contracts_f c,
        per_person_types ppt
    WHERE c.effective_start_date < SYSDATE AND SYSDATE < c.effective_end_date
        AND p.effective_start_date < SYSDATE AND SYSDATE < p.effective_end_date
        AND c.person_id = p.person_id
        AND p.person_type_id = ppt.person_type_id
        AND p.business_group_id = ppt.business_group_id
        AND ppt.system_person_type = 'OTHER');

prompt
prompt
prompt ==============
prompt ***Total number of employees, measured for version >= 11.5.7 including R12

define USAGE_QUERY=HR_E_>=11.5.7_including_R12

SELECT
    '&&GREP_PREFIX.,&USAGE_QUERY.,'     ||
    COUNT(DISTINCT party_id)        ||','
FROM
    PER_ALL_PEOPLE_F P
WHERE
    P.EFFECTIVE_START_DATE < SYSDATE AND SYSDATE < P.EFFECTIVE_END_DATE
    AND (current_npw_flag ='Y' OR current_employee_flag = 'Y');



REM   *************************************************************************************************
REM
REM   Script Name: HR Ex_Emp_WithBenefits
REM
REM   DESCRIPTION: HR_Person consists of two scripts, the first one counts the number of
REM                employees (and contractors), while the second (below here) counts all
REM                ex_employees with active benefits.
REM

prompt
prompt
prompt ==============
prompt ***Total number of ex-employees with active benefits in the system, measured for version 11.0, 11i and 12

define USAGE_QUERY=HR_P_11.0_11i_and_12

SELECT
    '&&GREP_PREFIX.,&USAGE_QUERY.,'     ||
    COUNT(DISTINCT PARTY_ID)        ||','
FROM
    per_all_people_f p
WHERE
    p.employee_number IS NOT NULL
    AND p.effective_start_date < SYSDATE AND  SYSDATE < p.effective_end_date
    AND p.current_employee_flag IS NULL
    AND EXISTS
    (SELECT NULL
        FROM ben_prtt_enrt_rslt_f ben
        WHERE ben.effective_start_date < SYSDATE AND SYSDATE < ben.effective_end_date
        ---- check for live coverage
            AND ((ben.enrt_cvg_strt_dt <= SYSDATE) AND (SYSDATE <= ben.enrt_cvg_thru_dt))
        AND ben.prtt_enrt_rslt_stat_cd IS NULL
        AND ben.ENRT_CVG_THRU_DT       >= ben.ENRT_CVG_STRT_DT
        AND ben.person_id               = p.person_id
        AND ben.business_group_id       = p.business_group_id
        AND ben.enrt_cvg_strt_dt       <= ben.effective_end_date
        AND ben.enrt_cvg_thru_dt       >= ben.effective_start_date);



REM   *************************************************************************************************
REM
REM   Script Name: Old HR User Types
REM
REM   DESCRIPTION: This script displays the different system person types and user person
REM                types in the customer's environment and the number of employees under
REM                each type.
REM

prompt
prompt
prompt ==============
prompt ***Total number of persons per each system_person_type and user_person_type, measured for version 11i(11.5.x) to 12. Old HR Types script

define USAGE_QUERY=OLD_HR_TYPES

SELECT '&&GREP_PREFIX.,&USAGE_QUERY.,'      ||
    spt                 ||','||
    upt                 ||','||
    COUNT(DISTINCT party_id)        ||','
FROM
    (SELECT party_id,
        TRIM(HR_PERSON_TYPE_USAGE_INFO.GET_USER_PERSON_TYPE(SYSDATE,paf.person_id)) upt,
            TRIM(HR_PERSON_TYPE_USAGE_INFO.GETSYSTEMPERSONTYPE(paf.person_type_id)) spt
        FROM per_all_people_f paf
        WHERE effective_start_date < SYSDATE AND SYSDATE < effective_end_date)
GROUP BY
    spt,upt
ORDER BY
    spt,upt;


prompt
prompt
prompt ==============
prompt ***HR User Types - Total number of persons per each system_person_type and user_person_type, measured for version 11i(11.5.x) to 12

define USAGE_QUERY=HR_TYPES_11i(11.5.x)_to_12

SELECT '&&GREP_PREFIX.,&USAGE_QUERY.,'    ||
  spt          ||','||
  upt          ||
  ' - Flag: '|| cw_emp_flag  ||','||
  dist_count_party_id ||','
FROM 
(SELECT
       spt,
       upt,
       NVL(cw_emp_flag,'NULL') cw_emp_flag,
       COUNT(DISTINCT party_id) dist_count_party_id
  FROM (SELECT party_id,
               TRIM(HR_PERSON_TYPE_USAGE_INFO.GET_USER_PERSON_TYPE(SYSDATE,person_id)) upt,
               TRIM(HR_PERSON_TYPE_USAGE_INFO.GETSYSTEMPERSONTYPE(person_type_id)) spt,
               DECODE(DECODE(current_npw_flag, 'Y','C',NULL),NULL,DECODE(current_employee_flag, 'Y','E',NULL),DECODE(current_npw_flag, 'Y','C',NULL)) cw_emp_flag,
               current_npw_flag contingent_worker_flag,
               current_employee_flag employee_flag
          FROM (SELECT paf.party_id,
                       person_id,
                       person_type_id,
                       current_npw_flag,
                       current_employee_flag,
                       row_number() over(PARTITION BY party_id ORDER BY person_id DESC) r
                  FROM per_all_people_f paf
                 WHERE effective_start_date < SYSDATE
                   AND SYSDATE < effective_end_date
                   AND (current_npw_flag ='Y' OR current_employee_flag = 'Y'))
         WHERE r = 1)
GROUP BY 
  spt,upt,NVL(cw_emp_flag,'NULL')
UNION ALL
SELECT
       spt,
       upt,
       NVL(cw_emp_flag,'NULL') cw_emp_flag,
       COUNT(DISTINCT party_id) dist_count_party_id
  FROM (SELECT party_id,
               TRIM(HR_PERSON_TYPE_USAGE_INFO.GET_USER_PERSON_TYPE(SYSDATE,person_id)) upt,
               TRIM(HR_PERSON_TYPE_USAGE_INFO.GETSYSTEMPERSONTYPE(person_type_id)) spt,
               DECODE(DECODE(current_npw_flag, 'Y','C',NULL),NULL,DECODE(current_employee_flag, 'Y','E',NULL),DECODE(current_npw_flag, 'Y','C',NULL)) cw_emp_flag,
               current_npw_flag contingent_worker_flag,
               current_employee_flag employee_flag
          FROM (SELECT paf.party_id,
                       person_id,
                       person_type_id,
                       current_npw_flag,
                       current_employee_flag,
                       row_number() over(PARTITION BY party_id ORDER BY person_id DESC) r
                  FROM per_all_people_f paf
                 WHERE effective_start_date < SYSDATE
                   AND SYSDATE < effective_end_date)
         WHERE r = 1
         AND (current_npw_flag IS NULL AND current_employee_flag IS NULL)
         ANd party_id not in (SELECT party_id
                          FROM (SELECT paf.party_id,
                                       person_id,
                                       person_type_id,
                                       current_npw_flag,
                                       current_employee_flag,
                                       row_number() over(PARTITION BY party_id ORDER BY person_id DESC) r
                                FROM per_all_people_f paf
                                WHERE effective_start_date < SYSDATE
                                AND SYSDATE < effective_end_date
                                AND (current_npw_flag = 'Y' OR current_employee_flag = 'Y'))
                                WHERE r = 1))
          GROUP BY spt,upt,NVL(cw_emp_flag,'NULL') ORDER BY spt,upt,cw_emp_flag);


REM   *************************************************************************************************
REM
REM   Script Name: HR Foundation functionality checks
REM


PROMPT
PROMPT
PROMPT ================================
PROMPT ***People with Datetrack history

SELECT 'DATETRACK_CNT,' || business_group_id ||','|| cnt ||',' from
(select count(*) cnt
,      business_group_id
from
(select count(*)
,      person_id
,      business_group_id
from   per_all_people_f
group by person_id,business_group_id
having count(*) > 1)
group by business_group_id);


PROMPT
PROMPT
PROMPT ===============================
PROMPT ***People with Legislative Data

SELECT 'LEGISLATIVE_CNT,' || per_information_category ||',' ||business_group_id ||','|| cnt ||',' from
(select per_information_category
,      business_group_id
,      count(*) cnt
from per_all_people_f p
where (PER_INFORMATION1 is not null or
     PER_INFORMATION2 is not null or
     PER_INFORMATION3 is not null or
     PER_INFORMATION4 is not null or
     PER_INFORMATION5 is not null or
     PER_INFORMATION6 is not null or
     PER_INFORMATION7 is not null or
     PER_INFORMATION8 is not null or
     PER_INFORMATION9 is not null or
     PER_INFORMATION10 is not null or
     PER_INFORMATION11 is not null or
     PER_INFORMATION12 is not null or
     PER_INFORMATION13 is not null or
     PER_INFORMATION14 is not null or
     PER_INFORMATION15 is not null or
     PER_INFORMATION16 is not null or
     PER_INFORMATION17 is not null or
     PER_INFORMATION18 is not null or
     PER_INFORMATION19 is not null or
     PER_INFORMATION20 is not null or
     PER_INFORMATION21 is not null or
     PER_INFORMATION22 is not null or
     PER_INFORMATION23 is not null or
     PER_INFORMATION24 is not null or
     PER_INFORMATION25 is not null or
     PER_INFORMATION26 is not null or
     PER_INFORMATION27 is not null or
     PER_INFORMATION28 is not null or
     PER_INFORMATION29 is not null or
     PER_INFORMATION30 is not null)
group by per_information_category,business_group_id);


PROMPT
PROMPT
PROMPT ======================================
PROMPT ***Human Resources installation status

SELECT DECODE(status,'S','Shared HR Installed','Full HR')
FROM   fnd_product_installations WHERE application_id=800;


PROMPT
PROMPT
PROMPT =========================================================
PROMPT ***Support for Applicants or Contacts in HR (user person)

SELECT DISTINCT hr_person_type_usage_info.get_user_person_type (sysdate,person_id)
FROM   per_all_people_f
WHERE  sysdate BETWEEN effective_start_date AND effective_end_date
AND    hr_person_type_usage_info.getsystempersontype (person_type_id) = 'OTHER';


PROMPT
PROMPT
PROMPT ===============================================
PROMPT ***Support for Applicants in HR (system person)

SELECT DISTINCT hr_person_type_usage_info.getsystempersontype (person_type_id)
FROM   per_all_people_f
WHERE  sysdate BETWEEN effective_start_date AND effective_end_date
AND    hr_person_type_usage_info.getsystempersontype (person_type_id) LIKE '%APL%';


PROMPT
PROMPT
PROMPT ========================================
PROMPT ***Country specific address layout check

SELECT DISTINCT style
FROM   per_addresses
WHERE  (style NOT LIKE '%GLB' AND style <> 'GENERIC');


PROMPT
PROMPT
PROMPT =========================================
PROMPT ***Datetrack - Profile Option Value check

SELECT DISTINCT profile_option_name ,a.profile_option_value
FROM   fnd_profile_option_values a, fnd_profile_options b
WHERE  a.profile_option_id = b.profile_option_id
AND    b.profile_option_name IN ('DATETRACK:ENABLED','PER_ENABLE_DTW4');


PROMPT
PROMPT
PROMPT =============================================
PROMPT ***Datetrack - Legislation installation check

SELECT application_short_name,legislation_code
FROM   hr_legislation_installations
WHERE  status = 'I';

prompt ==============

SET VERIFY ON
SPOOL OFF

HOST cat &&OUTPUT_PATH_ROOT.export_log_*.txt > &&OUTPUT_PATH_ROOT.export_log.txt
HOST rm &&OUTPUT_PATH_ROOT.export_log_*.txt
