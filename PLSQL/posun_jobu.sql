DECLARE
  Procedure MoveJobRun
    ( 
      ptxt_Name     VARCHAR2,
      pdat_Date     DATE DEFAULT NULL,
      ptxt_Interval VARCHAR2 DEFAULT NULL
    ) AS
    lint_JobNum NUMBER;
    ltxt_Interval VARCHAR2(255);
    ltxt_What VARCHAR2(255);
  BEGIN
    IF pdat_Date IS NOT NULL THEN
      IF ptxt_Interval IS NULL THEN
        BEGIN 
          SELECT j.JOB,interval,what
            INTO lint_JobNum,ltxt_Interval,ltxt_What
            FROM ALL_JOBS j 
            WHERE j.WHAT LIKE '%' || ptxt_Name || '%';
  
          DBMS_JOB.change
            (
              job => lint_JobNum,
              what => ltxt_What,
              next_date => pdat_Date,
              interval => ltxt_Interval
            );
        COMMIT;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            null;
          WHEN TOO_MANY_ROWS THEN
            null;
        END;      
      ELSE  
        BEGIN 
          SELECT j.JOB,interval,what
            INTO lint_JobNum,ltxt_Interval,ltxt_What
            FROM ALL_JOBS j 
            WHERE j.WHAT LIKE '%' || ptxt_Name || '%'
              AND j.INTERVAL LIKE '%' || ptxt_Interval || '%';
  
          DBMS_JOB.change
            (
              job => lint_JobNum,
              what => ltxt_What,
              next_date => pdat_Date,
              interval => ltxt_Interval
            );
        COMMIT;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            null;
          WHEN TOO_MANY_ROWS THEN
            null;
        END;      
      END IF;  
    END IF;  
  END;  
BEGIN
  MoveJobRun('db_maint_pckg.DBMaintenance',TO_DATE('08072006 2340','ddmmyyyy hh24mi')); -- trunc(sysdate) + 1 + 23/24 + 35/1440
  MoveJobRun('db_archive_pckg.CheckFileStatus',TO_DATE('08072006 0330','ddmmyyyy hh24mi')); -- TO_DATE(TO_CHAR((SYSDATE + 1), 'YYYYMMDD') || ' 00:40', 'YYYYMMDD HH24:MI')
--  MoveJobRun('begin mw.CheckPartitions; end'); -- to_date(to_char(sysdate+1,'DD.MM.YYYY')||' 07', 'DD.MM.YYYY HH24')
END;
/








