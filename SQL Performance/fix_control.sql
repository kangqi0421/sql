select *
from v$system_fix_control
where optimizer_feature_enable='12.1.0.2'
  and description like '%row_number%';