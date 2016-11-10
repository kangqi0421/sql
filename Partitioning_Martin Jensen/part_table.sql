
rem Martin Jensen - partition a table - 25. Oct. 2005 - tested on 10.1.0.4, 10.2.0.1, 11.1.0.7

alter session set nls_language = American;

------------------------- On re-Partitioning 

drop type t1_rec_typ;

create or replace type t1_rec_typ as table of number;
/

  create or replace function counter(start_no number, offset number)
    return t1_rec_typ
    pipelined
  is
  begin
    for i in start_no..start_no+offset-1 loop
      pipe row(i);
    end loop;
    return;
  end;
/

================= partitioning of a non table =============

drop table bigemp purge;
drop table bigemp_fact purge;

create table bigemp (
  empno number not null, sal number not null, job varchar2(12) not null,
  deptno number not null, hiredate date not null)
  tablespace users storage (initial 10M next 10M maxextents unlimited);

insert /*+APPEND */ into bigemp (empno, sal, job, deptno, hiredate)
select empno+t.column_value*300000 empno, sal, job, deptno,
       hiredate+mod(t.column_value,1000) hiredate
from scott.emp, table(system.counter(1,300000) ) t;
commit;
-- 4200000 rows

create unique index bigemp_pk on bigemp (hiredate, empno) 
  tablespace USERS STORAGE (initial 10M next 10M pctincrease 0) compute statistics;

alter table bigemp add constraint bigemp_pk primary key (hiredate, empno)
  using index bigemp_pk;

create unique index bigemp_empno on bigemp (empno) 
  tablespace USERS STORAGE (initial 10M next 10M pctincrease 0) compute statistics;

create bitmap index bigemp_job_bix on bigemp(job) 
  tablespace USERS STORAGE (initial 10M next 10M pctincrease 0) compute statistics;

execute DBMS_STATS.GATHER_TABLE_STATS(null, 'BIGEMP', estimate_percent => 100, -
  method_opt => 'FOR ALL INDEXED COLUMNS size 254', cascade => false);

select blocks from user_tables where table_name = 'BIGEMP';
-- 20623
select sum(leaf_blocks) from user_indexes where table_name = 'BIGEMP';
-- 25638

---

drop table bigemp_range purge;

create table bigemp_Range (
  empno number not null, sal number not null, job varchar2(12) not null,
  deptno number not null, hiredate date not null)
  partition by range (hiredate)
  ( partition rest values LESS THAN (MAXVALUE))
  tablespace users storage (initial 10M next 10M maxextents unlimited);

create unique index bigemp_range_pk on bigemp_range(hiredate, empno) local
  tablespace USERS STORAGE (initial 10M next 10M pctincrease 0) compute statistics;

alter table bigemp_range add constraint bigemp_range_pk 
  primary key (hiredate, empno)
  using index bigemp_range_pk;

create unique index bigemp_range_empno on bigemp_range (empno) global
  tablespace USERS STORAGE (initial 10M next 10M pctincrease 0) compute statistics;

create bitmap index bigemp_range_job_bix on bigemp_range(job) local
  tablespace USERS STORAGE (initial 10M next 10M pctincrease 0) compute statistics;

alter table bigemp_range enable row movement;

execute DBMS_STATS.GATHER_TABLE_STATS(null, 'BIGEMP_RANGE', estimate_percent => 100, -
  method_opt => 'FOR ALL INDEXED COLUMNS size 254');

column name format a30
column subname format a30
select object_name name, subobject_name subname, object_id from user_objects
where object_name in ('BIGEMP', 'BIGEMP_RANGE', 
  'BIGEMP_PKEY', 'BIGEMP_JOB_BIX', 'BIGEMP_RANGE_PK', 'BIGEMP_RANGE_JOB_BIX'); 

NAME                           SUBNAME                         OBJECT_ID
------------------------------ ------------------------------ ----------
BIGEMP                                                             52071
BIGEMP_JOB_BIX                                                     52073
BIGEMP_PKEY                                                        52072
BIGEMP_RANGE                   REST                                52075
BIGEMP_RANGE                                                       52074
BIGEMP_RANGE_JOB_BIX           REST                                52079
BIGEMP_RANGE_JOB_BIX                                               52078
BIGEMP_RANGE_PK                REST                                52077
BIGEMP_RANGE_PK                                                    52076

select table_name, tablespace_name from user_tables
where table_name in ('BIGEMP');

select table_name, partition_name, tablespace_name from user_tab_partitions
where table_name in ('BIGEMP_RANGE');


       BG        CG        PR        BC       CC       SEC    REDO_WS     REDO_B
--------- --------- --------- --------- -------- --------- ---------- ----------
   104355    249071    288278     30261      936     34071     269296  130132040

alter table bigemp_Range exchange partition rest with table bigemp
including indexes without validation;

-- ORA-14098: index mismatch for tables in ALTER TABLE EXCHANGE PARTITION

drop index bigemp_range_empno;
drop index bigemp_empno;

alter table bigemp_Range exchange partition rest with table bigemp
including indexes without validation;

select partition_name, blocks from user_tab_partitions 
where table_name = 'BIGEMP_RANGE';
-- REST                                20623

select partition_name, header_block, header_block+blocks end_block, blocks 
from dba_segments
where segment_name = 'BIGEMP_RANGE'
order by 1,2;

-- REST                                   1420      22924      21504

