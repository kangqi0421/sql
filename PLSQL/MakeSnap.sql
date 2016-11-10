CREATE OR REPLACE PROCEDURE PERFSTAT.MakeSnap
IS
   statLevel   NUMBER := 0;
--// default is staspack level 0 //--
BEGIN
   IF (TO_NUMBER (TO_CHAR (SYSDATE, 'MI'), '99') < 1)
   THEN
      statLevel := 5;
   END IF;
   statspack.snap (i_snap_level => statLevel);
END MakeSnap;
/


// statspack snap po 15-ti min
DECLARE
   statLevel   NUMBER := 0;
BEGIN
   IF MOD(TO_NUMBER (TO_CHAR (SYSDATE, 'MI'), '99'), 15) < 1)
        THEN statLevel := 5;
    END IF;
END;
/

