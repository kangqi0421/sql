--
-- SYSTEM SYS DBSNMP
-- zmena hesel pres hash values
--

set verify off

--
-- select spare4 from sys.user$ where name = 'SYSTEM';
--

-- nutno rozdelit na 3 casti z duvodu debilniho omezeni sqlplus na max. 240 char
define hash_p1="S:604641389BECDA06B3B70C4E38B04EF393715AA4A832789D29D6A6254A65;"
define hash_p2="H:7E7C644EA22ECBECCD45FAD68C997E0B;"
define hash_p3="T:16FDA9C623D03D543B62EA5D0FC8BC6B6BD72BA7399922F375C26FCCAA0ECF00AFDD605813F806CA1F66D120B139AB002B90250BC41B68778EF28C3503B2DCB13AD297356B4E16E6C5DD5ADC9ADFB825"

alter user SYSTEM identified by values '&hash_p1.&hash_p2.&hash_p3' account unlock;
alter user SYS identified by values '&hash_p1.&hash_p2.&hash_p3' account unlock;
alter user DBSNMP identified by values '&hash_p1.&hash_p2.&hash_p3' account unlock;
