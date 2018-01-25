--
-- LOB CLOB
--

-- compress
+ secure files
- zkusit deduplikaci ? kompresi ?
- STORE AS SECUREFILE, NOCOMPRESS  KEEP_DUPLICATES
alter table MW.LOG_FE_REPLY modify LOB(MESSAGE) (deduplicate compress medium);

-- MDWTB
alter table MW.LOG_FE_REPLY modify partition D20180125 LOB(MESSAGE) (deduplicate compress medium);
alter table MW.LOG_FE_REPLY modify partition D20180126 LOB(MESSAGE) (deduplicate compress medium);


select PARTITION_NAME, COMPRESSION, deduplication
  from   dba_lob_partitions
  where table_owner = 'MW'
    and table_name = 'LOG_FE_REPLY'
order by partition_name ;

select partition_name, bytes/power(1024,3) from dba_segments where SEGMENT_NAME='SYS_LOB0000079599C00006$$';


-- TABLE and INDEX PARTITION
  SELECT partition_name, round(sum(bytes)/1048576) "MB"
    FROM dba_segments
   WHERE owner = 'MW'
GROUP BY partition_name
ORDER BY partition_name;


-- LOB PARTITIONS
  SELECT l.partition_name, ROUND (SUM (bytes) / 1048576) "MB"
    FROM    dba_segments s
         INNER JOIN
            dba_lob_partitions l
         ON (    s.owner = l.table_owner
             AND s.partition_name = l.lob_partition_name)
   WHERE s.OWNER = 'MW' AND l.table_name LIKE 'LOG%'
GROUP BY l.partition_name
order by l.partition_name;

-- LOB INDEXY
  SELECT l.partition_name, ROUND (SUM (bytes) / 1048576) "MB"
    FROM    dba_segments s
         INNER JOIN
            dba_lob_partitions l
         ON (    s.owner = l.table_owner
             AND s.partition_name = l.lob_indpart_name)
   WHERE s.OWNER = 'MW' AND l.table_name LIKE 'LOG%'
GROUP BY l.partition_name
order by l.partition_name;

SELECT a.table_owner,
       a.table_name,
       a.column_name,
       a.subpartition_name,
       b.segment_name,
       b.tablespace_name,
       b.bytes / 1048576 "MB"
  FROM    dba_lob_subpartitions a
       INNER JOIN
          dba_segments b
       ON     b.partition_name = a.lob_subpartition_name
          AND b.segment_name = a.lob_name
          AND a.table_owner = b.owner
 WHERE b.owner = 'ZC037_003'
   --AND b.tablespace_name = 'ARS_MIG_TBS'
   -- and a.subpartition_name > 'SP158'
order by table_owner, table_name, subpartition_name, column_name;





---

SQL> select sum(LENGTHB(TO_CHAR(SUBSTR(MW_REQUEST,1,4000))))/1048576 MB from ZC037_003.LOG_TRN SUBPARTITION (SP001);

        MB
----------
376.567105



select sum(LENGTHB(TO_CHAR(SUBSTR(MW_REQUEST,1,4000))))/1048576 MB from ZC037_003.LOG_TRN SUBPARTITION (SP001)


select max(dbms_lob.getlength(DATA)) from ZC037_003.LOG_TRN SUBPARTITION (SP001)


select transaction_id, delka
from
(
select transaction_id, ceil(nvl(dbms_lob.getlength(MW_REQUEST), 0)*2) delka from ZC037_003.LOG_TRN SUBPARTITION (SP001)
)
where delka > 4000



--
CLOB::  lpad( '*', 32767, '*' )


       SID USERNAME                       CACHE_LOBS
---------- ------------------------------ ----------
       510 TUXCRM                               7102


       SID        PID SPID                     STATE               SQL_ID        PGA_ALLOC_MEM PGA_USED_MEM
---------- ---------- ------------------------ ------------------- ------------- ------------- ------------
       510         92 9255                     WAITING             f9816jak24gb1      73721124     58860582


10.2.0.4 and above
===============

In addition to the above approaches For 10.2.0.4 and above a new event introduced (event 60025) where when set if there are no active temp lobs in the session (ie: both cache temp lob and no-cache temp lobs used are zero) then the temp segment itself will also be freed releasing the space for other sessions to use. Note that this change is disabled by default.



select * from v$tempseg_usage where username = 'SRBA';


alter session set events '60025 trace name context forever';
alter session set events '60025 trace name context off';

set serveroutput on

declare
   clb clob;
   ch varchar2(32767);
   n number;
begin
    dbms_lob.createtemporary(clb,true);
    for i in 1..1500 loop
     ch:=lpad('o',32767,'Y');
     dbms_lob.writeappend(clb,length(ch),ch);
    end loop;
  n:=dbms_lob.getlength(clb);
  dbms_lob.freetemporary(clb);
  dbms_output.put_line('the clob length: '||n);
end;
/


DBMS_LOB.OPEN
  DBMS_LOB.WRITE
DBMS_LOB.CLOSE

create table t (clb clob);

declare
  clb clob;
begin
  insert into t values ( empty_clob() ) returning clb into clb;
  dbms_lob.writeAppend( clb, 32000, lpad( '*', 32767, '*' ) );
  commit;
end;
/

insert into t values (lpad('*',32767,'*'));
commit;

select dbms_lob.getlength(clb) from t;


select sid, username, CACHE_LOBS, nocache_lobs from v$temporary_lobs l natural join v$session s where username = 'TUXCRM';