-- ifdef split_strategy
delete from bigemp_range where job = 'SALESMAN';
commit;
execute DBMS_STATS.GATHER_TABLE_STATS(null, 'BIGEMP_RANGE', estimate_percent => 100, -
  cascade => false, method_opt => 'FOR ALL COLUMNS SIZE 1');
select partition_name, blocks, empty_blocks from user_tab_partitions 
where table_name = 'BIGEMP_RANGE';
-- REST                                20623

-- efter split:
-- BEFORE_1982                          1784            0
-- REST                                12780            0
-- total                               14565
-- end if

select table_name, tablespace_name from user_tables
where table_name in ('BIGEMP');

select table_name, partition_name, tablespace_name from user_tab_partitions
where table_name in ('BIGEMP_RANGE');

Forløbet: 00:00:00.38

       BG        CG        PR        BC       CC       SEC    REDO_WS     REDO_B
--------- --------- --------- --------- -------- --------- ---------- ----------
   108681    250125    288288     35634     1157     34097     270623  130779292

-- The tables may now be renamed so that the bigemp_range is in fact the good old bigemp.
-- and all invalid database objects recompiled

-- the object id's seems to be consistent:

select object_name name, subobject_name subname, object_id from user_objects
where object_name in ('BIGEMP', 'BIGEMP_RANGE', 
  'BIGEMP_PKEY', 'BIGEMP_JOB_BIX', 'BIGEMP_RANGE_PK', 'BIGEMP_RANGE_JOB_BIX'); 

NAME                           SUBNAME                         OBJECT_ID
------------------------------ ------------------------------ ----------
BIGEMP                                                             52071
BIGEMP_JOB_BIX                                                     52073
BIGEMP_PKEY                                                        52072
BIGEMP_RANGE                   REST                                52075
BIGEMP_RANGE                                                       52074
BIGEMP_RANGE_JOB_BIX           REST                                52079
BIGEMP_RANGE_JOB_BIX                                               52078
BIGEMP_RANGE_PK                REST                                52077
BIGEMP_RANGE_PK                                                    52076

select to_char(hiredate, 'yyyy'), count(*) from bigemp_Range
group by to_char(hiredate, 'yyyy')
order by 1;

TO_C   COUNT(*)
---- ----------
1980       4500
1981     609300
1982    1314300
1983    1469100
1984     645000
1985     157800

       BG        CG        PR        BC       CC       SEC    REDO_WS     REDO_B
--------- --------- --------- --------- -------- --------- ---------- ----------
   108681    280921    318578     35634     1157     34328     270688  130779292

-- alter session set sql_trace = true;

alter table bigemp_Range split partition rest at 
  (to_date('1982-01-01','YYYY-MM-DD')) into
  (partition before_1982 /* tablespace ilm_users */, partition rest) update indexes;


select partition_name, header_block, header_block+blocks end_block, blocks 
from dba_segments
where segment_name = 'BIGEMP_RANGE'
order by 1,2;

-- BEFORE_1982                          129164     132236       3072
-- REST                                 174348     192780      18432

-- create the local index partitions in special tablespaces:
alter table bigemp_Range split partition rest at 
  (to_date('1982-01-01','YYYY-MM-DD')) into
  (partition before_1982 /* tablespace ilm_users */, partition rest) 
  update indexes ( bigemp_range_pk (partition before_1982 tablespace ilm_users, partition rest),
                   bigemp_range_job_bix (partition before_1982 tablespace ilm_users, partition rest)) ;

alter table bigemp_range modify partition rest shrink space ;

alter table bigemp_range modify partition rest rebuild unusable local indexes;

-- now also using shrink
alter table bigemp_Range split partition rest at 
  (to_date('1982-01-01','YYYY-MM-DD')) into
  (partition before_1982 /* tablespace ilm_users */, partition rest ) 
   shrink space update indexes;

select * from user_tab_partitions
where table_name = 'BIGEMP_RANGE';
-- last_analyzed not set

select * from user_ind_partitions
where index_name in (select index_name from user_indexes where table_name = 'BIGEMP_RANGE');
-- last_analysed set - and so are the other statisticsl attributes


Forløbet: 00:01:52.67

       BG        CG        PR        BC       CC       SEC    REDO_WS     REDO_B
--------- --------- --------- --------- -------- --------- ---------- ----------
   155477    362914    391212     46412     1439     34505     526667  257470148

alter table bigemp_Range split partition rest at 
  (to_date('1983-01-01','YYYY-MM-DD')) into
  (partition before_1983, partition rest) update indexes;

Forløbet: 00:01:15.15

       BG        CG        PR        BC       CC       SEC    REDO_WS     REDO_B
--------- --------- --------- --------- -------- --------- ---------- ----------
   194602    423857    450787     54091     1769     34655     744419  365426640

alter table bigemp_Range split partition rest at 
  (to_date('1986-01-01','YYYY-MM-DD')) into
  (partition before_1986, partition rest) update indexes;

Forløbet: 00:00:00.32

       BG        CG        PR        BC       CC       SEC    REDO_WS     REDO_B
--------- --------- --------- --------- -------- --------- ---------- ----------
   195441    427321    450795     54925     1803     36035     745567  365529972
   108681    280921    318578     35634     1157     34328     270688  130779292
----------------------------------------------------------------------------------
    86760    146300    132117     19291      646      1708     474879  234750680

select dbms_mview.pmarker(rowid), count(*) from bigemp_Range
group by dbms_mview.pmarker(rowid)
order by 1;

