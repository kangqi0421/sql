set serveroutput on

DECLARE
  t_start   TIMESTAMP;
  t_end     TIMESTAMP;
BEGIN
  t_start := SYSTIMESTAMP;
  DBMS_STATS.gather_table_stats(ownname          => 'ASCBL',
                                tabname          => 'LOG_ACTIONS',
                                granularity      => 'PARTITION',
                                partname         => 'D20100406',
                                DEGREE           => DBMS_STATS.auto_degree,
                                estimate_percent => DBMS_STATS.auto_sample_size,
                                no_invalidate    => FALSE,
                                CASCADE          => DBMS_STATS.auto_cascade);
  t_end := SYSTIMESTAMP;
  DBMS_OUTPUT.put_line(t_end - t_start);
END;
/

select * from v$pq_sesstat;