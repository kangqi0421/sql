DECLARE
   pocetMesicu       NUMBER := 12;
   tableOwner        VARCHAR (100) := 'SYMADM';
   partitionPrefix   CHAR (1) := 'M';
   sqlcmd            VARCHAR (1000);
BEGIN
   -- vyberu vhodne kandidaty pro pridani mesicnich
   FOR rec
      IN (SELECT a.table_name,
                 a.partition,
                 (TO_DATE (SUBSTR (a.partition, 2), 'YYYYMM')
                  - TRUNC (SYSDATE))
                    pocetDniDopredu
            FROM (  SELECT table_name, MAX (partition_name) partition
                      FROM all_tab_partitions
                     WHERE table_owner = tableOwner
                  GROUP BY table_name) a
           WHERE a.partition NOT LIKE '%MAX%'
                 AND SUBSTR (a.partition, 1, 1) =partitionPrefix )
   LOOP
      -- pridam partitions na pocetMesicu
      FOR i IN 1 .. pocetMesicu
      LOOP
         sqlcmd :=
               'alter table  '||tableOwner||'.'||rec.table_name
            || ' add partition '
            || partitionprefix
            || TO_CHAR (ADD_MONTHS ( (SYSDATE + rec.pocetDniDopredu), i),
                        'YYYYMM')
            || ' values less than (to_date('''
            || TO_CHAR (
                  TRUNC (ADD_MONTHS (SYSDATE + rec.pocetDniDopredu, i + 1), 'MM'),
                  'DD.MM.YYYY')
            || ''', ''DD.MM.YYYY''));';
         DBMS_OUTPUT.put_line (sqlcmd);
      END LOOP;
   END LOOP;
END;
/