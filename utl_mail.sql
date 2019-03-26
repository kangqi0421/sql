-- UTL_MAIL
-- ACL
-- init

GRANT EXECUTE ON UTL_MAIL TO <username>;

BEGIN
   DBMS_NETWORK_ACL_ADMIN.CREATE_ACL (
    acl          => 'mail_access.xml',
    description  => 'Permissions to access e-mail server.',
    principal    => 'PUBLIC',
    is_grant     => TRUE,
    privilege    => 'connect');
   COMMIT;
END;

BEGIN
   DBMS_NETWORK_ACL_ADMIN.ASSIGN_ACL (
    acl          => 'mail_access.xml',
    host         => 'smtp.csin.cz',
    lower_port   => 25,
    upper_port   => 25
    );
   COMMIT;
END;

commit;

– zistenie ACL cesty, napríklad /sys/acls/acl_for_SD.xml
SELECT ACL as ACL_PATH FROM DBA_NETWORK_ACLS WHERE HOST = 'smtp.csin.cz' AND LOWER_PORT = 25 AND UPPER_PORT = 25;

exec DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE('/sys/acls/mail_access.xml','<username>',TRUE,'resolve');
commit;
