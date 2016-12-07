--
-- ASM data
--

select disk_group, round(total_size) "size GB"
  from SYSMAN.MGMT_ASM_DISKGROUP_ECM
  where
       disk_group like 'RDSP_%'
    or disk_group like 'BRAP_%'
    or disk_group like 'RDLP_%'
order by disk_group;

select disk_group,
       round(total_size),
       member_disk_count,
       round(total_size/member_disk_count) "disk size",
       round(total_size)/8 "disk size po 8-mi",
       redundancy
  from SYSMAN.MGMT_ASM_DISKGROUP_ECM
  where disk_group like 'INEP_%'
order by disk_group;