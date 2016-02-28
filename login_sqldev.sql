set serveroutput on size unlimited

-- ANSI console output
-- SET SQLFORMAT ANSICONSOLE

-- to have less garbage on screen
SET VERIFY OFF

-- NLS date format
ALTER SESSION SET NLS_DATE_FORMAT = 'DD.MM.RRRR HH24:MI:SS';

set pagesize 5000
	
-- format some more columns for common DBA queries
col file_name for a60
col owner heading owner for a20
col member for a60
col first_change# for 99999999999999999
col next_change# for 99999999999999999
col checkpoint_change# for 99999999999999999
col resetlogs_change# for 99999999999999999
