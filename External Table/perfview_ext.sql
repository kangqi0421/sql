CREATE TABLE CONS.OVO_STAGE_20120118
(
  HOST                           VARCHAR2(100),
  DATETIME_DATE                  char(10),
  DATETIME_TIME                  char(8),
  GBL_CPU_USER_MODE_UTIL         NUMBER,
  GBL_CPU_SYS_MODE_UTIL          NUMBER,
  GBL_CPU_IDLE_UTIL              NUMBER,
  GBL_MEM_UTIL                   NUMBER,
  GBL_MEM_USER_UTIL              NUMBER,
  GBL_MEM_SYS_UTIL               NUMBER,
  GBL_DISK_PHYS_READ             NUMBER,
  GBL_DISK_PHYS_IO               NUMBER
)
ORGANIZATION EXTERNAL
  (  TYPE oracle_loader
     DEFAULT DIRECTORY consolidace
     ACCESS PARAMETERS
       ( RECORDS DELIMITED BY NEWLINE
      BADFILE 'ovo_stage.bad'
      LOGFILE 'ovo_stage.log'
         FIELDS TERMINATED BY ';'
      LRTRIM
  MISSING FIELD VALUES ARE NULL   (HOST,
  datetime_date CHAR(10) DATE_FORMAT DATE MASK 'MM/DD/YY',
  datetime_time CHAR(8)  DATE_FORMAT DATE MASK 'HH24:MI:SS',
  GBL_CPU_USER_MODE_UTIL        ,
  GBL_CPU_SYS_MODE_UTIL          ,
  GBL_CPU_IDLE_UTIL              ,
  GBL_MEM_UTIL                   ,
  GBL_MEM_USER_UTIL              ,
  GBL_MEM_SYS_UTIL               ,
  GBL_DISK_PHYS_READ             ,
  GBL_DISK_PHYS_IO
      )
    )
     LOCATION (
'perf_hpux_amldb1t.vs.csin.cz.out',
'perf_hpux_amldb1.vs.csin.cz.out',
'perf_hpux_apscdbp1.vs.csin.cz.out',
'perf_hpux_apscdbp2.vs.csin.cz.out',
'perf_hpux_apscdbt1.vs.csin.cz.out',
'perf_hpux_apscdbt2.vs.csin.cz.out',
'perf_hpux_apscdbt3.vs.csin.cz.out',
'perf_hpux_bcdbrc1.vs.csin.cz.out',
'perf_hpux_bcdbrc2.vs.csin.cz.out',
'perf_hpux_bcrmd1.cc.csin.cz.out',
'perf_hpux_bdbzal.cc.csin.cz.out',
'perf_hpux_bdbzal.vs.csin.cz.out',
'perf_hpux_bdwhpo1.cc.csin.cz.out',
'perf_hpux_bovo.vs.csin.cz.out',
'perf_hpux_bsdk.vs.csin.cz.out',
'perf_hpux_bsym1.cc.csin.cz.out',
'perf_hpux_btuxdbv.cc.csin.cz.out',
'perf_hpux_btuxdb.vs.csin.cz.out',
'perf_hpux_bwcmb.vs.csin.cz.out',
'perf_hpux_bwdondb.cc.csin.cz.out',
'perf_hpux_cdbrc1st.vs.csin.cz.out',
'perf_hpux_cdbrc2st.vs.csin.cz.out',
'perf_hpux_cicdb1.vs.csin.cz.out',
'perf_hpux_cicdb2.vs.csin.cz.out',
'perf_hpux_cict1dbm.vs.csin.cz.out',
'perf_hpux_cict2dbm.vs.csin.cz.out',
'perf_hpux_crmatd.cc.csin.cz.out',
'perf_hpux_crmd1.cc.csin.cz.out',
'perf_hpux_crmstd1.cc.csin.cz.out',
'perf_hpux_crmstd2.cc.csin.cz.out',
'perf_hpux_dbzal.cc.csin.cz.out',
'perf_hpux_dbzal.vs.csin.cz.out',
'perf_hpux_dwhdm.cc.csin.cz.out',
'perf_hpux_dwhpd.cc.csin.cz.out',
'perf_hpux_dwhpo1.cc.csin.cz.out',
'perf_hpux_dwhtd.cc.csin.cz.out',
'perf_hpux_dwhto.cc.csin.cz.out',
'perf_hpux_gentdb.vs.csin.cz.out',
'perf_hpux_hp3n.cc.csin.cz.out',
'perf_hpux_ovo.vs.csin.cz.out',
'perf_hpux_rdbp1.vs.csin.cz.out',
'perf_hpux_rdbt1.vs.csin.cz.out',
'perf_hpux_riodb1.cc.csin.cz.out',
'perf_hpux_riodb2.cc.csin.cz.out',
'perf_hpux_riodbt1.vs.csin.cz.out',
'perf_hpux_riodbt2.vs.csin.cz.out',
'perf_hpux_sdk.vs.csin.cz.out',
'perf_hpux_smdb3t.vs.csin.cz.out',
'perf_hpux_smdb3.vs.csin.cz.out',
'perf_hpux_sym1.cc.csin.cz.out',
'perf_hpux_tovo.vs.csin.cz.out',
'perf_hpux_tuxdbstv.cc.csin.cz.out',
'perf_hpux_tuxdbst.vs.csin.cz.out',
'perf_hpux_tuxdbv.cc.csin.cz.out',
'perf_hpux_tuxdb.vs.csin.cz.out',
'perf_hpux_twcma.vs.csin.cz.out',
'perf_hpux_vovo.vs.csin.cz.out',
'perf_hpux_wcmb.vs.csin.cz.out',
'perf_hpux_wdondb.cc.csin.cz.out',
'perf_hpux_wdondbt.cc.csin.cz.out',
'perf_hpux_xriodb1.cc.csin.cz.out',
'perf_hpux_xriodb2.cc.csin.cz.out')
  )
