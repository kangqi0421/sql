-- nastavení thresholdů na tablespaces do OEM
-- dba_thresholds na tablespaces
SELECT  metrics_name, object_name, warning_operator, warning_value, critical_operator, critical_value
    FROM dba_thresholds
   WHERE OBJECT_TYPE = 'TABLESPACE'
     and object_name in ('USERS')
ORDER BY metrics_name, object_name;


-- vypnutí monitoringu - OPERATOR:DO NOT CHECK
      DBMS_SERVER_ALERT.set_threshold (DBMS_SERVER_ALERT.tablespace_pct_full,
                                       DBMS_SERVER_ALERT.OPERATOR_DO_NOT_CHECK,0,
                                       DBMS_SERVER_ALERT.OPERATOR_DO_NOT_CHECK,0,
                                       1,1,NULL,DBMS_SERVER_ALERT.object_type_tablespace,
                                       rec.name
                                       );
-- monitoring tablespace s prefixem DM na Warning 80%, Critical 90%
DECLARE
   CURSOR c
   IS
      SELECT name
      FROM v$tablespace
      WHERE name LIKE 'DM%';
BEGIN
   FOR rec IN c
   LOOP
      DBMS_SERVER_ALERT.set_threshold (DBMS_SERVER_ALERT.tablespace_pct_full,
                                       DBMS_SERVER_ALERT.OPERATOR_GE,'85',
                                       DBMS_SERVER_ALERT.OPERATOR_GE, '90',
									   1,1,NULL,DBMS_SERVER_ALERT.object_type_tablespace,
                                       rec.name
      );
   END LOOP;
END;
/

-- promazani monitoringu neexistujicich tablespaces
DECLARE
   CURSOR c
   IS
      SELECT object_name AS name
      FROM dba_thresholds th
      WHERE     th.metrics_name LIKE 'Tablespace%'
            AND th.object_name IS NOT NULL
            AND NOT EXISTS (SELECT 1
                            FROM v$tablespace tbs
                            WHERE th.object_name = tbs.name);
BEGIN
   FOR rec IN c
   LOOP
      DBMS_SERVER_ALERT.set_threshold (DBMS_SERVER_ALERT.tablespace_pct_full,
                                       NULL,
                                       NULL,
                                       NULL,
                                       NULL,
                                       NULL,
                                       NULL,
                                       NULL,
                                       DBMS_SERVER_ALERT.object_type_tablespace,
                                       rec.name
      );
   END LOOP;
END;
/
