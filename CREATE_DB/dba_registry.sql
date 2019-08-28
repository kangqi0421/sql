WHENEVER SQLERROR EXIT 1

set lines 120 pages 999

col CON_ID format 99
col comp_id for a10
col comp_name for a40
col SCHEMA format a12
col version for a15
col status for a10

select CON_ID,
       comp_id,
       substr(comp_name,1,40) comp_name,
       schema,
       version,
       status
  from CDB_REGISTRY  -- DBA_REGISTRY
 order by 1;

-- PL/SQL to raise error
DECLARE
  v_cnt integer;
BEGIN
select COUNT(*) into v_cnt
  from DBA_REGISTRY where STATUS not in ('VALID', 'OPTION OFF');
  IF v_cnt > 0 THEN
     RAISE_APPLICATION_ERROR (-20001, 'Invalid Registry Components found.');
  END IF;
END;
/

prompt
prompt Invalid Components:
prompt ===================
select COMP_ID, COMP_NAME, STATUS, VERSION
  from DBA_REGISTRY
where STATUS not in ('VALID', 'OPTION OFF');

prompt
prompt Errors:
prompt =======
set pagesize 50000
select * from sys.registry$error order by identifier;
