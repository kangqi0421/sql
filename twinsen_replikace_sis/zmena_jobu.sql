BEGIN DBMS_JOB.CHANGE(job => 1354, next_date => to_date(
    '21.02.02 06:05', 'DD.MM.YY HH:MI'), interval => NULL, what => NULL);
END;
/