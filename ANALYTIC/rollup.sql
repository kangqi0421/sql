select   machine ,process ,count(*)
from v$session
group by rollup (machine,process)
/


-- pocty a velikosti disku dle VGR

select OS_MB "MB", substr(path, 6, 5) vgr, count(*) as "#disku"
  from v$asm_disk 
 where GROUP_NUMBER = 1
group by rollup (OS_MB,substr(path, 6, 5))
order by OS_MB, vgr
/