REJECT LIMIT UNLIMITED;


CREATE TABLE disk_util_ext (
   datum    DATE,
   bydsk_devname CHAR(40),
   bydsk_util NUMBER,
   bydsk_request_queue  NUMBER,
   bydsk_avg_service_time  NUMBER,
   bydsk_dirname     VARCHAR(30),
   bydsk_fs_read     NUMBER,
   bydsk_fs_write NUMBER
   )
   ORGANIZATION EXTERNAL (
   TYPE  oracle_loader
   DEFAULT DIRECTORY srba_dir
   ACCESS PARAMETERS (
      RECORDS DELIMITED BY NEWLINE
      BADFILE 'ext_table.bad'
      LOGFILE 'ext_table.log'
      SKIP 1
      FIELDS TERMINATED BY ';'
      OPTIONALLY ENCLOSED BY '"' AND '"'
      LRTRIM
      (datum CHAR(20) DATE_FORMAT DATE MASK 'MM/DD/YY HH24:MI Dy',
      bydsk_devname,
   bydsk_util,
   bydsk_request_queue,
   bydsk_avg_service_time,
   bydsk_dirname,
   bydsk_fs_read,
   bydsk_fs_write
   )
      )
   LOCATION ('diskutil.csv')
)
PARALLEL
/

drop table perf_global_ext
/

CREATE TABLE perf_global_ext (
   datum    DATE,
   GBL_CPU_IDLE_UTIL number,
GBL_CPU_USER_MODE_UTIL number,
GBL_CPU_SYSCALL_TIME number,
GBL_CPU_SYSCALL_UTIL number,
GBL_RUN_QUEUE number,
GBL_DISK_UTIL_PEAK number,
GBL_DISK_PHYS_IO_RATE number,
GBL_DISK_LOGL_IO_RATE number,
GBL_DISK_PHYS_BYTE_RATE number,
GBL_MEM_FREE_UTIL number,
GBL_MEM_UTIL number,
GBL_MEM_SWAPOUT_RATE number,
GBL_NET_COLLISION_1_MIN_RATE number,
GBL_DISK_SUBSYSTEM_QUEUE number
   )
   ORGANIZATION EXTERNAL (
   TYPE  oracle_loader
   DEFAULT DIRECTORY srba_dir
   ACCESS PARAMETERS (
      RECORDS DELIMITED BY NEWLINE
      BADFILE 'ext_table.bad'
      LOGFILE 'ext_table.log'
      SKIP 1
      FIELDS TERMINATED BY ';'
      OPTIONALLY ENCLOSED BY '"' AND '"'
      LRTRIM
      (datum CHAR(20) DATE_FORMAT DATE MASK 'MM/DD/YY HH24:MI Dy',
GBL_CPU_IDLE_UTIL,
GBL_CPU_USER_MODE_UTIL,
GBL_CPU_SYSCALL_TIME,
GBL_CPU_SYSCALL_UTIL,
GBL_RUN_QUEUE,
GBL_DISK_UTIL_PEAK,
GBL_DISK_PHYS_IO_RATE,
GBL_DISK_LOGL_IO_RATE,
GBL_DISK_PHYS_BYTE_RATE,
GBL_MEM_FREE_UTIL,
GBL_MEM_UTIL,
GBL_MEM_SWAPOUT_RATE,
GBL_NET_COLLISION_1_MIN_RATE,
GBL_DISK_SUBSYSTEM_QUEUE
   )
      )
   LOCATION ('perfview.csv')
)
PARALLEL
/