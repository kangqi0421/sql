-- integrigy / Partition move test  - Martin Jensen - 21. Oct. 2005 - tested on 10.1.0.2, 10.2.0.1, 11.1.0.7

CREATE TABLESPACE "ILM_USERS" 
DATAFILE 'D:\app\mjensen\oradata\O11\ILM_USERS.DBF' SIZE 200M 
AUTOEXTEND ON NEXT 1G MAXSIZE UNLIMITED 
LOGGING EXTENT MANAGEMENT LOCAL AUTOALLOCATE
SEGMENT SPACE MANAGEMENT AUTO;

-------------------------

rem Integrity.sql

drop table bigemp;
drop table bigdept;
create table bigdept (
  DEPTNO  NUMBER not null,
  DNAME  VARCHAR2(14),
  LOC    VARCHAR2(13),
  last_changed date not null)
  partition by range (last_changed) (
    partition first_third values
      less than(to_date('1983-01-01','YYYY-MM-DD')) tablespace users,
    partition second_third values 
      less than(to_date('1987-01-01','YYYY-MM-DD')) tablespace users,
    partition last_third values 
      less than(to_date('2991-01-01','YYYY-MM-DD')) tablespace users)
  tablespace USERS STORAGE (initial 10M next 10M pctincrease 0) ;
insert /*+APPEND */ into bigdept (deptno, dname, loc, last_changed)
select (t.column_value-1)*4+ deptno/10-1, dname, loc,
       to_date('1980-01-01', 'YYYY-MM-DD')+mod(t.column_value,10000) last_changed
from scott.dept, table(system.counter(1,10000) ) t;
commit;
-- 40000 rows

select deptno, count(*) from bigdept
group by deptno having count(*) > 1;

select min(deptno), max(deptno) from bigdept;

create unique index bigdept_pk on bigdept(deptno) global
  tablespace USERS STORAGE (initial 10M next 10M pctincrease 0) ;

alter table bigdept add constraint bigdept_pk primary key (deptno) 
  using index bigdept_pk;

create index bigdept_last on bigdept(last_changed) local
  tablespace USERS STORAGE (initial 10M next 10M pctincrease 0) ;

alter table bigdept enable row movement;

execute DBMS_STATS.GATHER_TABLE_STATS(null, 'BIGDEPT', cascade => true, -
     estimate_percent => 100, method_opt => 'FOR ALL INDEXED COLUMNS size 254');

select partition_name, num_rows from user_tab_partitions
where table_name = 'BIGDEPT'
order by 1;

PARTITION_NAME                   NUM_ROWS
------------------------------ ----------
FIRST_THIRD                          4384
LAST_THIRD                          29772
SECOND_THIRD                         5844

drop table bigemp;
create table bigemp (
  empno number not null, sal number not null, job varchar2(12) not null,
  deptno number not null, hiredate date not null)
  partition by range (hiredate) (
    partition first_third values
      less than(to_date('1983-01-01','YYYY-MM-DD')) tablespace users,
    partition second_third values 
      less than(to_date('1987-01-01','YYYY-MM-DD')) tablespace users,
    partition last_third values 
      less than(to_date('1991-01-01','YYYY-MM-DD')) tablespace users)
  storage (initial 10M next 10M maxextents unlimited);

insert /*+APPEND */ into bigemp (empno, sal, job, deptno, hiredate)
select empno+t.column_value*300000 empno, sal, job, 
       mod(t.column_value,10000) deptno,
       hiredate+mod(t.column_value,1000) hiredate
from scott.emp, table(system.counter(1,300000) ) t;
commit;
-- 4200000 rows

create unique index bigemp_pk on bigemp(empno) global
  tablespace USERS STORAGE (initial 10M next 10M pctincrease 0);

alter table bigemp add constraint bigemp_pk primary key (empno) 
  using index bigemp_pk;

alter table bigemp add constraint dept_fk foreign key (deptno) 
  references bigdept deferrable;

create index bigemp_deptno_fk on bigemp(deptno) local
  tablespace USERS STORAGE (initial 10M next 10M pctincrease 0) ;

alter table bigemp enable row movement;

