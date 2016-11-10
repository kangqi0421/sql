SELECT * FROM v$sql_cs_histogram WHERE sql_id = '&sqlid';

SELECT * FROM v$sql_cs_statistics WHERE sql_id = '&sqlid';

SELECT * FROM v$sql_cs_selectivity WHERE sql_id = '&sqlid';

-- disable ACS
_optimizer_extended_cursor_sharing = none