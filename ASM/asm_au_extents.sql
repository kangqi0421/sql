-- ASM extent map
https://twiki.cern.ch/twiki/bin/view/PDBService/ASM_Internals

# ziskani group number
select GROUP_NUMBER, NAME from v$asm_diskgroup;

# velikosti ASM files
select file_number, bytes/1048576 from V$ASM_FILE where GROUP_NUMBER = 1;

# find file_number for online redologs
select file_number, name from  v$asm_alias where name like 'group_1.%';

# find the number and location of the extents
select 
    --GROUP_KFFXP,  -- group number to join with v$asm_diskgroup
	DISK_KFFXP,		-- disk number
	AU_KFFXP, 		-- Relative position of the allocation
	--PXN_KFFXP,	-- Progressive file extent number - physical extent
	XNUM_KFFXP		-- ASM file extent number - virtual extent
	--LXN_KFFXP      -- 0->primary extent, 1->mirror extent, 2->2nd mirror copy (high redundancy and metadata)
  from x$kffxp 
 where 
  GROUP_KFFXP= 1 
  AND number_kffxp = (select file_number from v$asm_alias where name='group_1.308.854893895')
 order by XNUM_KFFXP ;


select number_kfdat "disk#"
      ,count(*) "AU cnt#"
 from x$kfdat 
where GROUP_KFDAT = 2
  and V_KFDAT = 'V'
group by number_kfdat;

col "VF" for a2
select GROUP_KFDAT "group#", number_kfdat "disk#", v_kfdat "VF", count(*)
 from x$kfdat
where GROUP_KFDAT = 2
group by GROUP_KFDAT, number_kfdat, v_kfdat;

select GROUP_KFDAT,NUMBER_KFDAT,AUNUM_KFDAT from x$kfdat where 
   fnum_kfdat=(select file_number from v$asm_alias where name='Backup.256.730593523');

select count(XNUM_KFFXP) AU_count,  NUMBER_KFFXP file#, GROUP_KFFXP DG# from x$kffxp where NUMBER_KFFXP < 256
group by NUMBER_KFFXP, GROUP_KFFXP
order by count(XNUM_KFFXP) ;

col Name format a60
select f.group_number, f.file_number, bytes/1048576 "bytes [MB]", space/(1024*1024) "space [MB]", a.name "Name"
from v$asm_file f, v$asm_alias a
where f.group_number=a.group_number and f.file_number=a.file_number
   and system_created='Y'
	and f.group_number = 2
   order by f.group_number, f.file_number;


select DISK_KFFXP, sum(AU_KFFXP)
 from x$kffxp 
  where GROUP_KFFXP = 2
group by DISK_KFFXP
order by DISK_KFFXP;