/* Nezapomenout zmenit datum !!! */

DECLARE
   jobno number;
BEGIN
   DBMS_JOB.SUBMIT(
      job => jobno,
      what => 'delete from dipl@twinsen.natur.cuni.cz;
insert into DIPL@twinsen.natur.cuni.cz( DID, DSKR, DFAK, DTYP, DIDENT, DOBOR, DUSTAV, DNAZEV1, DNAZEV2, DNAZEV3, DVEDOUCI, DOPONENT, DDVYPSANO, DDZADANO,  DDOBHAJOBA, DDUSPECH, DKDO, DDT, DOPONENT2, DOPONENT3, DOPONENT4
) select  DID, DSKR, DFAK, DTYP, DIDENT, DOBOR, DUSTAV, DNAZEV1,
 DNAZEV2, DNAZEV3, DVEDOUCI, DOPONENT, DDVYPSANO, DDZADANO,
 DDOBHAJOBA, DDUSPECH, DKDO, DDT, DOPONENT2, DOPONENT3, DOPONENT4
from DIPL;
commit;
',
      next_date => TO_DATE('10.1.02 06:05', 'dd.mm.yy hh:mi'),
      interval => '/*1 Day*/ sysdate + 1');
END;
/ 

DECLARE
   jobno number;
BEGIN
   DBMS_JOB.SUBMIT(
      job => jobno,
      what => 'update stud set soscislo = sprukaz@twinsen.natur.cuni.cz;
delete from stud@twinsen.natur.cuni.cz;
insert into stud@twinsen.natur.cuni.cz("SIDENT", "SPRUKAZ", "SJMENO", "SPRIJMENI", "SRODC", "SROC", "SOBOR", "SSTUPR", "SFAK", "SDRUH", "SFST", "SSTAV", "SUCIT", "SUCIT2")
select sident, soscislo, sjmeno, sprijmeni, srodc, sroc, sobor, sstupr,
sfak, sdruh, sfst, sstav, sucit, sucit2
from stud
where (((((SSTAV) = (''S'')) OR ((SSTAV) = (''O''))) OR ((SSTAV) = (''D''))) OR ((SSTAV) = 
(''R''))) OR ((SSTAV) = (''U''));
commit;
',
      next_date => TO_DATE('26.1.02 06:10', 'dd.mm.yy hh:mi'),
      interval => '/*1 Day*/ sysdate + 1');
END;
/ 

DECLARE
   jobno number;
BEGIN
   DBMS_JOB.SUBMIT(
      job => jobno,
      what => 'delete from zkous@twinsen.natur.cuni.cz;
insert into zkous@twinsen.natur.cuni.cz(ZIDENT, ZSKR, ZSEM, ZMARX, ZPOVINN, ZCISPR, ZROC, ZTYP, ZVYSL, ZPOKUS, ZDATUM, ZSPLSEM, ZSPLCELK, ZBODY, ZBODYCELK, ZSIGNR, ZSIGN, ZDZAPIS, ZPLATNOST, ZNSEM, ZVJ1, ZVJ2, ZKDO, ZDT) select ZIDENT, ZSKR, ZSEM, ZMARX, ZPOVINN, ZCISPR, ZROC, ZTYP, ZVYSL, ZPOKUS, ZDATUM, ZSPLSEM, ZSPLCELK, ZBODY, ZBODYCELK, ZSIGNR, ZSIGN, ZDZAPIS, ZPLATNOST, ZNSEM, ZVJ1, ZVJ2, ZKDO, ZDT from ZKOUS;
commit;',
      next_date => TO_DATE('10.1.02 06:15', 'dd.mm.yy hh:mi'),
      interval => '/*1 Day*/ sysdate + 1');
END;
/ 


/* prenasi dat na vysledky prijimaciho rizeni */
DECLARE
   jobno number;
BEGIN
   DBMS_JOB.SUBMIT(
      job => jobno,
      what => 'delete from nucha@twinsen.natur.cuni.cz;
insert into nucha@twinsen.natur.cuni.cz(uident, urodc, ujmeno, uprijmeni, uobor, uzk, uvpr) select uident, urodc, ujmeno, uprijmeni, uobor, uzk, uvpr from NUCHA;
commit;',
      next_date => TO_DATE('10.1.02 06:15', 'dd.mm.yy hh:mi'),
      interval => '/*1 Day*/ sysdate + 1');
END;
/ 
