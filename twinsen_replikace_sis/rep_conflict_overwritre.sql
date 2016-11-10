/* shod replikaci */
BEGIN
   DBMS_REPCAT.SUSPEND_MASTER_ACTIVITY (
      gname => 'pav');
END;
/

BEGIN
   DBMS_REPCAT.MAKE_COLUMN_GROUP (
      sname => 'stdowner',
      oname => 'zpokusy',
      column_group => 'zpokusy_cg',
      list_of_column_names => '???region_id,region_name,site');
END;
/


BEGIN
   DBMS_REPCAT.ADD_UPDATE_RESOLUTION (
      sname => 'stdowner',
      oname => 'zpokusy',
      column_group => 'zpokusy__cg',
      sequence_no => 1,
      method => 'OVERWRITE',
      parameter_column_name => '???, ????, ????');
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

