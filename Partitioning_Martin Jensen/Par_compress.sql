
rem Martin Jensen - Par-test (Nordea) , 10.1.0.4, 11.1.0.7


drop table bigemp_range;

create table bigemp_range (
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

insert /*+APPEND */ into bigemp_range (empno, sal, job, deptno, hiredate)
select empno+t.column_value*300000 empno, sal, job, deptno,
       hiredate+mod(t.column_value,1000) hiredate
from scott.emp, table(system.counter(1,300000) ) t;
commit;
-- 4200000 rows

create unique index bigemp_range_pk on bigemp_range(hiredate, empno) local
  tablespace USERS STORAGE (initial 10M next 10M pctincrease 0) compute statistics;

alter table bigemp_range add constraint bigemp_range_pk 
  primary key (hiredate, empno)
  using index bigemp_range_pk;

execute DBMS_STATS.GATHER_TABLE_STATS(null, 'BIGEMP_RANGE', -
  estimate_percent => 100, -
  method_opt => 'FOR ALL INDEXED COLUMNS size 254');

alter table bigemp_range enable row movement;

---- compress

Article-ID:         Note 204548.1
Circulation:        PUBLISHED (EXTERNAL)
Folder:             server.Performance.Partitioning
Topic:              Scripts and Working Examples
Title:              How to compress local indexes on a Partition  - Example

Article-ID:         Note 312843.1
Circulation:        REVIEW_READY (EXTERNAL)
Folder:             server.Performance.Partitioning
Topic:              Partitioned Tables and Indexes Administration
Title:              Rebuild a partitioned index specifying compression raises 
                    Ora-28659

select table_name, partition_name, partition_position, tablespace_name,
  blocks, num_rows, compression
from user_tab_partitions
where table_name = 'BIGEMP_RANGE';

TABLE_NAME                     PARTITION_NAME                 PARTITION_POSITION
------------------------------ ------------------------------ ------------------
TABLESPACE_NAME                    BLOCKS   NUM_ROWS COMPRESS
------------------------------ ---------- ---------- --------
BIGEMP_RANGE                   FIRST_THIRD                                     1
USERS                                9555    1921200 DISABLED

BIGEMP_RANGE                   SECOND_THIRD                                    2
USERS                                8323    1678800 DISABLED

BIGEMP_RANGE                   LAST_THIRD                                      3
USERS                                2871     600000 DISABLED

select index_name, partition_name, tablespace_name,
  blevel, leaf_blocks, num_rows, compression, status
from user_ind_partitions
where index_name in (
  select index_name from user_indexes 
  where table_name = 'BIGEMP_RANGE')
order by index_name, partition_name;

INDEX_NAME                     PARTITION_NAME
------------------------------ ------------------------------
TABLESPACE_NAME                    BLEVEL LEAF_BLOCKS   NUM_ROWS COMPRESS
------------------------------ ---------- ----------- ---------- --------
STATUS
--------
BIGEMP_RANGE_PK                FIRST_THIRD
USERS                                   2        6914    1921200 DISABLED
USABLE

BIGEMP_RANGE_PK                LAST_THIRD
USERS                                   2        2166     600000 DISABLED
USABLE

BIGEMP_RANGE_PK                SECOND_THIRD
USERS                                   2        6032    1678800 DISABLED
USABLE
-----------

-- use move partition compress

alter table bigemp_range move partition first_third compress;
-- Forløbet: 00:00:09.71
-- same space
execute DBMS_STATS.GATHER_TABLE_STATS(null, 'BIGEMP_RANGE', -
  estimate_percent => 100, cascade => false, -
  method_opt => 'FOR ALL INDEXED COLUMNS size 254');
-- space fra 9555 til 5339 blokke
-- Using 'manuel' compress it is possible to get as low as 3680 blocks

------------


drop table exch_bigemp_fact;
create table exch_bigemp_fact compress
tablespace ilm_users 
as select * from bigemp_range where rownum < 1;

insert /*+APPEND */ into exch_bigemp_fact
select * from bigemp_range partition (first_third)
order by hiredate, job;

commit;

create unique index exch_bigemp_pk on exch_bigemp_fact(hiredate, empno)
  tablespace ILM_USERS STORAGE (initial 10M next 10M pctincrease 0) compute statistics;

rem alter index exch_bigemp_pk rebuild compress;

alter table exch_bigemp_fact add constraint exch_bigemp_pk 
  primary key (hiredate, empno) using index exch_bigemp_pk;

execute DBMS_STATS.GATHER_TABLE_STATS(null,'EXCH_BIGEMP_FACT', estimate_percent => 100, -
  method_opt => 'FOR ALL INDEXED COLUMNS size 254', cascade => TRUE);

select * from user_tables where table_name = 'EXCH_BIGEMP_FACT';

EXCH_BIGEMP_FACT               ILM_USERS
                                                                       0
                    1        255          65536                       1
 2147483645                                         YES N    1921200       3671
           0          0          0          30                         0
                  0          1
         1                                   N                ENABLED
    1921200 07-NOV-05 NO               N N NO  DEFAULT DISABLED YES NO
                DISABLED YES                                DISABLED ENABLED
NO

select * from user_indexes where table_name = 'EXCH_BIGEMP_FACT';

EXCH_BIGEMP_PK                 NORMAL
SYSTEM                         EXCH_BIGEMP_FACT               TABLE
UNIQUE    ENABLED              1 ILM_USERS                               2
       255       10485760                       1  2147483645
                                                                10 YES
         2        4786       1921200                       1
                      1           1532038 VALID       1921200     1921200
07-NOV-05 1
1                                        NO  N N N DEFAULT NO


YES                              NO  NO  NO

-- alter table bigemp_fact modify partition first_third compress;

alter table bigemp_range exchange partition first_third 
with table exch_bigemp_fact
including indexes without validation;

alter table bigemp_range exchange partition first_third 
with table exch_bigemp_fact
including indexes without validation;

alter table bigemp_range modify partition first_third compress;
-- but this does not actually compress the partition!

alter table bigemp_range move partition first_third compress update indexes;

--------------------

-- now with shrink

select count(*) from bigemp_range partition (second_third)
where hiredate < to_date('1985-01-01','YYYY-MM-DD');

alter table bigemp_Range split partition second_third at 
  (to_date('1985-01-01','YYYY-MM-DD')) into
  (partition before_1985 compress, partition second_third );

 execute DBMS_STATS.GATHER_TABLE_STATS(null, 'BIGEMP_RANGE', -
estimate_percent => 100, cascade => false, -
method_opt => 'FOR ALL INDEXED COLUMNS size 254');

-- fra 11125 blokke til  5869 + 754 = 6623 blokke

============= now with bitmap index ...

drop table bigemp_range;

create table bigemp_range (
  empno number not null, sal number not null, job varchar2(12) not null,
  deptno number not null, hiredate date not null)
  partition by range (hiredate) (
    partition compress_14646 values
      less than(to_date('1900-01-01','YYYY-MM-DD')) tablespace users,
    partition first_third values
      less than(to_date('1983-01-01','YYYY-MM-DD')) tablespace users,
    partition second_third values 
      less than(to_date('1987-01-01','YYYY-MM-DD')) tablespace users,
    partition last_third values 
      less than(to_date('1991-01-01','YYYY-MM-DD')) tablespace users)
  storage (initial 10M next 10M maxextents unlimited);

insert /*+APPEND */ into bigemp_range (empno, sal, job, deptno, hiredate)
select empno+t.column_value*300000 empno, sal, job, deptno,
       hiredate+mod(t.column_value,1000) hiredate
from scott.emp, table(system.counter(1,300000) ) t;
commit;
-- 4200000 rows

-- get round ORA-14646
alter table bigemp_range modify partition compress_14646 compress;

create unique index bigemp_range_pk on bigemp_range(hiredate, empno) local
  tablespace USERS STORAGE (initial 10M next 10M pctincrease 0) compute statistics;

alter table bigemp_range add constraint bigemp_range_pk 
  primary key (hiredate, empno)
  using index bigemp_range_pk;

-- created later
-- create bitmap index bigemp_date_fk on bigemp_fact(hiredate) local
--   tablespace USERS STORAGE (initial 10M next 10M pctincrease 0) compute statistics;

execute DBMS_STATS.GATHER_TABLE_STATS(null, 'BIGEMP_RANGE', -
  estimate_percent => 100, -
  method_opt => 'FOR ALL INDEXED COLUMNS size 254');

alter table bigemp_range enable row movement;

select table_name, partition_name, partition_position, tablespace_name,
  blocks, num_rows, compression
from user_tab_partitions
where table_name = 'BIGEMP_RANGE';

TABLE_NAME                     PARTITION_NAME                 PARTITION_POSITION
------------------------------ ------------------------------ ------------------
TABLESPACE_NAME                    BLOCKS   NUM_ROWS COMPRESS
------------------------------ ---------- ---------- --------
BIGEMP_FACT_RANGE              COMPRESS_14646                                  1
USERS                                   0          0 ENABLED

BIGEMP_FACT_RANGE              FIRST_THIRD                                     2
USERS                                9596    1928100 DISABLED

BIGEMP_FACT_RANGE              SECOND_THIRD                                    3
USERS                               11125    2271900 DISABLED

BIGEMP_FACT_RANGE              LAST_THIRD                                      4
USERS                                   0          0 DISABLED

select index_name, partition_name, tablespace_name,
  blevel, leaf_blocks, num_rows, compression, status
from user_ind_partitions
where index_name in (
  select index_name from user_indexes 
  where table_name = 'BIGEMP_RANGE')
order by index_name, partition_name;

INDEX_NAME                     PARTITION_NAME
------------------------------ ------------------------------
TABLESPACE_NAME                    BLEVEL LEAF_BLOCKS   NUM_ROWS COMPRESS
------------------------------ ---------- ----------- ---------- --------
STATUS
--------
BIGEMP_RANGE_PK                COMPRESS_14646
USERS                                   0           0          0 DISABLED
USABLE

BIGEMP_RANGE_PK                FIRST_THIRD
USERS                                   2        6940    1928100 DISABLED
USABLE

BIGEMP_RANGE_PK                LAST_THIRD
USERS                                   0           0          0 DISABLED
USABLE

BIGEMP_RANGE_PK                SECOND_THIRD
USERS                                   2        8172    2271900 DISABLED
USABLE

drop table exch_bigemp_fact;
create table exch_bigemp_fact compress
tablespace ilm_users 
as select * from bigemp_range where rownum < 1;

create unique index exch_bigemp_pk on exch_bigemp_fact(hiredate, empno) 
  tablespace ILM_USERS STORAGE (initial 10M next 10M pctincrease 0) compute statistics;

alter table exch_bigemp_fact add constraint exch_bigemp_pk 
  primary key (hiredate, empno)
  using index exch_bigemp_pk;

execute DBMS_STATS.GATHER_TABLE_STATS(null,'EXCH_BIGEMP_FACT', estimate_percent => 100, -
  method_opt => 'FOR ALL INDEXED COLUMNS size 254', cascade => TRUE);

alter table bigemp_fact_range exchange partition compress_14646 
  with table exch_bigemp_fact
  including indexes without validation;

-- and remove the values again (if there were any)
alter table bigemp_fact_range exchange partition compress_14646 
  with table exch_bigemp_fact
  including indexes without validation;

select count(*) from bigemp_range partition (compress_14646);

create bitmap index bigemp_range_date_fk on bigemp_range(hiredate) local
  tablespace USERS STORAGE (initial 10M next 10M pctincrease 0) 
  online compute statistics;

truncate table exch_bigemp_fact;

insert /*+APPEND */ into exch_bigemp_fact
select * from bigemp_range partition (first_third)
order by hiredate, job;
commit;

create bitmap index exc_bigemp_date_fk on exch_bigemp_fact(hiredate)
  tablespace ILM_USERS STORAGE (initial 10M next 10M pctincrease 0) compute statistics;

execute DBMS_STATS.GATHER_TABLE_STATS(null,'EXCH_BIGEMP_FACT', estimate_percent => 100, -
  method_opt => 'FOR ALL INDEXED COLUMNS size 254', cascade => TRUE);

alter table bigemp_range modify partition first_third compress;

alter table bigemp_range exchange partition first_third 
  with table exch_bigemp_fact
  including indexes without validation;

-- Elapsed: 00:00:09.70

select table_name, partition_name, partition_position, tablespace_name,
    blocks, num_rows, compression
  from user_tab_partitions
  where table_name = 'BIGEMP_RANGE';

TABLE_NAME                     PARTITION_NAME                 PARTITION_POSITION
------------------------------ ------------------------------ ------------------
TABLESPACE_NAME                    BLOCKS   NUM_ROWS COMPRESS
------------------------------ ---------- ---------- --------
BIGEMP_FACT_RANGE              COMPRESS_14646                                  1
ILM_USERS                               0          0 ENABLED

BIGEMP_FACT_RANGE              FIRST_THIRD                                     2
USERS                                3674    1928100 ENABLED

BIGEMP_FACT_RANGE              SECOND_THIRD                                    3
USERS                               11125    2271900 DISABLED

BIGEMP_FACT_RANGE              LAST_THIRD                                      4
USERS                                   0          0 DISABLED

select index_name, partition_name, tablespace_name,
  blevel, leaf_blocks, num_rows, compression, status
from user_ind_partitions
where index_name in (
  select index_name from user_indexes 
  where table_name = 'BIGEMP_RANGE')
order by index_name, partition_name;

INDEX_NAME                     PARTITION_NAME
------------------------------ ------------------------------
TABLESPACE_NAME                    BLEVEL LEAF_BLOCKS   NUM_ROWS COMPRESS
------------------------------ ---------- ----------- ---------- --------
STATUS
--------
BIGEMP_DATE_FK                 COMPRESS_14646
USERS                                   0           0          0 DISABLED
USABLE

BIGEMP_DATE_FK                 FIRST_THIRD
ILM_USERS                               1          45        745 DISABLED
USABLE

BIGEMP_DATE_FK                 LAST_THIRD
USERS                                   1         332       1034 DISABLED
USABLE

BIGEMP_DATE_FK                 SECOND_THIRD
USERS                                   2         927       1892 DISABLED
USABLE

BIGEMP_PK                      COMPRESS_14646
USERS                                   0           0          0 DISABLED
USABLE

BIGEMP_PK                      FIRST_THIRD
ILM_USERS                               2        6215    1921200 DISABLED
USABLE

BIGEMP_PK                      LAST_THIRD
USERS                                   2        2166     600000 DISABLED
USABLE

BIGEMP_PK                      SECOND_THIRD
USERS                                   2        6032    1678800 DISABLED
USABLE

-- ORA-14646: Specified alter table operation involving compression cannot be
-- performed in the presence of usable bitmap indexes

Cause:	The first time a table is altered to include compression, it 
	cannot have a usable bitmap index (partition). Subsequent alter 
	table statements involving compression do not have this same 
	restriction. 
Action:	A) Drop any bitmap indexes defined on the table, and re-create 
	them once the operation is complete or, B) Mark all index 
	fragments of all bitmap indexes defined on the table UNUSABLE and 
	rebuild them once the operation is complete.

