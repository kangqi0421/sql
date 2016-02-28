-- select user with defaut profile except of built-in users
SELECT username, profile, ACCOUNT_STATUS, EXPIRY_DATE
  FROM dba_users
WHERE
  1=1
  --AND profile     = 'DEFAULT'
AND username NOT IN (SELECT user_name FROM sys.default_pwd$)
AND NOT REGEXP_LIKE(username, '^(EXT|CEN|ITA|SOL|ARM_)[^_].*')
AND username NOT IN ('SYSTEM','SYS','ANONYMOUS','APPQOSSYS','EXFSYS',
  'ORACLE_OCM','WMSYS','XDB','OUTLN','DBSNMP','XS$NULL','SRBA','POLAK','ZELA','ZELENY',
  'VANCURA','ZAKOVA')
ORDER BY username;

-- špatně nastavený kerberos
select username, external_name, authentication_type, profile
  from dba_users 
 where authentication_type = 'EXTERNAL' and external_name is NULL;

-- přegenerování kerberos uctu a přehození na OPEN
BEGIN
  FOR rec IN
  (
    SELECT   username
      FROM dba_users
      WHERE REGEXP_LIKE(username, '^(EXT|CEN|ITA|SOL)[^_].*')
        AND authentication_type = 'EXTERNAL'
  )
  LOOP
    execute immediate 'alter user '||upper(rec.username)||
    ' identified externally as '''|| lower(rec.username)||'@CEN.CSIN.CZ'''||
    ' account UNLOCK';
  END LOOP;
END;
/ 

-- DEFAULT profile
SELECT username, profile, account_status, expiry_date
      FROM dba_users
      WHERE REGEXP_LIKE(username, '^(EXT|CEN|ITA|SOL)[^_].*')
        AND profile = 'DEFAULT'
     ORDER BY 1;
--     
BEGIN
  FOR rec IN
  (
    SELECT   username
      FROM dba_users
     WHERE REGEXP_LIKE(username, '^(EXT|CEN|ITA|SOL)[^_].*')
        AND profile = 'DEFAULT'  )
  LOOP
    execute immediate 'alter user '||upper(rec.username)||
    ' profile PROF_USER';
  END LOOP;
END;
/       