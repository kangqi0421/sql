 - statistika popadaných záloh

col ERROR for a70
col count(*) for 999

SELECT substr(trim(acknowledged_note), 1, 70) "ERROR", count(*)
    FROM BACKUP.LOG
   WHERE FINISH >
            (SELECT CASE (SELECT TO_CHAR (SYSDATE, 'D')
                            FROM DUAL)
                       WHEN '2'
                          THEN TRUNC (SYSDATE - 3)
                       ELSE TRUNC (SYSDATE - 1)
                    END
               FROM DUAL)
     AND status <> 'OK'
group by substr(trim(acknowledged_note), 1, 70)
order by 2 desc ;



--
$ crontab -l | grep -v ^# | grep -E "(MCIP|AMLP|SDSK0).*level 0"


--

--// incr level 0 ERROR //--

col DBNAME for a20
col STATUS for a6
col BACKUP for a15
col DBNAME for a8


select to_char(max_finish_OK, 'DD.MM.YY HH24:MI:SS') max_finish_OK,
a.dbname, a.backup, substr(trim(a.acknowledged_note), 1, 34)
from
(
SELECT   begin, finish, status, dbname, backup, note, acknowledged_note
    FROM BACKUP.LOG
   WHERE FINISH >
            (SELECT CASE (SELECT TO_CHAR (SYSDATE, 'D')
                            FROM DUAL)
                       WHEN '2'
                          THEN TRUNC (SYSDATE - 3)
                       ELSE TRUNC (SYSDATE - 1)
                    END
               FROM DUAL)
     AND status <> 'OK'
     --AND acknowledged_by is NULL
) a
,
(
SELECT   max(finish) max_finish_OK,dbname,backup
    FROM BACKUP.LOG
    where status = 'OK'
    group by dbname,backup
) b
where A.dbname=b.dbname and a.backup=b.backup
and max_finish_OK<finish
and a.backup = 'db_incr0'
ORDER BY FINISH DESC;
