--
-- init parametry
--

WHENEVER SQLERROR EXIT SQL.SQLCODE

prompt
prompt nastaveni  parametru pred zmenami
prompt
set lin 180
col name for a40
col value for a20
col recommended for a20
SELECT
  name,
  value,
  case
    when name = 'audit_sys_operations' and value <> 'TRUE' then 'ERR:'||value
    when name = 'processes' and value < 500 then 'ERR:'||value
    when name = 'resource_limit' and value <> 'TRUE' then 'ERR:'||value
    when name = 'session_cached_cursors' and value < 299 then 'ERR:'||value
    when name = 'fast_start_mttr_target' and value  < 300 then 'ERR:'||value
    when name = 'archive_lag_target' and value < 1800 then 'ERR:'||value
    when name = 'os_authent_prefix' and value is not NULL then 'ERR:'||value
    ELSE 'OK'
  END recommended
FROM
  v$parameter
WHERE
  name IN ('audit_sys_operations', 'resource_limit','processes',
           'session_cached_cursors', 'fast_start_mttr_target',
           'archive_lag_target', 'os_authent_prefix')
;

--
-- Oracle version 12.1
--

--
-- bugy a workaround pro verzi 12.1.0.2
DECLARE
  v_platform VARCHAR2(101);
  v_version  VARCHAR2(17);
BEGIN
  SELECT
    version, platform_name
  INTO v_version, v_platform
  FROM
    v$database, v$instance;
  IF v_version = '12.1.0.2.0' THEN
    -- workaround ve 12.1.0.2
    execute immediate q'[alter system set "_optimizer_reduce_groupby_key"=false  comment='Wrong results GROUP BY bugs 20804826 22864303 23321926' scope=both]';
    IF v_platform like 'AIX%' THEN
      -- workaroundy pro AIX
      -- od PSU již není potřeba
      NULL;
      -- execute immediate q'[alter system set "_use_single_log_writer"=true comment='Doc ID 1957710.1 AIX:ORA-600 kcrfrgv_nextlwn_scn' SCOPE=SPFILE]';
    END IF;
  END IF;
END;
/

--
-- best practices
--
-- procesess zvednout minimálně na 1000, v 12c je minimum 300 a nestačí to
DECLARE
  v_processes int;
BEGIN
  select TO_NUMBER(value) into v_processes
    FROM v$parameter where name = 'processes';
  IF (v_processes <999) THEN
    execute immediate 'alter system set processes=1000 scope=spfile';
  END IF;
END;
/

-- reset default params: [sessions]
BEGIN
FOR REC in (select name FROM v$parameter where isdefault = 'FALSE'
             AND name in ('sessions'))
  LOOP
    execute immediate 'alter system reset '||rec.name;
  END LOOP;
END;
/

-- diag adresář přesměrovat do /oracle
alter system set diagnostic_dest = '/oracle';

-- security, audit
alter system set audit_trail=DB,EXTENDED scope=spfile;
alter system set audit_sys_operations = true scope=spfile;

-- audit nastavuji pro RAC do společného adresáře
column db_name new_value db_name print
SELECT SYS_CONTEXT ('USERENV', 'DB_NAME') as db_name from dual;
alter system set audit_file_dest = '/oradiag/admin/&db_name/adump' scope=spfile;
alter system set resource_limit = true;

-- kerberos
-- remote_os_authent je od 11.2 deprecated, provádím tedy jeho reset
-- alter system reset remote_os_authent scope = spfile;
alter system set os_authent_prefix = '' scope = spfile;

-- povolím async IO pro ASM, pokud nejsem na HP-UX filesystemu
-- alter system set disk_asynch_io = true scope=spfile;

-- pro kontrolu záloh redo přes EM metric extension
alter system set ARCHIVE_LAG_TARGET= 1800;

-- fast_start_mttr_target aspoň na 300
DECLARE
  v_value int;
BEGIN
  select TO_NUMBER(value) into v_value
    FROM v$parameter where name = 'fast_start_mttr_target';
  IF (v_value = 0) THEN
    execute immediate 'alter system set fast_start_mttr_target = 300';
  END IF;
END;
/

-- open_cursors zvednout minimálně na 1000
DECLARE
  v_open_cursors int;
BEGIN
  select TO_NUMBER(value) into v_open_cursors
    FROM v$parameter where name = 'open_cursors';
  IF (v_open_cursors <999) THEN
    execute immediate 'alter system set open_cursors=1000';
  END IF;
END;
/

-- zvednu session_cached_cursors z 50 aspoň na 300
DECLARE
  v_value int;
BEGIN
  select TO_NUMBER(value) into v_value
    FROM v$parameter where name = 'session_cached_cursors';
  IF (v_value <299) THEN
    execute immediate 'alter system set session_cached_cursors = 300 scope=spfile';
  END IF;
END;
/

-- kontrola nastaveni
set lin 180
col name for a40
col value for a20
col recommended for a20

prompt
prompt kontrola nastaveni init parametru v spfile pred restartem
prompt
SELECT
  name,
  value,
  case
    when name = 'audit_sys_operations' and value <> 'TRUE' then 'ERR:'||value
    when name = 'processes' and value < 500 then 'ERR:'||value
    when name = 'resource_limit' and value <> 'TRUE' then 'ERR:'||value
    when name = 'resource_limit' and value <> 'TRUE' then 'ERR:'||value
    when name = 'session_cached_cursors' and value < 299 then 'ERR:'||value
    when name = 'fast_start_mttr_target' and value  < 300 then 'ERR:'||value
    when name = 'archive_lag_target' and value < 1800 then 'ERR:'||value
    when name = 'os_authent_prefix' and value is not NULL then 'ERR:'||value
    ELSE 'OK'
  END recommended
FROM
  v$spparameter
WHERE
  name IN ('audit_sys_operations', 'resource_limit','processes',
           'session_cached_cursors', 'fast_start_mttr_target',
           'archive_lag_target', 'os_authent_prefix')
;
