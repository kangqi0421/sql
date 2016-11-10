connect repadmin/jiricek@twinsen.natur.cuni.cz;

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
      oname => 'povinn',
      type => 'TABLE',
      ddl_text => 'ALTER TABLE stdowner.povinn ADD (pjenpgs VARCHAR2(20))');
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

BEGIN
   DBMS_REPCAT.ALTER_MASTER_REPOBJECT (
      sname => 'stdowner',
      oname => 'ustav',
      type => 'TABLE',
      ddl_text => 'ALTER TABLE stdowner.ustav MODIFY (anazev VARCHAR2(100))');
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

/* nahod replikaci */
BEGIN
   DBMS_REPCAT.RESUME_MASTER_ACTIVITY (
      gname => 'pav');
END;
/



