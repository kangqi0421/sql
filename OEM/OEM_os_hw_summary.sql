
--// seznam všech serverù pro platformy Windows/HP UX/AIX, cpu count, mem, domain //--
  SELECT
         a.target_name "hostname",
         b.domain "domain",
         'Backup',  -- Production/Pre-production/Backup/Test/Development
         DECODE (substr(b.domain,1,INSTR (b.domain, '.')-1),  'cc', 'Wien-???', 'Prague-???') "DC",
         null,
         B.CPU_COUNT "CPUS",
         b.mem "MEMORY",
         null,null,null,null,null,null,null,null,null,null,
         'YES', --HASDR YES/null
         a.category_prop_1 "platform",
         null
    FROM SYSMAN.MGMT_TARGETS a inner join SYSMAN.mgmt$os_hw_summary b on (A.TARGET_GUID = b.target_guid)
   WHERE     a.target_type = 'host'
        and A.TARGET_NAME like '%arcdb%'
         --AND a.category_prop_1 = 'Windows'
ORDER BY target_name
/

--// seznam všech databází --//

SELECT a.target_name, b.category_prop_1, cpu_count
  FROM    (SELECT target_name, host_name
             FROM mgmt_targets
            WHERE target_type IN ('oracle_database')) a
       LEFT JOIN
          (SELECT a.host_name, cpu_count, category_prop_1
             FROM    mgmt$os_hw_summary a
                  INNER JOIN
                     mgmt_targets b
                  ON a.host_name = b.host_name AND B.target_TYPE = 'host') b
       ON a.host_name = b.host_name
order by 1
/



--// vypis vsech hostname bez suffixu mgmt. rozhranni -m //--
SELECT DISTINCT
       (RTRIM (SUBSTR (b.host_name, 1, INSTR (b.host_name, '.') - 1), '-m'))
          AS hostname
  FROM SYSMAN.MGMT_TARGETS b
 WHERE b.target_type = 'oracle_database'
ORDER BY 1


-- rozdily MGMT_TARGETS a CONS.HW
SELECT DISTINCT
       (RTRIM (SUBSTR (b.host_name, 1, INSTR (b.host_name, '.') - 1), '-m'))
          AS hostname
  FROM SYSMAN.MGMT_TARGETS b
 WHERE b.target_type = 'oracle_database'
minus
SELECT SUBSTR (a.hostname, 1, INSTR (a.hostname, '.') - 1)
  FROM CONS.HW a
 WHERE status IN ('Production', 'Backup', 'Pre-production')
order by 1