DBMS_MVIEW.PMARKER(ROWID)   COUNT(*)
------------------------- ----------
                    52045     613800
                    52055    1314300
                    52056    2271900

-- not all in:

column name format a30
select nvl(o.object_name,null,o.object_name||' part: '||o.subobject_name) name, p.id, p.cnt 
from user_objects o,
   (select dbms_mview.pmarker(rowid) id, count(*) cnt from bigemp_Range
    group by dbms_mview.pmarker(rowid)) p
where o.object_id(+) = p.id
order by name;

NAME                                   ID        CNT
------------------------------ ---------- ----------
                                    52056    2271900
BIGEMP_RANGE part: BEFORE_1982      52045     613800
BIGEMP_RANGE part: BEFORE_1983      52055    1314300

alter index BIGEMP_RANGE_PK rebuild partition before_1986;
alter index BIGEMP_RANGE_PK rebuild partition before_1983;
alter index BIGEMP_RANGE_JOB_BIX rebuild partition before_1986;
alter index BIGEMP_RANGE_JOB_BIX rebuild partition before_1983;

execute DBMS_STATS.GATHER_TABLE_STATS(null, 'BIGEMP_RANGE', estimate_percent => 100, -
  method_opt => 'FOR ALL INDEXED COLUMNS size 254');

==========================================
--- try reverse split

       BG        CG        PR        BC       CC       SEC    REDO_WS     REDO_B
--------- --------- --------- --------- -------- --------- ---------- ----------
   298467    701950    868172     87466     2779     37545    1262471  620260828

alter table bigemp_Range split partition rest at 
  (to_date('1986-01-01','YYYY-MM-DD')) into
  (partition before_1986, partition rest) update indexes;

Forløbet: 00:00:00.48

       BG        CG        PR        BC       CC       SEC    REDO_WS     REDO_B
--------- --------- --------- --------- -------- --------- ---------- ----------
   305615    703914    868177     94597     2937     37580    1264171  621095156

alter table bigemp_Range split partition before_1986 at 
  (to_date('1983-01-01','YYYY-MM-DD')) into
  (partition before_1983, partition before_1986) update indexes;

Forløbet: 00:01:23.27

       BG        CG        PR        BC       CC       SEC    REDO_WS     REDO_B
--------- --------- --------- --------- -------- --------- ---------- ----------
   352892    772282    940421    106108     3290     37692    1519872  747884664

alter table bigemp_Range split partition before_1983 at 
  (to_date('1982-01-01','YYYY-MM-DD')) into
  (partition before_1982, partition before_1983) update indexes;

Forløbet: 00:00:31.97

       BG        CG        PR        BC       CC       SEC    REDO_WS     REDO_B
--------- --------- --------- --------- -------- --------- ---------- ----------
   375486    805936    960304    111579     3516     37760    1637412  806151068
   298467    701950    868172     87466     2779     37545    1262471  620260828
---------------------------------------------------------------------------------
    77019    103986     92132     24113      737       215     374941  185890240 

select dbms_mview.pmarker(rowid), count(*) from bigemp_Range
group by dbms_mview.pmarker(rowid)
order by 1;

DBMS_MVIEW.PMARKER(ROWID)   COUNT(*)
------------------------- ----------
                    51815    2271900
                    51824     613800
                    51825    1314300

drop table bigemp purge;
drop table bigemp_fact purge;
drop table bigemp_range purge;


----------------

Tests:
set timing on

-- A. Insert as select with indexes
==========================================

alter table bigemp_Range split partition rest at 
  (to_date('1982-01-01','YYYY-MM-DD')) into
  (partition before_1982, partition rest);
-- Forløbet: 00:00:00.49 - Elapsed: 00:00:00.14

alter table bigemp_Range split partition rest at 
  (to_date('1983-01-01','YYYY-MM-DD')) into
  (partition before_1983, partition rest);
-- Forløbet: 00:00:00.11 - Elapsed: 00:00:00.04

alter table bigemp_Range split partition rest at 
  (to_date('1986-01-01','YYYY-MM-DD')) into
  (partition before_1986, partition rest);
-- Forløbet: 00:00:00.16 - Elapsed: 00:00:00.04

insert /*+APPEND */ into bigemp_range select * from bigemp;
-- Forløbet: 00:05:36.33 - Elapsed: 00:04:23.93
commit;
-- Forløbet: 00:00:01.98 - Elapsed: 00:00:00.53

truncate table bigemp;
-- Forløbet: 00:00:01.46 - Elapsed: 00:00:00.45

execute DBMS_STATS.GATHER_TABLE_STATS(null, 'BIGEMP_RANGE', -
  estimate_percent => 100, cascade => true, method_opt => 'FOR ALL COLUMNS SIZE 1');
-- Forløbet: 00:02:58.76 - Elapsed: 00:01:33.29

select sum(blocks) from user_tab_partitions where table_name = 'BIGEMP_RANGE';
-- 20740

select index_name, partition_name, leaf_blocks, status, last_analyzed
from user_ind_partitions
where index_name in (select index_name from user_indexes where table_name = 'BIGEMP_RANGE')
order by 1, 2;

select index_name, leaf_blocks, status 
from user_indexes where table_name = 'BIGEMP_RANGE'
order by 1, 2;

select sum(leaf_blocks) from user_indexes where table_name = 'BIGEMP_RANGE';
--  25143

