-- max CPU
select max(cpu_count) from DBA_CPU_USAGE_STATISTICS
  order by timestamp;