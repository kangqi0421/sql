-- SMP0 poslední EOD
SELECT MIN(start_time),  MAX(end_time) FROM symbols.fm_process WHERE process_seq_no > 0;
  
-- KMP0 poslední EOD
select min(start_time),max(end_time) from kmdw.KM_process where sym_run_date = kmdw.km_get_run_date;


-- Symbols historie EOD
SELECT   a.run_date, a.start_date, b.end_date,
         round((b.end_date - a.start_date) * 24 * 60, 0) "mins"
    FROM (SELECT run_date, start_date
            FROM symbols.fm_split_process_hist
           WHERE process_seq_no = 1 AND system_phase = 'EOD') a,
         (SELECT run_date, end_date
            FROM symbols.fm_split_process_hist
           WHERE process_seq_no = 2005 AND system_phase = 'EOD') b
   WHERE a.run_date = b.run_date - 1
   		 and a.run_date > trunc(sysdate - 14)
ORDER BY run_date DESC;