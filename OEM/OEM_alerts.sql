--
-- 12g 
--
col target for a18
col type for a28
col creation_date for date heading "Open Since"
--col ACKNOWLEDGED_BY for a15
col message for a51
set lines 150 pages 2000
set feed off

select decode(i.severity, 0, 'Clear', 4, 'Advisory', 8, 'Warning', 16, 'Critical', 32, 'Fatal') state,
       DECODE(instr(t.target_name,'.',1),0,t.target_name,SUBSTR(t.target_name,1,instr(t.target_name,'.',1)-1)) target,
       t.type_display_name "type",
--       i.issue_type,
--       i.creation_date,
       CAST((FROM_TZ(CAST(i.creation_date AS TIMESTAMP),'GMT') AT TIME ZONE 'EUROPE/PRAGUE') AS DATE) ,  -- convert date to LOCAL timezone
--       i.owner,
       SUBSTR(msg.summary_msg,1,51) MESSAGE
 from              sysman.em_issues_internal i
        INNER JOIN sysman.em_issues_msg msg ON (i.issue_id = msg.issue_id)
        INNER JOIN sysman.mgmt$target t ON (i.target_guid  = t.TARGET_GUID)
where
   severity > 4
   and i.open_status > 0
   and is_ack = 0
   and is_suppressed = 0
   -- vyhod vsechny incidety k jiz acknowledged problemum
   -- zatím plně neotestováno
   AND i.issue_id not in (SELECT i.issue_id FROM sysman.em_issues_internal p WHERE i.related_problem_id = p.issue_id
                            AND p.OPEN_STATUS > 0 AND p.is_ack > 0)
   AND t.target_guid IN (SELECT member_target_GUID  FROM mgmt$target_flat_members  WHERE aggregate_target_name='PRODUKCE')
order by state, last_updated_date desc;


--
-- 10g OEM
--
/*
SELECT a.alert_state state,
  DECODE(instr(a.target_name,'.',1),0,a.target_name,SUBSTR(a.target_name,1,instr(a.target_name,'.',1)-1)) target,
  a.type_display_name TYPE,
  a.collection_timestamp,
  SUBSTR(a.MESSAGE,1,51) MESSAGE
FROM sysman.mgmt$alert_current a,
  sysman.mgmt$target b,
  sysman.MGMT_VIOLATIONS c
WHERE a.target_guid = b.target_guid
AND A.VIOLATION_GUID=c.VIOLATION_GUID
  --     AND a.violation_type IN ('Resource', 'Threshold Violation')
AND a.alert_state     IN ('Critical', 'Warning')
AND c.ACKNOWLEDGED_BY IS NULL
  --     AND a.target_guid in (select member_target_GUID from mgmt$target_flat_members where aggregate_target_name='PRODUKCE')
ORDER BY target;
*/
