
define db = 'BRAEA'

-- DATABASES

- OLI_DATABASE
- EM_DATABASE

-- chybí ještě insert do OLI_OWNER.APP_DB
select *
FROM
  OLI_OWNER.DATABASES d
    join OLI_OWNER.APP_DB o ON (d.licdb_id = o.licdb_id)
    JOIN OLI_OWNER.APPLICATIONS a ON (A.APP_ID = o.APP_ID)
    JOIN OLI_OWNER.DBINSTANCES i ON (d.licdb_id = i.licdb_id)
  where d.dbname like '&db'
--  licdb_id = 6367
;


-- update ENV status
define lifecycle = 'Education'

update OLI_OWNER.DATABASES d
  set d.env_status = '&lifecycle'
  where dbname like '&db';

--
-- API add databaze
--

-- app ve formatu bez SAS

define db=DRDMTA
define app=DRDM


-- OLI API add db
set serveroutput on

DECLARE
  v_licdb_id NUMBER;
  v_db_exist NUMBER;
BEGIN
  select count(*) into v_db_exist from oli_owner.databases
   where dbname = '&db';
  if v_db_exist = 0  then
    v_licdb_id := oli_owner.oli_api.add_database('&db', '&app');
    dbms_output.put_line('licdb_id: ' || v_licdb_id);
  end if;
END;
/

--
ORA-06502: PL/SQL: numeric or value error: character to number conversion error
ORA-06512: at "OLI_OWNER.OLI_API", line 141

OLI_OWNER.OLI_API:140
    if (l_instances_skipped>0) then
        raise_application_error(ERR_DBINST_NOT_FOUND,'Some database instance found for database '
                               ||p_dbname||' in OEM could not be added to OLI');


-- ||p_dbname||' in OEM could not be added to OLI (number of instances skipped:' + l_instances_skipped+')');


--
-- delete
--

select 'call OLI_API.delete_database('|| DBMS_ASSERT.enquote_literal(d.dbname) ||');' as cmd
  from OLI_OWNER.DATABASES d
 where d.dbname like 'TS2%';

    select licdb_id
       from databases
       where upper(dbname)=upper('TS2O');

delete from dbinstances where licdb_id=91;
delete from databases where licdb_id = 91;

select * from   OLI_OWNER.APP_DB
  where app_id=80;

--
-- INSERT do DATABASES
--

-- update em_guid DATABASES
// db migrate: update em guid
UPDATE
  OLI_OWNER.DATABASES oli
set em_guid = (select db_target_guid
    from  OLI_OWNER.OMS_DATABASES_MATCHING oms
      WHERE 1 = 1
        -- and match_status in ('NM')
        and oli.dbname = oms.db_name
        and oli.env_status = oms.envstatus)
  WHERE upper(oli.dbname) = '&dbname'
    -- and oli.env_status = '{{ lifecycle_env }}'
;


--
INSERT INTO OLI_OWNER.DATABASES (DBNAME, RAC, ENV_STATUS, DBVERSION, EM_GUID)
select DB_NAME,
       decode(dbracopt, 'YES', 'Y', 'N'),
       envstatus,
       dbversion,
       db_target_guid
  from OLI_OWNER.OMS_DATABASES_MATCHING
 WHERE match_status in ('U')
   and upper(db_name) = upper('&dbname')
;
--

MERGE
 into OLI_OWNER.DATABASES oli
USING
  (select dbname, em_guid, is_rac
     from  DASHBOARD.EM_DATABASE
    where dbname like '&dbname'
  ) em
ON (oli.dbname = em.dbname AND oli.env_status = em.env_status)
  when matched then
    update set oli.em_guid = em.em_guid
  WHEN NOT MATCHED THEN
    INSERT (oli.DBNAME, oli.EM_GUID, oli.RAC)
    VALUES (em.dbname, em.em_guid, em.is_rac);
;

-- run job OEM_RESYNC_TO_OLI - syncne verze, status atd.
exec  dbms_scheduler.run_job('OLI_OWNER.OEM_RESYNC_TO_OLI', use_current_session => TRUE);

-- INSERT do DBINSTANCES
select * from OLI_OWNER.OMS_DBINSTANCES_MATCHING
  where db_name like '&dbname';

