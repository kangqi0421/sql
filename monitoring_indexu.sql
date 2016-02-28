--// stav monitoringu nad tabulkou //--

SELECT u.name "owner",
       io.name "index_name",
       t.name "table_name",
       DECODE (BITAND (i.flags, 65536), 0, 'no', 'yes') "monitoring",
       DECODE (BITAND (NVL (ou.flags, 0), 1), 0, 'no', 'yes') "used",
       ou.start_monitoring "start_monitoring",
       ou.end_monitoring "end_monitoring"
  FROM sys.obj$ io,
       sys.obj$ t,
       sys.ind$ i,
       sys.object_usage ou,
       sys.user$ u
 WHERE     t.obj# = i.bo#
       AND io.owner# = u.user#
       AND io.obj# = i.obj#
       AND u.name = 'ASCBL'
       AND t.name = 'BDT_MC_MSG'
       AND i.obj# = ou.obj#(+);