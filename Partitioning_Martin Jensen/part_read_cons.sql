-- part_read_cons.sql
-- Partition exchange / read-consistency - Martin Jensen 30. Dec. 2005, 10.2.0.2, 11,1,0,7

connect /@O11 as sysdba

grant execute on dbms_lock to system;

connect system/oracle@O11

drop table bigemp_range;

create table bigemp_Range (
  empno number not null, sal number not null, job varchar2(12) not null,
  deptno number not null, hiredate date not null)
  partition by range (hiredate)
  (
    partition before_1982 values
      less than(to_date('1982-01-01','YYYY-MM-DD')) tablespace users,
    partition before_1984 values 
      less than(to_date('1984-01-01','YYYY-MM-DD')) tablespace users,
    partition before_1986 values 
      less than(to_date('1986-01-01','YYYY-MM-DD')) tablespace users,
    partition rest values LESS THAN (MAXVALUE))
  storage (initial 10M next 10M maxextents unlimited);

insert /*+APPEND */ into bigemp_range (empno, sal, job, deptno, hiredate)
select empno+t.column_value*300000 empno, sal, job, deptno,
       hiredate+mod(t.column_value,1000) hiredate
from scott.emp, table(system.counter(1,300000) ) t;
commit;
-- 4200000 rows

create unique index bigemp_range_pk on bigemp_range (hiredate, empno) local
  tablespace USERS STORAGE (initial 10M next 10M pctincrease 0) compute statistics;

alter table bigemp_range add constraint bigemp_range_pk primary key (hiredate, empno)
  using index bigemp_range_pk;

execute DBMS_STATS.GATHER_TABLE_STATS(null, 'BIGEMP_RANGE', estimate_percent => 100, -
  method_opt => 'FOR ALL INDEXED COLUMNS size 254');

select partition_name, num_rows from user_tab_partitions
where table_name = 'BIGEMP_RANGE'
order by partition_name;

PARTITION_NAME                   NUM_ROWS
------------------------------ ----------
BEFORE_1982                        613800
BEFORE_1984                       2560800
BEFORE_1986                        425400
REST                               600000

select min(hiredate), max(hiredate), count(*) 
from bigemp_range partition (before_1986);

MIN(HIRE MAX(HIRE   COUNT(*)
-------- -------- ----------
84-01-01 84-10-18     425400

drop table extra_tab;

create table extra_tab tablespace users as 
select * from bigemp_range where rownum < 1;

insert into extra_tab (empno, sal, job, deptno, hiredate) values
  (1111, 2222, 'EXTRA', 10, to_date('1985-01-01', 'YYYY-MM_DD'));
commit;

select min(hiredate), max(hiredate), count(*) 
from extra_tab;

create unique index extra_tab_pk on extra_tab (hiredate, empno)
  tablespace USERS STORAGE (initial 10M next 10M pctincrease 0) compute statistics;

alter table extra_tab add constraint extra_tab_pk primary key (hiredate, empno)
  using index extra_tab_pk;

execute DBMS_STATS.GATHER_TABLE_STATS(null, 'EXTRA_TAB', estimate_percent => 100, -
  method_opt => 'FOR ALL INDEXED COLUMNS size 254');


set autotrace trace
select empno, sal, job, hiredate from bigemp_range;

set autotrace off

select r, job from (
  select rownum r, empno, sal, job, hiredate from bigemp_range
  order by hiredate)
where job = 'EXTRA';

create or replace procedure query_test as
begin
declare
   row_no number := 0;
   cursor user_query is
      select empno, sal, job, hiredate from bigemp_range;
   rec    user_query%rowtype;
begin 
   open user_query;
   fetch user_query into rec;
   row_no := row_no + 1;
   dbms_output.put_line ( 'first record is '|| to_date(rec.hiredate,'YYYY-MM-DD'));

   dbms_lock.sleep( 60 ); -- wait 1 min.

   loop
      fetch user_query into rec;
      exit when user_query%notfound;
      row_no := row_no + 1;
      if rec.job = 'EXTRA' then
         dbms_output.put_line( 'into third partition (EXTRA): '||
            to_date(rec.hiredate,'YYYY-MM-DD') );
         exit;
      end if;
   end loop;
   dbms_output.put_line ( 'last record is '|| to_date(rec.hiredate,'YYYY-MM-DD'));
   close user_query;
   dbms_output.put_line ( 'Query test terminated. '|| row_no); 
end; 
end query_test;
/


-- Now - As session A execute:

set serveroutput on
execute query_test;

-- And at the same time start session B and do:

alter table bigemp_range
  exchange partition before_1986 with table extra_tab  including indexes;

drop table extra_tab /* purge */;

-----------

alter table bigemp_range
  exchange partition before_1986 with table extra_tab including indexes;

drop table extra_tab purge;

drop table drop_me purge;

create table drop_me (
  empno number not null, sal number not null, job varchar2(12) not null,
  deptno number not null, hiredate date not null)
  storage (initial 10M next 10M maxextents unlimited);

insert /*+APPEND */ into drop_me (empno, sal, job, deptno, hiredate)
select empno+t.column_value*300000 empno, sal, job, deptno,
       hiredate+mod(t.column_value,1000) hiredate
from scott.emp, table(system.counter(1,300000) ) t;
commit;

drop table drop_me -- purge;