--
-- recycle bin OFF
--

WHENEVER SQLERROR EXIT SQL.SQLCODE

-- kontrola nastaveni
set lin 180
col name for a40
col value for a20

prompt kontrola nastaveni init parametru recyclebin
SELECT name, value
FROM
  v$parameter
WHERE
  name IN ('recyclebin')
;

-- recycle bin vysypu a vypnu
purge dba_recyclebin;
alter system set recyclebin = off scope=spfile;

prompt
prompt kontrola nastaveni init parametru v spfile pred restartem
prompt
SELECT name, value
FROM
  v$spparameter
WHERE
  name IN ('recyclebin')
;