execute DBMS_STATS.GATHER_TABLE_STATS(null, 'BIGEMP', cascade => true, -
     estimate_percent => 100, method_opt => 'FOR ALL INDEXED COLUMNS size 254');

select partition_name, num_rows from user_tab_partitions
where table_name = 'BIGEMP'
order by 1;

PARTITION_NAME                   NUM_ROWS
------------------------------ ----------
FIRST_THIRD                       1921200
LAST_THIRD                         600000
SECOND_THIRD                      1678800


-- alter index BIGDEPT_LAST rebuild partition first_third;
-- alter index BIGDEPT_LAST rebuild partition second_third;
-- alter index BIGDEPT_LAST rebuild partition last_third;
-- alter index BIGEMP_DEPTNO_FK rebuild partition first_third;
-- alter index BIGEMP_DEPTNO_FK rebuild partition second_third;
-- alter index BIGEMP_DEPTNO_FK rebuild partition last_third;
----------------

select table_name, index_name, tablespace_name,
  blevel, leaf_blocks, num_rows, status, global_stats
from user_indexes
where index_name in (
  select index_name from user_indexes 
  where table_name in ('BIGDEPT', 'BIGEMP'))
order by index_name;

select index_name, partition_name, tablespace_name,
  blevel, leaf_blocks, num_rows, status
from user_ind_partitions
where index_name in (
  select index_name from user_indexes 
  where table_name in ('BIGDEPT', 'BIGEMP'))
order by index_name, partition_name;

select table_name, constraint_name, constraint_type, status 
from user_constraints
where table_name in ('BIGDEPT', 'BIGEMP')
order by table_name;

=============================

column bg format 99999999
column cg format 99999999
column pr format 99999999
column bc format 99999999
column cc format 9999999
column sec format 99999999
select io.block_gets bg, io.consistent_gets cg, io.physical_reads pr, io.block_changes bc,
       io.consistent_changes cc, to_number( to_char( sysdate, 'SSSSS' ) ) sec, 
       sy.value redo_ws, se.value redo_b
from v$sess_io io, v$sysstat sy, v$sesstat se
  where io.sid = ( select sid from v$session where audsid =userenv( 'sessionid' ) )
  and se.sid = io.sid
  and sy.statistic# = 138 -- 104  --  redo blocks written
  and se.statistic# = 133 -- 99 -- redo size;

-- for 9i:
select io.block_gets, io.consistent_gets, io.physical_reads, io.block_changes,
       io.consistent_changes, to_number( to_char( sysdate, 'SSSSS' ) ), 
       sy.value redo_writes, se.value redo_bytes
from v$sess_io io, v$sysstat sy, v$sesstat se
  where io.sid = ( select sid from v$session where audsid =userenv( 'sessionid' ) )
  and se.sid = io.sid
  and sy.statistic# = 104  --  redo blocks written
  and se.statistic# = 99 -- redo size;

       BG        CG        PR        BC       CC       SEC    REDO_WS     REDO_B
--------- --------- --------- --------- -------- --------- ---------- ----------
  5375920   4475695    445601   4143375      576     32637    1478588  723628332

ALTER TABLE bigemp MOVE PARTITION first_third TABLESPACE ILM_USERS UPDATE INDEXES;
-- Elapsed: 00:05:10.99
-- i 9i er det kun muligt at specificere 'UPDATE GLOBAL INDEXES
-- ALTER TABLE bigemp MOVE PARTITION first_third TABLESPACE ILM_USERS UPDATE GLOBAL INDEXES;
-- herefter skal lokale indexes retableres:
-- alter index BIGEMP_DEPTNO_FK rebuild partition first_third online;

       BG        CG        PR        BC       CC       SEC    REDO_WS     REDO_B
--------- --------- --------- --------- -------- --------- ---------- ----------
 11263473   4498735    552294   8046690      688     32984    2525598 1236909124

ALTER TABLE bigdept MOVE PARTITION first_third TABLESPACE ILM_USERS UPDATE INDEXES;
-- Elapsed: 00:00:00.86

       BG        CG        PR        BC       CC       SEC    REDO_WS     REDO_B
--------- --------- --------- --------- -------- --------- ---------- ----------
 11273185   4499203    552357   8056230      716     33036    2528180 1238142996

