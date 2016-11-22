set pagesize 999
set linesize 160
column tsname format a28     heading "tablespace"          truncate
column nfexts format 9999990 heading "# of free|extents"
column mxfext format 99990.9 heading "largest free|extent [MB]"
column stotal format 9999990.9 heading "total|size [MB]"
column maxbyt format a20     heading "Extensible|Max.tot.size [MB]"
column extmng format a10     heading "Ext.|Mngm."
column freesp format 9999990.9 heading "free|size [MB]"
column pcused format 990.9   heading "used|[%]"

select
  T.tablespace_name				tsname,
  decode(g.EXTENT_MANAGEMENT,'LOCAL','LOC','DICTIONARY','DIC','')||' / '||
  decode(g.ALLOCATION_TYPE,'UNIFORM','UNI','USER','USR','SYSTEM','SYS','**') extmng,
  '   '||Q.AUTOEXTENSIBLE||' / '||
  decode(nvl(round(T.maxbytes/1024/1024,0),0),32768,'Unlimited',nvl(round(T.maxbytes/1024/1024,0),0))	maxbyt,
  T.bytes/1024/1024				stotal,
  nvl( round(F.bytes/1024/1024,0), 2 )			freesp,
  round(( 1-nvl( F.bytes, 0 ) / T.bytes ) * 100,2)	pcused
from
  ( select tablespace_name, sum(bytes) bytes,sum(maxbytes) maxbytes from dba_data_files  group by tablespace_name ) T,
  ( select tablespace_name, count(*) extents, sum(bytes) bytes, max(bytes) max_extent from dba_free_space group by tablespace_name ) F ,
  (select tablespace_name, case when tablespace_name in (select a.tablespace_name from dba_data_files a, dba_data_files b where a.autoextensible ='YES' and b.autoextensible ='NO' and a.tablespace_name = b.tablespace_name) then '*ERR*' else AUTOEXTENSIBLE end AUTOEXTENSIBLE from dba_data_files  group by tablespace_name,AUTOEXTENSIBLE) Q,
  (select EXTENT_MANAGEMENT,ALLOCATION_TYPE,tablespace_name from dba_tablespaces ) G
where
    T.tablespace_name = F.tablespace_name(+)
and T.tablespace_name = Q.tablespace_name(+)
and T.tablespace_name = G.tablespace_name(+)
order by pcused DESC
;