-- B. Insert as select without indexes but added as last step
=========================================================

alter table bigemp_range drop constraint bigemp_range_pk;
drop index bigemp_range_pk;
drop index bigemp_range_empno;
drop index bigemp_range_job_bix;

alter table bigemp_Range split partition rest at 
  (to_date('1982-01-01','YYYY-MM-DD')) into
  (partition before_1982, partition rest);
-- Forløbet: 00:00:00.11 - Elapsed: 00:00:00.09

alter table bigemp_Range split partition rest at 
  (to_date('1983-01-01','YYYY-MM-DD')) into
  (partition before_1983, partition rest);
-- Forløbet: 00:00:00.05 - elapsed: 00:00:00.03

alter table bigemp_Range split partition rest at 
  (to_date('1986-01-01','YYYY-MM-DD')) into
  (partition before_1986, partition rest);
-- Forløbet: 00:00:00.05 - elapsed: 00:00:00.03

insert /*+APPEND */ into bigemp_range select * from bigemp;
-- Forløbet: 00:00:20.15 - Elapsed: 00:00:11.95
commit;
-- Forløbet: 00:00:00.01 - Elapsed: 00:00:00.00

truncate table bigemp;
-- Forløbet: 00:00:02.45 - Elapsed: 00:00:00.23

execute DBMS_STATS.GATHER_TABLE_STATS(null, 'BIGEMP_RANGE', estimate_percent => 100, -
  cascade => false, method_opt => 'FOR ALL COLUMNS SIZE 1');
-- Forløbet: 00:01:22.61 - Elapsed: 00:00:41.29

select sum(blocks) from user_tab_partitions where table_name = 'BIGEMP_RANGE';
-- 20740

create unique index bigemp_range_pk on bigemp_range(hiredate, empno) local
  tablespace USERS STORAGE (initial 10M next 10M pctincrease 0) compute statistics;
-- Forløbet: 00:01:01.27 - Elapsed: 00:00:18.45

alter table bigemp_range add constraint bigemp_range_pk 
  primary key (hiredate, empno)
  using index bigemp_range_pk;
-- Forløbet: 00:00:00.09 - Elapsed: 00:00:00.01

create unique index bigemp_range_empno on bigemp_range (empno) global
  tablespace USERS STORAGE (initial 10M next 10M pctincrease 0) compute statistics;
-- Forløbet: 00:00:51.71 - Elapsed: 00:00:18.70

create bitmap index bigemp_range_job_bix on bigemp_range(job) local
  tablespace USERS STORAGE (initial 10M next 10M pctincrease 0) compute statistics;
-- Forløbet: 00:00:10.38 - Elapsed: 00:00:05.51

select sum(leaf_blocks) from user_indexes where table_name = 'BIGEMP_RANGE';
-- 27984

-- C. Split with index rebuild
=============================================

drop index bigemp_empno;
-- Forløbet: 00:00:00.11 - Elapsed: 00:00:00.06

alter table bigemp_Range exchange partition rest with table bigemp
including indexes without validation;
-- Forløbet: 00:00:00.15 - Elapsed: 00:00:00.25

select partition_name, blocks
from user_tab_partitions where table_name = 'BIGEMP_RANGE'
order by 1;
-- REST                                20623

alter table bigemp_Range split partition rest at 
  (to_date('1982-01-01','YYYY-MM-DD')) into
  (partition before_1982, partition rest);
-- Forløbet: 00:00:21.87 - Elapsed: 00:00:13.20

alter table bigemp_Range split partition rest at 
  (to_date('1983-01-01','YYYY-MM-DD')) into
  (partition before_1983, partition rest);
-- Forløbet: 00:00:18.91 - Elapsed: 00:00:10.79

alter table bigemp_Range split partition rest at 
  (to_date('1986-01-01','YYYY-MM-DD')) into
  (partition before_1986, partition rest);
-- Forløbet: 00:00:05.67 - Elapsed: 00:00:06.12

select index_name, partition_name, leaf_blocks, status, last_analyzed
from user_ind_partitions
where index_name in (select index_name from user_indexes where table_name = 'BIGEMP_RANGE')
order by 1, 2;

-- execute DBMS_STATS.GATHER_TABLE_STATS(null, 'BIGEMP_RANGE', estimate_percent => 100, -
--   cascade => false, method_opt => 'FOR ALL COLUMNS SIZE 1');
-- Forløbet: 00:09:59.62 -- tæller ikke med

select partition_name, blocks
from user_tab_partitions where table_name = 'BIGEMP_RANGE'
order by 1;
-- BEFORE_1982                          3072
-- BEFORE_1983                          6543
-- BEFORE_1986                         11125
-- REST                                    0

-- alter table bigemp_range modify partition before_1982 shrink space ;
-- forløbet: 00:00:00.06

-- alter table bigemp_range modify partition before_1983 shrink space ;
-- forløbet: 00:00:00.02

-- alter table bigemp_range modify partition before_1986 shrink space ;
-- forløbet: 00:00:00.01

-- alter table bigemp_range modify partition rest shrink space ;
-- forløbet: 00:00:00.02

execute DBMS_STATS.GATHER_TABLE_STATS(null, 'BIGEMP_RANGE', estimate_percent => 100, -
  cascade => false, method_opt => 'FOR ALL COLUMNS SIZE 1');
-- Forløbet: 00:02:20.90 - Elapsed: 00:00:40.17

