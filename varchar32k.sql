--
-- nastaveni
--
startup mount
alter database open migrate;

alter system set max_string_size = EXTENDED;
@?/rdbms/admin/utl32k.sql

shutdown immediate;

select value$ from SYS.PROPS$ where name = 'MAX_STRING_SIZE';

--
-- test case
--
create table TEST_CLOB (name clob);
create table TEST_VARCHAR (name varchar(32767));

insert into TEST_CLOB select lpad(rownum,9000,'x') from dual connect by level < 11;
insert into TEST_VARCHAR select lpad(rownum,9000,'x') from dual connect by level < 11;
commit;

set autotrace TRACEONLY
select NAME from TEST_CLOB;

Statistics
----------------------------------------------------------
          0  recursive calls
          0  db block gets
         56  consistent gets
         80  physical reads
          0  redo size
      15065  bytes sent via SQL*Net to client
      10942  bytes received via SQL*Net from client
         52  SQL*Net roundtrips to/from client
          0  sorts (memory)
          0  sorts (disk)
         10  rows processed



select NAME from TEST_VARCHAR;

Statistics
----------------------------------------------------------
          0  recursive calls
          0  db block gets
         48  consistent gets
          0  physical reads
          0  redo size
      90716  bytes sent via SQL*Net to client
        552  bytes received via SQL*Net from client
          2  SQL*Net roundtrips to/from client
          0  sorts (memory)
          0  sorts (disk)
         10  rows processed


set autotrace traceonly
set timing on

    SELECT LENGTH(LPAD(ROWNUM, 2000, 'x'))
      FROM DUAL
CONNECT BY LEVEL < 100000;


    SELECT LENGTH(LPAD(ROWNUM, 4000, 'x'))
      FROM DUAL
CONNECT BY LEVEL < 100000;

    SELECT LENGTH(LPAD(ROWNUM, 4001, 'x'))
      FROM DUAL
CONNECT BY LEVEL < 100000;

    SELECT LENGTH(LPAD(TO_CLOB(ROWNUM), 4001, 'x'))
      FROM DUAL
CONNECT BY LEVEL < 100000;