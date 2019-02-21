--
-- target name na _ a .
--    when instr(target_name, '_') > 0 THEN substr(target_name, 1, instr(target_name, '_')-1)
--    when instr(target_name, '.') > 0 THEN substr(target_name, 1, instr(target_name, '.')-1)
--    ELSE target_name


--
-- lifecycle - update dle prvniho pismenka serveru
--

select target_name ||':'|| target_type ||':'||
  'LifeCycle Status'||':'||lifecycle
from
  (
select target_name,
    case when substr(host_name, 1, 1) = 'z'
        then 'rac_database'
  else 'oracle_database'
  end target_type,
    case substr(host_name, 1, 1)
      when 't' then 'Test'
      when 'd' then 'Development'
      when 'z' then 'Pre-production'
    end lifecycle
  from em_database
  where env_status is NULL
    and substr(lower(dbname), 4, 1) = substr(host_name, 1, 1)
)
order by target_name;

emcli set_target_property_value -property_records="AMLT:oracle_database:LifeCycle Status:Test"



-- Department z OLI
-- generate file for emcli set_target_property_value -property_records=REC_FILE -input_file=REC_FILE:oli
--
-- emcli set_target_property_value -property_records=REC_FILE -separator=property_records="\n" -input_file=REC_FILE:oli.txt
select target_name||':'||target_type||':'||'Department'||':'||app_name
  from (
       select target_name, target_type,
         CASE
           when instr(target_name, '_') > 0 THEN substr(target_name, 1, instr(target_name, '_')-1)
           when instr(target_name, '.') > 0 THEN substr(target_name, 1, instr(target_name, '.')-1)
         ELSE target_name
         END dbname_short
       from DASHBOARD.MGMT$TARGET
       where target_type in ('rac_database','oracle_database')
       ) t
    JOIN
       (select   DBNAME,
         LISTAGG(APP_NAME,',') WITHIN GROUP (ORDER BY DBNAME) APP_NAME
       FROM OLI_OWNER.DATABASES d
          JOIN OLI_OWNER.APP_DB o ON (d.licdb_id = o.licdb_id)
          JOIN OLI_OWNER.APPLICATIONS a ON (A.APP_ID = o.APP_ID)
         WHERE APP_NAME not in ('EIGER','PWC','TPII','GASPR',
           'ELZU','KCPOR','SWMAN','ECOM') -- KC
         GROUP BY DBNAME ) oli
            ON (t.dbname_short = oli.DBNAME)
--  WHERE t.target_name like 'COL%'
;


select
  p.*
  --p.target_name, p.property_value "Contact"
--  p.target_name||': '||p.property_value
 from DASHBOARD.MGMT$TARGET_PROPERTIES p
where 1=1
  and p.target_type in ('rac_database','oracle_database')
  and p.property_name = 'orcl_gtp_department'
--  and p.property_name = 'orcl_gtp_contact'  -- Contact
  --and property_name = 'orcl_gtp_lifecycle_status' -- Lifecycle status
  -- and property_name = 'OracleHome'  -- OracleHome
  and p.target_type like '%database'
  and p.target_name like 'COL%'
order by upper(p.target_name);

--
select * from DASHBOARD.MGMT$TARGET_PROPERTIES where target_name like 'COLP%';

-- OLI
select  *
--DBNAME,
--         LISTAGG(APP_NAME,',') WITHIN GROUP (ORDER BY DBNAME) APP_NAME
       FROM OLI_OWNER.DATABASES d
          JOIN OLI_OWNER.APP_DB o ON (d.licdb_id = o.licdb_id)
          JOIN OLI_OWNER.APPLICATIONS a ON (A.APP_ID = o.APP_ID)
  WHERE DBNAME like 'ARKC%'
--         GROUP BY DBNAME, APP_NAME
;

-- generate emcli update Application (Comment)
-- MEPDA:oracle_database:Comment:MEP
--
-- nahra�eno za
SELECT  'emcli set_target_property_value -property_records="'||
   DBNAME||':'||
   decode(RAC, 'Y', 'rac_database','oracle_database')||
   ':Comment:'||LISTAGG(APP_NAME,',') WITHIN GROUP (ORDER BY DBNAME) ||
   '"'
from (
SELECT
  EM_GUID,
  DBNAME,
  APP_NAME,
  RAC
FROM
  OLI_OWNER.APP_DB NATURAL
JOIN OLI_OWNER.DATABASES NATURAL
JOIN OLI_OWNER.applications
)
 --where DBNAME = 'MCIP'
group by DBNAME, RAC;

-- EM data
select
    -- konverze podivn�ch target name s podtr��tkama
    target_name,
    case
      when instr(target_name, '_') > 0 THEN substr(target_name, 1, instr(target_name, '_')-1)
      when instr(target_name, '.') > 0 THEN substr(target_name, 1, instr(target_name, '.')-1)
      ELSE target_name
    END dbname,
    m.category_prop_1 version
    from DASHBOARD.ALL_MGMT_TARGETS m
  where category_prop_3 = 'DB' -- pouze DB, bez RAC instanc�
  AND target_name like 'COL%'
ORDER by 1;