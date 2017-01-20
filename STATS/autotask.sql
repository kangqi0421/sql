--
-- autotask
--

select * from dba_autotask_operation;

select * from dba_autotask_client
  where client_name = 'auto optimizer stats collection'
;



--Set to DB service Auto Statistics Collection
BEGIN
  DBMS_AUTO_TASK_ADMIN.SET_CLIENT_SERVICE(
      client_name => 'auto optimizer stats collection',
      service_name => 'RTODS_RTOZA_ETL');
END;
/


-- change to ETL service
BEGIN
  for rec in (select name from v$services where name like '%ETL')
  LOOP
    DBMS_AUTO_TASK_ADMIN.SET_CLIENT_SERVICE(
      client_name => 'auto optimizer stats collection',
      service_name => rec.name);
  END LOOP;
END;
/

select Client_Name, status, Service_Name
  from DBA_AUTOTASK_CLIENT
  where client_name = 'auto optimizer stats collection'
;