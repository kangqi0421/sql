-- SQL response time

SELECT
  TO_CHAR(round(end_time,'HH24'),'hh24:mi') TIME, -- round time to HOUR
  TO_CHAR(END_TIME, 'DAY')|| metric_name,
  ROUND( average * 10, 2) "Response Time (ms)"
FROM
  dba_hist_sysmetric_summary
WHERE
  1              =1
AND metric_name IN ( 'SQL Service Response Time' )
  --      AND end_time > TRUNC(sysdate-:days)
AND end_time BETWEEN DATE'2016-02-08' AND DATE'2016-02-10'
ORDER BY
  1;

