--
-- BCT block change tracking
--

select * from v$block_change_tracking;


sql 'alter database enable block change tracking';

    DECLARE
      v_status varchar2(10);
    BEGIN
      select status into v_status from v$block_change_tracking;
      IF v_status != 'ENABLED' THEN
        execute immediate 'alter database enable block change tracking';
      END IF;
    END;
    /



--// ověření, že je block change tracinkg použit //--

SELECT file#,
       completion_time,
       used_change_tracking BCT,
       incremental_level INCR,
       datafile_blocks BLKS,
       blocks_read READ,
       ROUND ( (blocks_read / datafile_blocks) * 100) AS "% read for backup"
       from v$backup_datafile
WHERE 1=1
--  and file# = 8  -- SYSTEM tablespace datafile
  and file# > 0
  and completion_time > sysdate -1
order by 1;

select file#,
            avg(datafile_blocks),
            avg(blocks_read),
            avg(blocks_read/datafile_blocks) * 100 as "% read for backup"
       from v$backup_datafile
      where incremental_level > 0
        and used_change_tracking = 'YES'
        and completion_time > sysdate -1
      group by file#
      order by file#;
