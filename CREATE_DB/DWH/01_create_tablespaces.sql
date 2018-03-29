--
-- create tablespaces
--

-- import DWH_OWNER
create tablespace MSG_DATA datafile size 512m autoextend on next 512m maxsize 32767M;
create tablespace ODS_ACC_BAL_INDX_2M datafile size 512m autoextend on next 512m maxsize 32767M;
create tablespace ODS_ACC_DATA2_7M datafile size 512m autoextend on next 512m maxsize 32767M;
create tablespace ODS_ACC_DATA_2M datafile size 512m autoextend on next 512m maxsize 32767M;
create tablespace ODS_ACC_INDX_1M datafile size 512m autoextend on next 512m maxsize 32767M;
create tablespace ODS_ACC_INDX_32K datafile size 512m autoextend on next 512m maxsize 32767M;
create tablespace ODS_ACC_INDX_5M datafile size 512m autoextend on next 512m maxsize 32767M;
create tablespace ODS_ACC_TRAN_DATA_3M datafile size 512m autoextend on next 512m maxsize 32767M;
create tablespace ODS_ACC_TRAN_INDX_1M datafile size 512m autoextend on next 512m maxsize 32767M;
create tablespace ODS_CARD_TRAN_DATA_3M datafile size 512m autoextend on next 512m maxsize 32767M;
create tablespace ODS_CARD_TRAN_INDX_1M datafile size 512m autoextend on next 512m maxsize 32767M;
create tablespace ODS_INDX_1M datafile size 512m autoextend on next 512m maxsize 32767M;
create tablespace ODS_PARTY_CRW_INDX_5M datafile size 512m autoextend on next 512m maxsize 32767M;
create tablespace ODS_PARTY_DATA_7M datafile size 512m autoextend on next 512m maxsize 32767M;
create tablespace ODS_PARTY_HIST_DATA_256K datafile size 512m autoextend on next 512m maxsize 32767M;
create tablespace ODS_PARTY_INST_DATA_3M datafile size 512m autoextend on next 512m maxsize 32767M;
create tablespace ODS_PARTY_INST_INDX_128K datafile size 512m autoextend on next 512m maxsize 32767M;
create tablespace OUT_INDX datafile size 512m autoextend on next 512m maxsize 32767M;
create tablespace OWB_RUNTIME_INDX datafile size 512m autoextend on next 512m maxsize 32767M;
create tablespace STAGE_DATA_128K datafile size 512m autoextend on next 512m maxsize 32767M;
create tablespace STAGE_DATA_3M datafile size 512m autoextend on next 512m maxsize 32767M;
create tablespace STAGE_DATA_5M datafile size 512m autoextend on next 512m maxsize 32767M;
create tablespace STAGE_DATA_OLD datafile size 512m autoextend on next 512m maxsize 32767M;
create tablespace STAGE_INDX_128K datafile size 512m autoextend on next 512m maxsize 32767M;
create tablespace STAGE_INDX_1M datafile size 512m autoextend on next 512m maxsize 32767M;
create tablespace STAGE_INDX_5M datafile size 512m autoextend on next 512m maxsize 32767M;
