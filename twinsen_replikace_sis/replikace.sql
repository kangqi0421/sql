connect repadmin/jiricek@twinsen.natur.cuni.cz

CREATE MATERIALIZED VIEW LOG ON "STDOWNER"."USTAV"
WITH PRIMARY KEY;


BEGIN
   DBMS_REPCAT.CREATE_MASTER_REPGROUP(
     gname => 'PAV',
     qualifier => '',
     group_comment => '');
END;
/

BEGIN
   DBMS_REPCAT.CREATE_MASTER_REPOBJECT(
     gname => 'PAV',
     type => 'TABLE',
     oname => 'USTAV',
     sname => 'STDOWNER',
     copy_rows => TRUE,
     retry => TRUE,
     use_existing_object => TRUE);
END;
/

BEGIN
   DBMS_REPCAT.GENERATE_REPLICATION_SUPPORT(
     sname => 'STDOWNER',
     oname => 'USTAV', 
     type => 'TABLE',
     min_communication => TRUE);
END;
/
BEGIN
	DBMS_REPCAT.RESUME_MASTER_ACTIVITY(
	gname => 'PAV');
END;
/

/*  Na originu ....*/

BEGIN
   DBMS_REPCAT.CREATE_SNAPSHOT_REPGROUP(
     gname => 'PAV',
     master => 'TWINSEN.NATUR.CUNI.CZ',
     propagation_mode => 'ASYNCHRONOUS');
END;
/


CREATE MATERIALIZED VIEW "STDOWNER"."USTAV"  
FOR UPDATE
AS SELECT * FROM
"STDOWNER"."USTAV"@TWINSEN.NATUR.CUNI.CZ;

/* Pokud chci object zrušit */

BEGIN
  DBMS_REPCAT.DROP_SNAPSHOT_REPOBJECT (
    sname => 'STDOWNER', 
    oname => 'OKRUH',
    type => 'SNAPSHOT',
    drop_objects => false);
END;
/


/* bez primarniho klice ... */
CREATE SNAPSHOT "STDOWNER"."ZPOKUSY"  
REFRESH FORCE WITH ROWID
FOR UPDATE
AS SELECT * FROM
"STDOWNER"."ZPOKUSY"@TWINSEN.NATUR.CUNI.CZ


BEGIN
   DBMS_REPCAT.CREATE_SNAPSHOT_REPOBJECT(
      gname => 'PAV',
      sname => 'STDOWNER',
      oname => 'OKRUH',
      type => 'SNAPSHOT',
      min_communication => TRUE);
END;
/

/* replikace snapshotu ... */
BEGIN
   DBMS_REPCAT.CREATE_SNAPSHOT_REPOBJECT(
      gname => '"PAV"',
      sname => '"STDOWNER"',
      oname => '"POVINN_PRE_INS_ROW_1"',
      type => 'TRIGGER');
END;
/

BEGIN
   DBMS_REPCAT.CREATE_SNAPSHOT_REPOBJECT(
      gname => '"PAV"',
      sname => '"STDOWNER"',
      oname => '"POVODDO"',
      type => 'INDEX');
END;
/
BEGIN
   DBMS_REFRESH.ADD(
     name => '"STDOWNER"."TAJEMNIK"',
     list => '"STDOWNER"."USTAV"',
     lax => TRUE);
END;
/
