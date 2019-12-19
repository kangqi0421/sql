--
-- VPD
--

select * from dba_policies
  where object_owner = 'SYSMAN'; 

-- test case

create table test(id int);

insert into test values (1);
insert into test values (2);
insert into test values (3);

commit;

CREATE OR REPLACE FUNCTION sys.vpd_test (oowner IN VARCHAR2, ojname IN VARCHAR2) 
RETURN VARCHAR2
AS
BEGIN
     IF SYS_CONTEXT ('USERENV','SESSION_USER') = 'TC'
     THEN RETURN 'id=1'; ELSE RETURN '';
     END IF;
END;
/


BEGIN
DBMS_RLS.ADD_POLICY ('tc', 'test', 'moje_policy','sys',
                     'vpd_test', 'select');
END;
/

BEGIN
DBMS_RLS.DROP_POLICY ('TC', 'TEST', 'moje_policy');
end;
/

-- disable policy
BEGIN
DBMS_RLS.ENABLE_POLICY('SIEBEL', 'S_SYS_PREF', 'CRM_PLAIN_PSWD_POLICY',FALSE);
END;
/