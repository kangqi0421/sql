
-- SYS granty
-- nutno přes spool, protože se generuje pod SYSTEM, ale spouští pod SYS
-- vyřešeno přes PUBLIC link i pro spuštění pod SYS

set lines 32767 pages 0 trims on head off feed off

spool public.sql

select 'GRANT '||privilege||' "'||owner||'"."'||
table_name||'" to '||grantee||' '||grantable||';' as CMD
  from (
    select GRANTEE, OWNER, TABLE_NAME,
      case
        when privilege in ('READ','WRITE')  THEN privilege||' ON '||'DIRECTORY'
        else privilege||' ON'
      end privilege,
      decode(grantable,'YES','WITH Grant option') grantable
    from (
      SELECT grantee, owner, table_name, privilege, grantable
        FROM dba_tab_privs@export_impdp
       where grantee = 'PUBLIC'
      UNION
      SELECT grantee, owner, table_name, privilege, grantable
        FROM dba_tab_privs@export_impdp
       WHERE owner in ('SYS', 'SYSTEM')
         and grantee not in (select role from dba_roles where oracle_maintained = 'Y')
         )
  )
  -- pouze exitujici objekty
  WHERE (owner, table_name) in
       (select owner, object_name from dba_objects)
;

spool off

-- PL/SQL verze PUBLIC a SYS grantů
BEGIN
  for rec in (
    select GRANTEE, OWNER, TABLE_NAME,
      case
        when privilege in ('READ','WRITE')  THEN privilege||' ON '||'DIRECTORY'
        else privilege||' ON'
      end privilege,
      decode(grantable,'YES','WITH Grant option') grantable
    from (
      SELECT grantee, owner, table_name, privilege, grantable
        FROM dba_tab_privs@export_impdp
       where grantee = 'PUBLIC'
      UNION
      SELECT grantee, owner, table_name, privilege, grantable
        FROM dba_tab_privs@export_impdp
       WHERE owner in ('SYS', 'SYSTEM')
         and grantee not in (select role from dba_roles where oracle_maintained = 'Y')
         ))
  loop
    execute immediate 'GRANT '||rec.privilege||' '
        ||DBMS_ASSERT.enquote_name(rec.owner)||'.'
        ||DBMS_ASSERT.enquote_name(rec.table_name)||' TO '
        ||rec.grantee||' '||rec.grantable;
  end loop;
  EXCEPTION
      WHEN OTHERS THEN
        IF sqlcode not in (-4042, -1917) THEN RAISE;
        END IF;
END;
/

-- DWH owner: ENABLE NOVALIDATE CONSTRAINT
BEGIN
  for rec in (
    SELECT
        c.owner,
        tc.table_name,
        c.constraint_name
    FROM
        dba_constraints c
        JOIN dba_cons_columns cc ON c.constraint_name = cc.constraint_name
        JOIN dba_tab_columns tc ON tc.column_name = cc.column_name
                                   AND tc.table_name = cc.table_name
    WHERE
        c.owner = 'DWH_OWNER'
        AND c.table_name IN (
            'DEPOSIT_ACCOUNT_HISTORY',
            'ACCOUNT_HISTORY',
            'CARD_HISTORY'
        )
            AND c.constraint_type = 'C'
                AND c.status = 'DISABLED'
  ) loop
  execute immediate 'ALTER TABLE '|| rec.owner
                      || '.' || rec.table_name
                      || ' ENABLE NOVALIDATE CONSTRAINT '
                      || rec.constraint_name;
  end loop;
END;
/


-- PUBLIC synonym
BEGIN
  for rec in (
    SELECT
      synonym_name,
      table_owner,
      table_name
    FROM dba_synonyms@EXPORT_IMPDP
    WHERE owner='PUBLIC'
      and table_owner in
        (select username from dba_users@EXPORT_IMPDP
           where oracle_maintained = 'N')
  ) loop
  BEGIN
      execute immediate 'CREATE PUBLIC SYNONYM ' || rec.synonym_name || ' FOR '
            || rec.table_owner || '.' || rec.table_name;
  EXCEPTION
      WHEN OTHERS THEN
        IF sqlcode != -955 THEN RAISE;
        END IF;
  END;
  end loop;
END;
/
