REM Script version: 18.1
REM The following privileges are needed to run this script:
REM grant create session
REM grant select on sys.v_$instance
REM grant select on sys.dba_users
REM grant select on sys.dba_tables
REM grant select on sys.v_$version
REM grant select on <<oid schema>>.ods_process        --ver 10g
REM grant select on <<oid schema>>.ods_process_status --ver 11g
REM grant select on <<oid schema>>.ds_attrstore
REM grant select on <<oid schema>>.ct_objectclass
REM grant select on <<oid schema>>.ct_tombstone

-- PREPARE AND DISPLAY LICENSE AGREEMENT
SET TERMOUT OFF
SET ECHO OFF

SPOOL lms_license_agreement.txt
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

HOST more lms_license_agreement.txt
HOST rm   lms_license_agreement.txt
HOST del  lms_license_agreement.txt

-- PROMT FOR LICENSE AGREEMENT ACCEPTANCE
DEFINE LANSWER=N
SET TERMOUT ON
ACCEPT LANSWER FORMAT A1 PROMPT 'Accept License Agreement? (y\n): '

SET TERMOUT OFF
WHENEVER SQLERROR EXIT
select 1/decode('&LANSWER', 'Y', null, 'y', null, decode('', null, 0, null)) as " " from dual;
PROMPT 

-- PROMT FOR BASE_DN
SET TERMOUT ON
ACCEPT BDN_ANSWER PROMPT 'Enter BASE_DN: '
SET TERMOUT OFF


WHENEVER SQLERROR CONTINUE

SET TERMOUT ON
SET FEEDBACK ON
SET LINESIZE 160
SET SERVEROUTPUT ON SIZE 1000000
SET SERVEROUTPUT ON SIZE UNLIMITED
SET VERIFY OFF

column host_name new_value v_h_name
column instance_name new_value v_i_name
select host_name, instance_name from sys.v_$instance;

SPOOL results-oid-users-count-&v_h_name-&v_i_name..txt;

PROMPT =================================================================================
PROMPT Script Name=oid_users_count_v18_1.sql
PROMPT =================================================================================
PROMPT 

select host_name, instance_name from sys.v_$instance;

SELECT banner FROM sys.v_$version WHERE banner like 'Oracle%';

select USERNAME, ACCOUNT_STATUS, LOCK_DATE, EXPIRY_DATE, CREATED from SYS.DBA_USERS where username='ODS';

-- Querying table ODS_PROCESS or ODS_PROCESS_SYSTEM

DECLARE
	N_ODS_PROCESS NUMBER;
	N_ODS_PROCESS_STATUS NUMBER;
