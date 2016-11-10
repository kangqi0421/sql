col database for a15
select database_name "database",
         sum(space)/1024/1024 "Size in MB" FROM (
  SELECT
      CONNECT_BY_ROOT db_name as database_name, space
  FROM
      ( SELECT
            a.parent_index       pindex
          , a.name               db_name
          , a.reference_index    rindex
          , f.bytes              bytes
          , f.space              space
          , f.type               type
        FROM
            v$asm_file f RIGHT OUTER JOIN v$asm_alias a
                         USING (group_number, file_number)
      )
  WHERE type IS NOT NULL
  START WITH (MOD(pindex, POWER(2, 24))) = 0
      CONNECT BY PRIOR rindex = pindex)
group by database_name
order by database_name
/