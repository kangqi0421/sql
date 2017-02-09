--
-- bez zaruky, obèas tam chybí Oracle Home v OEM
--

select * from MGMT$APPLIED_PATCHES;
select * from MGMT$OH_PATCH;

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