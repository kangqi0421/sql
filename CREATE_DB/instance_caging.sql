--
-- instance caging
--

-- nastav resource_manager_plan na DEFAULT_PLAN
-- pouze, pokud již není nataven na jinou hodnotu
DECLARE
  v_value VARCHAR2(80);
BEGIN
  select value into v_value
    FROM v$parameter where name = 'resource_manager_plan';
  IF (v_value IS NULL) THEN
    execute immediate 'alter system set resource_manager_plan = DEFAULT_PLAN';
  END IF;
END;
/

-- nastav omezení na počet CPU dle předaného paramtru skriptu
ALTER SYSTEM SET cpu_count = &1 ;

-- kontorlní výstup
select instance_caging from v$rsrc_plan where cpu_managed='ON' and is_top_plan='TRUE';
select value from v$parameter where name ='cpu_count'
  and (isdefault='FALSE' or ismodified != 'FALSE');