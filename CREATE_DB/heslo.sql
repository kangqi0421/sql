--
-- SYSTEM SYS DBSNMP
-- zmena hesel pres hash values
--

set verify off

--
-- select spare4 from sys.user$ where name = 'SYSTEM';
--

-- nutno rozdelit na 3 casti z duvodu debilniho omezeni sqlplus na max. 240 char
define hash_p1="S:B87EE8A2CEB7EDE455B9161072BD368BA180F64DB271CF0D3703B58A834D;"
define hash_p2="H:647419ADE1FCDEF82F3D09DCE32FA814;"
define hash_p3="T:66907002F9D2F1F4D13E9C79AA7FC9353793B0B92FF3EB8F4F2E0F82BF8DBE3A0259A63EAE498AEC280AE460797DE5AAEC5C35F3E4C1AC314BBE78D922ED20CC47DC886E5C9A9F2BB9E2A5F1AFCC85CA"

alter user SYSTEM identified by values '&hash_p1.&hash_p2.&hash_p3' account unlock;
alter user SYS identified by values '&hash_p1.&hash_p2.&hash_p3' account unlock;
alter user DBSNMP identified by values '&hash_p1.&hash_p2.&hash_p3' account unlock;
