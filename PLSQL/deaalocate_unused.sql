/* Formatted on 2007/12/21 14:36 (Formatter Plus v4.8.8) */
SELECT   di.owner, di.index_name, dip.partition_name
    FROM dba_ind_partitions dip, dba_indexes di
   WHERE di.table_name = 'LOG_ACTIONS'
     AND dip.partition_name IN
            ('D20071215', 'D20071216', 'D20071217', 'D20071218', 'D20071219',
             'D20071220')
     AND dip.index_owner = di.owner
     AND dip.index_name = di.index_name
ORDER BY di.owner, di.index_name, dip.partition_name;



--SET serveroutput on

-- table partitions
DECLARE
   s   VARCHAR (1000);
   CURSOR c_table
   IS
      SELECT table_owner, table_name, partition_name
        FROM dba_tab_partitions
       WHERE table_name = 'LOG_ACTIONS'
         AND partition_name IN
                ('D20071215', 'D20071216', 'D20071217', 'D20071218',
                 'D20071219', 'D20071220');
BEGIN
   FOR rec IN c_table
   LOOP
      s :=
            'alter table '
         || rec.table_owner
         || '.'
         || rec.table_name
         || ' MODIFY PARTITION '
         || rec.partition_name
         || ' DEALLOCATE UNUSED';
      DBMS_OUTPUT.put_line (s || ';');
   END LOOP;
END;
/

-- index partitions

DECLARE
   s   VARCHAR (1000);
   CURSOR c_index
   IS
      SELECT   di.owner, di.index_name, dip.partition_name
          FROM dba_ind_partitions dip, dba_indexes di
         WHERE di.table_name = 'LOG_ACTIONS'
           AND dip.partition_name IN
                  ('D20071215', 'D20071216', 'D20071217', 'D20071218',
                   'D20071219', 'D20071220')
           AND dip.index_owner = di.owner
           AND dip.index_name = di.index_name
      ORDER BY di.owner, di.index_name, dip.partition_name;
BEGIN
   FOR rec IN c_index
   LOOP
      s :=
            'alter index '
         || rec.owner
         || '.'
         || rec.index_name
         || ' MODIFY PARTITION '
         || rec.partition_name
         || ' DEALLOCATE UNUSED';
      DBMS_OUTPUT.put_line (s || ';');
   END LOOP;
END;
/