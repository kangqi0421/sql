--// zjisteni z logu informace o stavu prenosu //--

DEFINE db=RTOP

SELECT *  FROM ARM_ADMIN.ARM_DATABASES 
  WHERE ARM_DB_NAME LIKE '%&db%'
order by ARM_DB_NAME;

-- ARM status ERROR
SELECT * FROM arm_admin.arm_status
  WHERE 1=1
    AND ARM_DB_NAME LIKE '%&db%'
--    AND status <> 'OK'
--    AND status not like 'DISABLED'
ORDER by ARM_DB_NAME;

-- ARM logs
SELECT *
    -- FROM ARM11.ARM_LOG11
    FROM ARM12.ARM_LOG12
   WHERE 1=1
     AND arm_db_name LIKE '%&db%'
--      AND arm_db_name LIKE 'RTOP_AIX'
     AND sub_date > sysdate - interval '4' hour
--     AND status <> 'F'
ORDER BY sub_date DESC;

--// client logs on cetral ARM
select *
  from ARM_ADMIN.arm_client_logs
 where arm_db_name = '%&db%' and sub_date > sysdate - 1/24
order by sub_date desc;

--// zjisteni presouvaciho jobu //--
select * from dba_scheduler_jobs
  where owner = 'ARM_ADMIN'
  and job_name like '%&db%';

--// running jobs //--
select * from dba_scheduler_running_jobs
--  where owner = 'ARM_ADMIN'
  --and job_name like '%&db'
  ;

--// scheduler job logy //--
select * from DBA_SCHEDULER_JOB_RUN_DETAILS
  where owner = 'ARM_ADMIN'
  and job_name like '%&db'
  order by log_date desc;

--// re-run prenosoveho jobu //--
begin
  dbms_scheduler.run_job('ARM_ADMIN.ARM_CENTRAL_&db', false);
end;
/

--// re-run vlastniho prenosu //--
DECLARE
  v_ARM_FULLID ARM_ADMIN.ARM_DATABASES.ARM_FULLID%TYPE;
BEGIN
  SELECT   ARM_FULLID
    INTO v_ARM_FULLID
    FROM ARM_ADMIN.ARM_DATABASES
    WHERE ARM_DB_NAME LIKE '%&db%';
  ARM_ADMIN.ARM_MOVE_S.MOVE_TO_CENTRAL11(v_ARM_FULLID);
END;
/


--// reinstalace - doplnit lokï¿½lnï¿½ zaznam //--
--// spustit na SEAPT pod ARM_ADMIN
insert into arm_client.ARM_DATABASE@&db
  select * from ARM_ADMIN.ARM_DATABASES  WHERE arm_db_name = upper('&db');

--// data ve stage tabulce //--
select count(*) from ARM12.ARM_AUD$12STAGE s where S.ARM_DB_NAME = '&db';

--
-- oprave ARM prenosu
--

-- srovnam subpartition template s DB s povolenym prenosem v ARM_ADMIN.ARM_DATABASES:
exec arm_admin.arm_adm.mod_template('ARM_UNIAUD12');

-- najdu nejstrasi zaznam (doporucuji jeste overit na klientovy vlastni unified_audit_trail na min(event_timestamp) a arm_client.arm_uniaud12_TMP na min(arm_timestamp))
select min(arm_timestamp) from arm12.arm_uniaud12stage where arm_fullid = 'RTOP1246254454';

-- zavolam procku pro pridan subparticii, protoze modifikace template nezajisti vytvoreni subpartitions pro jiz existujici particie
exec arm_admin.arm_adm.add_subpart('RTOP1246254454',DATE '2016-09-18', DATE '2016-11-14');

-- a ted uz prenosy z RTOP@pordb06 funguji ...

-- disable transfer after drop database
update ARM_ADMIN.ARM_DATABASES SET TRANSFER_ENABLED = 'N' WHERE ARM_FULLID LIKE 'DWHP1517715351';
commit;

--
-- DELETE/DROP ARM db
--

-- delete all subpart
select arm_fullid, data_protected,version, age_max * 30 from arm_admin.arm_databases where ARM_DB_NAME LIKE '%&db%';
-- pøenastavit age_max na 2 dny, na 1 den tam má Aleš ochranu ;-)
update arm_admin.arm_databases set age_max = 2/30 where ARM_DB_NAME LIKE '%&db%';

