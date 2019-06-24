WHENEVER SQLERROR EXIT 1

col comp_id for a15
col comp_name for a35
col version for a15
col status for a10

select substr(comp_id,1,15) comp_id,substr(comp_name,1,30) comp_name,
       substr(version,1,10) version, status
  from dba_registry
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