select partition_name, blocks
from user_tab_partitions where table_name = 'BIGEMP_RANGE'
order by 1;
-- BEFORE_1982                          3072
-- BEFORE_1983                          6543
-- BEFORE_1986                         11125
-- REST                                    0

select sum(blocks)
from user_tab_partitions where table_name = 'BIGEMP_RANGE';
--  20740

select index_name, partition_name, leaf_blocks, status, last_analyzed
from user_ind_partitions
where index_name in (select index_name from user_indexes where table_name = 'BIGEMP_RANGE')
order by 1, 2;
-- unusable

alter table bigemp_range modify partition rest rebuild unusable local indexes;
-- Forløbet: 00:00:00.09 - Elapsed: 00:00:01.56

alter table bigemp_range modify partition before_1986 rebuild unusable local indexes;
-- Forløbet: 00:00:31.75 - Elapsed: 00:00:08.68

alter table bigemp_range modify partition before_1983 rebuild unusable local indexes;
-- Forløbet: 00:00:24.52 - Elapsed: 00:00:08.39

alter table bigemp_range modify partition before_1982 rebuild unusable local indexes;
-- Forløbet: 00:00:09.08 - Elapsed: 00:00:01.75

select sum(leaf_blocks) from user_ind_partitions
where index_name in (select index_name from user_indexes where table_name = 'BIGEMP_RANGE');
-- 15207

alter index bigemp_range_empno rebuild;
-- Forløbet: 00:00:50.84 - Elapsed: 00:00:18.85

-- create unique index bigemp_range_empno on bigemp_range (empno) global
--   tablespace USERS STORAGE (initial 10M next 10M pctincrease 0) compute statistics;
-- Forløbet: 00:00:53.34

select sum(leaf_blocks) from user_indexes where table_name = 'BIGEMP_RANGE';
-- 12777

-- D. Split the other way round with index rebuild 
===========================================================

drop index bigemp_empno;
-- Forløbet: 00:00:00.11 - Elapsed: 00:00:00.03

alter table bigemp_Range exchange partition rest with table bigemp
including indexes without validation;
-- Forløbet: 00:00:00.15

select partition_name, blocks
from user_tab_partitions where table_name = 'BIGEMP_RANGE'
order by 1;
-- REST                                20623

alter table bigemp_Range split partition rest at 
  (to_date('1986-01-01','YYYY-MM-DD')) into
  (partition before_1986, partition rest);
-- Forløbet: 00:00:00.15 - Elapsed: 00:00:00.23

alter table bigemp_Range split partition before_1986 at 
  (to_date('1983-01-01','YYYY-MM-DD')) into
  (partition before_1983, partition before_1986);
-- Forløbet: 00:00:22.69 - Elapsed: 00:00:11.98

alter table bigemp_Range split partition before_1983 at 
  (to_date('1982-01-01','YYYY-MM-DD')) into
  (partition before_1982, partition before_1983);
-- Forløbet: 00:00:12.16 - Elapsed: 00:00:11.01

select index_name, partition_name, leaf_blocks, status, last_analyzed
from user_ind_partitions
where index_name in (select index_name from user_indexes where table_name = 'BIGEMP_RANGE')
order by 1, 2;

-- execute DBMS_STATS.GATHER_TABLE_STATS(null, 'BIGEMP_RANGE', estimate_percent => 100, -
--   cascade => false, method_opt => 'FOR ALL COLUMNS SIZE 1');
-- Forløbet: 00:09:59.62 -- tæller ikke med

select partition_name, blocks
from user_tab_partitions where table_name = 'BIGEMP_RANGE'
order by 1;
-- BEFORE_1982                          3072
-- BEFORE_1983                          6543
-- BEFORE_1986                         11125
-- REST                                    0

-- alter table bigemp_range modify partition before_1982 shrink space ;
-- forløbet: 00:00:00.06

-- alter table bigemp_range modify partition before_1983 shrink space ;
-- forløbet: 00:00:00.02

-- alter table bigemp_range modify partition before_1986 shrink space ;
-- forløbet: 00:00:00.01

-- alter table bigemp_range modify partition rest shrink space ;
-- forløbet: 00:00:00.02

execute DBMS_STATS.GATHER_TABLE_STATS(null, 'BIGEMP_RANGE', estimate_percent => 100, -
  cascade => false, method_opt => 'FOR ALL COLUMNS SIZE 1');
-- Forløbet: 00:01:20.57 - Elapsed: 00:00:40.15

select partition_name, blocks
from user_tab_partitions where table_name = 'BIGEMP_RANGE'
order by 1;
-- BEFORE_1982                          3072
-- BEFORE_1983                          6543
-- BEFORE_1986                         11125
-- REST                                    0

select sum(blocks)
from user_tab_partitions where table_name = 'BIGEMP_RANGE';
--  20740

select index_name, partition_name, leaf_blocks, status, last_analyzed
from user_ind_partitions
where index_name in (select index_name from user_indexes where table_name = 'BIGEMP_RANGE')
order by 1, 2;
-- unusable

alter table bigemp_range modify partition rest rebuild unusable local indexes;
-- Forløbet: 00:00:00.07 - Elapsed: 00:00:01.57

alter table bigemp_range modify partition before_1986 rebuild unusable local indexes;
-- Forløbet: 00:00:40.14 - Elapsed: 00:00:08.50

