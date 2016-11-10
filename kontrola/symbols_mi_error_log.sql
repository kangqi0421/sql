-- EOD errors
select *
  from kmdw.mi_error_log
  where error_date >= trunc(sysdate - &pocet_dni)
  order by error_date desc;

-- EOD  
select * from KMDW.KM_PROCESS
 where sym_run_date >= trunc(sysdate - &pocet_dni)
order by end_time desc;   