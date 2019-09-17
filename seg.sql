-- velikost segmentu per owner
--

define min_size_gb = 1

col owner for a30
col tablespace_name for a30
select * from
(select tablespace_name, owner,
       round(sum(bytes/power(1024, 3)),1) "GB"
    from dba_segments
  where
    owner like upper('&1')
--    NOT REGEXP_LIKE(owner, '^[A-Z]+\d{4,}$')
    and owner not in ('SYS')
 group by tablespace_name, ROLLUP (owner)
 order by tablespace_name, owner
 -- order by owner, tablespace_name
)
where GB > &min_size_gb;

/*

-- segments in CSV

select sys_context('USERENV', 'DB_NAME')||';'|| owner ||';'||
       round(sum(bytes/power(1024, 3))) as GB
    from dba_segments
  where
    owner in ('CONSOLE','JOB','LOG')
  group by owner
;

-- seg per schema
select owner,
       round(sum(bytes/power(1024, 3)))
    from dba_segments
  where
    owner like 'SIEBEL%'
  group by owner
;

*/