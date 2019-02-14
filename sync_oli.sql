-- SYN data from OEM

-- OEM to OLI
BEGIN
  OLI_OWNER.SYNCHRO_OEM.resync_to_oli;
END;
/

-- refresh server
BEGIN
  DASHBOARD.REFRESH_OLI_DBHOST_PROPERTIES;
END;
/

-- NOTE: jiz soucasti predchoziho jobu
BEGIN
DBMS_SNAPSHOT.REFRESH('DASHBOARD.API_DB_MV','C');
END;
/

commit;



--
-- reload basic lists from oem to OLI_OWNER.OMS_* tables - databases, dbinstances, hosts

exec OLI_OWNER.SYNCHRO_OEM.reload_lists;

/* refresh data in OLI_OWNER based on data from OLI_OWNER.OMS_* tables,
   if p_reload_lists=true, OLI_OWNER.OMS_* tables will be reloaded as part of this resync */

exec OLI_OWNER.SYNCHRO_OEM.resync_to_oli(p_reload_lists => true);



--
    update oli_owner.databases d
       set (dbversion,rac,archivelog,env_status,EM_LAST_SYNC_DATE) =
                    (select dbversion,decode(upper(dbracopt),'YES','Y','N') rac,
                            decode(upper(log_mode),'ARCHIVELOG','Y','NOARCHIVELOG','N', null) archivelog,
                            envstatus, sysdate
                          from oli_owner.oms_databases emd
                          where emd.db_target_guid=d.em_guid)
       where exists (select *
                          from oli_owner.oms_databases emd
                          where emd.db_target_guid=d.em_guid);
--