# DB timezone

--
* Timestamps & time zones - Frequently Asked Questions (Doc ID 340512.1)
--

DB timezone - má smysl pouze pro xTTS migrace, nikde jinde jsem to zatím nevyužil

DBMS_SCHEDULER.set_scheduler_attribute

only TIMESTAMP WITH LOCAL TIME ZONE columns

The best setting for dbtimezone is simply +00:00 (or any other OFFSET like -09:00, +08:00, …), if your current dbtimezone value is an OFFSET then please leave it like it is.

col PROPERTY_NAME  for a40
col PROPERTY_VALUE for a40
SELECT PROPERTY_NAME, PROPERTY_VALUE FROM DATABASE_PROPERTIES
  where PROPERTY_NAME = 'DBTIMEZONE' ;

select dbtimezone,sessiontimezone from dual;

alter session set time_zone = 'Europe/Prague';

1. At creation time
SQL> CREATE DATABASE ...
SET TIME_ZONE='Europe/London';
If not specified with the CREATE DATABASE statement, the database time zone defaults to the server’s O/S timezone offset.

cat /etc/sysconfig/clock

2. After database creation, use the ALTER DATABASE SET TIME_ZONE statement and
then shut down and restart the database.
SQL> ALTER DATABASE SET TIME_ZONE = 'Europe/Prague';
The change will not take effect until the database is bounced.


-- ověření sloupců WITH LOCAL TIME ZONE
select c.owner || '.' || c.table_name || '(' || c.column_name || ') -'   || c.data_type || ' ' col
  from dba_tab_cols c, dba_objects o
 where c.data_type like '%WITH LOCAL TIME ZONE'
    and c.owner=o.owner
   and c.table_name = o.object_name
   and o.object_type = 'TABLE'
order by col
/
