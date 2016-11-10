SELECT   count(*)
    FROM dba_scheduler_running_jobs;

---

SELECT   owner, job_name, enabled, next_run_date, state
    FROM dba_scheduler_jobs
where state <> 'SCHEDULED'
ORDER BY owner, job_name;

---

SELECT   *
    FROM dba_scheduler_job_run_details
ORDER BY log_date DESC