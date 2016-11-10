--// info o narustu segmentu //--

DBA_HIST_SEG_STAT
-- obcas to haze nesmysly
-- vraci nesmysly na MCIP

db block changes - odpovídá cca redo size per segment

SELECT
  end_interval_time,
  owner,
  object_name,
  space_allocated_total,
  space_used_delta
FROM
  DBA_HIST_SEG_STAT NATURAL
JOIN dba_hist_snapshot NATURAL
JOIN DBA_HIST_SEG_STAT_OBJ
WHERE
  begin_interval_time > SYSDATE - 7
  --and owner = ''
AND object_name = 'CMS_RE_EVALUATION' ;


//-- db_block_changes_delta //--
SELECT *
  FROM (  SELECT owner,
                 object_name,
                 object_type,
                 CEIL (
                    ratio_to_report (SUM (db_block_changes_delta)) OVER ()
                    * 100)
                    "DB_BLOCK_CHANGES [%]",
                 CEIL (
                    ratio_to_report (SUM (physical_writes_delta)) OVER () * 100)
                    "PHYSICAL_WRITES [%]"
            FROM DBA_HIST_SEG_STAT NATURAL JOIN DBA_HIST_SEG_STAT_OBJ NATURAL JOIN dba_hist_snapshot
           WHERE instance_number = 1
		     AND begin_interval_time > sysdate - 5/24
        GROUP BY owner, object_name, object_type
        ORDER BY 4 DESC)
 WHERE ROWNUM <= 10;