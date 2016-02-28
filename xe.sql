prompt Display execution plan 
select * from table(dbms_xplan.display(null,null,'ALLSTATS LAST +PEEKED_BINDS +PARALLEL +PARTITION +COST +ALIAS'));
