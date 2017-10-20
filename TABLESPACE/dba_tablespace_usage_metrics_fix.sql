create or replace view DBA_TABLESPACE_USAGE_METRICS
    (TABLESPACE_NAME, USED_SPACE, TABLESPACE_SIZE, USED_PERCENT)
as
--  SELECT  t.name,
--        tstat.kttetsused,
--        tstat.kttetsmsize,
--        (tstat.kttetsused / tstat.kttetsmsize) * 100
--  FROM  sys.ts$ t, x$kttets tstat
--  WHERE
--        t.online$ != 3 and
--        t.bitmapped <> 0 and
--        t.contents$ = 0 and
--        bitand(t.flags, 16) <> 16 and
--        t.ts# = tstat.kttetstsn
--
-- DATAFILE
  SELECT  t.name,
       sum(f.allocated_space),
       sum(f.file_maxsize),
       (sum(f.allocated_space)/sum(f.file_maxsize))*100
  FROM sys.ts$ t, v$filespace_usage f
 WHERE
     t.online$ != 3 and
     t.bitmapped <> 0 and
     t.contents$ = 0 and
     bitand(t.flags, 16) <> 16 and
     t.ts# = f.tablespace_id
     GROUP BY t.name, f.tablespace_id, t.ts#
union
-- TEMP
 SELECT t.name, sum(f.allocated_space), sum(f.file_maxsize),
     (sum(f.allocated_space)/sum(f.file_maxsize))*100
     FROM sys.ts$ t, v$filespace_usage f
     WHERE
     t.online$ != 3 and
     t.bitmapped <> 0 and
     t.contents$ <> 0 and
     f.flag = 6 and
     t.ts# = f.tablespace_id
     GROUP BY t.name, f.tablespace_id, t.ts#
union
-- UNDO
 SELECT t.name, sum(f.allocated_space), sum(f.file_maxsize),
     (sum(f.allocated_space)/sum(f.file_maxsize))*100
     FROM sys.ts$ t, gv$filespace_usage f, gv$parameter param
     WHERE
     t.online$ != 3 and
     t.bitmapped <> 0 and
     f.inst_id = param.inst_id and
     param.name = 'undo_tablespace' and
     t.name = param.value and
     f.flag = 6 and
     t.ts# = f.tablespace_id
     GROUP BY t.name, f.tablespace_id, t.ts#
/