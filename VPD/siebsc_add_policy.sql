BEGIN
  DBMS_RLS.ADD_POLICY(
     object_schema => 'SIEBEL',
     object_name => 'S_SYS_PREF',
     policy_name => 'CRM_PLAIN_PSWD_POLICY',
     function_schema => 'SIEBSC',
     policy_function => 'CRM_PREDICATE',
     statement_types => 'SELECT, INSERT, UPDATE, DELETE',
     update_check => TRUE,     -- default=FALSE; TRUE nastavi, ze se policy spousti i v pripade INSERT a UPDATE prikazu
     enable => TRUE, 
     static_policy => FALSE);  -- default=FALSE; TRUE rekne policy, ze predikatni retezec je vzdy stejny bez ohledu, kdo do tabulky pristupuje
END;
/