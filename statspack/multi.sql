define DB=TS3D
define FROM=20111216_1200
define TO=20111218_2000


set head off feed off trimout on trimspool on pagesize 0 echo off
set head off feed off pages 0 term off ver off echo off
spool makesnap.sql;
SELECT    'def begin_snap='
       || snap_id
       || CHR (10)
       || 'def end_snap='
       || next_snap
       || CHR (10)
       || 'def report_name=&DB' || '_'
       || to_char(from_time,'YYMMDD_HH24MI')
       || '__'
       || to_char(to_time,'YYMMDD_HH24MI') || '.sp'
       || CHR (10)
       || '@?/rdbms/admin/spreport' || ';'
  FROM (
-- snap a nasledujici
        SELECT *
          FROM (SELECT   snap_id,SNAP_TIME,
                         LAG (snap_id) OVER (ORDER BY snap_id DESC) next_snap,
                         snap_time from_time,
                                                 LAG (snap_time) OVER (ORDER BY snap_id DESC) to_time
                    FROM stats$snapshot
                ORDER BY snap_id)
        )
   WHERE SNAP_TIME >= TO_DATE ('&FROM', 'YYYYMMDD_HH24MI')
     AND SNAP_TIME <= TO_DATE ('&TO', 'YYYYMMDD_HH24MI')
     AND SNAP_ID!=(SELECT MAX(SNAP_ID) from stats$snapshot);
spool off;