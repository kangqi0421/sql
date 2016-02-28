--// všechny transakce //--


SELECT
    a.username  "UserName"
  , a.sid       "DB Sid"
  , e.spid      "Unix Pid"
  , TO_CHAR(TO_DATE(b.start_time,'mm/dd/yy hh24:mi:ss'),'yyyy/mm/dd hh24:mi:ss') "Trnx_start_time"
  , ROUND(60*24*(sysdate-to_date(b.start_time,'mm/dd/yy hh24:mi:ss')),2) "Elapsed(mins)"
  , c.segment_name "Undo Name"
  , TO_CHAR(b.used_ublk*d.value/1024) "Used Undo Size(Kb)"
  , TO_CHAR(b.used_ublk) "Used Undo Blks"
  , b.log_io "Logical I/O(Blks)"
  , b.log_io*d.value/1024 "Logical I/O(Kb)"
  , b.phy_io "Physical I/O(Blks)"
  , b.phy_io*d.value/1024 "Physical I/O(Kb)"
  , a.program
FROM
    v$session         a
  , v$transaction     b
  , dba_rollback_segs c
  , v$parameter       d
  , v$process         e
WHERE
      b.ses_addr = a.saddr
  AND b.xidusn   = c.segment_id
  AND d.name     = 'db_block_size'
  AND e.ADDR     = a.PADDR
ORDER BY 5
/


--//-- aktivni transakce --//--

select count(1) 
     from v$session a, v$process b
     where a.paddr = b.addr(+)
      and not exists (select 1 from v$mystat where rownum < 2 and sid = a.sid)
      and a.audsid != sys_context('USERENV','SESSIONID')
      and a.taddr is not null
--      and a.username not in ('OPS$SBCIC')
      and exists (select 1 from v$transaction where addr = a.taddr) 
      and not exists (select 1 from v$bgprocess where paddr = a.paddr);