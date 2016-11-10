formát dat:
===========

15:06:57, disk13_lunpath18, 42.48, 0.50, 93, 0, 1494, 0.00, 5.92
15:06:57, disk13_lunpath22, 43.74, 0.50, 93, 0, 1497, 0.00, 6.24
15:06:57, disk13_lunpath24, 43.34, 0.50, 93, 0, 1491, 0.00, 6.07
15:06:57, disk13_lunpath26, 43.08, 0.50, 93, 0, 1497, 0.00, 5.96

---
create or replace directory SAR as '/home/oracle';

drop table sar_test_1;

CREATE TABLE sar_test_1
(
   datum     date,
   lunpath   CHAR (17),
   busy      NUMBER,
   avque     NUMBER,
   rs        NUMBER,
   ws        NUMBER,
   blks      NUMBER,
   avwait    NUMBER,
   avserv    NUMBER
)
ORGANIZATION EXTERNAL
   (TYPE oracle_loader
         DEFAULT DIRECTORY SAR ACCESS PARAMETERS  (
        RECORDS DELIMITED BY NEWLINE
        BADFILE SAR:'sar.bad'
        LOGFILE SAR:'sar.log'
        FIELDS TERMINATED BY ','
        (datum date 'hh24:mi:ss', lunpath, busy, avque, rs, ws, blks, avwait, avserv
        )
    )
         LOCATION ('test1_1_res_ok.txt',
                   'test2_1_res_ok.txt',
                   'test3_1_res_ok.txt'))
/


-- pøeklopení do HEAP tabulky SAR
create table sar as select * from sar_test_1;


SELECT TO_CHAR (a.datum, 'hh24:mi:ss'),
         a.busy disk13_lunpath18,
         b.busy disk13_lunpath22,
         c.busy disk13_lunpath24,
         d.busy disk13_lunpath26,
         e.busy disk24_lunpath31,
         f.busy disk24_lunpath34,
         g.busy disk24_lunpath37,
         h.busy disk24_lunpath40,
         ch.busy disk25_lunpath32,
         i.busy disk25_lunpath35,
         j.busy disk25_lunpath38,
         k.busy disk25_lunpath41,
         l.busy disk26_lunpath33,
         m.busy disk26_lunpath36,
         n.busy disk26_lunpath39,
         o.busy disk26_lunpath42
    FROM sar a,
         sar b,
         sar c,
         sar d,
         sar e,
         sar f,
         sar g,
         sar h,
         sar ch,
         sar i,
         sar j,
         sar k,
         sar l,
         sar m,
         sar n,
         sar o
   WHERE     a.lunpath = 'disk13_lunpath18'
         AND b.lunpath = 'disk13_lunpath22'
         AND c.lunpath = 'disk13_lunpath24'
         AND d.lunpath = 'disk13_lunpath26'
         AND e.lunpath = 'disk24_lunpath31'
         AND f.lunpath = 'disk24_lunpath34'
         AND g.lunpath = 'disk24_lunpath37'
         AND h.lunpath = 'disk24_lunpath40'
         AND ch.lunpath = 'disk25_lunpath32'
         AND i.lunpath = 'disk25_lunpath35'
         AND j.lunpath = 'disk25_lunpath38'
         AND k.lunpath = 'disk25_lunpath41'
         AND l.lunpath = 'disk26_lunpath33'
         AND m.lunpath = 'disk26_lunpath36'
         AND n.lunpath = 'disk26_lunpath39'
         AND o.lunpath = 'disk26_lunpath42'
         AND A.DATUM = b.datum
         AND b.datum = c.datum
         AND c.datum = d.datum
         AND d.datum = e.datum
         AND e.datum = f.datum
         AND f.datum = g.datum
         AND g.datum = h.datum
         AND h.datum = ch.datum
         AND ch.datum = i.datum
         AND i.datum = j.datum
         AND j.datum = k.datum
         AND k.datum = l.datum
         AND l.datum = m.datum
         AND m.datum = n.datum
         AND n.datum = o.datum
ORDER BY 1;


-- left join --
SELECT a.datum, a.busy, b.busy
    FROM    sar a
         LEFT JOIN
            sar b
         ON     a.datum = b.datum
            AND a.lunpath = 'disk13_lunpath24'                --tahle existuje
            AND b.lunpath = 'disk13_lunpath18'                -- tahle nikoliv
ORDER BY 1 DESC