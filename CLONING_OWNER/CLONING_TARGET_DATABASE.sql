-- view

-- 20190614 Add METHOD_group_name pro identifikaci diskového klonu

CREATE OR REPLACE FORCE EDITIONABLE VIEW "CLONING_OWNER"."CLONING_TARGET_DATABASE"
   AS
  with server_lists as (SELECT i.licdb_id,
             listagg( case when trim(s.hostname) is not null and trim(s.domain) is not null then trim(s.hostname) ||'.'||trim(s.domain)
                            else trim(s.hostname) || trim(s.domain) end,', ') within group (order by i.inst_name) hostnames
                FROM oli_owner.servers s,
                  oli_owner.dbinstances i
                WHERE s.server_id =i.server_id
                    AND (i.inst_role IS NULL
                              OR (upper(i.inst_role) NOT LIKE '%STANDBY%'
                                   AND upper(i.inst_role) NOT LIKE '%FAILOVER%'))
                group by i.licdb_id)
select d.licdb_id target_licdb_id,d.dbname target_dbname, st.hostnames target_hostnames, d.rac target_is_rac, d.dbversion target_dbversion,
       d.clone_source_licdb_id source_licdb_id, src.dbname source_dbname, ssrc.hostnames source_hostnames,src.rac source_is_rac,
       D.CLONING_METHOD_ID,m.method_name, m.method_title,
       g.method_group_id, g.METHOD_group_name,
       D.CLONING_TEMPLATE_ID,t.template_name
   from oli_owner.databases d,
        cloning_method m,
        method_group g,
        cloning_template t,
        oli_owner.databases src,
        server_lists st,
        server_lists ssrc
  where d.CLONING_METHOD_ID=m.cloning_method_id
        and d.CLONING_METHOD_group_ID = g.method_group_id(+)
        and d.CLONING_TEMPLATE_ID=t.template_id(+)
        and D.CLONE_SOURCE_LICDB_ID=src.licdb_id(+)
        and d.licdb_id=st.licdb_id(+)
        and D.CLONE_SOURCE_LICDB_ID=ssrc.licdb_id(+)
    and nvl(upper(trim(d.env_status)),'X')!='PRODUCTION';
