--
--

Statistics Space Used by SM/OPTSTAT in the SYSAUX Tablespace is not Reclaimed After Purging (Doc ID 454678.1)


-- retention
select DBMS_STATS.GET_STATS_HISTORY_RETENTION from dual;


execute DBMS_STATS.ALTER_STATS_HISTORY_RETENTION (3);

select dbms_stats.get_stats_history_availability from dual;


How do I restore the statistics?
Having decided what date you know the statistics were good for, you can use:-


execute DBMS_STATS.RESTORE_TABLE_STATS ('owner','table',date)
execute DBMS_STATS.RESTORE_DATABASE_STATS(date)
execute DBMS_STATS.RESTORE_DICTIONARY_STATS(date)
execute DBMS_STATS.RESTORE_FIXED_OBJECTS_STATS(date)
execute DBMS_STATS.RESTORE_SCHEMA_STATS('owner',date)
execute DBMS_STATS.RESTORE_SYSTEM_STATS(date)