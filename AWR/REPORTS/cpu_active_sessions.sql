-- CPU active sessions pøes obì DB instance
WITH cpu AS
    (
      SELECT   inst_id,
          CAST(sample_time AS DATE) TIME,
          COUNT(*) cnt
        FROM GV$ACTIVE_SESSION_HISTORY A
        WHERE SAMPLE_TIME BETWEEN TIMESTAMP '2014-12-10 09:00:00' 
                              AND TIMESTAMP '2014-12-10 12:00:00'
          AND a.session_state = 'ON CPU'
        GROUP BY inst_id, sample_time
    )
  SELECT   cpu1.time,
      cpu1.cnt "MCIP1",
      cpu2.cnt "MCIP2"
    FROM
      (SELECT   TIME, cnt FROM cpu WHERE inst_id = 1) cpu1
    LEFT OUTER JOIN
      (SELECT   TIME, cnt FROM cpu WHERE inst_id = 2) cpu2
    ON (cpu1.time = cpu2.time)
    order by 1
;