/* dropni pouze prazdne tablespace ze seznamu */

set serveroutput on

DECLARE
  cntExtents number;
BEGIN
   FOR c IN (select name from v$tablespace where name in (
('DWH_ACC_BAL_DATA_2M_201301','DWH_ACC_BAL_INDX_1M_201301')
	         )
   LOOP
      select count(*) into cntExtents from dba_segments where tablespace_name = c.name;
      IF cntExtents = 0 
        then
          execute immediate 'drop tablespace '||c.name;
      ELSE
         dbms_output.put_line('tablespace '||c.name||' nelze dropnout, obsahuje '||cntExtents||' segmentù');
      END IF;
   END LOOP;
END;
/

select count(*) from v$tablespace where name in (
'DWH_REPAYF_DATA_5M_201108',
'DWH_REPAYF_DATA_5M_201109',
'DWH_REPAYF_DATA_5M_201110',
'DWH_REPAYF_DATA_5M_201111',
'DWH_REPAYF_DATA_5M_201112',
'DWH_REPAYF_INDX_3M_201108',
'DWH_REPAYF_INDX_3M_201109',
'DWH_REPAYF_INDX_3M_201110',
'DWH_REPAYF_INDX_3M_201111',
'DWH_REPAYF_INDX_3M_201112',
'DMA_FACT_DATAC_201106',
'DMA_FACT_INDXC_201106'
	)
/