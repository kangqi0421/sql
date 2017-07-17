-- Oracle Linux farma z OEM
 where REGEXP_LIKE(host_name, 'z?(t|d|p|b)ordb[[:digit:]]+.vs.csin.cz')

-- VM dev hosts
REGEXP_LIKE(host_name, '^[dt][pb][a-z]{3}db\d{2}.vs.csin.cz')

-- filtr na personální účty
REGEXP_LIKE(username, '^[A-Z]+\d{4,}$')

-- hostname, domain
SELECT
    regexp_replace(hostname, '^(\w+)(\.\w+)*$', '\1') hostname,
    regexp_replace(hostname, '^\w+\.(.+?\.)', '\1')     domain,


set lin 180
col username for a15
col profile for a10
col EXTERNAL_NAME for a20

select username,
       --AUTHENTICATION_TYPE, password, EXTERNAL_NAME,
       profile,
       account_status, expiry_date
FROM dba_users
WHERE
  REGEXP_LIKE(username, '^[A-Z]+\d{4,}$')
-- REGEXP_LIKE(username, '^(EXT|CEN|ITA|SOL|A)\d+S')
--WHERE REGEXP_LIKE(username, '^(EXT|CEN|ITA|SOL|A)\d+')
  --and username NOT IN ('SYS', 'SYSTEM','ARM_CLIENT','DBSNMP')  -- system default accounts
  -- AND password IS NULL -- neni jiz nastavena externi authentizaci
  --  and profile not like 'PROF_APPL'  -- mimo naše DBA účty
  and account_status = 'OPEN'
ORDER BY USERNAME;

-- hromadná konverze EXT|CEN|ITA|SOL účtů
BEGIN
  FOR rec IN
  (
    SELECT   username
      FROM dba_users
      WHERE REGEXP_LIKE(username, '^(EXT|CEN|ITA|SOL)[^_].*')
        AND username NOT IN ('SYS', 'SYSTEM','ARM_CLIENT','DBSNMP') -- system default accounts
        AND password IS NULL -- neni jiz nastavena externi authentizaci
  )
  LOOP
    execute immediate 'alter user '||upper(rec.username)||
    ' identified externally as '''|| lower(rec.username)||'@CEN.CSIN.CZ''';
  END LOOP;
END;
/

-- vyber tablespace na konci radku ORA-01659:... tablespace XXX
with query as
(select distinct (REGEXP_REPLACE(line, '.*tablespace (\S+)$', '\1')) tbs
from migr_logs
where 1=1
  and mark like 'error%'
  and line like 'ORA-01659%'
  and timestamp > timestamp'2012-02-23 12:00:00'
order by 1
)
select 'alter tablespace '||tbs||' add datafile size 128m autoextend on next 256m maxsize 32g'
from query;

-- pouze FS d02 a d03
and REGEXP_LIKE(file_name, '^/oradb/MDWP/d0[23]/.*')

-- dba directories pro předprodukci
SELECT 'create or replace directory '
    ||directory_name || ' as '
    || DBMS_ASSERT.enquote_literal(REGEXP_REPLACE(directory_path, '/srv/data/\w+/(\w+)/\w+/(.*)','/srv/data/pred/\1/$DBNAME/\2'))
    || ';' as cmd
  FROM dba_directories
  WHERE (
         directory_name not like 'ORACLE%'
    and  directory_name not like 'OPATCH%'
    and  directory_name not in ('DATA_PUMP_DIR','XSDDIR','XMLDIR')
         )
;