  * https://blogs.oracle.com/optimizer/entry/how_can_i_hint_a
  * How To Use DBMS_SQLDIAG To Diagnose Various Query Issues (Doc ID 1509192.1)

-- aktualne pouzivane SQL patche
select * from dba_sql_patches
  order by created DESC;

-- Hinty si vytahnu z exec planu a upravim dle vzoru outlines
select * from table(dbms_xplan.display_cursor('&sqlid',null,format=>'outline'));

-- Extract z PLAN_TABLE
SELECT regexp_replace(extractvalue(value(d), '/hint'),'''','''''') plan_hint
        from
        xmltable('/*/outline_data/hint'
                passing (
                        select
                                xmltype(other_xml) as xmlval
                        from    plan_table
                        where   other_xml is not null
                        and     plan_id = (select max(plan_id) from plan_table)
                        and     rownum=1
                        )
                ) d;


DECLARE
  v_sql_text v$sqlstats.sql_fulltext%TYPE;
BEGIN
  SELECT   sql_fulltext INTO v_sql_text
    FROM v$sqlstats  WHERE sql_id='&sqlid'
        AND rownum  =1;
  SYS.DBMS_SQLDIAG_INTERNAL.I_CREATE_PATCH(
       SQL_TEXT => v_sql_text,
       hint_text => 'USE_HASH(@SEL$1 T4 T10)',
       name => 'SQL_PATCH_&&sqlid'
       );
END;
/

define sqlid = gygdvbjdj9gvq

DECLARE
  v_sql_text v$sqlstats.sql_fulltext%TYPE;
BEGIN
  SELECT   sql_fulltext INTO v_sql_text
    FROM v$sqlstats  WHERE sql_id='&sqlid'
        AND rownum  =1;
  SYS.DBMS_SQLDIAG_INTERNAL.I_CREATE_PATCH(
       SQL_TEXT => v_sql_text,
       hint_text => 'IGNORE_OPTIM_EMBEDDED_HINTS',
       name => 'SQL_PATCH_&&sqlid'
       );
END;
/

--
Statistics  Table "ESPIS"."CS_TMP_OBJECT_GTT" was not analyzed.
--

-- disable SQL patch
EXEC DBMS_SQLDIAG.ALTER_SQL_PATCH(name=>'SQL_PATCH_&&sqlid', attribute_name=>'STATUS', value=>'DISABLED');

-- DROP SQL patch
begin
  sys.dbms_sqldiag.drop_sql_patch('SQL_PATCH_&&sqlid');
end;
/

-- extract SQL patch
select EXACT_MATCHING_SIGNATURE from v$sql where sql_id = '&sqlid';

select cast(extractvalue(value(x), '/hint') as varchar2(500)) as outline_hints
  from   xmltable('/outline_data/hint'
         passing (select xmltype(comp_data) xml
                  from   sys.sqlobj$data
                  where  signature = 2640606212120450132)) x;

-- 12.1+
SELECT * FROM TABLE(dbms_xplan.display_sql_patch_plan('SQL_PATCH_&&sqlid'));


-- ESPIS gygdvbjdj9gvq

-- ignore HINT
sqlprof_attr('IGNORE_OPTIM_EMBEDDED_HINTS')
