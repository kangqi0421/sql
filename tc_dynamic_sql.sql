select sql_text, sharable_mem, executions, parse_calls  from v$sql
where PARSING_USER_ID = 50
and sql_text like 'INSERT INTO%'

alter system flush shared_pool;

select * from dba_users

/* Formatted on 2008/02/12 15:05 (Formatter Plus v4.8.8) */
DECLARE
   i_id   NUMBER;
BEGIN
   FOR i IN 1 .. 4
   LOOP
      INSERT INTO t (ID) VALUES (i_id);
   END LOOP;
END;
/

DECLARE
  i_id  number;
begin
   FOR i IN 1 .. 4
   LOOP
      execute immediate 'INSERT INTO T (ID) VALUES (:B1 )' USING i_id;
   END LOOP;
end;
/