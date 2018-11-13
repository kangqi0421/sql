--
-- DWH: create tablespaces
--

-- SYSTEM
alter database datafile 1 autoextend on next 1G maxsize  65535m;
alter tablespace SYSTEM add datafile autoextend on next 1G maxsize 65535m;

-- SYSAUX
alter database datafile 2 autoextend on next 1G maxsize  65535m;
alter tablespace SYSAUX add datafile autoextend on next 1G maxsize 65535m;
alter tablespace SYSAUX add datafile autoextend on next 1G maxsize 65535m;
