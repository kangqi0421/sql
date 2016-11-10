kcsqldb.cen.csin.cz\kcsqldb db Kalendar
SQLCONSDB\SQLCONSDB

use Kalendar;

-- users
select
 *
--    ID, Employee_ID, first_Name, Name, Username, Active
  from Person
where
 Active > 0  -- pouze aktivní useri
 --AND Def_group = 75   -- DBA group Zelenho
 and Name like 'Srba'
 --and Username = 'sol60210'
;

-- skupiny
select g.Group_ID, g.Group_Name from Groups g
 where Group_Name like '410 Database Services';

-- typy udalosti v Kalendari - Reasons
select Reason_ID, description from Reasons
  where Description like 'Volno zdravotní'
  --270 - Rezervace náhradního volna
;

-- udalosti v kalendari
SELECT
     pa.Event_ID, p.Name, r.Description, Start_Time, End_time
     -- year(Start_Time), COUNT(*)
FROM Person_Available pa
    INNER JOIN Person p ON pa.Employee_ID = p.Employee_ID
    INNER JOIN Reasons r ON r.Reason_ID = pa.Reason_ID
WHERE p.Name = 'Srba'
  --AND r.Description = 'Volno zdravotní'
  AND r.Description = 'Rezervace náhradního volna'
  --and End_Time > GETDATE()  -- pouze aktualni udalosti
  AND End_Time > DATEADD(MONTH, -2, GETDATE())  -- posledni 2 mesice
--GROUP BY year(Start_Time)
ORDER BY start_time;

delete from Person_Available where Event_ID = 1058982;

commit;

-- Holiday - kolik mám pro letošek nárok
select * from HolidayBalance
--  where Employee_ID = '28822'
where Employee_ID = '28822'
  and ClaimOnYear = '2015';

-- Dovolená
SELECT
    -- DATEDIFF(day,Start_Time,End_Time)
    Start_Time, End_time,
    p.Name, r.Description
	 --,pa.Event_ID
FROM Person_Available pa
    INNER JOIN Person p ON pa.Employee_ID = p.Employee_ID
    INNER JOIN Reasons r ON r.Reason_ID = pa.Reason_ID
WHERE p.Name = 'Srba'
  AND r.Description = 'Dovolená celodenní'
  and End_Time > GETDATE()  -- pouze aktualni udalosti
ORDER BY Start_Time;

-- Dovolená this year-- Dovolena
-- pozor, pocita vcetne vikendu ;-(
SELECT
   Start_Time, End_time,
   DATEDIFF(day,Start_Time,End_Time)
FROM Person_Available pa
    INNER JOIN Person p ON pa.Employee_ID = p.Employee_ID
    INNER JOIN Reasons r ON r.Reason_ID = pa.Reason_ID
WHERE p.Name = 'Srba'
  AND r.Description = 'Dovolená celodenní'
--  and End_Time > DATEADD(MONTH, -3, GETDATE())
--  and Start_Time > DATEADD(yy,-1,DATEADD(dd, DATEDIFF(dd, 0, GETDATE()),0))
  and year(Start_Time) = '2015'
--GROUP BY DATEDIFF(day,Start_Time,End_Time)
;

select DATEPART(YEAR,GETDATE());

-- aktuální událost v KRP pro Srba
SELECT Start_Time, End_time,
     p.Name, r.Description
	 --,pa.Event_ID
FROM Person_Available pa
    INNER JOIN Person p ON pa.Employee_ID = p.Employee_ID
    INNER JOIN Reasons r ON r.Reason_ID = pa.Reason_ID
WHERE p.Name = 'Srba'
  --AND r.Description = 'Dovolená celodenní'
  and End_Time > GETDATE()  -- pouze aktualni udalosti
ORDER BY 1 desc;

-- update +1 hour po posunu na zimni cas - event Pohotovost SM DB
UPDATE Person_Available
SET Start_Time = dateadd(hour, 1, Start_Time),
    end_time = dateadd(hour, 1,end_time)
WHERE Event_id IN
    (SELECT pa.Event_ID
     FROM Person_Available pa
         INNER JOIN Person p ON pa.Employee_ID = p.Employee_ID
     WHERE Reason_ID = 422 -- Pohotovost SM DB
       AND End_Time > GETDATE() -- pouze aktualni
       AND DATEPART(hh,Start_Time) = 5 -- pouze posunute o hodinu
     )
;

-- dohledani rezervace nahr. volna
SELECT DATEDIFF(HOUR,Start_Time,End_Time),* FROM dbo.Person_Available pa WHERE pa.Employee_ID = '28822' AND Reason_ID IN (270)

