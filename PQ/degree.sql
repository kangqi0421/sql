--// zjištìní DOP	//--
select table_name, degree from dba_tables;

DEFAULT = parallel
1 = serial
16 = konrétní hodnota

--// zmìna //--
alter table TEST parallel;