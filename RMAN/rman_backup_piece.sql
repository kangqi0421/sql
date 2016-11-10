select bp.handle, d.name, D.File#
from
  v$backup_piece bp,
  v$backup_datafile bd,
  v$datafile d
where bp.for_xtts = 'YES'
  and d.file# = 22
  and bp.handle is not null
  and bp.COMPLETION_TIME > sysdate - interval '4' hour
  and bd.set_stamp = bp.set_stamp
  and bd.set_count = bp.set_count
  and bd.file# = d.file#
/

-- list bp to apply on Linux
select start_time, tag, handle, media
  from V$BACKUP_PIECE bp
     where for_xtts = 'YES'
order by set_count desc, start_time desc
;