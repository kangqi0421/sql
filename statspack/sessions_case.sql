/* Formatted on 2005/01/31 19:55 (Formatter Plus v4.8.0) */
SELECT   CASE
            WHEN TO_CHAR (sn.snap_time, 'HH24') = '00'
            AND TO_CHAR (sn.snap_time, 'MI') = '00'
               THEN TO_CHAR (sn.snap_time, 'dd.mm.yy')
            ELSE NULL
         END AS "datum",
         CASE
            WHEN TO_CHAR (sn.snap_time, 'HH24') IN ('00', '06', '12', '18')
            AND TO_CHAR (sn.snap_time, 'MI') = '00'
               THEN TO_CHAR (sn.snap_time, 'hh24:mi')
            ELSE NULL
         END AS "cas",
         st.VALUE "#sessions [-]"
    FROM stats$sysstat st, stats$snapshot sn
   WHERE st.snap_id = sn.snap_id
     AND st.NAME = 'logons current'
     AND sn.snap_time between to_date('31.1.2005', 'dd.mm.yyyy') and to_date('13.2.2005', 'dd.mm.yyyy')
ORDER BY snap_time