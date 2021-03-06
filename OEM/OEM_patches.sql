--
-- bez zaruky, obèas tam chybí Oracle Home v OEM
--

select * from MGMT$APPLIED_PATCHES;
select * from MGMT$OH_PATCH;

-- patche na Linuxu
-- pouze pokud existuje Grid nebo Oracle DB HOME, jinak to nevrátí žádné řádky
select
--    p.*,
    p.host,
--    p.home_location,
    P.PATCH,
    patch_release,
    P.INSTALLATION_TIME
  from MGMT$APPLIED_PATCHES p
    --inner join MGMT_TARGETS t ON (p.TARGET_GUID = t.TARGET_GUID)
WHERE 1=1
and platform = 'Linux x86-64'
and host like 'p%'
and home_location like '%grid/%'
--and home_location like '%/db/%'
and patch_release like '12.%'
--and IS_PSU = 'N'  -- nefunguje
and patch in ('24732088', '24917972')
order by p.host, patch
;



-- AUDIT 18743542 pro 12.1
SELECT
  host_name,
  base_version,
  home_location,
  interim_patches_in_home
FROM
  mgmt$software_components
WHERE
  name IN ('oracle.server')
AND
  (
    base_version LIKE '12.1%'
  AND interim_patches_in_home NOT LIKE '%18743542%'
  )
order by host_name;

-- OEM monitoring tablespaces
SELECT
  host_name,
  base_version,
  home_location,
  interim_patches_in_home
FROM
  mgmt$software_components
WHERE
  name IN ('oracle.server')
AND
  (
    base_version LIKE '11.2.0.4%'
  AND interim_patches_in_home NOT LIKE '%19441081%'
  )
order by host_name;