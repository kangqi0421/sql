col dt new_value datum
col db new_value datab
col pl new_value platf
col vr new_value versi

select to_char(sysdate, 'yyyy_mm_dd-hh24_mi_ss') as dt from dual;
select NAME as db, PLATFORM_NAME as pl from v$database;
select version as vr from v$instance;
set lines 20000 pages 20000 trims on echo off feedback off heading off

spool java_policy_all_&datab._&datum..txt
prompt --###Basic information
prompt ----------------------

prompt --Date:     &datum
prompt --Database: &datab
prompt --Platform: &platf
prompt --Version:  &versi
prompt --!!!Please remove all unwanted grants/restrictions as this is copy off ALL including defaults!!!

prompt var a number;
SELECT 'exec '
 ||stmt
FROM
 (SELECT seq,
   (
   CASE
     WHEN KIND='GRANT'
     THEN 'dbms_java.grant_permission('''
     ELSE 'dbms_java.restrict_permission('''
   END)
   ||grantee
   ||''','''
   || type_schema
   ||':'
   ||type_name
   ||''','''
   ||name
   ||''','''
   ||action
   || ''');'
   || (
   CASE
     WHEN ENABLED='ENABLED'
     THEN NULL
     ELSE chr(10)
       ||'exec dbms_java.disable_permission(:a);'
   END) stmt
 FROM dba_java_policy
 WHERE
   grantee not in ('JAVADEBUGPRIV', 'JAVASYSPRIV', 'JAVAUSERPRIV', 'JAVA_ADMIN', 'JAVA_DEPLOY', 'SYS','PUBLIC') and
   type_name!='oracle.aurora.rdbms.security.PolicyTablePermission'
 UNION ALL
 SELECT a.seq,
   (
   CASE
     WHEN a.KIND='GRANT'
     THEN 'dbms_java.grant_policy_permission('''
     ELSE 'dbms_java.restrict_permission('''
   END)
   ||a.grantee
   ||''','''
   || u.name
   ||(
   CASE
     WHEN a.KIND='GRANT'
     THEN ''','''
       ||a.permition
       ||''','''
       ||a.action
       ||''');'
     ELSE ':oracle.aurora.rdbms.security.PolicyTablePermission'
       ||''',''0:'
       ||a.permition
       ||'#'
       ||a.action
       ||''', null);'
   END)
   || (
   CASE
     WHEN a.ENABLED='ENABLED'
     THEN NULL
     ELSE chr(10)
       ||'exec dbms_java.disable_permission(:a);'
   END) stmt
 FROM sys.user$ u,
   (SELECT seq,
     KIND,
     grantee,
     ENABLED,
     to_number(SUBSTR(name,1,instr(name,':')-1)) userid,
     SUBSTR(name,instr(name,':')            +1,instr(name,'#') - instr(name,':')-1) permition,
     SUBSTR(name,instr(name,'#')            +1 ) action
   FROM dba_java_policy
   WHERE
     grantee not in ('JAVADEBUGPRIV', 'JAVASYSPRIV', 'JAVAUSERPRIV', 'JAVA_ADMIN', 'JAVA_DEPLOY', 'SYS', 'PUBLIC') and
     type_name = 'oracle.aurora.rdbms.security.PolicyTablePermission'
   ) a
 WHERE u.user#=userid
 )
ORDER BY seq;
prompt commit;;
spool off
