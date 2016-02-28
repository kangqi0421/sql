--------------------------------------------------------------------------------
--
-- File name:   w.sql
-- Purpose:     List all active session with optional where condition for SID value
--              user=???
--              sid=???
--
-- Author:	Jiri Srba
--
--------------------------------------------------------------------------------

set verify off

col u_username head USERNAME for a23
col u_sid head SID for a14 
col u_spid head SPID for a12 wrap
col u_audsid head AUDSID for 9999999999
col u_osuser head OSUSER for a16 truncate
col u_machine head MACHINE for a18 truncate
col u_program head PROGRAM for a20 truncate
col u_module head MODULE for a20 truncate

-- detekce number, nepouzito
-- SELECT '--' is_not_sid FROM dual WHERE REGEXP_LIKE ('&1', '^[,0-9]+$')

define sid=&1

column sid	noprint new_value sid

SELECT CASE
          WHEN TRIM (LOWER ('&sid')) LIKE 'sid=%' THEN TRIM (REPLACE ('&sid', 'sid=', ''))
          WHEN TRIM (LOWER ('&sid')) LIKE 'user=%' THEN 'select sid from v$session where lower(username) like '''||lower(trim(replace('&sid','user=','')))||'''' 
          WHEN TRIM (LOWER ('&sid')) LIKE 'spid=%' then 'select sid from v$session where paddr in (select addr from v$process where spid in ('||lower(trim(replace('&sid','spid=','')))||'))'
          WHEN TRIM (LOWER ('&sid')) LIKE 'active' then 'select sid from v$session where status = ''ACTIVE'' and type!=''BACKGROUND'''
          ELSE 'select sid from v$session where type!=''BACKGROUND'''
        END sid
  FROM DUAL
/

SELECT s.username u_username,
       decode(sid, sys_context('USERENV','SID'), 
       '*''' || s.sid || ',' || s.serial# || '''*',     -- prihod hvezdicku k vlastni SID session
       ' ''' || s.sid || ',' || s.serial# || '''') u_sid,
--       s.audsid u_audsid,
       s.osuser u_osuser,
       SUBSTR (s.machine, INSTR (s.machine, '\')) u_machine,
--       s.machine u_machine,
--       s.program u_program,
       SUBSTR (s.program, INSTR (s.program, '(')) u_program,
       module u_module,
--       p.pid,
       p.spid u_spid,
       s.sql_id,
--       s.sql_hash_value,
       s.last_call_et lastcall,
       s.status,
       s.logon_time
  FROM v$session s INNER JOIN v$process p ON (s.paddr = p.addr)
 WHERE s.sid IN (&sid)
--  and s.type <> 'BACKGROUND'
--  and s.status = 'ACTIVE'
/


