--
-- kontrola nastaveni init parametru pro MW
--

set feed off head on verify off lines 100

col name for a30
col value for a35
col status for a20

def color_ok  = '''OK'''
def color_err = chr(27)||'[1;36m'||'ERR'||chr(27)||'[0;39m'

-- default nezavisle parametry
  SELECT name,
         VALUE,
         CASE
            WHEN name = 'audit_sys_operations' THEN DECODE (VALUE, 'FALSE', &color_ok, &color_err)
            WHEN name = 'audit_file_dest' THEN DECODE (VALUE, '/oradiag/admin/'||sys_context('userenv', 'db_name')||'/adump', &color_ok, &color_err)
            WHEN name = 'audit_trail' THEN DECODE (VALUE, 'NONE', &color_ok, &color_err)
            WHEN name = 'resource_limit' THEN DECODE (VALUE, 'TRUE', &color_ok, &color_err)
            WHEN name = 'db_file_multiblock_read_count' THEN DECODE (ISDEFAULT, 'TRUE', &color_ok, &color_err)
            WHEN name = 'diagnostic_dest' THEN DECODE (VALUE, '/oracle', &color_ok, &color_err)
         END
            status
    FROM V$SYSTEM_PARAMETER
   WHERE name IN
            (
             'audit_file_dest',
             'audit_sys_operations',
             'audit_trail',
             'db_file_multiblock_read_count',
             'diagnostic_dest',
             'resource_limit'
             )
ORDER BY name;

set head off

-- MDW specific
   SELECT name,
         VALUE,
         CASE
            WHEN name = 'compatible' THEN DECODE (VALUE, '11.2.0.3', &color_ok, &color_err)
            WHEN name = 'db_domain' THEN DECODE (ISDEFAULT, 'TRUE', &color_ok, &color_err)
            WHEN name = 'utl_file_dir' THEN DECODE (VALUE, '/oradb/logs/'||sys_context('userenv', 'db_name')||'log', &color_ok, &color_err)
            WHEN name = 'global_names' THEN DECODE (ISDEFAULT, 'TRUE', &color_ok, &color_err)
            WHEN name = 'job_queue_processes' THEN DECODE (VALUE, 10, &color_ok, &color_err)
            WHEN name = 'processes' THEN DECODE (VALUE, 300, &color_ok, &color_err)
            WHEN name = 'db_recovery_file_dest' THEN DECODE (VALUE, '', &color_ok, &color_err)
         END
            status
    FROM V$SYSTEM_PARAMETER
   WHERE name IN
            (
             'compatible',
             'db_domain',
             'utl_file_dir',
             'global_names',
             'job_queue_processes',
             'processes',
             'db_recovery_file_dest'
             )
ORDER BY name;


-- NLS na UTF8, idealne AL32UTF8
SELECT parameter name,
       VALUE,
       DECODE (VALUE, 'AL32UTF8', &color_ok, &color_err) status
  FROM NLS_DATABASE_PARAMETERS
 WHERE parameter = 'NLS_CHARACTERSET';


