select owner, TABLESPACE_NAME , round(sum(bytes/1048576/1024),1) "GB" from dba_segments
  where owner like upper('&1')
 group by owner, TABLESPACE_NAME 
;