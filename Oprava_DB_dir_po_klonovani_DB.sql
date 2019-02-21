/**
* Skript pro nastaveni / opravu DB directories a java file permission potrebnych pro EIM.
* Skript je urcen pro databaze WBL, INE a MCI.
* Tento skript je potreba spustit po kazdem naklonovani DB, protoze jinak nebude EIM fungovat.
* --------------------------------------------------------------------------------------------
* CHANGELOG
* Datum      Autor        Popis zmeny
* ---------- ------------ --------------------------------------------------------------------
* 13.07.2017 Fusek Igor   Zaloeno.
*
* @version 1.0
* @headcom
*/
DECLARE
  ltxt_relative_path   VARCHAR2(100 CHAR);
  lint_keynum          NUMBER;
BEGIN
  SELECT CASE
      WHEN b.db_pilar_name = 'EU' THEN '/srv/data/edu/' || b.db_instance_name || '/' || b.db_name || '/remote'
      WHEN b.db_pilar_name = 'DEV' THEN '/srv/data/dev/' || b.db_instance_name || '/' || b.db_name || '/remote'
      WHEN b.db_pilar_name = 'INT' THEN '/srv/data/int/' || b.db_instance_name || '/' || b.db_name || '/remote'
      WHEN b.db_pilar_name = 'PRS' THEN '/srv/data/prs/' || b.db_instance_name || '/' || b.db_name || '/remote'
      WHEN b.db_pilar_name = 'Z' THEN '/srv/data/pred/' || b.db_instance_name || '/' || b.db_name || '/remote'
      WHEN b.db_pilar_name = 'P' THEN '/srv/data/prod/' || b.db_instance_name || '/' || b.db_name || '/remote'
    END
    INTO ltxt_relative_path
    FROM (SELECT CASE
                   WHEN SUBSTR(LOWER(SYS_CONTEXT('USERENV', 'DB_NAME')), 1, 3) = 'wbl' THEN SUBSTR(LOWER(SYS_CONTEXT('USERENV', 'DB_NAME')), 1, 3)
                   WHEN SUBSTR(LOWER(SYS_CONTEXT('USERENV', 'DB_NAME')), 1, 3) = 'ine' THEN 'inet'
                   WHEN SUBSTR(LOWER(SYS_CONTEXT('USERENV', 'DB_NAME')), 1, 3) = 'mci' THEN 'cic'
                 END
                   AS db_instance_name,
                 SUBSTR(UPPER(SYS_CONTEXT('USERENV', 'DB_NAME')), 4) AS db_pilar_name,
                 UPPER(SYS_CONTEXT('USERENV', 'DB_NAME'))            AS db_name
            FROM DUAL) b;
  DBMS_OUTPUT.put_line('Relative path=' || ltxt_relative_path);
  -- Naprava DB directories
  EXECUTE IMMEDIATE 'CREATE OR REPLACE DIRECTORY csops_archimp_dir AS ''' || ltxt_relative_path || '/csopsd/archiv/import''';
  EXECUTE IMMEDIATE 'CREATE OR REPLACE DIRECTORY csops_exp_dir AS ''' || ltxt_relative_path || '/csopsd/export''';
  EXECUTE IMMEDIATE 'CREATE OR REPLACE DIRECTORY csops_imp_dir AS ''' || ltxt_relative_path || '/csopsd/import''';
  EXECUTE IMMEDIATE 'CREATE OR REPLACE DIRECTORY csops_imp_log_dir AS ''' || ltxt_relative_path || '/imp-logs''';
  -- Naprava adresaru
  sys.DBMS_JAVA.grant_permission(grantee           => 'DBEIM',
                                 permission_type   => 'SYS:java.io.FilePermission',
                                 permission_name   => ltxt_relative_path || '/csopsd/archiv/import/*',
                                 permission_action => 'write',
                                 key               => lint_keynum);
  sys.DBMS_JAVA.grant_permission(grantee           => 'DBEIM',
                                 permission_type   => 'SYS:java.io.FilePermission',
                                 permission_name   => ltxt_relative_path || '/csopsd/import',
                                 permission_action => 'read',
                                 key               => lint_keynum);
  sys.DBMS_JAVA.grant_permission(grantee           => 'DBEIM',
                                 permission_type   => 'SYS:java.io.FilePermission',
                                 permission_name   => ltxt_relative_path || '/csopsd/import/*',
                                 permission_action => 'read',
                                 key               => lint_keynum);
  sys.DBMS_JAVA.grant_permission(grantee           => 'DBEIM',
                                 permission_type   => 'SYS:java.io.FilePermission',
                                 permission_name   => ltxt_relative_path || '/csopsd/import/*',
                                 permission_action => 'write',
                                 key               => lint_keynum);
  sys.DBMS_JAVA.grant_permission(grantee           => 'DBEIM',
                                 permission_type   => 'SYS:java.io.FilePermission',
                                 permission_name   => ltxt_relative_path || '/csopsd/export',
                                 permission_action => 'read',
                                 key               => lint_keynum);
  sys.DBMS_JAVA.grant_permission(grantee           => 'DBEIM',
                                 permission_type   => 'SYS:java.io.FilePermission',
                                 permission_name   => ltxt_relative_path || '/csopsd/export/*',
                                 permission_action => 'read',
                                 key               => lint_keynum);
  sys.DBMS_JAVA.grant_permission(grantee           => 'DBEIM',
                                 permission_type   => 'SYS:java.io.FilePermission',
                                 permission_name   => ltxt_relative_path || '/csopsd/export/*',
                                 permission_action => 'write',
                                 key               => lint_keynum);
  sys.DBMS_JAVA.grant_permission(grantee           => 'DBEIM',
                                 permission_type   => 'SYS:java.io.FilePermission',
                                 permission_name   => ltxt_relative_path || '/csopsd/export/*',
                                 permission_action => 'delete',
                                 key               => lint_keynum);
END;
/