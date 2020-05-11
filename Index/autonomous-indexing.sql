--
-- Autonomous Indexing 19c
--
https://static.rainfocus.com/oracle/oow18/sess/1523250557343001OBEw/PF/TRN3980_Test_Drive_Auto_Index_Creation_in_ADB_1541192406753001UYd0.pdf

alter system set "_exadata_feature_on" = true scope=spfile;
  alter system set "_exadata_feature_on" = false scope=spfile;


begin
  dbms_auto_index.configure ('AUTO_INDEX_MODE', 'IMPLEMENT');
  -- dbms_auto_index.configure ('AUTO_INDEX_MODE','REPORT ONLY');
end;
/

DBMS_AUTO_INDEX.CONFIGURE(‘AUTO_INDEX_REPORT_RETENTION’, ‘60’);

DBMS_AUTO_INDEX.CONFIGURE ('AUTO_INDEX_RETENTION_FOR_AUTO', '100')

-- OFF
EXEC DBMS_AUTO_INDEX.CONFIGURE('AUTO_INDEX_MODE','OFF');



-- report

SET LONG 1000000 PAGESIZE 0


-- Default TEXT report for the last 24 hours.
SELECT DBMS_AUTO_INDEX.report_activity() FROM dual;

-- Default TEXT report for the latest activity.
SELECT DBMS_AUTO_INDEX.report_last_activity() FROM dual;

-- HTML Report for the day before yesterday.
SELECT DBMS_AUTO_INDEX.report_activity(
         activity_start => SYSTIMESTAMP-2,
         activity_end   => SYSTIMESTAMP-1,
         type           => 'HTML')
FROM   dual;


declare
  report clob := null;
begin
  report := DBMS_AUTO_INDEX.REPORT_ACTIVITY (
              --activity_start => DATE'2019-06-24',
              --activity_end   => DATE'2019-06-26',
              type           => 'TEXT',
              section        => 'SUMMARY',
              level          => 'BASIC');
end;
/


-- analyza
select * from DBA_INDEXES
  where auto = 'YES';

select
    owner, index_name, table_name,
    VISIBILITY, STATUS
  from dba_indexes
 where index_name like 'SYS_AI%';

select *
  from dba_advisor_tasks
where owner='SYS'
  and task_name like '%AI%'
order by task_id;
