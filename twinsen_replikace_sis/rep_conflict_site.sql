BEGIN
   DBMS_REPCAT.RESUME_MASTER_ACTIVITY (
      gname => 'pav');
END;connect repadmin/jiricek@twinsen.natur.cuni.cz;

/* shod replikaci */
BEGIN
   DBMS_REPCAT.SUSPEND_MASTER_ACTIVITY (
      gname => 'pav');
END;
/

/* zmena v tabulce */
BEGIN
   DBMS_REPCAT.ALTER_MASTER_REPOBJECT (
      sname => 'stdowner',
      oname => 'zpokusy',
      type => 'TABLE',
      ddl_text => 'ALTER TABLE stdowner.zpokusy ADD (site VARCHAR2(20))');
END;
/

/* regenerate replication support */
BEGIN 
    DBMS_REPCAT.GENERATE_REPLICATION_SUPPORT (
      sname => 'stdowner',
      oname => 'zpokusy',
      type => 'TABLE',
      min_communication => TRUE); 
END;
/

BEGIN
   DBMS_REPCAT.CREATE_MASTER_REPOBJECT (
      gname => 'pav',
      type => 'TRIGGER',
      oname => 'insert_site_zpokusy',
      sname => 'stdowner',
      ddl_text => 'CREATE TRIGGER stdowner.insert_site_zpokusy
                     BEFORE
                       INSERT OR UPDATE ON stdowner.zpokusy FOR EACH ROW
                     BEGIN 
                       IF DBMS_REPUTIL.FROM_REMOTE = FALSE THEN
                         SELECT global_name INTO :NEW.SITE FROM GLOBAL_NAME;
                       END IF;
                     END;');
END;
/

BEGIN
   DBMS_REPCAT.MAKE_COLUMN_GROUP (
      sname => 'stdowner',
      oname => 'zpokusy',
      column_group => 'zpokusy_sitepriority_cg',
      list_of_column_names => '???region_id,region_name,site');
END;
/

BEGIN
   DBMS_REPCAT.DEFINE_SITE_PRIORITY (
      gname => 'pav',
      name => 'zpokusy_sitepriority_pg');
END;
/

BEGIN
   DBMS_REPCAT.ADD_SITE_PRIORITY_SITE (
      gname => 'pav',
      name => 'zpokusy_sitepriority_pg',
      site => 'twinsen.natur.cuni.cz',
      priority => 2);
END;
/

/* a dalsi priority ...*/


BEGIN
   DBMS_REPCAT.ADD_UPDATE_RESOLUTION (
      sname => 'stdowner',
      oname => 'zpokusy',
      column_group => 'zpokusy_sitepriority_cg',
      sequence_no => 1,
      method => 'SITE PRIORITY',
      parameter_column_name => 'site',
      priority_group => 'zpokusy_sitepriority_pg');
END;
/

/* regenerate replication support */
BEGIN 
    DBMS_REPCAT.GENERATE_REPLICATION_SUPPORT (
      sname => 'stdowner',
      oname => 'zpokusy',
      type => 'TABLE',
      min_communication => TRUE); 
END;
/


BEGIN
   DBMS_REPCAT.RESUME_MASTER_ACTIVITY (
      gname => 'pav');
END;
/











/* nahod replikaci */
BEGIN
   DBMS_REPCAT.RESUME_MASTER_ACTIVITY (
      gname => 'pav');
END;
/



