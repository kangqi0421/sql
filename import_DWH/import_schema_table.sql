--IMPORT_SCHEMA

drop table SYSTEM.IMPORT_SCHEMA;

create table SYSTEM.IMPORT_SCHEMA(
    username            VARCHAR2(128) PRIMARY KEY,
    imported            char(1),
    fix_value_too_large char(1),
    size_gb             int
    );

SELECT 'insert into IMPORT_SCHEMA (username) values ('
      || DBMS_ASSERT.enquote_literal(USERNAME)
      || ');'
  FROM dba_users@EXPORT_IMPDP
 WHERE ORACLE_MAINTAINED = 'N'
  and username not in ('ARM_CLIENT','ARM_CLSYS', 'ZELA', 'XDB', 'WMSYS', 'OJVMSYS','CTXSYS', 'DBSNMP')
ORDER by 1
;

-- co ještě chybí doimportovat
select listagg(username, ',') WITHIN GROUP (order by username)
from (
select username
  from IMPORT_SCHEMA
minus
select username
  from dba_users
)
;


-- zmena VARCHAR
select --d.*,
   'alter table '||o.owner||'.'||o.object_name||
        ' modify '||c.name||' '||
       decode(c.type#, 1, decode(c.charsetform, 2, 'NVARCHAR2', 'VARCHAR2'),
                       2, decode(c.scale, null,
                                 decode(c.precision#, null, 'NUMBER', 'FLOAT'),
                                 'NUMBER'),
                       9, decode(c.charsetform, 2, 'NCHAR VARYING', 'VARCHAR'),
                       12, 'DATE',
                       96, decode(c.charsetform, 2, 'NCHAR', 'CHAR'),
                       'UNDEFINED')
        ||'('|| d.MAX_LENGTH ||'); '
        || '-- '|| max_current_length
        as cmd_modify
  from   dba_objects o
    inner join sys.col$ c ON (c.obj# = o.object_id)
    inner join DUM$COLUMNS d on (o.object_id = d.OBJ# and c.intcol# = d.intcol#)
  where o.owner = 'ADS_RETAIL_OWNER'
--    and o.object_id = 55589416
    and d.too_large > 0
--    and c.type# > 1
order by o.owner, o.object_name, c.name
;