--
-- create tablespaces
--

-- SYSTEM
alter database datafile 1 autoextend on next 512m maxsize  65535m;

-- SYSAUX
alter database datafile 2 autoextend on next 512m maxsize  65535m;
