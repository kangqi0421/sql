--------------------------------------------------------
--  DDL for Procedure api_delete_server
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "OLI_OWNER"."API_DELETE_SERVER" (
   p_hostname VARCHAR2)
AS
   v_licdb_id     number;
   v_server_id    number;
   v_multi_server VARCHAR2(1);
BEGIN
  select     l.lic_env_id, l.multi_server, s.server_id
        into   v_licdb_id, v_multi_server, v_server_id
     from LICENSED_ENVIRONMENTS l
             inner join SERVERS s
          on (l.lic_env_id = s.lic_env_id)
   where
     OLIFQDN(lower(s.hostname), lower(s.domain)) = lower(p_hostname);

  -- delete cascade db instances
  delete from dbinstances where server_id = v_server_id;

  -- delete db server
  DELETE from SERVERS where server_id = v_server_id;

  -- zruseni navíc lic env, pokud to neni sdílený VMWare nebo AIX dle v_multi_server
  if v_multi_server = 'N' then
    DELETE from LICENSED_ENVIRONMENTS where lic_env_id = v_licdb_id;
  end if;

exception
   when TOO_MANY_ROWS then
      raise_application_error(-20001, 'Multiple servers ' || p_hostname ||' exist in OLI');
   when NO_DATA_FOUND then
      raise_application_error(-20002, 'Server ' || p_hostname ||' not found in OLI');
END;

/
