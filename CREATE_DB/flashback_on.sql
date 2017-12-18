-- enable flashback database ON

WHENEVER SQLERROR EXIT SQL.SQLCODE

alter database flashback on;
