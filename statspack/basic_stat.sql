/* Formatted on 2005/05/17 16:10 (Formatter Plus v4.8.5) */
SELECT   TO_CHAR (sn.snap_time, 'dd.mm.yyyy hh24:mi') "datum",
         lc.VALUE "#sessions [-]", 
		 uc.VALUE "#user commits [-]", uc.uc_sec "#user commits/sec [-]", 
		 ur.VALUE "#user rollbacks [-]",
         ROUND (rs.VALUE / 1024, 0) "redo size [kB]", ROUND (rs.rs_sec / 1024, 0) "redo size/sec [kB]"
    FROM (SELECT lc.snap_id, lc.VALUE
            FROM stats$sysstat lc
           WHERE NAME = 'logons current') lc,
         (SELECT uc.snap_id, uc.VALUE, ROUND (VALUE / c_time, 1) uc_sec
            FROM sysstat_per_sec uc
           WHERE NAME = 'user commits') uc,
         (SELECT ur.snap_id, ur.VALUE, ROUND (VALUE / c_time, 1) ur_sec
            FROM sysstat_per_sec ur
           WHERE NAME = 'user rollbacks') ur,
         (SELECT rs.snap_id, rs.VALUE, ROUND (VALUE / c_time, 1) rs_sec
            FROM sysstat_per_sec rs
           WHERE NAME = 'redo size') rs,
         stats$snapshot sn
   WHERE lc.snap_id = uc.snap_id
     AND uc.snap_id = ur.snap_id
     AND ur.snap_id = rs.snap_id
     AND rs.snap_id = lc.snap_id
     AND lc.snap_id = sn.snap_id
     AND sn.snap_id BETWEEN &snap_start AND &snap_konec
ORDER BY snap_time
/