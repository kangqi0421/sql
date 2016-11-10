-- RMAN block size
SELECT   file#,
    incremental_level INCR,
    datafile_blocks BLKS,
    block_size blksz,
    blocks_read READ,
    ROUND((blocks_read/datafile_blocks) * 100,2) "%READ",
    blocks WRTN,
    ROUND((blocks/datafile_blocks)*100,2) "%WRTN"
  FROM v$backup_datafile
  WHERE completion_time > sysdate - 7
    AND file#           = 1
  ORDER BY file#;
