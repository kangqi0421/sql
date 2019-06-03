--// nastaven� utilizace Open Cursors do OEM //--
SELECT
    ROUND (b.curr / a.MAX * 100) "Open Cursors util [%]"
  FROM -- max. pocet kurzoru z open_cursors
      (SELECT a.CURRENT_UTILIZATION * b.VALUE AS MAX
         FROM v$resource_limit a, v$parameter b
        WHERE b.name LIKE 'open_cursors' AND a.resource_name = 'sessions') a,
       -- aktualni pocet otevrenych
       (SELECT SUM (VALUE) AS curr
          FROM v$sesstat NATURAL JOIN v$statname
         WHERE name = 'opened cursors current') b;

-- max open_cursors
-- ORA-01000: maximum open cursors exceeded
select
      max(a.value) as highest_open_cur,
      p.value as max_open_cur
  from v$sesstat a, v$statname b, v$parameter p
 where a.statistic# = b.statistic#
  and b.name = 'opened cursors current'
  and p.name= 'open_cursors'
 group by p.value
;

select * from v$statname where name = 'opened cursors current';

SELECT COUNT(*), address
  FROM v$open_cursor
 WHERE sid = 135
  GROUP BY address HAVING COUNT(address) > 1 ORDER BY COUNT(*);

-- v$open_cursor
SELECT sid, user_name, count(*)
   from v$open_cursor
  where user_name like 'ADSREPDA_M'
 group by sid, user_name
order by 3 desc;

-- session cursor cache %
select cache/tot*100 "Session cursor cache%"
   from
 (select value tot from v$sysstat where name='parse count (total)'),
 ( select value cache from sys.v_$sysstat where name = 'session cursor cache hits' );

--
SELECT 'session_cached_cursors' parameter, LPAD(value, 5) value,
DECODE(value, 0, ' n/a', to_char(100 * used / value, '990') || '%' ) usage
FROM ( SELECT MAX(s.value) used
FROM v$statname n, v$sesstat s
WHERE n.name = 'session cursor cache count' and
  s.statistic# = n.statistic# ),
(SELECT value FROM v$parameter WHERE name = 'session_cached_cursors' )
UNION ALL
SELECT 'open_cursors', LPAD(value, 5), to_char(100 * used / value, '990') || '%'
FROM (SELECT MAX(sum(s.value)) used
FROM v$statname n, v$sesstat s
WHERE n.name in ('opened cursors current', 'session cursor cache count')
  and s.statistic#=n.statistic#
GROUP BY s.sid
),
(SELECT value FROM v$parameter WHERE name = 'open_cursors' ) ;

-- v$sesstat 'opened cursors current'
SELECT ses.sid,
         sn.name,
         ses.value
    FROM    v$sesstat ses
         INNER JOIN
            v$statname sn
         ON sn.statistic# = ses.statistic#
   WHERE sn.name = LOWER ('opened cursors current')
         --AND VALUE > 800
ORDER BY VALUE DESC;


--// top 10 sql id with the most value of opened cursors //--
SELECT sql_id,
         COUNT (*),
         ROW_NUMBER () OVER (ORDER BY COUNT (*) DESC) rn
    FROM gv$open_cursor
  GROUP BY sql_id
 fetch first 10 rows only;


select * from v$session where username = 'ADSREPDA_M';
select * from v$sql where sql_id = '33vmcj1yp1hj7';
