--
-- check for NLS_CHARACTERSET == AL32UTF8
--

SET SERVEROUTPUT ON VERIFY OFF

column property_name format a25
column property_value format a25
select property_name, property_value from database_properties where property_name in ('NLS_CHARACTERSET');

-- check for ansible return code
DECLARE
  v_nls VARCHAR2(256);
BEGIN
  select property_value into v_nls
    from database_properties
    where property_name in ('NLS_CHARACTERSET');
  IF v_nls != 'AL32UTF8' THEN
      RAISE_APPLICATION_ERROR (-20001, 'NLS not set to AL32UTF8');
  END IF;
END;
/
