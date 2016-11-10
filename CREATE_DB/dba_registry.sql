col comp_id for a15
col comp_name for a35
col version for a15
col status for a10

select substr(comp_id,1,15) comp_id,substr(comp_name,1,30) comp_name,
       substr(version,1,10) version, status
  from dba_registry 
 order by 1;
