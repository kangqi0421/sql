  SELECT obj#, SUM (bbw)
    FROM (SELECT SNAP_ID,
                 DATAOBJ#,
                 OBJ#,
                 NVL (
                    DECODE (
                       GREATEST (
                          BUFFER_BUSY_WAITS,
                          NVL (
                             LAG (
                                BUFFER_BUSY_WAITS)
                             OVER (PARTITION BY dataobj#, obj#
                                   ORDER BY snap_id),
                             0)),
                       BUFFER_BUSY_WAITS, BUFFER_BUSY_WAITS
                                          - LAG (
                                               BUFFER_BUSY_WAITS)
                                            OVER (PARTITION BY dataobj#, obj#
                                                  ORDER BY snap_id),
                       BUFFER_BUSY_WAITS),
                    0)
                    bbw
            FROM stats$seg_stat)
   WHERE snap_id BETWEEN 266330 AND 266347
GROUP BY obj#
ORDER BY 2 DESC        
/