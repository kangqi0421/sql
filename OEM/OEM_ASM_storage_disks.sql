--
-- ASM storage
--

define db = CTL

select 
       NVL(d.db_name, 'UNKNOWN') dbname,
       REGEXP_SUBSTR(disk.cm_target_name, '[dt][^\.]+', 1, 1)
        || '_' || replace(dg.disk_group, 'D01', 'DATA') storage_group,  -- nutno jeětě poladit
       dg.disk_group,
       replace(dg.disk_group, 'D01', 'DATA') disk_group_new,  -- nutno jeětě poladit
       round(total_size) "total size GB",
       round(total_size/member_disk_count) "disk size",
       round(total_size)/4 "disk size po 4",       
       round(total_size)/8 "disk size po 8-mi",
       member_disk_count
  from (
      select distinct disk_group, total_size, member_disk_count from SYSMAN.MGMT_ASM_DISKGROUP_ECM)
        dg
       LEFT JOIN (
          select distinct DISKGROUP, DB_NAME from SYSMAN.MGMT_ASM_CLIENT_ECM
          ) d
         on (d.diskgroup = dg.disk_group)
        join  (
           select distinct cm_target_name, disk_group from SYSMAN.cm$mgmt_asm_disk_ecm)
           disk
          on (disk.disk_group = dg.disk_group)
  where 1 = 1 
--    AND d.db_name like '&db%'
    and d.diskgroup like 'REVT%'
order by db_name, disk_group
;



select * from SYSMAN.MGMT_ASM_DISKGROUP_ECM
  where disk_group like 'CMTT%';

select * from SYSMAN.cm$mgmt_asm_disk_ecm;

-- metric
AND m.metric_name = 'DiskGroup_Usage'
AND metric_column in ('usable_file_mb',  -- Disk Group Usable (MB)
                      'total_mb',        -- Size (MB)
                      'percent_used'     -- Percent Used
                      )


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

-- ASM disky
set pages 999
SELECT
  distinct cm_target_name, disk_group
--  * 
FROM
    sysman.cm$mgmt_asm_disk_ecm
  where path like '/dev/mapper/asm_449%'
    --- and disk_group like '%D01'
order by 1,2;


-- CM view
CM$MGMT_ASM_CLUSTER_ECM
CM$MGMT_ASM_DISKGROUP_ECM
CM$MGMT_ASM_INIT_PARAMS_ECM
CM$MGMT_ASM_DG_ATTR_ECM
CM$MGMT_ASM_DISK_ECM
CM$MGMT_DB_ASM_DISK_ECM -- prázdné
CM$MGMT_HAS_MANAGED_ASM_ECM
CM$MGMT_ASM_INSTANCE_ECM
MGMT$CS_ASM_DISKGRP_SETTINGS
CM$MGMT_ASM_FLEX_ENABLED_ECM
CM$MGMT_ASM_CLIENT_ECM
CM$MGMT_ASM_PATCHES_ECM
--
