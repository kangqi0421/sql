set verify off

--select spare4 from sys.user$ where name = 'SYSTEM';

-- nutno rozdelit na 3 casti z duvodu debilniho omezeni sqlplus na max. 240 char
define hash_p1="S:F180269F9E13360A4F71FB402FD371F8B14C5A42F3D719E84504AAF1A849;H:C574DBC7851ECAA12ED624B793C3333A;"
define hash_p3="T:579E80ED90C7607D3739790A6AA838D87EA8B20A837DE17F0AC095AB4ABBCC2FE1B8C0314DBCE8592C5CD4D824C6C4B584EB35F1FF95E71A8066054851DD00A4E227C76AFA535BD4EF115E3CBA5501E3"


alter user system identified by values '&hash_p1.&hash_p3' account unlock;
alter user sys identified by values '&hash_p1.&hash_p3' account unlock;
alter user dbsnmp identified by values '&hash_p1.&hash_p3' account unlock;