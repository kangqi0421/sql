-- LICENSE_COSTS_FULL
select
    app_name,
    lic_env_name,
    current_prod_name,
    --licdb_name,
    lic_type_name,
    round(sum(calc_lic_cnt),1)
  from OLI_OWNER.LICENSE_COSTS_FULL
 where app_name like 'FASCR'
  -- and current_prod_name = 'Enterprise Edition'
 group by app_name, LIC_ENV_NAME,current_prod_name, lic_type_name
order by 1,2, 3, 4
 ;

select * from OLI_OWNER.OLAPI_LICENCE_USAGE_SUMMARY
fetch first 5 rows only
-- where hostname like 'tgsymdb1%'
 ;

-- oprava Active na Y v Oracle licencích
select a.*
  from OLI_OWNER.LICENSE_ALLOCATIONS a
  join OLI_OWNER.LICENSED_ENVIRONMENTS e on (a.lic_env_id = e.lic_env_id)
  where lic_env_name like 'tordb06%';
;

update OLI_OWNER.LICENSE_ALLOCATIONS
  SET allocation_date = trunc(sysdate),
      csi_id = 133,
      initial_csi_id = 133,
      active='Y'
where lic_env_id in (1187,1188) ;

