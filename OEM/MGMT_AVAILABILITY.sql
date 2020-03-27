-- MGMT$AVAILABILITY_CURRENT

Target Up	1
Target Down	0
Blackout	5

SELECT *
FROM   sysman.mgmt$availability_current
--WHERE  availability_status='Target Down'
;

select
    target_name, availability_status,
    availability_status_code,
    availability_status_code
   from SYSMAN.MGMT$AVAILABILITY_CURRENT
  where
    target_type like '%database'
    and availability_status_code <> 1;
