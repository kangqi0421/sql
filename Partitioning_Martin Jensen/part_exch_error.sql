-- part_exch_error.sql
-- Partition exchange / novalidate error - Martin Jensen 29. Dec. 2008, 11,1,0,7

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


drop table extra_tab;

create table extra_tab tablespace users as 
select * from bigemp_range where rownum < 1;

insert into extra_tab (empno, sal, job, deptno, hiredate) values
  (1111, 2222, 'EXTRA', 10, to_date('1985-01-01', 'YYYY-MM_DD'));
commit;

create unique index extra_tab_pk on extra_tab (hiredate, empno)
  tablespace USERS STORAGE (initial 10M next 10M pctincrease 0) compute statistics;

alter table extra_tab add constraint extra_tab_pk primary key (hiredate, empno)
  using index extra_tab_pk;

execute DBMS_STATS.GATHER_TABLE_STATS(null, 'EXTRA_TAB', estimate_percent => 100, -
  method_opt => 'FOR ALL INDEXED COLUMNS size 254');

alter table bigemp_range
  exchange partition before_1982 with table extra_tab including indexes with /*out*/ validation;

alter table bigemp_range
  exchange partition before_1982 with table extra_tab including indexes without validation;
-----

select a.cnt+b.cnt+c.cnt+d.cnt from
  (select count(1) cnt from bigemp_range 
   where hiredate < to_date('1982-01-01','YYYY-MM-DD')) a,
  (select count(1) cnt from bigemp_range 
   where hiredate >= to_date('1982-01-01','YYYY-MM-DD') and hiredate < to_date('1984-01-01','YYYY-MM-DD')) b,
  (select count(1) cnt from bigemp_range 
   where hiredate >= to_date('1984-01-01','YYYY-MM-DD') and hiredate < to_date('1986-01-01','YYYY-MM-DD')) c,
  (select count(1) cnt from bigemp_range 
   where hiredate >= to_date('1986-01-01','YYYY-MM-DD')) d;

select count(1) from bigemp_range;

-----

select * from bigemp_range where job = 'EXTRA';

select * from bigemp_range partition (before_1982) where job = 'EXTRA';

select count(1) from bigemp_range where job = 'EXTRA' 
and hiredate = to_date('1985-01-01', 'YYYY-MM_DD');

select /*+rule */ count(1) from bigemp_range where job = 'EXTRA' 
and hiredate = to_date('1985-01-01', 'YYYY-MM_DD');