alter table bigemp_range modify partition before_1983 rebuild unusable local indexes;
-- Forløbet: 00:00:19.57 - Elapsed: 00:00:08.51

alter table bigemp_range modify partition before_1982 rebuild unusable local indexes;
-- Forløbet: 00:00:07.52 - Elapsed: 00:00:01.89

select sum(leaf_blocks) from user_ind_partitions
where index_name in (select index_name from user_indexes where table_name = 'BIGEMP_RANGE');
-- 15207

alter index bigemp_range_empno rebuild;
-- Forløbet: 00:00:51.84 - Elapsed: 00:00:18.53

-- create unique index bigemp_range_empno on bigemp_range (empno) global
--   tablespace USERS STORAGE (initial 10M next 10M pctincrease 0) compute statistics;
-- Forløbet: 00:00:53.34

select sum(leaf_blocks) from user_indexes where table_name = 'BIGEMP_RANGE';
-- 12777

-- E. Split with index rebuild during the process
=========================================================

drop index bigemp_empno;
-- Forløbet: 00:00:00.11 -  00:00:00.06

alter table bigemp_Range exchange partition rest with table bigemp
including indexes without validation;
-- Forløbet: 00:00:00.14 - Forløbet: 00:00:00.26

select partition_name, blocks
from user_tab_partitions where table_name = 'BIGEMP_RANGE'
order by 1;
-- REST                                20623

alter table bigemp_Range split partition rest at 
  (to_date('1986-01-01','YYYY-MM-DD')) into
  (partition before_1986, partition rest);
-- Forløbet: 00:00:00.12 - 00:00:11.81

alter table bigemp_Range split partition before_1986 at 
  (to_date('1983-01-01','YYYY-MM-DD')) into
  (partition before_1983, partition before_1986);
-- Forløbet: 00:00:23.07 - 00:00:11.60

alter table bigemp_Range split partition before_1983 at 
  (to_date('1982-01-01','YYYY-MM-DD')) into
  (partition before_1982, partition before_1983) update indexes;
-- Forløbet: 00:00:44.27 - 00:00:14.45

select index_name, partition_name, leaf_blocks, status, last_analyzed
from user_ind_partitions
where index_name in (select index_name from user_indexes where table_name = 'BIGEMP_RANGE')
order by 1, 2;

-- execute DBMS_STATS.GATHER_TABLE_STATS(null, 'BIGEMP_RANGE', estimate_percent => 100, -
--   cascade => false, method_opt => 'FOR ALL COLUMNS SIZE 1');
-- Forløbet: 00:09:59.62 -- tæller ikke med

select partition_name, blocks
from user_tab_partitions where table_name = 'BIGEMP_RANGE'
order by 1;
-- BEFORE_1982                          3072
-- BEFORE_1983                          6543
-- BEFORE_1986                         11125
-- REST                                    0

-- alter table bigemp_range modify partition before_1982 shrink space ;
-- forløbet: 00:00:00.06

-- alter table bigemp_range modify partition before_1983 shrink space ;
-- forløbet: 00:00:00.02

-- alter table bigemp_range modify partition before_1986 shrink space ;
-- forløbet: 00:00:00.01

-- alter table bigemp_range modify partition rest shrink space ;
-- forløbet: 00:00:00.02

execute DBMS_STATS.GATHER_TABLE_STATS(null, 'BIGEMP_RANGE', estimate_percent => 100, -
  cascade => false, method_opt => 'FOR ALL COLUMNS SIZE 1');
-- Forløbet: 00:01:19.36 - 00:00:39.81

select partition_name, blocks
from user_tab_partitions where table_name = 'BIGEMP_RANGE'
order by 1;
-- BEFORE_1982                          3072
-- BEFORE_1983                          6543
-- BEFORE_1986                         11125
-- REST                                    0

select sum(blocks)
from user_tab_partitions where table_name = 'BIGEMP_RANGE';
--  20740

select index_name, partition_name, leaf_blocks, status, last_analyzed
from user_ind_partitions
where index_name in (select index_name from user_indexes where table_name = 'BIGEMP_RANGE')
order by 1, 2;
-- unusable

alter table bigemp_range modify partition rest rebuild unusable local indexes;
-- Forløbet: 00:00:00.10 - 00:00:01.50

alter table bigemp_range modify partition before_1986 rebuild unusable local indexes;
-- Forløbet: 00:00:42.19 - 00:00:09.89

-- alter table bigemp_range modify partition before_1983 rebuild unusable local indexes;
-- Forløbet: 00:00:19.57

-- alter table bigemp_range modify partition before_1982 rebuild unusable local indexes;
-- Forløbet: 00:00:07.52

select sum(leaf_blocks) from user_ind_partitions
where index_name in (select index_name from user_indexes where table_name = 'BIGEMP_RANGE');
-- 15207

alter index bigemp_range_empno rebuild;
-- Forløbet: 00:00:53.12 - 00:00:20.37

-- create unique index bigemp_range_empno on bigemp_range (empno) global
--   tablespace USERS STORAGE (initial 10M next 10M pctincrease 0) compute statistics;
-- Forløbet: 00:00:53.34

select index_name, leaf_blocks, status, last_analyzed
from user_indexes where table_name = 'BIGEMP_RANGE';

-- F. Split with index rebuild during the process
================================================

drop index bigemp_empno;
-- Forløbet: 00:00:00.11 - 00:00:00.01

