/* Formatted on 2005/02/09 11:17 (Formatter Plus v4.8.0) */
DROP TABLE sa_init_parameters
/

CREATE TABLE sa_init_parameters (
      NAME VARCHAR(64),
      value_sym VARCHAR(512),
      value_km VARCHAR(512)
      )
      ORGANIZATION EXTERNAL (
        TYPE      oracle_loader
         DEFAULT DIRECTORY srba_dir
  ACCESS PARAMETERS (
   RECORDS DELIMITED BY NEWLINE
   BADFILE 'ext_table.bad'
   LOGFILE 'ext_table.log'
   SKIP 1
   FIELDS TERMINATED BY ';'
   OPTIONALLY ENCLOSED BY '"' AND '"'
   LRTRIM
      )
  LOCATION ('sa_par.csv')
)
PARALLEL
/
