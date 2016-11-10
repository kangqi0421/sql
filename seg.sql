-- velikost segmentu per owner
--

define min_size_gb = 1

col owner for a30
col tablespace_name for a30
select * from
(select tablespace_name, owner,
       round(sum(bytes/1048576/1024),1) "GB" from dba_segments
  where
    owner like upper('&1')
--    NOT REGEXP_LIKE(owner, '^[A-Z]+\d{4,}$')
    and owner not in ('SYS')
 group by tablespace_name, ROLLUP (owner)
 order by tablespace_name, owner
 -- order by owner, tablespace_name
)
where GB > &min_size_gb;