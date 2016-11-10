col TABLESPACE_NAME for a40

select TABLESPACE_NAME, round(MAX_BYTES/1048576) MB
  from dba_ts_quotas
 where upper(username) like upper('&1')
 order by TABLESPACE_NAME
;
