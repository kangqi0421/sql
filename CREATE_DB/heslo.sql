set verify off

--
-- select spare4 from sys.user$ where name = 'SYSTEM';
--

-- nutno rozdelit na 3 casti z duvodu debilniho omezeni sqlplus na max. 240 char
define hash_p1="S:26A30A50E092F00E30C954B8BB78ACACCF88CA425321169A2AC270513737;"
define hash_p2="H:C529B4B6819FFEDA6A6677B305AAA1C7;"
define hash_p3="T:4D3E8B8508F33582091B49C31F3DC6A2804ACF868509E77ACF21A0D45340BFAB024728ED73F2FEC1127B91BC170EDB85D9630CDC48F321AA201A78E0F386CBFB7FD2C66AB20FF3C47C60909F96C7123D"


alter user system identified by values '&hash_p1.&hash_p2.&hash_p3' account unlock;
alter user sys identified by values '&hash_p1.&hash_p2.&hash_p3' account unlock;
alter user dbsnmp identified by values '&hash_p1.&hash_p2.&hash_p3' account unlock;

