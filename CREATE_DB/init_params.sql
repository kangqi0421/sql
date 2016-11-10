--
-- init parametry
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
    execute immediate q'[alter system set "_optimizer_aggr_groupby_elim"=false  comment='Wrong results GROUP BY bugs 19567916 20508819' scope=both]';
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
-- procesess zvednout minimálně na 1000, v 12c je minimum 300 a obcas nestačí
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
alter system reset sessions;

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
alter system set disk_asynch_io = true scope=spfile;

-- pro kontrolu záloh redo přes EM metric extension
alter system set ARCHIVE_LAG_TARGET= 1800;

-- fast_start_mttr_target aspoň na 300
alter system set fast_start_mttr_target = 300;

-- recycle bin vypnu, do DEV a TEST prostřeí klidně ponechám
-- alter system set recyclebin = off scope=spfile;

-- zvednu session_cached_cursors z 50 aspoň na 300
alter system set session_cached_cursors = 300 scope=spfile;

-- zvednout AWR retention na 14 dni
exec  DBMS_WORKLOAD_REPOSITORY.MODIFY_SNAPSHOT_SETTINGS(retention=>20160);