alter table bigemp_Range exchange partition rest with table bigemp
including indexes without validation update indexes;
-- Forløbet: 00:02:07.68 -  00:01:04.50

select index_name, leaf_blocks, status, last_analyzed
from user_indexes where table_name = 'BIGEMP_RANGE';

select partition_name, blocks
from user_tab_partitions where table_name = 'BIGEMP_RANGE'
order by 1;
-- REST                                20623


alter table bigemp_Range split partition rest at 
  (to_date('1986-01-01','YYYY-MM-DD')) into
  (partition before_1986, partition rest) update indexes;
-- Forløbet: 00:00:00.19 - 00:04:05.59

alter table bigemp_Range split partition before_1986 at 
  (to_date('1983-01-01','YYYY-MM-DD')) into
  (partition before_1983, partition before_1986) update indexes;
-- Forløbet: 00:08:13.57 - 00:04:01.40

alter table bigemp_Range split partition before_1983 at 
  (to_date('1982-01-01','YYYY-MM-DD')) into
  (partition before_1982, partition before_1983) update indexes;
-- Forløbet: 00:02:51.29 - 00:02:13.15

select index_name, partition_name, leaf_blocks, status, last_analyzed
from user_ind_partitions
where index_name in (select index_name from user_indexes where table_name = 'BIGEMP_RANGE')
order by 1, 2;

-- execute DBMS_STATS.GATHER_TABLE_STATS(null, 'BIGEMP_RANGE', estimate_percent => 100, -
--   cascade => false, method_opt => 'FOR ALL COLUMNS SIZE 1');
-- Forløbet: 00:09:59.62 -- tæller ikke med

select partition_name, blocks
from user_tab_partitions where table_name = 'BIGEMP_RANGE'
order by 1;
-- BEFORE_1982                          3072
-- BEFORE_1983                          6543
-- BEFORE_1986                         11125
-- REST                                    0

-- alter table bigemp_range modify partition before_1982 shrink space ;
-- forløbet: 00:00:00.06

-- alter table bigemp_range modify partition before_1983 shrink space ;
-- forløbet: 00:00:00.02

-- alter table bigemp_range modify partition before_1986 shrink space ;
-- forløbet: 00:00:00.01

-- alter table bigemp_range modify partition rest shrink space ;
-- forløbet: 00:00:00.02

execute DBMS_STATS.GATHER_TABLE_STATS(null, 'BIGEMP_RANGE', estimate_percent => 100, -
  cascade => false, method_opt => 'FOR ALL COLUMNS SIZE 1');
-- Forløbet: 00:01:23.23 - 00:00:41.98

select partition_name, blocks
from user_tab_partitions where table_name = 'BIGEMP_RANGE'
order by 1;
-- BEFORE_1982                          3072
-- BEFORE_1983                          6543
-- BEFORE_1986                         11125
-- REST                                    0

select sum(blocks)
from user_tab_partitions where table_name = 'BIGEMP_RANGE';
--  20740

select index_name, partition_name, leaf_blocks, status, last_analyzed
from user_ind_partitions
where index_name in (select index_name from user_indexes where table_name = 'BIGEMP_RANGE')
order by 1, 2;
-- usable

select index_name, status, last_analyzed, leaf_blocks from user_ind_partitions
where index_name in (select index_name from user_indexes where table_name = 'BIGEMP_RANGE');
-- 15207

select index_name, leaf_blocks, status, last_analyzed
from user_indexes where table_name = 'BIGEMP_RANGE';

-- G. Manual Split with index rebuild last
================================================

Assume table T has partition P to be split at value V to Pa, and rest stay in P
1. create en ny tabel Ta with signatur like T
2. Insert rows in Ta from P with values less than V (direct load)
3. delete rows from P where rows less than V.
4. P can now be "skrink'ed"
5. Use FAST split to create Pa, at it must be empty..
6. Exchange  Ta with Pa.

drop index bigemp_empno;
-- Forløbet: 00:00:00.65 - 00:00:00.01

alter table bigemp_range drop constraint bigemp_range_pk;
-- Forløbet: 00:00:00.13 -  00:00:00.06

drop index bigemp_range_pk;
-- Forløbet: 00:00:00.20 - 00:00:00.01

drop index bigemp_range_empno;
-- Forløbet: 00:00:00.11 - 00:00:00.03

drop index bigemp_range_job_bix;
-- Forløbet: 00:00:00.08 - 00:00:00.03

alter table bigemp_Range exchange partition rest with table bigemp
excluding indexes without validation;
-- Forløbet: 00:00:00.57 - 00:00:00.20

select partition_name, blocks
from user_tab_partitions where table_name = 'BIGEMP_RANGE'
order by 1;
-- REST                                20623

drop table bigemp_range_temp;

create table bigemp_range_temp
tablespace users storage (initial 10M next 10M maxextents unlimited)
as select * from bigemp_range where rownum < 1;
-- Forløbet: 00:00:00.17 - 00:00:00.03

insert /*+APPEND */ into bigemp_range_temp 
select *
from bigemp_range partition (rest)
where hiredate < to_date('1982-01-01','YYYY-MM-DD');
-- 613800 rækker er oprettet.
-- Forløbet: 00:00:11.66 - 00:00:05.26
commit;
-- Forløbet: 00:00:00.01

delete from bigemp_range partition (rest)
where hiredate < to_date('1982-01-01','YYYY-MM-DD');
-- 613800 rækker er slettet.
-- Forløbet: 00:00:31.82 - 00:00:23.68
commit;
-- Forløbet: 00:00:00.01

