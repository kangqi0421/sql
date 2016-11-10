DECLARE
   pocetDni          NUMBER := 5;
   tableOwner        VARCHAR (100) := 'SYMADM';
   partitionPrefix   CHAR (1) := 'D';
   sqlcmd            VARCHAR (1000);
BEGIN
   FOR rec
      IN (SELECT a.table_name,
                 a.partition,
                 (TO_DATE (SUBSTR (a.partition, 2), 'YYYYMMDD')
                  - TRUNC (SYSDATE))
                    pocetDniDopredu
            FROM (  SELECT table_name, MAX (partition_name) partition
                      FROM all_tab_partitions
                     WHERE table_owner = tableOwner
                  GROUP BY table_name) a
           WHERE a.partition NOT LIKE '%MAX%'
                 AND SUBSTR (a.partition, 1, 1) = partitionPrefix)
   LOOP
      -- pridam partitions na pocetDni
      FOR i IN 1 .. pocetDni
      LOOP
         sqlcmd :=
               'alter table  '
            || tableOwner
            || '.'
            || rec.table_name
            || ' add partition '
            || partitionprefix
            || TO_CHAR (SYSDATE + i + rec.pocetDniDopredu, 'YYYYMMDD')
            || ' values less than (to_date('''
            || TO_CHAR (SYSDATE + i + rec.pocetDniDopredu + 1, 'DD.MM.YYYY')
            || ''', ''DD.MM.YYYY''));';
         DBMS_OUTPUT.put_line (sqlcmd);
      END LOOP;
   END LOOP;
END;
/
