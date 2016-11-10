OPTIONS (SKIP=3)
LOAD DATA
INFILE *
APPEND
INTO TABLE CONS.OVO_STAGE_20120202
FIELDS TERMINATED BY ';' trailing nullcols
( hostname "trim(:hostname)",
  datetime_date,
  datetime_time,
  GBL_CPU_USER_MODE_UTIL        ,
  GBL_CPU_SYS_MODE_UTIL          ,
  GBL_CPU_IDLE_UTIL              ,
  GBL_MEM_UTIL                   ,
  GBL_MEM_USER_UTIL              ,
  GBL_MEM_SYS_UTIL               ,
  GBL_DISK_PHYS_READ             ,
  GBL_DISK_PHYS_IO		 ,
  datetime  "to_date(:datetime_date || :datetime_time, 'MM/DD/YYYYHH24:MI:SS')"  -- hodnota datetime je ziskana z date a time
)