alter table bigemp_Range split partition rest at 
  (to_date('1982-01-01','YYYY-MM-DD')) into
  (partition before_1982, partition rest);
-- Forløbet: 00:00:10.91 - 00:00:05.17

select count(*) from bigemp_range partition (before_1982);
-- 0

alter table bigemp_Range exchange partition before_1982 
with table bigemp_range_temp
excluding indexes with validation;
-- Forløbet: 00:00:02.00 - 00:00:01.21
-- Forløbet: 00:00:00.03 (without validation)

select count(*) from bigemp_range_temp;
-- 0

select count(*) from bigemp_range partition (rest)
where hiredate < to_date('1982-01-01','YYYY-MM-DD');
-- 0

insert /*+APPEND */ into bigemp_range_temp 
select *
from bigemp_range partition (rest)
where hiredate < to_date('1983-01-01','YYYY-MM-DD');
-- 1314300 rækker er oprettet.
-- Forløbet: 00:00:14.36 - 00:00:06.20
commit;
-- Forløbet: 00:00:00.01

delete from bigemp_range partition (rest)
where hiredate < to_date('1983-01-01','YYYY-MM-DD');
-- 1314300 rækker er slettet.
-- Forløbet: 00:01:21.40 - 00:00:38.64

alter table bigemp_Range split partition rest at 
  (to_date('1983-01-01','YYYY-MM-DD')) into
  (partition before_1983, partition rest);
-- Forløbet: 00:00:19.00 - 00:00:09.01

select count(*) from bigemp_range partition (before_1983);

select count(*) from bigemp_range_temp;

alter table bigemp_Range exchange partition before_1983 
with table bigemp_range_temp
excluding indexes with validation;
-- Forløbet: 00:00:02.80 - 00:00:02.14
-- Forløbet: 00:00:00.07 (without validation)

alter table bigemp_range modify partition rest shrink space ;
-- Forløbet: 00:04:35.52 - 00:02:47.84

alter table bigemp_Range split partition rest at 
  (to_date('1986-01-01','YYYY-MM-DD')) into
  (partition before_1986, partition rest);
-- Forløbet: 00:00:04.72 - 00:00:05.71

execute DBMS_STATS.GATHER_TABLE_STATS(null, 'BIGEMP_RANGE', estimate_percent => 100, -
  cascade => false, method_opt => 'FOR ALL COLUMNS SIZE 1');
-- Forløbet: 00:01:14.97 - 00:00:41.37

select partition_name, blocks
from user_tab_partitions where table_name = 'BIGEMP_RANGE'
order by 1;
-- BEFORE_1982                          3072
-- BEFORE_1983                          6543
-- BEFORE_1986                         10133 (before 11125)
-- REST                                    0

select sum(blocks)
from user_tab_partitions where table_name = 'BIGEMP_RANGE';
--  20740

create unique index bigemp_range_pk on bigemp_range(hiredate, empno) local
  tablespace USERS STORAGE (initial 10M next 10M pctincrease 0) compute statistics;
-- Forløbet: 00:00:58.00 - 00:00:16.93

alter table bigemp_range add constraint bigemp_range_pk 
  primary key (hiredate, empno)
  using index bigemp_range_pk;
-- Forløbet: 00:00:00.12 - 00:00:00.00

create unique index bigemp_range_empno on bigemp_range (empno) global
  tablespace USERS STORAGE (initial 10M next 10M pctincrease 0) compute statistics;
-- Forløbet: 00:00:51.08 - 00:00:18.46

create bitmap index bigemp_range_job_bix on bigemp_range(job) local
  tablespace USERS STORAGE (initial 10M next 10M pctincrease 0) compute statistics;
-- Forløbet: 00:00:10.44 - 00:00:05.46

select index_name, partition_name, leaf_blocks, status, last_analyzed
from user_ind_partitions
where index_name in (select index_name from user_indexes where table_name = 'BIGEMP_RANGE')
order by 1, 2;
-- usable

select index_name, status, last_analyzed, leaf_blocks from user_ind_partitions
where index_name in (select index_name from user_indexes where table_name = 'BIGEMP_RANGE');
-- 15207

select index_name, leaf_blocks, status, last_analyzed
from user_indexes where table_name = 'BIGEMP_RANGE';
-------------

-- resource usage for 11gR1:
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
  and sy.statistic# = 154 --  redo blocks written
  and se.statistic# = 146 --  redo size;

-- resource usage for 10gR2:
set timing on

descr v$statname

select * from v$statname where statistic# in (138, 133);

select * from v$statname where name in ('redo blocks written', 'redo size');

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
  and sy.statistic# = 139 -- 104  --  redo blocks written
  and se.statistic# = 134 -- 99 -- redo size;


-- resource usage for 10gR1:
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

select max(snap_id) from dba_hist_system_event;

select * from dba_hist_system_event
where snap_id = 213;

select * from dba_hist_active_sess_history
where snap_id = 213;

select sid from v$session where program = 'sqlplusw.exe';

select * from dba_hist_active_sess_history
where session_id = 101
and sample_time > trunc(sysdate)
order by snap_id;

select sample_time, event, session_state, blocking_session_serial#
   p1text, p2text, p3text
from dba_hist_active_sess_history
where session_id = 101
and sample_time > trunc(sysdate)
order by snap_id;


