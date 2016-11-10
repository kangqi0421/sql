
CREATE OR REPLACE PACKAGE maint_part
IS
--   PROCEDURE createpartition (tbl_owner IN VARCHAR2);
   PROCEDURE rebuildlocalindexes (idx_owner in varchar2);
   PROCEDURE rebuildglobalindexes (idx_owner in varchar2);
END maint_part;
/

CREATE OR REPLACE PACKAGE BODY maint_part
IS
   PROCEDURE rebuildlocalindexes (idx_owner IN VARCHAR2)
   IS
      --
      -- Procedura urcena k rebuildu partitioned indexu
      --
      txt_ddl   VARCHAR2 (2000);

      CURSOR cur_part
      IS
         SELECT   index_owner, index_name, partition_name
             FROM all_ind_partitions
            WHERE status <> 'USABLE' AND index_owner = idx_owner
         ORDER BY index_name, leaf_blocks DESC;
   BEGIN
      FOR cur_idx IN cur_part
      LOOP
         txt_ddl :=
               'alter index '
            || cur_idx.index_owner
            || '.'
            || cur_idx.index_name
            || ' rebuild partition ';
         txt_ddl := txt_ddl || cur_idx.partition_name || ' compute statistics';
         -- for debug print ltxt_ddl
         DBMS_OUTPUT.put_line (ltxt_ddl);
      --execute immediate ltxt_ddl;
      END LOOP;
   EXCEPTION
      WHEN OTHERS
      THEN
         DBMS_OUTPUT.put_line (TO_CHAR (SQLCODE) || ' - ' || SQLERRM);
   END rebuildlocalindexes;
   
   /* ------------------------------------------------------------------------- */
   
   PROCEDURE rebuildglobalindexes (idx_owner IN VARCHAR2)
   IS
      --
      -- Procedura urcena k rebuildu globalnich indexu
      --
      txt_ddl   VARCHAR2 (2000);

      CURSOR cur_all_idx
      IS
         SELECT   owner, index_name
             FROM all_indexes
            WHERE status <> 'USABLE' AND index_owner = idx_owner
         ORDER BY index_name, leaf_blocks DESC;
   BEGIN
      FOR cur_idx IN cur_all_idx
      LOOP
         txt_ddl :=
               'alter index '
            || cur_idx.index_owner
            || '.'
            || cur_idx.index_name
            || ' rebuild compute statistics';
         -- for debug print ltxt_ddl
         DBMS_OUTPUT.put_line (ltxt_ddl);
      --execute immediate ltxt_ddl;
      END LOOP;
   EXCEPTION
      WHEN OTHERS
      THEN
         DBMS_OUTPUT.put_line (TO_CHAR (SQLCODE) || ' - ' || SQLERRM);
   END rebuildglobalindexes;
   
END maint_part;
/