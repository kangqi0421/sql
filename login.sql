-- detekce SQL Plus
-- SQLDeveloper does not handle noprint very nice
define noprint="--"
col sqlplus_sqld noprint new_value noprint
select decode(substr(program,1,7),'sqlplus','noprint','') sqlplus_sqld
from v$session where sid = (select sid from v$mystat where rownum = 1);

-- init.sql
-- this must be here to avoid logon problems when SQLPATH env variable is unset
--def SQLPATH=""

-- set SQLPATH variable to either Unix or Windows format
--def SQLPATH=$SQLPATH -- (Unix)
--def SQLPATH=%SQLPATH% -- Windows

-- def _start=start   -- Windows
-- def _start=firefox -- Unix/Linux
-- def _start=open -- MacOS

--define all='"select /*+ no_merge */ sid from v$session"'

-- you should change linesize to match terminal width - 1 only 
-- if you don't have a terminal with horizontal scrolling
-- capability (cmd.exe and Terminator terminal do have horizontal scrolling)
set linesize 180

-- set truncate after linesize on
	--set truncate on

-- set pagesize larger to avoid repeting headings
set pagesize 5000

-- fetch 10000000 bytes of long datatypes. good for
-- querying DBA_VIEWS and DBA_TRIGGERS
	--set long 10000000
	--set longchunksize 10000000

-- larger arraysize for faster fetching of data
-- note that arraysize can affect outcome of experiments
-- like buffer gets for select statements etc.
set arraysize 500
	
-- normally I keep this commented out, otherwise
-- a DBMS_OUTPUT.GET_LINES call is made after all
-- PL/SQL executions from sqlplus. this may distort
-- execution statistics for experiments
set serveroutput on size unlimited

-- to have less garbage on screen
SET VERIFY OFF

-- to trim trailing spaces from spool files
set trimspool on

-- to trim trailing spaces from screen output
set trimout on

-- SQLDEveloper, SQLcl
SET sqlformat ansiconsole

-- don't use tabs instead of spaces for "wide blanks"
-- this can mess up the vertical column locations in output
-- set tab off

-- pro SQL Developer nefunguje

-- this makes describe command better to read and more
-- informative in case of complex datatypes in columns
	-- set describe depth 1 linenum on indent on  

-- you can make sqlplus run any command as your editor
-- I could use "start notepad" on windows if you want to 
-- return control back to sqlplus immediately after launching
-- notepad (so that you can continue typing in sqlplus

--define _editor = "gvim.exe"

/*
-- assign the tracefile name to trc variable
def trc=unknown

column tracefile &noprint new_value trc

	-- its nice to have termout off here as otherwise this would be
	-- displayed on the screen
set termout off

	select value ||'/'||(select instance_name from v$instance) ||'_ora_'||
	       (select spid||case when traceid is not null then '_'||traceid else null end
                from v$process where addr = (select paddr from v$session
	                                         where sid = (select sid from v$mystat
	                                                    where rownum = 1
	                                               )
	                                    )
	       ) || '.trc' tracefile
	from v$parameter where name = 'user_dump_dest';	
*/	

	-- NLS date format
ALTER SESSION SET NLS_DATE_FORMAT = 'DD.MM.RRRR HH24:MI:SS';
	
	-- format some more columns for common DBA queries
col file_name for a60
col owner heading owner for a20
col member for a60
col first_change# for 99999999999999999
col next_change# for 99999999999999999
col checkpoint_change# for 99999999999999999
col resetlogs_change# for 99999999999999999
col plan_plus_exp for a100
col value_col_plus_show_param ON HEADING  'VALUE'  FORMAT a100 

-- set html format
--@@Tanel\htmlset nowrap 

-- nefunguje se SQLcl
-- set editfile afiedit.sql

-- reset termout back to normal
set termout on

-- i.sql is the "who am i" script which shows your session/instance info and 
-- also sets command prompt window/xterm title
@@i.sql