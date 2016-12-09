--
-- ASM storage
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

--
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