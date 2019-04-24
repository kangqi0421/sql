-- Availability - UP, DOWN, UNKNOWN
select
    target_name, availability_status,
    availability_status_code,
    decode(availability_status_code, 0, 'DOWN', 1, 'UP', 'UNKNOWN') availability
   from SYSMAN.MGMT$AVAILABILITY_CURRENT
  where
    target_type like '%database'
    and availability_status_code <> 1;
