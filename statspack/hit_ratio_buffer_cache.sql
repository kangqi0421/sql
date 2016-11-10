/* buffer cache hit ratio
 * 
 * omezeno pouze pro pool DEFAULT
 */
SELECT   se.snap_id, se.snap_time, ev.namespace, ev.hitratio
    FROM (SELECT sn.snap_id, sn.snap_time, sn.dbid, sn.instance_number
            FROM stats$snapshot sn) se,
         (SELECT e.snap_id, e.dbid, e.instance_number, e.namespace,
                 CASE
                    WHEN (e.physical_reads - NVL (b.physical_reads, 0)
                         ) > = 0
                    AND (e.db_block_gets - NVL (b.db_block_gets, 0)) > = 0
                    AND (e.consistent_gets - NVL (b.consistent_gets, 0)) > = 0
                       THEN   100
                            - ROUND (  (  (  e.physical_reads
                                           - NVL (b.physical_reads, 0)
                                          )
                                        / (  (  e.db_block_gets
                                              - NVL (b.db_block_gets, 0)
                                             )
                                           + (  e.consistent_gets
                                              - NVL (b.consistent_gets, 0)
                                             )
                                          )
                                       )
                                     * 100,
                                     2
                                    )
                    ELSE   100
                         - ROUND (  (  e.physical_reads
                                     / (e.db_block_gets + e.consistent_gets)
                                    )
                                  * 100,
                                  2
                                 )
                 END hitratio
            FROM (SELECT snap_id, dbid, instance_number, NAME namespace,
                         physical_reads, db_block_gets, consistent_gets
                    FROM stats$buffer_pool_statistics) b,
                 (SELECT snap_id, dbid, instance_number, NAME namespace,
                         physical_reads, db_block_gets, consistent_gets
                    FROM stats$buffer_pool_statistics) e
           WHERE b.snap_id(+) = e.snap_id - 1
             AND b.dbid(+) = e.dbid
             AND b.instance_number(+) = e.instance_number
             AND b.namespace = e.namespace) ev
   WHERE se.snap_time >  TRUNC (SYSDATE - 14)
     AND ev.dbid(+) = se.dbid
     AND ev.instance_number(+) = se.instance_number
     AND ev.snap_id(+) = se.snap_id
	 AND ev.namespace = 'DEFAULT'
ORDER BY se.snap_id
