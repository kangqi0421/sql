--
-- SYSTEM SYS DBSNMP
-- zmena hesel pres hash values
--

--
-- set lines 32767 trims on
-- col spare4 for a9999999
-- select spare4 from sys.user$ where name = 'SYSTEM';
--

set verify off

-- nutno rozdelit na 3 casti z duvodu debilniho omezeni sqlplus na max. 240 char
define hash_p1="S:584985443CAE85DA4C50B8539ADEC1102DC1E3FC5ECE387CC8DF30293BE2;"
define hash_p2="H:C529B4B6819FFEDA6A6677B305AAA1C7;"
define hash_p3="T:ACA046ABE76B49BDD2ABDDFDAA50E2264B305397BB332B112299444095F528D381297EFAECFFCF99FE5B14B0C48A3BE4B98DF51B8DF1CCDB03C8E6D1A5ED6B4C32C5174D0F601410DDEEDE1CA4EDA143"


alter user SYSTEM identified by values '&hash_p1.&hash_p2.&hash_p3' account unlock;
alter user SYS identified by values '&hash_p1.&hash_p2.&hash_p3' account unlock;
alter user DBSNMP identified by values '&hash_p1.&hash_p2.&hash_p3' account unlock;
