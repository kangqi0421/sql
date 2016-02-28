SELECT PROPERTY_NAME, PROPERTY_VALUE FROM DATABASE_PROPERTIES
  WHERE PROPERTY_NAME like 'DEFAULT%TABLESPACE';
  
create tablespace USERS datafile size 1G;

select 'ALTER USER '||username||' QUOTA '||MAX_BYTES||' on USERS;' from dba_ts_quotas
 where tablespace_name like 'USERS%'
 and max_bytes > 0;

ALTER DATABASE DEFAULT TABLESPACE users;  