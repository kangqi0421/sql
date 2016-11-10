CREATE OR REPLACE PROCEDURE CBL.CheckPartitions IS

   -- how many days/months the partitions are generated in advance
   DAYS_ADVANCE CONSTANT NUMBER := 3;
   MONTHS_ADVANCE CONSTANT NUMBER := 1;

   -- check table partitons
   CURSOR lcur_tab_parts IS
     SELECT table_owner, table_name, max(partition_name) partition_name
     FROM all_tab_partitions
     GROUP BY table_owner, table_name;

   -- check LOB partitions
   CURSOR lcur_lob_parts IS
     SELECT table_owner, table_name, max(partition_name) partition_name
     FROM all_lob_partitions
     GROUP BY table_owner, table_name;

   ldt_part DATE;          -- table max. parititon
   ldt_exp_part DATE;      -- expected partition

BEGIN

   -- Log the start of this job
   db_inter_pckg.LogDBMsg ('3151', db_const_pckg.MSG_3151, 'Job: CheckPartitions');

   -- go through all partitioned tables
   FOR rec IN lcur_tab_parts LOOP
      IF (upper(substr(rec.partition_name, 1, 1)) = 'M') THEN
         -- monthly partitioned
         ldt_part := to_date(substr(rec.partition_name, 2), 'YYYYMM');
         ldt_exp_part := trunc(add_months(SYSDATE, MONTHS_ADVANCE), 'month');
         IF ldt_part < ldt_exp_part THEN
            -- generate warning
            db_inter_pckg.LogDBError('CheckPartitions',
                    rec.table_owner||'.'||rec.TABLE_name,
                    '-20931', 'ORA-20931: Expected partition missing');
         END IF;

      ELSIF (upper(substr(rec.partition_name, 1, 1)) = 'D') THEN
      -- daily partitioned
         ldt_part := to_date(substr(rec.partition_name, 2), 'YYYYMMDD');
         ldt_exp_part := trunc(SYSDATE+DAYS_ADVANCE);
         IF ldt_part < ldt_exp_part THEN
            -- generate warning
            db_inter_pckg.LogDBError('CheckPartitions',
                     rec.table_owner||'.'||rec.TABLE_name,
                     '-20931', 'ORA-20931: Expected partition missing');
         END IF;
      END IF;
   END LOOP;

   -- go through all partitioned tables - lob partitions
   FOR rec IN lcur_lob_parts LOOP
      IF (upper(substr(rec.partition_name, 1, 1)) = 'M') THEN
         -- monthly partitioned
         ldt_part := to_date(substr(rec.partition_name, 2), 'YYYYMM');
         ldt_exp_part := trunc(add_months(SYSDATE, MONTHS_ADVANCE), 'month');
         IF ldt_part < ldt_exp_part THEN
            -- generate warning
            db_inter_pckg.LogDBError('CheckPartitions',
                    rec.table_owner||'.'||rec.TABLE_name,
                    '-20931', 'ORA-20931: Expected LOB partition missing');
         END IF;

      ELSIF (upper(substr(rec.partition_name, 1, 1)) = 'D') THEN
      -- daily partitioned
         ldt_part := to_date(substr(rec.partition_name, 2), 'YYYYMMDD');
         ldt_exp_part := trunc(SYSDATE+DAYS_ADVANCE);
         IF ldt_part < ldt_exp_part THEN
            -- generate warning
            db_inter_pckg.LogDBError('CheckPartitions',
                     rec.table_owner||'.'||rec.TABLE_name,
                     '-20931', 'ORA-20931: LOB Expected partition missing');
         END IF;
      END IF;
   END LOOP;

   -- Log the succesfull end of this job
   db_inter_pckg.LogDBMsg ('3152', db_const_pckg.MSG_3152, 'Job: CheckPartitions');

   -- Error?
   EXCEPTION
      WHEN OTHERS THEN
         db_inter_pckg.LogDBError('CheckPartitions',
                    NULL,
                    SQLCODE,
                    SQLERRM);
      RAISE_APPLICATION_ERROR(db_inter_pckg.AppSQLCode(SQLCODE), SQLERRM);
END CheckPartitions;
/