INSERT INTO OLI_OWNER.DBINSTANCES (LICDB_ID, SERVER_ID, INST_NAME, EM_GUID)
SELECT
    matched_licdb_id,
    matched_server_id,
    instance_name,
    INSTANCE_TARGET_GUID
  from OLI_OWNER.OMS_DBINSTANCES_MATCHING
  where match_status in ('U')
    AND db_name = '&dbname'
;

--
-- SAS_APP
--

-- vložení záznamů z CA_APPLICATIONS do APPLICATIONS
MERGE
 into OLI_OWNER.APPLICATIONS d
USING
   (select cmdb_ci_id, APP_NAME, APP_LONG_NAME from OLI_OWNER.CA_APPLICATIONS
      where APP_NAME = 'SAS_ORDBF'
        and status = 'Alive'
    ) s
ON (s.app_name = d.app_name)
  WHEN NOT MATCHED THEN
    INSERT (d.ca_id, d.app_name, d.app_long_name)
    VALUES (s.cmdb_ci_id, s.APP_NAME, s.APP_LONG_NAME);
;

MERGE
 into OLI_OWNER.APP_DB d
USING
   (select d.licdb_id, a.app_id
    FROM
      OLI_OWNER.DATABASES d, OLI_OWNER.APPLICATIONS a
        where d.dbname   like 'CPTDA'
          and a.app_name like 'CPT'
    ) s
ON (s.licdb_id = d.licdb_id AND s.app_id = d.app_id)
  WHEN NOT MATCHED THEN
    INSERT (d.licdb_id, d.app_id)
    VALUES (s.licdb_id, s.app_id);
;


--
-- API delete databaze
--

define db=DWHDD18Z

call OLI_OWNER.OLI_API.delete_database('&db');
commit;


DELETE from CLONING_OWNER.DB_PARAM_VALUE  where licdb_id = l_licdb_id;

-- delete db instance pro migrace
DELETE from OLI_OWNER.DBINSTANCES
  WHERE licdb_id IN (
    SELECT distinct(i.licdb_id)
    FROM
      OLI_OWNER.DATABASES d
      JOIN OLI_OWNER.DBINSTANCES i ON (d.licdb_id = i.licdb_id)
    WHERE dbname = '&db'
);

--
BEGIN
  for rec in (
    select licdb_id from OLI_OWNER.DATABASES
      where dbname = '&db')
  LOOP
    DELETE from OLI_OWNER.APP_DB where licdb_id = rec.licdb_id;
    DELETE from OLI_OWNER.DBINSTANCES where licdb_id = rec.licdb_id;
    DELETE from OLI_OWNER.DATABASES where licdb_id = rec.licdb_id;
  END LOOP;
END;
/

-- OLI konfigurace

select * FROM config_data;
LIC_CAPTURE_USAGE_TIMEOUT : default(365)


-- sync EM - duplicity OMST, OMSP

select INST_NAME from
(
select  i2.dbinst_id,CPUCOUNT,INST_NAME,count(*)
                 from oli_owner.OMS_DBINSTANCES emi,oli_owner.dbinstances i2
                 where emi.instance_target_guid=i2.em_guid
                       and i2.EM_GUID is not null
group by INST_NAME,i2.dbinst_id,CPUCOUNT
having count(*) > 1
) order by 1

-- sync EM - duplicity v OMS_DATABASES
select
   db_target_guid, count(*)
 from oli_owner.oms_databases emd
 group by db_target_guid
 having count(*) > 1
;

-- duplicity em_guid v OLI_OWNER.DATABASES
select em_guid, count(*)
  from oli_owner.databases
 where em_guid is not NULL
 group by em_guid
   having count(*) > 1;


-- APP
- Change SAS app
  procedure reload_applications AS
  BEGIN
   insert into ca_applications("CMDB_CI_ID", "APP_NAME", "APP_LONG_NAME",
      select lower(cmdb_ci_id),
      trim(resource_name) app_name,
    from CA_SRC_APPLICATIONS;

select * from applications
  where app_name  like '%';

-- update prefix SAS
update applications
   set app_name = 'SAS_'||app_name
  where app_name not like 'SAS%';

