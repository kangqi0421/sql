--IMPORT_SCHEMA

drop table SYSTEM.IMPORT_SCHEMA;

create table SYSTEM.IMPORT_SCHEMA(
    username            VARCHAR2(128) PRIMARY KEY,
    imported            char(1),
    indexed             char(1),
    size_gb             int
    );

SELECT 'insert into IMPORT_SCHEMA (username) values ('
      || DBMS_ASSERT.enquote_literal(USERNAME)
      || ');'
  FROM dba_users@EXPORT_IMPDP
 WHERE ORACLE_MAINTAINED = 'N'
  and username not in ('ARM_CLIENT','ARM_CLSYS', 'ZELA', 'XDB', 'WMSYS',
    'OJVMSYS','CTXSYS', 'DBSNMP')
ORDER by 1
;

-- co ještě chybí doimportovat
select listagg(username, ',') WITHIN GROUP (order by username)
from (
  select username
  from dba_users@EXPORT_IMPDP
   WHERE ORACLE_MAINTAINED = 'N'
  and username not in ('ARM_CLIENT','ARM_CLSYS', 'ZELA', 'XDB', 'WMSYS',
    'OJVMSYS','CTXSYS', 'DBSNMP')
minus
select username
  from IMPORT_SCHEMA
)
;

insert into IMPORT_SCHEMA (username,size_gb) values ('COGNOSSPDWHDEV ', 0);
insert into IMPORT_SCHEMA (username,size_gb) values ('CHECK_OWNER', 0);
insert into IMPORT_SCHEMA (username,size_gb) values ('LOG_OWNER', 0);
insert into IMPORT_SCHEMA (username,size_gb) values ('UTL_OWNER', 0);
insert into IMPORT_SCHEMA (username,size_gb) values ('DWM_OWNER', 0);
insert into IMPORT_SCHEMA (username,size_gb) values ('DWH_RS_USER', 0);
insert into IMPORT_SCHEMA (username,size_gb) values ('DQ_OWNER ', 0);
insert into IMPORT_SCHEMA (username,size_gb) values ('RESTORE_PRE_LR2016 ', 0);
insert into IMPORT_SCHEMA (username,size_gb) values ('RUEXT_OWNER', 0);
insert into IMPORT_SCHEMA (username,size_gb) values ('CPT_USER ', 0);
insert into IMPORT_SCHEMA (username,size_gb) values ('REPCOGNOS', 0);
insert into IMPORT_SCHEMA (username,size_gb) values ('MSIIS_DON_WEB', 0);
insert into IMPORT_SCHEMA (username,size_gb) values ('PRODUCT_OWNER', 0);
insert into IMPORT_SCHEMA (username,size_gb) values ('DAMI_ETL_OWNER ', 0);
insert into IMPORT_SCHEMA (username,size_gb) values ('LOV_OWNER', 0);
insert into IMPORT_SCHEMA (username,size_gb) values ('OWBRT_SYS', 0);
insert into IMPORT_SCHEMA (username,size_gb) values ('DWH_DAMI_USER', 0);
insert into IMPORT_SCHEMA (username,size_gb) values ('REDIM_OWNER', 0);
insert into IMPORT_SCHEMA (username,size_gb) values ('DWH_MA_USER', 0);
insert into IMPORT_SCHEMA (username,size_gb) values ('PROCAL_OWNER ', 1);
insert into IMPORT_SCHEMA (username,size_gb) values ('PRICE_OWNER', 1);
insert into IMPORT_SCHEMA (username,size_gb) values ('ADR_OWNER', 1);
insert into IMPORT_SCHEMA (username,size_gb) values ('ADS_CORP_ETL_OWNER ', 1);
insert into IMPORT_SCHEMA (username,size_gb) values ('COGNOSDMADEV ', 2);
insert into IMPORT_SCHEMA (username,size_gb) values ('ODI_ADS_RETAIL_USER', 3);
insert into IMPORT_SCHEMA (username,size_gb) values ('EXT_OWNER', 3);
insert into IMPORT_SCHEMA (username,size_gb) values ('ALMDM_EXT_OWNER', 4);
insert into IMPORT_SCHEMA (username,size_gb) values ('RINT_OWNER ', 5);
insert into IMPORT_SCHEMA (username,size_gb) values ('RUIAN_OWNER', 6);
insert into IMPORT_SCHEMA (username,size_gb) values ('AUDIT_OWNER', 6);
insert into IMPORT_SCHEMA (username,size_gb) values ('ALMDM_OUT_OWNER', 7);
insert into IMPORT_SCHEMA (username,size_gb) values ('SPDWHDEV ', 8);
insert into IMPORT_SCHEMA (username,size_gb) values ('VDS_RETAIL_OWNER ', 8);
insert into IMPORT_SCHEMA (username,size_gb) values ('VDS_OWNER', 12);
insert into IMPORT_SCHEMA (username,size_gb) values ('ALMDM2_OWNER ', 15);
insert into IMPORT_SCHEMA (username,size_gb) values ('CRIBIS_OWNER ', 18);
insert into IMPORT_SCHEMA (username,size_gb) values ('ODI_LIC_USER ', 21);
insert into IMPORT_SCHEMA (username,size_gb) values ('FR_OWNER ', 24);
insert into IMPORT_SCHEMA (username,size_gb) values ('RUINT_OWNER', 28);
insert into IMPORT_SCHEMA (username,size_gb) values ('RR_OWNER ', 30);
insert into IMPORT_SCHEMA (username,size_gb) values ('DC_OWNER ', 39);
insert into IMPORT_SCHEMA (username,size_gb) values ('OWBSYS ', 58);
insert into IMPORT_SCHEMA (username,size_gb) values ('ADS_CORP_OWNER ', 64);
insert into IMPORT_SCHEMA (username,size_gb) values ('DWA_OWNER', 82);
insert into IMPORT_SCHEMA (username,size_gb) values ('OWF_MGR', 88);
insert into IMPORT_SCHEMA (username,size_gb) values ('ODI_ADS_USER ', 101);
insert into IMPORT_SCHEMA (username,size_gb) values ('ALMDM_INT_OWNER', 105);
insert into IMPORT_SCHEMA (username,size_gb) values ('TEMP_OWNER ', 185);
insert into IMPORT_SCHEMA (username,size_gb) values ('CESS_LISIFE_OWNER', 325);
insert into IMPORT_SCHEMA (username,size_gb) values ('CESS_FPV_OWNER ', 425);
insert into IMPORT_SCHEMA (username,size_gb) values ('ALMDM_OWNER', 447);
insert into IMPORT_SCHEMA (username,size_gb) values ('INT_OWNER', 544);
insert into IMPORT_SCHEMA (username,size_gb) values ('RUSA_OWNER ', 600);
insert into IMPORT_SCHEMA (username,size_gb) values ('RATING_OWNER ', 1097);
insert into IMPORT_SCHEMA (username,size_gb) values ('RUSB_OWNER ', 1204);
insert into IMPORT_SCHEMA (username,size_gb) values ('DMA_OWNER', 1347);
insert into IMPORT_SCHEMA (username,size_gb) values ('ETL_OWNER', 1347);
insert into IMPORT_SCHEMA (username,size_gb) values ('ADS_RETAIL_OWNER ', 1725);
insert into IMPORT_SCHEMA (username,size_gb) values ('LIC_OWNER', 1997);
insert into IMPORT_SCHEMA (username,size_gb) values ('DAMI_OWNER ', 2097);
insert into IMPORT_SCHEMA (username,size_gb) values ('ADS_OWNER', 2314);
insert into IMPORT_SCHEMA (username,size_gb) values ('OUT_OWNER', 3370);
insert into IMPORT_SCHEMA (username,size_gb) values ('DWH_OWNER', 15178);