BEGIN

	SYS.DBMS_OUTPUT.PUT_LINE('Querying table ODS_PROCESS (for version 10g) ...');
	SELECT COUNT(*) INTO N_ODS_PROCESS FROM SYS.DBA_TABLES WHERE OWNER = 'ODS' AND TABLE_NAME = 'ODS_PROCESS'; 
	
	IF (N_ODS_PROCESS > 0) THEN
		DECLARE
		ODS_PROC_CURSOR NUMBER := SYS.DBMS_SQL.OPEN_CURSOR;
		L_HOSTNAME    VARCHAR2(255);
		L_RESULTS NUMBER;
		BEGIN
			SYS.DBMS_SQL.PARSE(ODS_PROC_CURSOR,'SELECT DISTINCT HOSTNAME FROM ODS.ODS_PROCESS',SYS.DBMS_SQL.NATIVE);
			SYS.DBMS_SQL.DEFINE_COLUMN(ODS_PROC_CURSOR, 1, L_HOSTNAME, 255);
			L_RESULTS := SYS.DBMS_SQL.EXECUTE(ODS_PROC_CURSOR);
			SYS.DBMS_OUTPUT.PUT_LINE('HOSTNAME');
			SYS.DBMS_OUTPUT.PUT_LINE('-----------------------------');
			LOOP
			IF SYS.DBMS_SQL.FETCH_ROWS(ODS_PROC_CURSOR) > 0 THEN
				SYS.DBMS_SQL.COLUMN_VALUE(ODS_PROC_CURSOR, 1, L_HOSTNAME);
				SYS.DBMS_OUTPUT.PUT_LINE(L_HOSTNAME);
			ELSE
				EXIT;
			END IF;
		  END LOOP;
			SYS.DBMS_SQL.CLOSE_CURSOR(ODS_PROC_CURSOR);
			SYS.DBMS_OUTPUT.PUT_LINE(CHR(10));
		END;
	ELSE
		SYS.DBMS_OUTPUT.PUT_LINE('--- Table ODS_PROCESS not found.');
		SYS.DBMS_OUTPUT.PUT_LINE(CHR(10));
	END IF;

	SYS.DBMS_OUTPUT.PUT_LINE('Querying table ODS_PROCESS_STATUS (for version 11g) ...');

	SELECT COUNT(*) INTO N_ODS_PROCESS_STATUS	FROM SYS.DBA_TABLES	WHERE OWNER = 'ODS' AND TABLE_NAME = 'ODS_PROCESS_STATUS'; 
	
	IF (N_ODS_PROCESS_STATUS > 0) THEN
		DECLARE
		ODS_PROC_ST_CURSOR NUMBER := SYS.DBMS_SQL.OPEN_CURSOR;
		L_HOSTNAME    VARCHAR2(255);
		L_RESULTS NUMBER;
		BEGIN
		  SYS.DBMS_SQL.PARSE(ODS_PROC_ST_CURSOR,'SELECT DISTINCT HOSTNAME FROM ODS.ODS_PROCESS_STATUS', SYS.DBMS_SQL.NATIVE);
		  SYS.DBMS_SQL.DEFINE_COLUMN(ODS_PROC_ST_CURSOR, 1, L_HOSTNAME, 255);
		  L_RESULTS := SYS.DBMS_SQL.EXECUTE(ODS_PROC_ST_CURSOR);
		  SYS.DBMS_OUTPUT.PUT_LINE('HOSTNAME');
		  SYS.DBMS_OUTPUT.PUT_LINE('-----------------------------');
		  LOOP
			IF SYS.DBMS_SQL.FETCH_ROWS(ODS_PROC_ST_CURSOR) > 0 THEN
				SYS.DBMS_SQL.COLUMN_VALUE(ODS_PROC_ST_CURSOR, 1, L_HOSTNAME);
				SYS.DBMS_OUTPUT.PUT_LINE(L_HOSTNAME);
			ELSE
				EXIT;
			END IF;
		  END LOOP;
		  SYS.DBMS_SQL.CLOSE_CURSOR(ODS_PROC_ST_CURSOR);
		  SYS.DBMS_OUTPUT.PUT_LINE(CHR(10));
		END;
	ELSE
		SYS.DBMS_OUTPUT.PUT_LINE('--- Table ODS_PROCESS_STATUS not found.');
		SYS.DBMS_OUTPUT.PUT_LINE(CHR(10));
	END IF;

END;
/

PROMPT =================================================================================
PROMPT
PROMPT Number of records from ODS.DS_ATTRSTORE joined with ODS.CT_OBJECTCLASS for BASE_DN: &BDN_ANSWER
SELECT COUNT(*) FROM ODS.DS_ATTRSTORE STORE, ODS.CT_OBJECTCLASS OBJ WHERE STORE.ATTRNAME = 'orclentrydn' AND OBJ.ATTRVALUE = 'inetorgperson' AND STORE.ENTRYID = OBJ.ENTRYID AND REPLACE(LOWER(STORE.ATTRVAL),' ') LIKE REPLACE(LOWER('%&BDN_ANSWER'),' ');

PROMPT =================================================================================
PROMPT
PROMPT Number of records from ODS.DS_ATTRSTORE joined with ODS.CT_OBJECTCLASS
SELECT COUNT(*) FROM ODS.DS_ATTRSTORE STORE, ODS.CT_OBJECTCLASS OBJ WHERE STORE.ATTRNAME = 'orclentrydn' AND OBJ.ATTRVALUE = 'inetorgperson' AND STORE.ENTRYID = OBJ.ENTRYID;

PROMPT =================================================================================
PROMPT
PROMPT Number of records from ODS.CT_TOMBSTONE table:

SELECT COUNT(*) FROM ODS.CT_TOMBSTONE;

SPOOL OFF
QUIT