exec arm_admin.arm_adm.drop_subpart('2832974852CICAT1');

-- log
select * from ARM_ADMIN.ARM_DROP_LOG
  where drop_date > sysdate -1/24
  and arm_fullid = '2832974852CICAT1'
 order by drop_date desc;

-- drop subparts
-- resource busy ORA-00054
alter session set ddl_lock_timeout=60;

DECLARE
  p_fullid varchar2(30) := '''2832974852CICAT1''';
BEGIN
  FOR rec IN
  (SELECT table_owner,
    table_name,
    subpartition_name, high_value
  FROM dba_tab_subpartitions
  WHERE table_owner like 'ARM%'
  -- AND dbms_stats.convert_raw_value(high_value, cv) = '2832974852CICAT1'
  )
  LOOP
    if (rec.high_value = p_fullid) then
      dbms_output.put_line(rec.table_owner||'.'||rec.table_name||'.'||rec.subpartition_name||':'||rec.high_value);
      execute immediate 'alter table '||rec.table_owner||'.'||rec.table_name||' drop subpartition '||rec.subpartition_name;
    end if;
  END LOOP;
END;
/

--
-- DELETE db
--
delete from ARM_ADMIN.ARM_DATABASES  where ARM_FULLID LIKE 'RTOP1330573738'
  and TRANSFER_ENABLED = 'N';
-- pod arm_admin ARM_ADMIN/
conn ARM_ADMIN/arm234arm

select * from dba_db_links where db_link like 'RTOP%';

-- Paralellen� provoz 2 DB sou�asn�
-- vytvorit 2 samostane linky a 2 zaznamy v ARM_DATABASES
-- create db link
drop database link RTOP;
create database link RTOP_AIX connect to ARM_CLIENT identified by "cli456cli" using 'RTOP_AIX';

update ARM_ADMIN.ARM_DATABASES SET DBLINK = 'RTOP_AIX', ARM_DB_NAME = 'RTOP_AIX' 
  WHERE ARM_FULLID LIKE 'RTOP1246254454';
commit;

--
-- source local db
--

select * from arm_client.ARM_DATABASE;

-- logy
select *
  from ARM_CLIENT.ARM_LOG
 where sub_date > sysdate - interval '3' DAY
order by sub_date ;

select count(*) from UNIFIED_AUDIT_TRAIL;
select count(*) from ARM_CLIENT.ARM_AUD$12TMP;

-- Simply clean all audit records
exec DBMS_AUDIT_MGMT.CLEAN_AUDIT_TRAIL(DBMS_AUDIT_MGMT.AUDIT_TRAIL_UNIFIED,FALSE);
truncate table ARM_CLIENT.ARM_UNIAUD12TMP;

-- zjisteni, co zabira misto v SYSAUX
SELECT
  OCCUPANT_NAME,
  SCHEMA_NAME,
  ROUND(SPACE_USAGE_KBYTES/1024) "MB"
FROM
  V$SYSAUX_OCCUPANTS
ORDER BY
  space_usage_kbytes DESC
FETCH FIRST 2 ROWS ONLY;

-- kdy doslo k narustu auditnich dat
select * from ARM_CLIENT.ARM_AUDIT_HISTOGRAM order by log_id desc, bucket_id;

-- rerun do meziskladištì
exec SYS.ARM_MOVE_C.MOVE_TO_STAGE;


--//kill SQL*Net jobu //--
select 'alter system kill '''||sid||','||serial#||''';'
  from v$session
where username = 'ARM_ADMIN'
and status = 'ACTIVE'
--and event = 'SQL*Net more data from dblink'
;

select 'kill -9 '||p.spid
  from v$session s inner join v$process p on (s.paddr = p.addr)
 where s.sid ....

-- truncate v testu
truncate table SYS.aud$;
truncate table ARM_CLIENT.ARM_AUD$12TMP;

-- delete AUDIT data v STAGE area
delete from ARM11.ARM_AUD$11STAGE
where ARM_TIMESTAMP < sysdate - 360
and arm_db_name in ('MCMEP', 'MCMIP','APPA','CAEPA','CAIPA');

-- update SYS.AUD$
update sys.aud$
set sqltext = substr(ltrim(sqltext),1,1024)
where length(sqltext) > 1024;

update arm_client.arm_aud$11TMP
set sqltext = substr(ltrim(sqltext),1,1024)
where length(sqltext) > 1024;

commit;
