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
