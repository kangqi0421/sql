--
-- ASM storage
--

select asm.db_name,
       disk_group,
       round(total_size) "total size GB",
       round(total_size/member_disk_count) "disk size",
       round(total_size)/8 "disk size po 8-mi",
       member_disk_count
  from CM$MGMT_ASM_CLIENT_ECM asm join CM$MGMT_ASM_DISKGROUP_ECM dg
         on (asm.diskgroup = dg.disk_group)
  where asm.db_name like ('BMWE%')
order by db_name, disk_group
;

-- metric
AND m.metric_name = 'DiskGroup_Usage'
AND metric_column in ('usable_file_mb',  -- Disk Group Usable (MB)
                      'total_mb')        -- Size (MB)


--
select
    disk_group,
    round(total_size) "size GB",
    member_disk_count
  from SYSMAN.MGMT_ASM_DISKGROUP_ECM
  where
       disk_group like 'ODIP_%'
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

-- CM view
CM$MGMT_ASM_CLUSTER_ECM
CM$MGMT_ASM_DISKGROUP_ECM
CM$MGMT_ASM_INIT_PARAMS_ECM
CM$MGMT_ASM_DG_ATTR_ECM
CM$MGMT_ASM_DISK_ECM
CM$MGMT_DB_ASM_DISK_ECM
CM$MGMT_HAS_MANAGED_ASM_ECM
CM$MGMT_ASM_INSTANCE_ECM
MGMT$CS_ASM_DISKGRP_SETTINGS
CM$MGMT_ASM_FLEX_ENABLED_ECM
CM$MGMT_ASM_CLIENT_ECM
CM$MGMT_ASM_PATCHES_ECM
--