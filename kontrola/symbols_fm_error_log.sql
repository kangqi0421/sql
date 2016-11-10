select *
  from symbols.fm_error_log
  where error_date >= trunc(sysdate - &pocet_dni)
  order by error_date desc;

select *
  from fm_error_log_dtl
  where error_date >= trunc(sysdate - &pocet_dni)
  order by error_date desc;