REM Skript pro zvolenou databazi vypise hierarchii databazi, ktere
REM potencialne mohou vzniknout jako klon dane databaze a to bud
REM primo, nebo neprimo pres dalsi databazi.
REM V pripade klonovani z aliasu (skupiny databazi slouzicich jako zdroj
REM klonovani) jsou v hierarchii vypsany databaze i v pripade, ze jsou
REM clenem skupiny, ale aktivni je aktualne jina databaze ve skupine

set echo off verify off tab off
accept SOURCE_DBNAME PROMPT 'Enter source db.name:'

set lines 180 pages 999

column dbname format a20
column METHOD_GROUP_NAME format a20
column rac format a3
column dbversion format a15
column snapshot format a8

PROMPT ================================ SOURCE DATABASE ================================
select dbname,licdb_id,rac,dbversion
   from oli_owner.databases
   where upper(dbname)=upper('&&SOURCE_DBNAME.');

PROMPT =========================== TARGET DATABASE HIERARCHY ===========================
select substr(lpad(' ',2*level,' '),3) || t.dbname dbname,
      t.licdb_id,
      t.rac,
      t.dbversion,
      G.METHOD_GROUP_NAME,
      M.SNAPSHOT
   from ( --cilove databaze se vsemi potencialnimi zdroji
          select nvl(a.licdb_id,t2.CLONE_SOURCE_LICDB_ID) SOURCE_LICDB_ID,
               t2.licdb_id,
               t2.dbname,
               t2.rac,
               t2.dbversion,
               t2.CLONING_METHOD_GROUP_ID
           from oli_owner.databases t2
           left join cloning_owner.SOURCE_ALIAS_DB a on (t2.clone_source_alias_id=a.SOURCE_ALIAS_ID)) t
       left join cloning_owner.method_group g on (t.cloning_method_group_id=g.method_group_id)
       left join (--Je v method_group alespon jedna metoda pracujici se snapshoty?
                   select mgm.method_group_id, max(m2.ask_for_snapshot_name) snapshot
                   from cloning_owner.method_group_member mgm
                         left join cloning_owner.cloning_method m2 on (mgm.cloning_method_id=m2.cloning_method_id)
                   group by mgm.method_group_id) m  on (g.method_group_id=m.method_group_id)
     start with source_licdb_id in (select licdb_id
                                       from oli_owner.databases
                                       where upper(dbname)=upper('&&SOURCE_DBNAME.'))
     connect by nocycle source_licdb_id = prior licdb_id
     order siblings by t.dbname;