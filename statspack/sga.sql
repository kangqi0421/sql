/* Formatted on 2005/01/18 17:48 (Formatter Plus v4.8.0) */
/*	shared/large pool free size z v$sgastat	 		 */

SELECT sn.snap_time,
       sp.BYTES / 1048576 "shared pool free bytes [MB]",
       lp.BYTES / 1048576 "large pool free bytes [MB]"
    FROM (SELECT snap_id, BYTES
            FROM stats$sgastat
           WHERE NAME = 'free memory' AND pool = 'shared pool') sp,
         (SELECT snap_id, BYTES
            FROM stats$sgastat
           WHERE NAME = 'free memory' AND pool = 'large pool') lp,
         stats$snapshot sn
   WHERE sp.snap_id = sn.snap_id
     AND lp.snap_id = sn.snap_id
     AND sn.snap_id BETWEEN &snap_start AND &snap_konec
ORDER BY snap_time