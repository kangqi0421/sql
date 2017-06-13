--// denní velikost redologu a FRA --//
set lin 180 pages 100
col db format a8
col FRA_DG format A15
col FRA_DG_SIZE for 999999

define DNI = 31
--define DNI = 7

--// Supplemental logging //--
SELECT NAME, LOG_MODE, SUPPLEMENTAL_LOG_DATA_MIN SL_MIN, SUPPLEMENTAL_LOG_DATA_PK SL_PK,
       SUPPLEMENTAL_LOG_DATA_UI SL_UI, SUPPLEMENTAL_LOG_DATA_FK SL_FK, SUPPLEMENTAL_LOG_DATA_ALL SL_ALL
 FROM V$DATABASE;

--// v$archived_log per day //--
WITH QUERY AS
    (
      SELECT   TRUNC (FIRST_TIME)         AS DATUM,
               SUM (BLOCKS * BLOCK_SIZE)/power(1024,3)  AS redo_size
        FROM gv$archived_log
        WHERE 1=1
             AND first_time > TRUNC (SYSDATE - &DNI)
        GROUP BY TRUNC (FIRST_TIME)
    )
  SELECT
      to_char(DATUM,'dd.mm.yyyy') "date",
      ROUND(redo_size) "redo_size [GB]",
      ROUND(MAX(redo_size) over ()) "redo_max",
      ROUND(AVG(redo_size) over ()) "redo_avg"
    from query
     -- WHERE DATUM > SYSDATE - &DNI
    ORDER BY datum;

/*

--//pouze max a avg value //--
SELECT TRUNC (AVG (mb)), TRUNC (MAX (mb))
  FROM (  SELECT TRUNC (COMPLETION_TIME),
                 SUM (blocks * block_size) / 1048576 AS mb
            FROM gv$archived_log
        GROUP BY TRUNC (COMPLETION_TIME));

*/

-- log file switches per hour
/*
prompt log file switches per hour > optimal = 6/hour
prompt

SELECT to_char(FIRST_TIME,'YYYYMMDD-HH24') DAYDATE,
       count(*) switches
  FROM v$log_history
  WHERE first_time > TRUNC (SYSDATE - 0)
  group by to_char(FIRST_TIME,'YYYYMMDD-HH24')
  having count(*) > 6
  order by daydate;

--// redo max a FRA size //--
WITH
  -- avg a max FRA in used
  redo_max AS
  (
    SELECT
      MAX(redo_size) max_fra_used,
  	  AVG(redo_size) avg_fra_used
    FROM
      (
        SELECT
          TRUNC (FIRST_TIME),
          SUM(BLOCKS * BLOCK_SIZE) redo_size
        FROM
          gv$archived_log
        WHERE
          first_time > TRUNC (SYSDATE - &DNI)
          group by TRUNC (FIRST_TIME)
       )
  )
  ,
  -- params db_recovery_file_dest_size --
  db_reco AS
  (
    SELECT
      value db_reco_size
    FROM
      v$parameter
    WHERE
      name LIKE 'db_recovery_file_dest_size'
  )
SELECT
  sys_context('USERENV', 'DB_NAME') db,
  fra_dg, fra_dg_size,
  round(db_reco_size/power(1024,3)) db_fra_size,
  round(avg_fra_used/power(1024,3)) redo_avg,
  round(max_fra_used/power(1024,3)) redo_max,
  round(max_fra_used/db_reco_size*100,2) FRA_pct_used
FROM
  redo_max,
  db_reco,
  -- ASM disk group info --
  (SELECT name fra_dg, round(total_mb/1024) fra_dg_size FROM v$asm_diskgroup
  WHERE name in (select ltrim(value,'+') from v$parameter where name = 'db_recovery_file_dest')) fra
;

*/

/*

-- redo po jedné hodině


--// :n 	... definuje interval po n minutach  //--
SELECT   TRUNC (first_time, 'hh24') + (TRUNC (TO_CHAR (first_time, 'mi') / :n) * :n) / 24 / 60,
         COUNT (*) "cnt",
		 ROUND (SUM (blocks * block_size) / 1048576, 1) "redo size [MB]"
    FROM v$archived_log
   WHERE first_time > TRUNC (SYSDATE - 7)
GROUP BY   TRUNC (first_time, 'hh24')
         + (TRUNC (TO_CHAR (first_time, 'mi') / :n) * :n) / 24 / 60

// tabulka po hodine //
SELECT to_date(first_time) DAY,
to_char(sum(decode(to_char(first_time,'HH24'),'00',1,0)),'999') "00",
to_char(sum(decode(to_char(first_time,'HH24'),'01',1,0)),'999') "01",
to_char(sum(decode(to_char(first_time,'HH24'),'02',1,0)),'999') "02",
to_char(sum(decode(to_char(first_time,'HH24'),'03',1,0)),'999') "03",
to_char(sum(decode(to_char(first_time,'HH24'),'04',1,0)),'999') "04",
to_char(sum(decode(to_char(first_time,'HH24'),'05',1,0)),'999') "05",
to_char(sum(decode(to_char(first_time,'HH24'),'06',1,0)),'999') "06",
to_char(sum(decode(to_char(first_time,'HH24'),'07',1,0)),'999') "07",
to_char(sum(decode(to_char(first_time,'HH24'),'08',1,0)),'999') "08",
to_char(sum(decode(to_char(first_time,'HH24'),'09',1,0)),'999') "09",
to_char(sum(decode(to_char(first_time,'HH24'),'10',1,0)),'999') "10",
to_char(sum(decode(to_char(first_time,'HH24'),'11',1,0)),'999') "11",
to_char(sum(decode(to_char(first_time,'HH24'),'12',1,0)),'999') "12",
to_char(sum(decode(to_char(first_time,'HH24'),'13',1,0)),'999') "13",
to_char(sum(decode(to_char(first_time,'HH24'),'14',1,0)),'999') "14",
to_char(sum(decode(to_char(first_time,'HH24'),'15',1,0)),'999') "15",
to_char(sum(decode(to_char(first_time,'HH24'),'16',1,0)),'999') "16",
to_char(sum(decode(to_char(first_time,'HH24'),'17',1,0)),'999') "17",
to_char(sum(decode(to_char(first_time,'HH24'),'18',1,0)),'999') "18",
to_char(sum(decode(to_char(first_time,'HH24'),'19',1,0)),'999') "19",
to_char(sum(decode(to_char(first_time,'HH24'),'20',1,0)),'999') "20",
to_char(sum(decode(to_char(first_time,'HH24'),'21',1,0)),'999') "21",
to_char(sum(decode(to_char(first_time,'HH24'),'22',1,0)),'999') "22",
to_char(sum(decode(to_char(first_time,'HH24'),'23',1,0)),'999') "23"
from
v$log_history
where to_date(first_time) > sysdate - 7
GROUP by
to_char(first_time,'DD.MM.YYYY'), to_date(first_time)
order by to_date(first_time)
/

*/