prompt eXplain the execution plan for sqlid &1 child &2


--select * from table(dbms_xplan.display_cursor('&1', NULL, 'BASIC +NOTE'));
--select * from table(dbms_xplan.display_cursor('&1', NULL, 'BASIC +NOTE +OUTLINE'));
--select * from table(dbms_xplan.display_cursor('&1',NULL,'LAST +PEEKED_BINDS +PARTITION +OUTLINE'));
--select * from table(dbms_xplan.display_cursor('&1','&2','LAST +PEEKED_BINDS +PARTITION +OUTLINE'));
select * from table(dbms_xplan.display_cursor('&1', NULL, 'ALLSTATS LAST +PEEKED_BINDS +OUTLINE +ADAPTIVE'));