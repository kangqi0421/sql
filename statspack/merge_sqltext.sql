/* Formatted on 2005/11/01 17:20 (Formatter Plus v4.8.6) */
MERGE INTO stats$sqltext d
   USING (SELECT hash_value, text_subset, piece, sql_text, address,
                 command_type, last_snap_id
            FROM sqltext) s
   ON (    d.hash_value = s.hash_value
       AND d.text_subset = s.text_subset
       AND d.piece = s.piece)
   WHEN MATCHED THEN
      UPDATE
         SET d.address = s.address, d.sql_text = s.sql_text,
             d.command_type = s.command_type, d.last_snap_id = s.last_snap_id
   WHEN NOT MATCHED THEN
      INSERT (d.hash_value, d.text_subset, d.piece, d.sql_text, d.address,
              d.command_type, d.last_snap_id)
      VALUES (s.hash_value, s.text_subset, s.piece, s.sql_text, s.address,
              s.command_type, s.last_snap_id);