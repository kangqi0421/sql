--
-- type t_sys is table of varchar2(10);
--

declare
  type t_sys is table of varchar2(10);
  v_sys t_sys;
  -- execute
  procedure ex(p_cmd varchar2)
  is
  begin
    dbms_output.put_line(p_cmd);
    execute immediate p_cmd;
  exception when others then
    dbms_output.put_line(sqlerrm);
  end;
begin
  dbms_output.enable(1000000);
  v_sys := t_sys('L0_BRA','L0_CPS','L0_CPT','L0_CRM','L0_DMX','L0_EBPP','L0_EG','L0_ISPV','L0_MCI','L0_MEP','L0_PWC','L0_SB','L0_SMART','L0_SPZ','L0_SYMB','L0_VKC','L0_WBL');
  for i in v_sys.first .. v_sys.last loop

    -- create new L0 roles
    ex('create role '||v_sys(i)||'_ROLE_RO');
    ex('create role '||v_sys(i)||'_ROLE_RW');
    ex('create role '||v_sys(i)||'_ROLE_HOTFIX');

  end loop;
end;
/