select index_name, partition_name, status from user_ind_partitions
where index_name in (select index_name from user_indexes 
                     where table_name in ('BIGDEPT', 'BIGEMP'))
order by index_name, partition_name;

============================ check direct-load

set autotrace on stat
insert /*+APPEND */ into bigemp (empno, sal, job, deptno, hiredate)
select empno+t.column_value*300000 empno, sal, job, 
       mod(t.column_value,40000) deptno,
       hiredate+mod(t.column_value,1000) hiredate
from system.emp, table(system.counter(300001, 10000) ) t;
-- Elapsed: 00:03:14.43

         38  recursive calls
    1269588  db block gets
        995  consistent gets
      23193  physical reads
   99129812  redo size
        649  bytes sent via SQL*Net to client
        782  bytes received via SQL*Net from client
          3  SQL*Net roundtrips to/from client
          2  sorts (memory)
          0  sorts (disk)
     140000  rows processed

rollback;

alter session set CONSTRAINT = DEFERRED;

insert /*+APPEND */ into bigemp (empno, sal, job, deptno, hiredate)
select empno+t.column_value*300000 empno, sal, job, 
       mod(t.column_value,40000) deptno,
       hiredate+mod(t.column_value,1000) hiredate
from system.emp, table(system.counter(300001, 10000) ) t;
-- Elapsed: 00:04:08.30

         38  recursive calls
    1269586  db block gets
        995  consistent gets
      22904  physical reads
   99129752  redo size
        649  bytes sent via SQL*Net to client
        782  bytes received via SQL*Net from client
          3  SQL*Net roundtrips to/from client
          2  sorts (memory)
          0  sorts (disk)
     140000  rows processed

rollback;

alter session set CONSTRAINT = DEFAULT;
alter table bigemp modify constraint dept_fk rely;

insert /*+APPEND */ into bigemp (empno, sal, job, deptno, hiredate)
select empno+t.column_value*300000 empno, sal, job, 
       mod(t.column_value,40000) deptno,
       hiredate+mod(t.column_value,1000) hiredate
from system.emp, table(system.counter(300001, 10000) ) t;
-- Elapsed: 00:04:13.60

        298  recursive calls
    1269575  db block gets
       1115  consistent gets
      24705  physical reads
   99131248  redo size
        649  bytes sent via SQL*Net to client
        782  bytes received via SQL*Net from client
          3  SQL*Net roundtrips to/from client
         11  sorts (memory)
          0  sorts (disk)
     140000  rows processed

rollback;

alter table bigemp modify constraint dept_fk novalidate;

insert /*+APPEND */ into bigemp (empno, sal, job, deptno, hiredate)
select empno+t.column_value*300000 empno, sal, job, 
       mod(t.column_value,40000) deptno,
       hiredate+mod(t.column_value,1000) hiredate
from system.emp, table(system.counter(300001, 10000) ) t;
-- Elapsed: 00:03:51.47

        298  recursive calls
    1269572  db block gets
       1112  consistent gets
      23742  physical reads
   99130336  redo size
        649  bytes sent via SQL*Net to client
        782  bytes received via SQL*Net from client
          3  SQL*Net roundtrips to/from client
         11  sorts (memory)
          0  sorts (disk)
     140000  rows processed

rollback;

alter table bigemp modify constraint dept_fk disable;

insert /*+APPEND */ into bigemp (empno, sal, job, deptno, hiredate)
select empno+t.column_value*300000 empno, sal, job, 
       mod(t.column_value,40000) deptno,
       hiredate+mod(t.column_value,1000) hiredate
from system.emp, table(system.counter(300001, 10000) ) t;
-- Elapsed: 00:00:31.51

Statistics
---------------------------------------------------
        371  recursive calls
      17595  db block gets
        155  consistent gets
       5389  physical reads
    9892504  redo size
        633  bytes sent via SQL*Net to client
        782  bytes received via SQL*Net from client
          3  SQL*Net roundtrips to/from client
         11  sorts (memory)
          2  sorts (disk)
     140000  rows processed

alter table bigemp modify constraint dept_fk enable;
-- Elapsed: 00:00:17.40

==============  shrink  =================

alter table bigemp shrink space cascade;

alter table bigdept shrink space cascade;

alter table bigemp modify partition first_third shrink space cascade;