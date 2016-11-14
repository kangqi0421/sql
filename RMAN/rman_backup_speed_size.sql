-- DB v$rman_backup_job_details
set linesize 200

column status format a10
column COMMAND_ID for a12
column time_taken_display format a10;
column input_bytes_display format a12;
column output_bytes_display format a12;
column output_bytes_per_sec_display format a10;
column ses_key format 9999999
column ses_recid format 9999999
column device_type format a10
column "rate MB/s" for a13

SELECT
--  b.*,
  --b.session_key,
  --b.session_recid ses_recid,
  --b.session_stamp,
  --b.command_id,
  b.input_type,
  b.output_device_type device_type,
  to_char(b.start_time,'DD.MM.YYYY HH24:MI') "Start Time",
  b.time_taken_display,
  round(b.input_bytes/1048576/1024) "input [GB]",
  round(b.output_bytes/1048576/1024) "output [GB]",
  round(b.compression_ratio,1) "compress ratio",
  round(b.elapsed_seconds/60) "elapsed time [min]",
  OUTPUT_BYTES_PER_SEC_DISPLAY "rate",
  b.status
  FROM v$rman_backup_job_details b
 WHERE b.start_time > (SYSDATE - 4)
     AND b.input_type like 'DB%'
--    AND b.input_type = 'DATAFILE FULL'
--    AND b.output_device_type = 'DISK'
--   AND STATUS = 'COMPLETED'
ORDER BY b.start_time DESC;

-- summary per datafile backup
SELECT min(b.start_time), max(b.end_time),
	round(sum(b.elapsed_seconds)) "elapsed time",
  round(sum(b.output_bytes)/1048576/1024) "output bytes [GB]",
  round(sum(b.output_bytes)/1048576/sum(b.elapsed_seconds)) "rate MB/s"
  FROM v$rman_backup_job_details b
 WHERE b.start_time > (SYSDATE - 3)
    AND b.input_type = 'DATAFILE FULL'
	  AND b.output_device_type = 'DISK';
;

-- orientační délky a velikosti backup inkrementů
set lines 180
col rate for a10
SELECT start_time,
  b.input_type,
  round(b.input_bytes/1048576/1024) "input bytes [GB]",
  round(b.output_bytes/1048576/1024) "output bytes [GB]",
  round(b.elapsed_seconds/60) "elapsed time [min]",
  --round(b.output_bytes/1048576/b.elapsed_seconds) "rate MB/s",
  OUTPUT_BYTES_PER_SEC_DISPLAY "rate"
  FROM v$rman_backup_job_details b
 WHERE
      (b.input_type like 'DB%' or b.input_type like 'DATAFILE%')
--    AND b.output_device_type = 'DISK'
ORDER by start_time DESC
;

-- RMAN catalog backup SPEED, SIZE
column time_taken_display format a10;

SELECT
--    a.*,
    start_time,
--    round(a.elapsed_seconds/60) "ela [min]",
    a.time_taken_display,
--    a.input_type,
--    a.status,
--    round(COMPRESSION_RATIO, 1) "compress ratio",
--    round(output_bytes_per_sec/1048576, 1) "Output MB/s",
    a.output_bytes_per_sec_display,
--    ROUND(INPUT_BYTES /1048576/1024, 1) "Input [GB]",
    ROUND(OUTPUT_BYTES/1048576/1024, 1) "Output [GB]"
  FROM RMAN_CTLRP.RC_RMAN_BACKUP_JOB_DETAILS a
   WHERE 1=1
     AND input_type LIKE 'DB%'    -- db full
--     AND input_type LIKE 'RECVR AREA'   -- redo
--     AND input_type LIKE 'ARCHIVELOG'   -- redo
     AND status not like '%ERRORS'
--     and start_time > sysdate - 14
     and OUTPUT_BYTES /1048576/1024 > 600
  ORDER BY a.start_time ;