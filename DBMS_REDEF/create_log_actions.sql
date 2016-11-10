
CREATE TABLE CBL.LOG_ACTIONS_MOJE
(
  ACTION_ID       NUMBER(16)                    NOT NULL,
  ACT_CODE_ID     NUMBER(3)                     NOT NULL,
  RESULT_ID       NUMBER(16)                    NOT NULL,
  SESSION_CD      VARCHAR2(512 BYTE)            NOT NULL,
  CLIENT_ID       NUMBER(10),
  CONTRACT_ID     NUMBER(8),
  CALL_TYPE_CR    CHAR(1 BYTE)                  DEFAULT 'N'                   NOT NULL,
  USER_CD         VARCHAR2(24 BYTE)             NOT NULL,
  TRANSACTION_ID  NUMBER(16),
  TIMESTAMP       DATE                          DEFAULT SYSDATE               NOT NULL,
  CHANNEL         CHAR(1 BYTE)                  NOT NULL,
  REQUEST         CLOB                          DEFAULT null,
  REQUEST_IP      VARCHAR2(23 BYTE),
  ACC_PFX_ID      NUMBER(6),
  ACC_NO_ID       NUMBER(10),
  ACC_BANK_ID     NUMBER(4),
  S24_ID          NUMBER(8),
  ISCS_ACC_NO     NUMBER(10),
  SOURCE_APP      CHAR(1 BYTE),
  DEV_AMOUNT      NUMBER(17,4)
)
TABLESPACE DATA_LARGE
PCTUSED    70
PCTFREE    0
INITRANS   20
MAXTRANS   255
STORAGE    (
            INITIAL          10M
            NEXT             10M
            MAXEXTENTS       2147483645
            FREELISTS        5
           )
LOGGING
PARTITION BY RANGE (TIMESTAMP) 
SUBPARTITION BY HASH (act_code_id)
(  
  PARTITION D20060729 VALUES LESS THAN (TO_DATE(' 2006-07-30 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
    TABLESPACE DATA_LARGE
LOB (REQUEST) STORE AS 
        (   TABLESPACE  CBL_LOB_TS 
          ENABLE        STORAGE IN ROW
          CHUNK       8192
          PCTVERSION  100
          NOCACHE
          STORAGE    (
                      INITIAL          5M
                      NEXT             5M
                      MINEXTENTS       1
                      MAXEXTENTS       2147483645
                      PCTINCREASE      0
                      FREELISTS        1
                      FREELIST GROUPS  1
                      BUFFER_POOL      DEFAULT
                     )
        )
    PCTUSED    70
    PCTFREE    0
    INITRANS   20
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        5
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               ),  
  PARTITION D20060730 VALUES LESS THAN (TO_DATE(' 2006-07-31 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
    TABLESPACE DATA_LARGE
LOB (REQUEST) STORE AS 
        (   TABLESPACE  CBL_LOB_TS 
          ENABLE        STORAGE IN ROW
          CHUNK       8192
          PCTVERSION  100
          NOCACHE
          STORAGE    (
                      INITIAL          5M
                      NEXT             5M
                      MINEXTENTS       1
                      MAXEXTENTS       2147483645
                      PCTINCREASE      0
                      FREELISTS        1
                      FREELIST GROUPS  1
                      BUFFER_POOL      DEFAULT
                     )
        )
    PCTUSED    70
    PCTFREE    0
    INITRANS   20
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        5
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               ),  
  PARTITION D20060731 VALUES LESS THAN (TO_DATE(' 2006-08-01 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
    TABLESPACE DATA_LARGE
LOB (REQUEST) STORE AS 
        (   TABLESPACE  CBL_LOB_TS 
          ENABLE        STORAGE IN ROW
          CHUNK       8192
          PCTVERSION  100
          NOCACHE
          STORAGE    (
                      INITIAL          5M
                      NEXT             5M
                      MINEXTENTS       1
                      MAXEXTENTS       2147483645
                      PCTINCREASE      0
                      FREELISTS        1
                      FREELIST GROUPS  1
                      BUFFER_POOL      DEFAULT
                     )
        )
    PCTUSED    70
    PCTFREE    0
    INITRANS   20
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        5
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               ),  
  PARTITION D20060801 VALUES LESS THAN (TO_DATE(' 2006-08-02 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
    TABLESPACE DATA_LARGE
LOB (REQUEST) STORE AS 
        (   TABLESPACE  CBL_LOB_TS 
          ENABLE        STORAGE IN ROW
          CHUNK       8192
          PCTVERSION  100
          NOCACHE
          STORAGE    (
                      INITIAL          5M
                      NEXT             5M
                      MINEXTENTS       1
                      MAXEXTENTS       2147483645
                      PCTINCREASE      0
                      FREELISTS        1
                      FREELIST GROUPS  1
                      BUFFER_POOL      DEFAULT
                     )
        )
    PCTUSED    70
    PCTFREE    0
    INITRANS   20
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        5
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               ),  
  PARTITION D20060802 VALUES LESS THAN (TO_DATE(' 2006-08-03 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
    TABLESPACE DATA_LARGE
LOB (REQUEST) STORE AS 
        (   TABLESPACE  CBL_LOB_TS 
          ENABLE        STORAGE IN ROW
          CHUNK       8192
          PCTVERSION  100
          NOCACHE
          STORAGE    (
                      INITIAL          5M
                      NEXT             5M
                      MINEXTENTS       1
                      MAXEXTENTS       2147483645
                      PCTINCREASE      0
                      FREELISTS        1
                      FREELIST GROUPS  1
                      BUFFER_POOL      DEFAULT
                     )
        )
    PCTUSED    70
    PCTFREE    0
    INITRANS   20
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        5
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               ),  
  PARTITION D20060803 VALUES LESS THAN (TO_DATE(' 2006-08-04 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
    TABLESPACE DATA_LARGE
LOB (REQUEST) STORE AS 
        (   TABLESPACE  CBL_LOB_TS 
          ENABLE        STORAGE IN ROW
          CHUNK       8192
          PCTVERSION  100
          NOCACHE
          STORAGE    (
                      INITIAL          5M
                      NEXT             5M
                      MINEXTENTS       1
                      MAXEXTENTS       2147483645
                      PCTINCREASE      0
                      FREELISTS        1
                      FREELIST GROUPS  1
                      BUFFER_POOL      DEFAULT
                     )
        )
    PCTUSED    70
    PCTFREE    0
    INITRANS   20
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        5
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               ),  
  PARTITION D20060804 VALUES LESS THAN (TO_DATE(' 2006-08-05 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
    TABLESPACE DATA_LARGE
LOB (REQUEST) STORE AS 
        (   TABLESPACE  CBL_LOB_TS 
          ENABLE        STORAGE IN ROW
          CHUNK       8192
          PCTVERSION  100
          NOCACHE
          STORAGE    (
                      INITIAL          5M
                      NEXT             5M
                      MINEXTENTS       1
                      MAXEXTENTS       2147483645
                      PCTINCREASE      0
                      FREELISTS        1
                      FREELIST GROUPS  1
                      BUFFER_POOL      DEFAULT
                     )
        )
    PCTUSED    70
    PCTFREE    0
    INITRANS   20
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        5
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               ),  
  PARTITION D20060805 VALUES LESS THAN (TO_DATE(' 2006-08-06 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
    TABLESPACE DATA_LARGE
LOB (REQUEST) STORE AS 
        (   TABLESPACE  CBL_LOB_TS 
          ENABLE        STORAGE IN ROW
          CHUNK       8192
          PCTVERSION  100
          NOCACHE
          STORAGE    (
                      INITIAL          5M
                      NEXT             5M
                      MINEXTENTS       1
                      MAXEXTENTS       2147483645
                      PCTINCREASE      0
                      FREELISTS        1
                      FREELIST GROUPS  1
                      BUFFER_POOL      DEFAULT
                     )
        )
    PCTUSED    70
    PCTFREE    0
    INITRANS   20
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        5
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               ),  
  PARTITION D20060806 VALUES LESS THAN (TO_DATE(' 2006-08-07 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
    TABLESPACE DATA_LARGE
LOB (REQUEST) STORE AS 
        (   TABLESPACE  CBL_LOB_TS 
          ENABLE        STORAGE IN ROW
          CHUNK       8192
          PCTVERSION  100
          NOCACHE
          STORAGE    (
                      INITIAL          5M
                      NEXT             5M
                      MINEXTENTS       1
                      MAXEXTENTS       2147483645
                      PCTINCREASE      0
                      FREELISTS        1
                      FREELIST GROUPS  1
                      BUFFER_POOL      DEFAULT
                     )
        )
    PCTUSED    70
    PCTFREE    0
    INITRANS   20
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        5
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               ),  
  PARTITION D20060807 VALUES LESS THAN (TO_DATE(' 2006-08-08 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
    TABLESPACE DATA_LARGE
LOB (REQUEST) STORE AS 
        (   TABLESPACE  CBL_LOB_TS 
          ENABLE        STORAGE IN ROW
          CHUNK       8192
          PCTVERSION  100
          NOCACHE
          STORAGE    (
                      INITIAL          5M
                      NEXT             5M
                      MINEXTENTS       1
                      MAXEXTENTS       2147483645
                      PCTINCREASE      0
                      FREELISTS        1
                      FREELIST GROUPS  1
                      BUFFER_POOL      DEFAULT
                     )
        )
    PCTUSED    70
    PCTFREE    0
    INITRANS   20
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        5
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               ),  
  PARTITION D20060808 VALUES LESS THAN (TO_DATE(' 2006-08-09 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
    TABLESPACE DATA_LARGE
LOB (REQUEST) STORE AS 
        (   TABLESPACE  CBL_LOB_TS 
          ENABLE        STORAGE IN ROW
          CHUNK       8192
          PCTVERSION  100
          NOCACHE
          STORAGE    (
                      INITIAL          5M
                      NEXT             5M
                      MINEXTENTS       1
                      MAXEXTENTS       2147483645
                      PCTINCREASE      0
                      FREELISTS        1
                      FREELIST GROUPS  1
                      BUFFER_POOL      DEFAULT
                     )
        )
    PCTUSED    70
    PCTFREE    0
    INITRANS   20
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        5
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               ),  
  PARTITION D20060809 VALUES LESS THAN (TO_DATE(' 2006-08-10 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
    TABLESPACE DATA_LARGE
LOB (REQUEST) STORE AS 
        (   TABLESPACE  CBL_LOB_TS 
          ENABLE        STORAGE IN ROW
          CHUNK       8192
          PCTVERSION  100
          NOCACHE
          STORAGE    (
                      INITIAL          5M
                      NEXT             5M
                      MINEXTENTS       1
                      MAXEXTENTS       2147483645
                      PCTINCREASE      0
                      FREELISTS        1
                      FREELIST GROUPS  1
                      BUFFER_POOL      DEFAULT
                     )
        )
    PCTUSED    70
    PCTFREE    0
    INITRANS   20
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        5
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               ),  
  PARTITION D20060810 VALUES LESS THAN (TO_DATE(' 2006-08-11 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
    TABLESPACE DATA_LARGE
LOB (REQUEST) STORE AS 
        (   TABLESPACE  CBL_LOB_TS 
          ENABLE        STORAGE IN ROW
          CHUNK       8192
          PCTVERSION  100
          NOCACHE
          STORAGE    (
                      INITIAL          5M
                      NEXT             5M
                      MINEXTENTS       1
                      MAXEXTENTS       2147483645
                      PCTINCREASE      0
                      FREELISTS        1
                      FREELIST GROUPS  1
                      BUFFER_POOL      DEFAULT
                     )
        )
    PCTUSED    70
    PCTFREE    0
    INITRANS   20
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        5
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               ),  
  PARTITION D20060811 VALUES LESS THAN (TO_DATE(' 2006-08-12 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
    TABLESPACE DATA_LARGE
LOB (REQUEST) STORE AS 
        (   TABLESPACE  CBL_LOB_TS 
          ENABLE        STORAGE IN ROW
          CHUNK       8192
          PCTVERSION  100
          NOCACHE
          STORAGE    (
                      INITIAL          5M
                      NEXT             5M
                      MINEXTENTS       1
                      MAXEXTENTS       2147483645
                      PCTINCREASE      0
                      FREELISTS        1
                      FREELIST GROUPS  1
                      BUFFER_POOL      DEFAULT
                     )
        )
    PCTUSED    70
    PCTFREE    0
    INITRANS   20
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        5
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               ),  
  PARTITION D20060812 VALUES LESS THAN (TO_DATE(' 2006-08-13 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
    TABLESPACE DATA_LARGE
LOB (REQUEST) STORE AS 
        (   TABLESPACE  CBL_LOB_TS 
          ENABLE        STORAGE IN ROW
          CHUNK       8192
          PCTVERSION  100
          NOCACHE
          STORAGE    (
                      INITIAL          5M
                      NEXT             5M
                      MINEXTENTS       1
                      MAXEXTENTS       2147483645
                      PCTINCREASE      0
                      FREELISTS        1
                      FREELIST GROUPS  1
                      BUFFER_POOL      DEFAULT
                     )
        )
    PCTUSED    70
    PCTFREE    0
    INITRANS   20
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        5
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               ),  
  PARTITION D20060813 VALUES LESS THAN (TO_DATE(' 2006-08-14 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
    TABLESPACE DATA_LARGE
LOB (REQUEST) STORE AS 
        (   TABLESPACE  CBL_LOB_TS 
          ENABLE        STORAGE IN ROW
          CHUNK       8192
          PCTVERSION  100
          NOCACHE
          STORAGE    (
                      INITIAL          5M
                      NEXT             5M
                      MINEXTENTS       1
                      MAXEXTENTS       2147483645
                      PCTINCREASE      0
                      FREELISTS        1
                      FREELIST GROUPS  1
                      BUFFER_POOL      DEFAULT
                     )
        )
    PCTUSED    70
    PCTFREE    0
    INITRANS   20
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        5
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               ),  
  PARTITION D20060814 VALUES LESS THAN (TO_DATE(' 2006-08-15 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
    TABLESPACE DATA_LARGE
LOB (REQUEST) STORE AS 
        (   TABLESPACE  CBL_LOB_TS 
          ENABLE        STORAGE IN ROW
          CHUNK       8192
          PCTVERSION  100
          NOCACHE
          STORAGE    (
                      INITIAL          5M
                      NEXT             5M
                      MINEXTENTS       1
                      MAXEXTENTS       2147483645
                      PCTINCREASE      0
                      FREELISTS        1
                      FREELIST GROUPS  1
                      BUFFER_POOL      DEFAULT
                     )
        )
    PCTUSED    70
    PCTFREE    0
    INITRANS   20
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        5
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               ),  
  PARTITION D20060815 VALUES LESS THAN (TO_DATE(' 2006-08-16 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
    TABLESPACE DATA_LARGE
LOB (REQUEST) STORE AS 
        (   TABLESPACE  CBL_LOB_TS 
          ENABLE        STORAGE IN ROW
          CHUNK       8192
          PCTVERSION  100
          NOCACHE
          STORAGE    (
                      INITIAL          5M
                      NEXT             5M
                      MINEXTENTS       1
                      MAXEXTENTS       2147483645
                      PCTINCREASE      0
                      FREELISTS        1
                      FREELIST GROUPS  1
                      BUFFER_POOL      DEFAULT
                     )
        )
    PCTUSED    70
    PCTFREE    0
    INITRANS   20
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        5
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               ),  
  PARTITION D20060816 VALUES LESS THAN (TO_DATE(' 2006-08-17 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
    TABLESPACE DATA_LARGE
LOB (REQUEST) STORE AS 
        (   TABLESPACE  CBL_LOB_TS 
          ENABLE        STORAGE IN ROW
          CHUNK       8192
          PCTVERSION  100
          NOCACHE
          STORAGE    (
                      INITIAL          5M
                      NEXT             5M
                      MINEXTENTS       1
                      MAXEXTENTS       2147483645
                      PCTINCREASE      0
                      FREELISTS        1
                      FREELIST GROUPS  1
                      BUFFER_POOL      DEFAULT
                     )
        )
    PCTUSED    70
    PCTFREE    0
    INITRANS   20
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        5
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               ),  
  PARTITION D20060817 VALUES LESS THAN (TO_DATE(' 2006-08-18 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
    TABLESPACE DATA_LARGE
LOB (REQUEST) STORE AS 
        (   TABLESPACE  CBL_LOB_TS 
          ENABLE        STORAGE IN ROW
          CHUNK       8192
          PCTVERSION  100
          NOCACHE
          STORAGE    (
                      INITIAL          5M
                      NEXT             5M
                      MINEXTENTS       1
                      MAXEXTENTS       2147483645
                      PCTINCREASE      0
                      FREELISTS        1
                      FREELIST GROUPS  1
                      BUFFER_POOL      DEFAULT
                     )
        )
    PCTUSED    70
    PCTFREE    0
    INITRANS   20
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        5
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               ),  
  PARTITION D20060818 VALUES LESS THAN (TO_DATE(' 2006-08-19 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
    TABLESPACE DATA_LARGE
LOB (REQUEST) STORE AS 
        (   TABLESPACE  CBL_LOB_TS 
          ENABLE        STORAGE IN ROW
          CHUNK       8192
          PCTVERSION  100
          NOCACHE
          STORAGE    (
                      INITIAL          5M
                      NEXT             5M
                      MINEXTENTS       1
                      MAXEXTENTS       2147483645
                      PCTINCREASE      0
                      FREELISTS        1
                      FREELIST GROUPS  1
                      BUFFER_POOL      DEFAULT
                     )
        )
    PCTUSED    70
    PCTFREE    0
    INITRANS   20
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        5
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               ),  
  PARTITION D20060819 VALUES LESS THAN (TO_DATE(' 2006-08-20 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
    TABLESPACE DATA_LARGE
LOB (REQUEST) STORE AS 
        (   TABLESPACE  CBL_LOB_TS 
          ENABLE        STORAGE IN ROW
          CHUNK       8192
          PCTVERSION  100
          NOCACHE
          STORAGE    (
                      INITIAL          5M
                      NEXT             5M
                      MINEXTENTS       1
                      MAXEXTENTS       2147483645
                      PCTINCREASE      0
                      FREELISTS        1
                      FREELIST GROUPS  1
                      BUFFER_POOL      DEFAULT
                     )
        )
    PCTUSED    70
    PCTFREE    0
    INITRANS   20
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        5
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               ),  
  PARTITION D20060820 VALUES LESS THAN (TO_DATE(' 2006-08-21 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
    TABLESPACE DATA_LARGE
LOB (REQUEST) STORE AS 
        (   TABLESPACE  CBL_LOB_TS 
          ENABLE        STORAGE IN ROW
          CHUNK       8192
          PCTVERSION  100
          NOCACHE
          STORAGE    (
                      INITIAL          5M
                      NEXT             5M
                      MINEXTENTS       1
                      MAXEXTENTS       2147483645
                      PCTINCREASE      0
                      FREELISTS        1
                      FREELIST GROUPS  1
                      BUFFER_POOL      DEFAULT
                     )
        )
    PCTUSED    70
    PCTFREE    0
    INITRANS   20
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        5
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               ),  
  PARTITION D20060821 VALUES LESS THAN (TO_DATE(' 2006-08-22 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
    TABLESPACE DATA_LARGE
LOB (REQUEST) STORE AS 
        (   TABLESPACE  CBL_LOB_TS 
          ENABLE        STORAGE IN ROW
          CHUNK       8192
          PCTVERSION  100
          NOCACHE
          STORAGE    (
                      INITIAL          5M
                      NEXT             5M
                      MINEXTENTS       1
                      MAXEXTENTS       2147483645
                      PCTINCREASE      0
                      FREELISTS        1
                      FREELIST GROUPS  1
                      BUFFER_POOL      DEFAULT
                     )
        )
    PCTUSED    70
    PCTFREE    0
    INITRANS   20
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        5
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               ),  
  PARTITION D20060822 VALUES LESS THAN (TO_DATE(' 2006-08-23 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
    TABLESPACE DATA_LARGE
LOB (REQUEST) STORE AS 
        (   TABLESPACE  CBL_LOB_TS 
          ENABLE        STORAGE IN ROW
          CHUNK       8192
          PCTVERSION  100
          NOCACHE
          STORAGE    (
                      INITIAL          5M
                      NEXT             5M
                      MINEXTENTS       1
                      MAXEXTENTS       2147483645
                      PCTINCREASE      0
                      FREELISTS        1
                      FREELIST GROUPS  1
                      BUFFER_POOL      DEFAULT
                     )
        )
    PCTUSED    70
    PCTFREE    0
    INITRANS   20
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        5
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               ),  
  PARTITION D20060823 VALUES LESS THAN (TO_DATE(' 2006-08-24 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
    TABLESPACE DATA_LARGE
LOB (REQUEST) STORE AS 
        (   TABLESPACE  CBL_LOB_TS 
          ENABLE        STORAGE IN ROW
          CHUNK       8192
          PCTVERSION  100
          NOCACHE
          STORAGE    (
                      INITIAL          5M
                      NEXT             5M
                      MINEXTENTS       1
                      MAXEXTENTS       2147483645
                      PCTINCREASE      0
                      FREELISTS        1
                      FREELIST GROUPS  1
                      BUFFER_POOL      DEFAULT
                     )
        )
    PCTUSED    70
    PCTFREE    0
    INITRANS   20
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        5
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               ),  
  PARTITION D20060824 VALUES LESS THAN (TO_DATE(' 2006-08-25 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
    TABLESPACE DATA_LARGE
LOB (REQUEST) STORE AS 
        (   TABLESPACE  CBL_LOB_TS 
          ENABLE        STORAGE IN ROW
          CHUNK       8192
          PCTVERSION  100
          NOCACHE
          STORAGE    (
                      INITIAL          5M
                      NEXT             5M
                      MINEXTENTS       1
                      MAXEXTENTS       2147483645
                      PCTINCREASE      0
                      FREELISTS        1
                      FREELIST GROUPS  1
                      BUFFER_POOL      DEFAULT
                     )
        )
    PCTUSED    70
    PCTFREE    0
    INITRANS   20
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        5
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               ),  
  PARTITION D20060825 VALUES LESS THAN (TO_DATE(' 2006-08-26 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
    TABLESPACE DATA_LARGE
LOB (REQUEST) STORE AS 
        (   TABLESPACE  CBL_LOB_TS 
          ENABLE        STORAGE IN ROW
          CHUNK       8192
          PCTVERSION  100
          NOCACHE
          STORAGE    (
                      INITIAL          5M
                      NEXT             5M
                      MINEXTENTS       1
                      MAXEXTENTS       2147483645
                      PCTINCREASE      0
                      FREELISTS        1
                      FREELIST GROUPS  1
                      BUFFER_POOL      DEFAULT
                     )
        )
    PCTUSED    70
    PCTFREE    0
    INITRANS   20
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        5
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               ),  
  PARTITION D20060826 VALUES LESS THAN (TO_DATE(' 2006-08-27 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
    TABLESPACE DATA_LARGE
LOB (REQUEST) STORE AS 
        (   TABLESPACE  CBL_LOB_TS 
          ENABLE        STORAGE IN ROW
          CHUNK       8192
          PCTVERSION  100
          NOCACHE
          STORAGE    (
                      INITIAL          5M
                      NEXT             5M
                      MINEXTENTS       1
                      MAXEXTENTS       2147483645
                      PCTINCREASE      0
                      FREELISTS        1
                      FREELIST GROUPS  1
                      BUFFER_POOL      DEFAULT
                     )
        )
    PCTUSED    70
    PCTFREE    0
    INITRANS   20
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        5
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               ),  
  PARTITION D20060827 VALUES LESS THAN (TO_DATE(' 2006-08-28 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
    TABLESPACE DATA_LARGE
LOB (REQUEST) STORE AS 
        (   TABLESPACE  CBL_LOB_TS 
          ENABLE        STORAGE IN ROW
          CHUNK       8192
          PCTVERSION  100
          NOCACHE
          STORAGE    (
                      INITIAL          5M
                      NEXT             5M
                      MINEXTENTS       1
                      MAXEXTENTS       2147483645
                      PCTINCREASE      0
                      FREELISTS        1
                      FREELIST GROUPS  1
                      BUFFER_POOL      DEFAULT
                     )
        )
    PCTUSED    70
    PCTFREE    0
    INITRANS   20
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        5
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               ),  
  PARTITION D20060828 VALUES LESS THAN (TO_DATE(' 2006-08-29 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
    TABLESPACE DATA_LARGE
LOB (REQUEST) STORE AS 
        (   TABLESPACE  CBL_LOB_TS 
          ENABLE        STORAGE IN ROW
          CHUNK       8192
          PCTVERSION  100
          NOCACHE
          STORAGE    (
                      INITIAL          5M
                      NEXT             5M
                      MINEXTENTS       1
                      MAXEXTENTS       2147483645
                      PCTINCREASE      0
                      FREELISTS        1
                      FREELIST GROUPS  1
                      BUFFER_POOL      DEFAULT
                     )
        )
    PCTUSED    70
    PCTFREE    0
    INITRANS   20
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        5
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               ),  
  PARTITION D20060829 VALUES LESS THAN (TO_DATE(' 2006-08-30 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
    TABLESPACE DATA_LARGE
LOB (REQUEST) STORE AS 
        (   TABLESPACE  CBL_LOB_TS 
          ENABLE        STORAGE IN ROW
          CHUNK       8192
          PCTVERSION  100
          NOCACHE
          STORAGE    (
                      INITIAL          5M
                      NEXT             5M
                      MINEXTENTS       1
                      MAXEXTENTS       2147483645
                      PCTINCREASE      0
                      FREELISTS        1
                      FREELIST GROUPS  1
                      BUFFER_POOL      DEFAULT
                     )
        )
    PCTUSED    70
    PCTFREE    0
    INITRANS   20
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        5
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               ),  
  PARTITION D20060830 VALUES LESS THAN (TO_DATE(' 2006-08-31 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
    TABLESPACE DATA_LARGE
LOB (REQUEST) STORE AS 
        (   TABLESPACE  CBL_LOB_TS 
          ENABLE        STORAGE IN ROW
          CHUNK       8192
          PCTVERSION  100
          NOCACHE
          STORAGE    (
                      INITIAL          5M
                      NEXT             5M
                      MINEXTENTS       1
                      MAXEXTENTS       2147483645
                      PCTINCREASE      0
                      FREELISTS        1
                      FREELIST GROUPS  1
                      BUFFER_POOL      DEFAULT
                     )
        )
    PCTUSED    70
    PCTFREE    0
    INITRANS   20
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        5
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               ),  
  PARTITION D20060831 VALUES LESS THAN (TO_DATE(' 2006-09-01 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
    TABLESPACE DATA_LARGE
LOB (REQUEST) STORE AS 
        (   TABLESPACE  CBL_LOB_TS 
          ENABLE        STORAGE IN ROW
          CHUNK       8192
          PCTVERSION  100
          NOCACHE
          STORAGE    (
                      INITIAL          5M
                      NEXT             5M
                      MINEXTENTS       1
                      MAXEXTENTS       2147483645
                      PCTINCREASE      0
                      FREELISTS        1
                      FREELIST GROUPS  1
                      BUFFER_POOL      DEFAULT
                     )
        )
    PCTUSED    70
    PCTFREE    0
    INITRANS   20
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        5
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               ),  
  PARTITION D20060901 VALUES LESS THAN (TO_DATE(' 2006-09-02 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
    TABLESPACE DATA_LARGE
LOB (REQUEST) STORE AS 
        (   TABLESPACE  CBL_LOB_TS 
          ENABLE        STORAGE IN ROW
          CHUNK       8192
          PCTVERSION  100
          NOCACHE
          STORAGE    (
                      INITIAL          5M
                      NEXT             5M
                      MINEXTENTS       1
                      MAXEXTENTS       2147483645
                      PCTINCREASE      0
                      FREELISTS        1
                      FREELIST GROUPS  1
                      BUFFER_POOL      DEFAULT
                     )
        )
    PCTUSED    70
    PCTFREE    0
    INITRANS   20
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        5
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               ),  
  PARTITION D20060902 VALUES LESS THAN (TO_DATE(' 2006-09-03 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
    TABLESPACE DATA_LARGE
LOB (REQUEST) STORE AS 
        (   TABLESPACE  CBL_LOB_TS 
          ENABLE        STORAGE IN ROW
          CHUNK       8192
          PCTVERSION  100
          NOCACHE
          STORAGE    (
                      INITIAL          5M
                      NEXT             5M
                      MINEXTENTS       1
                      MAXEXTENTS       2147483645
                      PCTINCREASE      0
                      FREELISTS        1
                      FREELIST GROUPS  1
                      BUFFER_POOL      DEFAULT
                     )
        )
    PCTUSED    70
    PCTFREE    0
    INITRANS   20
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        5
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               ),  
  PARTITION D20060903 VALUES LESS THAN (TO_DATE(' 2006-09-04 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
    TABLESPACE DATA_LARGE
LOB (REQUEST) STORE AS 
        (   TABLESPACE  CBL_LOB_TS 
          ENABLE        STORAGE IN ROW
          CHUNK       8192
          PCTVERSION  100
          NOCACHE
          STORAGE    (
                      INITIAL          5M
                      NEXT             5M
                      MINEXTENTS       1
                      MAXEXTENTS       2147483645
                      PCTINCREASE      0
                      FREELISTS        1
                      FREELIST GROUPS  1
                      BUFFER_POOL      DEFAULT
                     )
        )
    PCTUSED    70
    PCTFREE    0
    INITRANS   20
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        5
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               ),  
  PARTITION D20060904 VALUES LESS THAN (TO_DATE(' 2006-09-05 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
    TABLESPACE DATA_LARGE
LOB (REQUEST) STORE AS 
        (   TABLESPACE  CBL_LOB_TS 
          ENABLE        STORAGE IN ROW
          CHUNK       8192
          PCTVERSION  100
          NOCACHE
          STORAGE    (
                      INITIAL          5M
                      NEXT             5M
                      MINEXTENTS       1
                      MAXEXTENTS       2147483645
                      PCTINCREASE      0
                      FREELISTS        1
                      FREELIST GROUPS  1
                      BUFFER_POOL      DEFAULT
                     )
        )
    PCTUSED    70
    PCTFREE    0
    INITRANS   20
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        5
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               ),  
  PARTITION D20060905 VALUES LESS THAN (TO_DATE(' 2006-09-06 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
    TABLESPACE DATA_LARGE
LOB (REQUEST) STORE AS 
        (   TABLESPACE  CBL_LOB_TS 
          ENABLE        STORAGE IN ROW
          CHUNK       8192
          PCTVERSION  100
          NOCACHE
          STORAGE    (
                      INITIAL          5M
                      NEXT             5M
                      MINEXTENTS       1
                      MAXEXTENTS       2147483645
                      PCTINCREASE      0
                      FREELISTS        1
                      FREELIST GROUPS  1
                      BUFFER_POOL      DEFAULT
                     )
        )
    PCTUSED    70
    PCTFREE    0
    INITRANS   20
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        5
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               ),  
  PARTITION D20060906 VALUES LESS THAN (TO_DATE(' 2006-09-07 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
    TABLESPACE DATA_LARGE
LOB (REQUEST) STORE AS 
        (   TABLESPACE  CBL_LOB_TS 
          ENABLE        STORAGE IN ROW
          CHUNK       8192
          PCTVERSION  100
          NOCACHE
          STORAGE    (
                      INITIAL          5M
                      NEXT             5M
                      MINEXTENTS       1
                      MAXEXTENTS       2147483645
                      PCTINCREASE      0
                      FREELISTS        1
                      FREELIST GROUPS  1
                      BUFFER_POOL      DEFAULT
                     )
        )
    PCTUSED    70
    PCTFREE    0
    INITRANS   20
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        5
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               ),  
  PARTITION D20060907 VALUES LESS THAN (TO_DATE(' 2006-09-08 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
    TABLESPACE DATA_LARGE
LOB (REQUEST) STORE AS 
        (   TABLESPACE  CBL_LOB_TS 
          ENABLE        STORAGE IN ROW
          CHUNK       8192
          PCTVERSION  100
          NOCACHE
          STORAGE    (
                      INITIAL          5M
                      NEXT             5M
                      MINEXTENTS       1
                      MAXEXTENTS       2147483645
                      PCTINCREASE      0
                      FREELISTS        1
                      FREELIST GROUPS  1
                      BUFFER_POOL      DEFAULT
                     )
        )
    PCTUSED    70
    PCTFREE    0
    INITRANS   20
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        5
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               ),  
  PARTITION D20060908 VALUES LESS THAN (TO_DATE(' 2006-09-09 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
    TABLESPACE DATA_LARGE
LOB (REQUEST) STORE AS 
        (   TABLESPACE  CBL_LOB_TS 
          ENABLE        STORAGE IN ROW
          CHUNK       8192
          PCTVERSION  100
          NOCACHE
          STORAGE    (
                      INITIAL          5M
                      NEXT             5M
                      MINEXTENTS       1
                      MAXEXTENTS       2147483645
                      PCTINCREASE      0
                      FREELISTS        1
                      FREELIST GROUPS  1
                      BUFFER_POOL      DEFAULT
                     )
        )
    PCTUSED    70
    PCTFREE    0
    INITRANS   20
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        5
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               ),  
  PARTITION D20060909 VALUES LESS THAN (TO_DATE(' 2006-09-10 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
    TABLESPACE DATA_LARGE
LOB (REQUEST) STORE AS 
        (   TABLESPACE  CBL_LOB_TS 
          ENABLE        STORAGE IN ROW
          CHUNK       8192
          PCTVERSION  100
          NOCACHE
          STORAGE    (
                      INITIAL          5M
                      NEXT             5M
                      MINEXTENTS       1
                      MAXEXTENTS       2147483645
                      PCTINCREASE      0
                      FREELISTS        1
                      FREELIST GROUPS  1
                      BUFFER_POOL      DEFAULT
                     )
        )
    PCTUSED    70
    PCTFREE    0
    INITRANS   20
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        5
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               ),  
  PARTITION D20060910 VALUES LESS THAN (TO_DATE(' 2006-09-11 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
    TABLESPACE DATA_LARGE
LOB (REQUEST) STORE AS 
        (   TABLESPACE  CBL_LOB_TS 
          ENABLE        STORAGE IN ROW
          CHUNK       8192
          PCTVERSION  100
          NOCACHE
          STORAGE    (
                      INITIAL          5M
                      NEXT             5M
                      MINEXTENTS       1
                      MAXEXTENTS       2147483645
                      PCTINCREASE      0
                      FREELISTS        1
                      FREELIST GROUPS  1
                      BUFFER_POOL      DEFAULT
                     )
        )
    PCTUSED    70
    PCTFREE    0
    INITRANS   20
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        5
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               ),  
  PARTITION D20060911 VALUES LESS THAN (TO_DATE(' 2006-09-12 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
    TABLESPACE DATA_LARGE
LOB (REQUEST) STORE AS 
        (   TABLESPACE  CBL_LOB_TS 
          ENABLE        STORAGE IN ROW
          CHUNK       8192
          PCTVERSION  100
          NOCACHE
          STORAGE    (
                      INITIAL          5M
                      NEXT             5M
                      MINEXTENTS       1
                      MAXEXTENTS       2147483645
                      PCTINCREASE      0
                      FREELISTS        1
                      FREELIST GROUPS  1
                      BUFFER_POOL      DEFAULT
                     )
        )
    PCTUSED    70
    PCTFREE    0
    INITRANS   20
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        5
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               ),  
  PARTITION D20060912 VALUES LESS THAN (TO_DATE(' 2006-09-13 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
    TABLESPACE DATA_LARGE
LOB (REQUEST) STORE AS 
        (   TABLESPACE  CBL_LOB_TS 
          ENABLE        STORAGE IN ROW
          CHUNK       8192
          PCTVERSION  100
          NOCACHE
          STORAGE    (
                      INITIAL          5M
                      NEXT             5M
                      MINEXTENTS       1
                      MAXEXTENTS       2147483645
                      PCTINCREASE      0
                      FREELISTS        1
                      FREELIST GROUPS  1
                      BUFFER_POOL      DEFAULT
                     )
        )
    PCTUSED    70
    PCTFREE    0
    INITRANS   20
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        5
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               ),  
  PARTITION D20060913 VALUES LESS THAN (TO_DATE(' 2006-09-14 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
    TABLESPACE DATA_LARGE
LOB (REQUEST) STORE AS 
        (   TABLESPACE  CBL_LOB_TS 
          ENABLE        STORAGE IN ROW
          CHUNK       8192
          PCTVERSION  100
          NOCACHE
          STORAGE    (
                      INITIAL          5M
                      NEXT             5M
                      MINEXTENTS       1
                      MAXEXTENTS       2147483645
                      PCTINCREASE      0
                      FREELISTS        1
                      FREELIST GROUPS  1
                      BUFFER_POOL      DEFAULT
                     )
        )
    PCTUSED    70
    PCTFREE    0
    INITRANS   20
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        5
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               ),  
  PARTITION D20060914 VALUES LESS THAN (TO_DATE(' 2006-09-15 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
    TABLESPACE DATA_LARGE
LOB (REQUEST) STORE AS 
        (   TABLESPACE  CBL_LOB_TS 
          ENABLE        STORAGE IN ROW
          CHUNK       8192
          PCTVERSION  100
          NOCACHE
          STORAGE    (
                      INITIAL          5M
                      NEXT             5M
                      MINEXTENTS       1
                      MAXEXTENTS       2147483645
                      PCTINCREASE      0
                      FREELISTS        1
                      FREELIST GROUPS  1
                      BUFFER_POOL      DEFAULT
                     )
        )
    PCTUSED    70
    PCTFREE    0
    INITRANS   20
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        5
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               ),  
  PARTITION D20060915 VALUES LESS THAN (TO_DATE(' 2006-09-16 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
    TABLESPACE DATA_LARGE
LOB (REQUEST) STORE AS 
        (   TABLESPACE  CBL_LOB_TS 
          ENABLE        STORAGE IN ROW
          CHUNK       8192
          PCTVERSION  100
          NOCACHE
          STORAGE    (
                      INITIAL          5M
                      NEXT             5M
                      MINEXTENTS       1
                      MAXEXTENTS       2147483645
                      PCTINCREASE      0
                      FREELISTS        1
                      FREELIST GROUPS  1
                      BUFFER_POOL      DEFAULT
                     )
        )
    PCTUSED    70
    PCTFREE    0
    INITRANS   20
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        5
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               ),  
  PARTITION D20060916 VALUES LESS THAN (TO_DATE(' 2006-09-17 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
    TABLESPACE DATA_LARGE
LOB (REQUEST) STORE AS 
        (   TABLESPACE  CBL_LOB_TS 
          ENABLE        STORAGE IN ROW
          CHUNK       8192
          PCTVERSION  100
          NOCACHE
          STORAGE    (
                      INITIAL          5M
                      NEXT             5M
                      MINEXTENTS       1
                      MAXEXTENTS       2147483645
                      PCTINCREASE      0
                      FREELISTS        1
                      FREELIST GROUPS  1
                      BUFFER_POOL      DEFAULT
                     )
        )
    PCTUSED    70
    PCTFREE    0
    INITRANS   20
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        5
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               ),  
  PARTITION D20060917 VALUES LESS THAN (TO_DATE(' 2006-09-18 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
    TABLESPACE DATA_LARGE
LOB (REQUEST) STORE AS 
        (   TABLESPACE  CBL_LOB_TS 
          ENABLE        STORAGE IN ROW
          CHUNK       8192
          PCTVERSION  100
          NOCACHE
          STORAGE    (
                      INITIAL          5M
                      NEXT             5M
                      MINEXTENTS       1
                      MAXEXTENTS       2147483645
                      PCTINCREASE      0
                      FREELISTS        1
                      FREELIST GROUPS  1
                      BUFFER_POOL      DEFAULT
                     )
        )
    PCTUSED    70
    PCTFREE    0
    INITRANS   20
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        5
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               ),  
  PARTITION D20060918 VALUES LESS THAN (TO_DATE(' 2006-09-19 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
    TABLESPACE DATA_LARGE
LOB (REQUEST) STORE AS 
        (   TABLESPACE  CBL_LOB_TS 
          ENABLE        STORAGE IN ROW
          CHUNK       8192
          PCTVERSION  100
          NOCACHE
          STORAGE    (
                      INITIAL          5M
                      NEXT             5M
                      MINEXTENTS       1
                      MAXEXTENTS       2147483645
                      PCTINCREASE      0
                      FREELISTS        1
                      FREELIST GROUPS  1
                      BUFFER_POOL      DEFAULT
                     )
        )
    PCTUSED    70
    PCTFREE    0
    INITRANS   20
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        5
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               ),  
  PARTITION D20060919 VALUES LESS THAN (TO_DATE(' 2006-09-20 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
    TABLESPACE DATA_LARGE
LOB (REQUEST) STORE AS 
        (   TABLESPACE  CBL_LOB_TS 
          ENABLE        STORAGE IN ROW
          CHUNK       8192
          PCTVERSION  100
          NOCACHE
          STORAGE    (
                      INITIAL          5M
                      NEXT             5M
                      MINEXTENTS       1
                      MAXEXTENTS       2147483645
                      PCTINCREASE      0
                      FREELISTS        1
                      FREELIST GROUPS  1
                      BUFFER_POOL      DEFAULT
                     )
        )
    PCTUSED    70
    PCTFREE    0
    INITRANS   20
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        5
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               ),  
  PARTITION D20060920 VALUES LESS THAN (TO_DATE(' 2006-09-21 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
    TABLESPACE DATA_LARGE
LOB (REQUEST) STORE AS 
        (   TABLESPACE  CBL_LOB_TS 
          ENABLE        STORAGE IN ROW
          CHUNK       8192
          PCTVERSION  100
          NOCACHE
          STORAGE    (
                      INITIAL          5M
                      NEXT             5M
                      MINEXTENTS       1
                      MAXEXTENTS       2147483645
                      PCTINCREASE      0
                      FREELISTS        1
                      FREELIST GROUPS  1
                      BUFFER_POOL      DEFAULT
                     )
        )
    PCTUSED    70
    PCTFREE    0
    INITRANS   20
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        5
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               ),  
  PARTITION D20060921 VALUES LESS THAN (TO_DATE(' 2006-09-22 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
    TABLESPACE DATA_LARGE
LOB (REQUEST) STORE AS 
        (   TABLESPACE  CBL_LOB_TS 
          ENABLE        STORAGE IN ROW
          CHUNK       8192
          PCTVERSION  100
          NOCACHE
          STORAGE    (
                      INITIAL          5M
                      NEXT             5M
                      MINEXTENTS       1
                      MAXEXTENTS       2147483645
                      PCTINCREASE      0
                      FREELISTS        1
                      FREELIST GROUPS  1
                      BUFFER_POOL      DEFAULT
                     )
        )
    PCTUSED    70
    PCTFREE    0
    INITRANS   20
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        5
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               ),  
  PARTITION D20060922 VALUES LESS THAN (TO_DATE(' 2006-09-23 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
    TABLESPACE DATA_LARGE
LOB (REQUEST) STORE AS 
        (   TABLESPACE  CBL_LOB_TS 
          ENABLE        STORAGE IN ROW
          CHUNK       8192
          PCTVERSION  100
          NOCACHE
          STORAGE    (
                      INITIAL          5M
                      NEXT             5M
                      MINEXTENTS       1
                      MAXEXTENTS       2147483645
                      PCTINCREASE      0
                      FREELISTS        1
                      FREELIST GROUPS  1
                      BUFFER_POOL      DEFAULT
                     )
        )
    PCTUSED    70
    PCTFREE    0
    INITRANS   20
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        5
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               ),  
  PARTITION D20060923 VALUES LESS THAN (TO_DATE(' 2006-09-24 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
    TABLESPACE DATA_LARGE
LOB (REQUEST) STORE AS 
        (   TABLESPACE  CBL_LOB_TS 
          ENABLE        STORAGE IN ROW
          CHUNK       8192
          PCTVERSION  100
          NOCACHE
          STORAGE    (
                      INITIAL          5M
                      NEXT             5M
                      MINEXTENTS       1
                      MAXEXTENTS       2147483645
                      PCTINCREASE      0
                      FREELISTS        1
                      FREELIST GROUPS  1
                      BUFFER_POOL      DEFAULT
                     )
        )
    PCTUSED    70
    PCTFREE    0
    INITRANS   20
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        5
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               ),  
  PARTITION D20060924 VALUES LESS THAN (TO_DATE(' 2006-09-25 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
    TABLESPACE DATA_LARGE
LOB (REQUEST) STORE AS 
        (   TABLESPACE  CBL_LOB_TS 
          ENABLE        STORAGE IN ROW
          CHUNK       8192
          PCTVERSION  100
          NOCACHE
          STORAGE    (
                      INITIAL          5M
                      NEXT             5M
                      MINEXTENTS       1
                      MAXEXTENTS       2147483645
                      PCTINCREASE      0
                      FREELISTS        1
                      FREELIST GROUPS  1
                      BUFFER_POOL      DEFAULT
                     )
        )
    PCTUSED    70
    PCTFREE    0
    INITRANS   20
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        5
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               ),  
  PARTITION D20060925 VALUES LESS THAN (TO_DATE(' 2006-09-26 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
    TABLESPACE DATA_LARGE
LOB (REQUEST) STORE AS 
        (   TABLESPACE  CBL_LOB_TS 
          ENABLE        STORAGE IN ROW
          CHUNK       8192
          PCTVERSION  100
          NOCACHE
          STORAGE    (
                      INITIAL          5M
                      NEXT             5M
                      MINEXTENTS       1
                      MAXEXTENTS       2147483645
                      PCTINCREASE      0
                      FREELISTS        1
                      FREELIST GROUPS  1
                      BUFFER_POOL      DEFAULT
                     )
        )
    PCTUSED    70
    PCTFREE    0
    INITRANS   20
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        5
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               ),  
  PARTITION D20060926 VALUES LESS THAN (TO_DATE(' 2006-09-27 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
    TABLESPACE DATA_LARGE
LOB (REQUEST) STORE AS 
        (   TABLESPACE  CBL_LOB_TS 
          ENABLE        STORAGE IN ROW
          CHUNK       8192
          PCTVERSION  100
          NOCACHE
          STORAGE    (
                      INITIAL          5M
                      NEXT             5M
                      MINEXTENTS       1
                      MAXEXTENTS       2147483645
                      PCTINCREASE      0
                      FREELISTS        1
                      FREELIST GROUPS  1
                      BUFFER_POOL      DEFAULT
                     )
        )
    PCTUSED    70
    PCTFREE    0
    INITRANS   20
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        5
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               ),  
  PARTITION D20060927 VALUES LESS THAN (TO_DATE(' 2006-09-28 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
    TABLESPACE DATA_LARGE
LOB (REQUEST) STORE AS 
        (   TABLESPACE  CBL_LOB_TS 
          ENABLE        STORAGE IN ROW
          CHUNK       8192
          PCTVERSION  100
          NOCACHE
          STORAGE    (
                      INITIAL          5M
                      NEXT             5M
                      MINEXTENTS       1
                      MAXEXTENTS       2147483645
                      PCTINCREASE      0
                      FREELISTS        1
                      FREELIST GROUPS  1
                      BUFFER_POOL      DEFAULT
                     )
        )
    PCTUSED    70
    PCTFREE    0
    INITRANS   20
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        5
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               ),  
  PARTITION D20060928 VALUES LESS THAN (TO_DATE(' 2006-09-29 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
    TABLESPACE DATA_LARGE
LOB (REQUEST) STORE AS 
        (   TABLESPACE  CBL_LOB_TS 
          ENABLE        STORAGE IN ROW
          CHUNK       8192
          PCTVERSION  100
          NOCACHE
          STORAGE    (
                      INITIAL          5M
                      NEXT             5M
                      MINEXTENTS       1
                      MAXEXTENTS       2147483645
                      PCTINCREASE      0
                      FREELISTS        1
                      FREELIST GROUPS  1
                      BUFFER_POOL      DEFAULT
                     )
        )
    PCTUSED    70
    PCTFREE    0
    INITRANS   20
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        5
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               ),  
  PARTITION D20060929 VALUES LESS THAN (TO_DATE(' 2006-09-30 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
    TABLESPACE DATA_LARGE
LOB (REQUEST) STORE AS 
        (   TABLESPACE  CBL_LOB_TS 
          ENABLE        STORAGE IN ROW
          CHUNK       8192
          PCTVERSION  100
          NOCACHE
          STORAGE    (
                      INITIAL          5M
                      NEXT             5M
                      MINEXTENTS       1
                      MAXEXTENTS       2147483645
                      PCTINCREASE      0
                      FREELISTS        1
                      FREELIST GROUPS  1
                      BUFFER_POOL      DEFAULT
                     )
        )
    PCTUSED    70
    PCTFREE    0
    INITRANS   20
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        5
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               ),  
  PARTITION D20060930 VALUES LESS THAN (TO_DATE(' 2006-10-01 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
    TABLESPACE DATA_LARGE
LOB (REQUEST) STORE AS 
        (   TABLESPACE  CBL_LOB_TS 
          ENABLE        STORAGE IN ROW
          CHUNK       8192
          PCTVERSION  100
          NOCACHE
          STORAGE    (
                      INITIAL          5M
                      NEXT             5M
                      MINEXTENTS       1
                      MAXEXTENTS       2147483645
                      PCTINCREASE      0
                      FREELISTS        1
                      FREELIST GROUPS  1
                      BUFFER_POOL      DEFAULT
                     )
        )
    PCTUSED    70
    PCTFREE    0
    INITRANS   20
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        5
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               ),  
  PARTITION D20061001 VALUES LESS THAN (TO_DATE(' 2006-10-02 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
    TABLESPACE DATA_LARGE
LOB (REQUEST) STORE AS 
        (   TABLESPACE  CBL_LOB_TS 
          ENABLE        STORAGE IN ROW
          CHUNK       8192
          PCTVERSION  100
          NOCACHE
          STORAGE    (
                      INITIAL          5M
                      NEXT             5M
                      MINEXTENTS       1
                      MAXEXTENTS       2147483645
                      PCTINCREASE      0
                      FREELISTS        1
                      FREELIST GROUPS  1
                      BUFFER_POOL      DEFAULT
                     )
        )
    PCTUSED    70
    PCTFREE    0
    INITRANS   20
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        5
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               ),  
  PARTITION D20061002 VALUES LESS THAN (TO_DATE(' 2006-10-03 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
    TABLESPACE DATA_LARGE
LOB (REQUEST) STORE AS 
        (   TABLESPACE  CBL_LOB_TS 
          ENABLE        STORAGE IN ROW
          CHUNK       8192
          PCTVERSION  100
          NOCACHE
          STORAGE    (
                      INITIAL          5M
                      NEXT             5M
                      MINEXTENTS       1
                      MAXEXTENTS       2147483645
                      PCTINCREASE      0
                      FREELISTS        1
                      FREELIST GROUPS  1
                      BUFFER_POOL      DEFAULT
                     )
        )
    PCTUSED    70
    PCTFREE    0
    INITRANS   20
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        5
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               ),  
  PARTITION D20061003 VALUES LESS THAN (TO_DATE(' 2006-10-04 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
    TABLESPACE DATA_LARGE
LOB (REQUEST) STORE AS 
        (   TABLESPACE  CBL_LOB_TS 
          ENABLE        STORAGE IN ROW
          CHUNK       8192
          PCTVERSION  100
          NOCACHE
          STORAGE    (
                      INITIAL          5M
                      NEXT             5M
                      MINEXTENTS       1
                      MAXEXTENTS       2147483645
                      PCTINCREASE      0
                      FREELISTS        1
                      FREELIST GROUPS  1
                      BUFFER_POOL      DEFAULT
                     )
        )
    PCTUSED    70
    PCTFREE    0
    INITRANS   20
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        5
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               ),  
  PARTITION D20061004 VALUES LESS THAN (TO_DATE(' 2006-10-05 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
    TABLESPACE DATA_SMALL_TS
LOB (REQUEST) STORE AS 
        (   TABLESPACE  DATA_SMALL_TS 
          ENABLE        STORAGE IN ROW
          CHUNK       8192
          PCTVERSION  10
          NOCACHE
          STORAGE    (
                      INITIAL          1M
                      NEXT             1M
                      MINEXTENTS       1
                      MAXEXTENTS       2147483645
                      PCTINCREASE      0
                      FREELISTS        1
                      FREELIST GROUPS  1
                      BUFFER_POOL      DEFAULT
                     )
        )
    PCTUSED    40
    PCTFREE    10
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          1M
                NEXT             1M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        1
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               ),  
  PARTITION D20061005 VALUES LESS THAN (TO_DATE(' 2006-10-06 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
    TABLESPACE DATA_LARGE
LOB (REQUEST) STORE AS 
        (   TABLESPACE  CBL_LOB_TS 
          ENABLE        STORAGE IN ROW
          CHUNK       8192
          PCTVERSION  100
          NOCACHE
          STORAGE    (
                      INITIAL          5M
                      NEXT             5M
                      MINEXTENTS       1
                      MAXEXTENTS       2147483645
                      PCTINCREASE      0
                      FREELISTS        1
                      FREELIST GROUPS  1
                      BUFFER_POOL      DEFAULT
                     )
        )
    PCTUSED    70
    PCTFREE    0
    INITRANS   20
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        5
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               ),  
  PARTITION D20061006 VALUES LESS THAN (TO_DATE(' 2006-10-07 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
    TABLESPACE DATA_LARGE
LOB (REQUEST) STORE AS 
        (   TABLESPACE  CBL_LOB_TS 
          ENABLE        STORAGE IN ROW
          CHUNK       8192
          PCTVERSION  100
          NOCACHE
          STORAGE    (
                      INITIAL          5M
                      NEXT             5M
                      MINEXTENTS       1
                      MAXEXTENTS       2147483645
                      PCTINCREASE      0
                      FREELISTS        1
                      FREELIST GROUPS  1
                      BUFFER_POOL      DEFAULT
                     )
        )
    PCTUSED    70
    PCTFREE    0
    INITRANS   20
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        5
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               ),  
  PARTITION D20061007 VALUES LESS THAN (TO_DATE(' 2006-10-08 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
    TABLESPACE DATA_LARGE
LOB (REQUEST) STORE AS 
        (   TABLESPACE  CBL_LOB_TS 
          ENABLE        STORAGE IN ROW
          CHUNK       8192
          PCTVERSION  100
          NOCACHE
          STORAGE    (
                      INITIAL          5M
                      NEXT             5M
                      MINEXTENTS       1
                      MAXEXTENTS       2147483645
                      PCTINCREASE      0
                      FREELISTS        1
                      FREELIST GROUPS  1
                      BUFFER_POOL      DEFAULT
                     )
        )
    PCTUSED    70
    PCTFREE    0
    INITRANS   20
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        5
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               ),  
  PARTITION D20061008 VALUES LESS THAN (TO_DATE(' 2006-10-09 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
    TABLESPACE DATA_LARGE
LOB (REQUEST) STORE AS 
        (   TABLESPACE  CBL_LOB_TS 
          ENABLE        STORAGE IN ROW
          CHUNK       8192
          PCTVERSION  100
          NOCACHE
          STORAGE    (
                      INITIAL          5M
                      NEXT             5M
                      MINEXTENTS       1
                      MAXEXTENTS       2147483645
                      PCTINCREASE      0
                      FREELISTS        1
                      FREELIST GROUPS  1
                      BUFFER_POOL      DEFAULT
                     )
        )
    PCTUSED    70
    PCTFREE    0
    INITRANS   20
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        5
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               ),  
  PARTITION D20061009 VALUES LESS THAN (TO_DATE(' 2006-10-10 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
    TABLESPACE DATA_LARGE
LOB (REQUEST) STORE AS 
        (   TABLESPACE  CBL_LOB_TS 
          ENABLE        STORAGE IN ROW
          CHUNK       8192
          PCTVERSION  100
          NOCACHE
          STORAGE    (
                      INITIAL          5M
                      NEXT             5M
                      MINEXTENTS       1
                      MAXEXTENTS       2147483645
                      PCTINCREASE      0
                      FREELISTS        1
                      FREELIST GROUPS  1
                      BUFFER_POOL      DEFAULT
                     )
        )
    PCTUSED    70
    PCTFREE    0
    INITRANS   20
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        5
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               ),  
  PARTITION D20061010 VALUES LESS THAN (TO_DATE(' 2006-10-11 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
    TABLESPACE DATA_LARGE
LOB (REQUEST) STORE AS 
        (   TABLESPACE  CBL_LOB_TS 
          ENABLE        STORAGE IN ROW
          CHUNK       8192
          PCTVERSION  100
          NOCACHE
          STORAGE    (
                      INITIAL          5M
                      NEXT             5M
                      MINEXTENTS       1
                      MAXEXTENTS       2147483645
                      PCTINCREASE      0
                      FREELISTS        1
                      FREELIST GROUPS  1
                      BUFFER_POOL      DEFAULT
                     )
        )
    PCTUSED    70
    PCTFREE    0
    INITRANS   20
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        5
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               ),  
  PARTITION D20061011 VALUES LESS THAN (TO_DATE(' 2006-10-12 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
    TABLESPACE DATA_LARGE
LOB (REQUEST) STORE AS 
        (   TABLESPACE  CBL_LOB_TS 
          ENABLE        STORAGE IN ROW
          CHUNK       8192
          PCTVERSION  100
          NOCACHE
          STORAGE    (
                      INITIAL          5M
                      NEXT             5M
                      MINEXTENTS       1
                      MAXEXTENTS       2147483645
                      PCTINCREASE      0
                      FREELISTS        1
                      FREELIST GROUPS  1
                      BUFFER_POOL      DEFAULT
                     )
        )
    PCTUSED    70
    PCTFREE    0
    INITRANS   20
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        5
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               ),  
  PARTITION D20061012 VALUES LESS THAN (TO_DATE(' 2006-10-13 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
    TABLESPACE DATA_LARGE
LOB (REQUEST) STORE AS 
        (   TABLESPACE  CBL_LOB_TS 
          ENABLE        STORAGE IN ROW
          CHUNK       8192
          PCTVERSION  100
          NOCACHE
          STORAGE    (
                      INITIAL          5M
                      NEXT             5M
                      MINEXTENTS       1
                      MAXEXTENTS       2147483645
                      PCTINCREASE      0
                      FREELISTS        1
                      FREELIST GROUPS  1
                      BUFFER_POOL      DEFAULT
                     )
        )
    PCTUSED    70
    PCTFREE    0
    INITRANS   20
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        5
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               ),  
  PARTITION D20061013 VALUES LESS THAN (TO_DATE(' 2006-10-14 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
    TABLESPACE DATA_LARGE
LOB (REQUEST) STORE AS 
        (   TABLESPACE  CBL_LOB_TS 
          ENABLE        STORAGE IN ROW
          CHUNK       8192
          PCTVERSION  100
          NOCACHE
          STORAGE    (
                      INITIAL          5M
                      NEXT             5M
                      MINEXTENTS       1
                      MAXEXTENTS       2147483645
                      PCTINCREASE      0
                      FREELISTS        1
                      FREELIST GROUPS  1
                      BUFFER_POOL      DEFAULT
                     )
        )
    PCTUSED    70
    PCTFREE    0
    INITRANS   20
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        5
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               ),  
  PARTITION D20061014 VALUES LESS THAN (TO_DATE(' 2006-10-15 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
    TABLESPACE DATA_LARGE
LOB (REQUEST) STORE AS 
        (   TABLESPACE  CBL_LOB_TS 
          ENABLE        STORAGE IN ROW
          CHUNK       8192
          PCTVERSION  100
          NOCACHE
          STORAGE    (
                      INITIAL          5M
                      NEXT             5M
                      MINEXTENTS       1
                      MAXEXTENTS       2147483645
                      PCTINCREASE      0
                      FREELISTS        1
                      FREELIST GROUPS  1
                      BUFFER_POOL      DEFAULT
                     )
        )
    PCTUSED    70
    PCTFREE    0
    INITRANS   20
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        5
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               ),  
  PARTITION D20061015 VALUES LESS THAN (TO_DATE(' 2006-10-16 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
    TABLESPACE DATA_LARGE
LOB (REQUEST) STORE AS 
        (   TABLESPACE  CBL_LOB_TS 
          ENABLE        STORAGE IN ROW
          CHUNK       8192
          PCTVERSION  100
          NOCACHE
          STORAGE    (
                      INITIAL          5M
                      NEXT             5M
                      MINEXTENTS       1
                      MAXEXTENTS       2147483645
                      PCTINCREASE      0
                      FREELISTS        1
                      FREELIST GROUPS  1
                      BUFFER_POOL      DEFAULT
                     )
        )
    PCTUSED    70
    PCTFREE    0
    INITRANS   20
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        5
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               )
)
NOCOMPRESS 
NOCACHE
NOPARALLEL
MONITORING;


GRANT SELECT ON  LOG_ACTIONS_MOJE TO CBL_APPL_SERVER;

GRANT SELECT ON  LOG_ACTIONS_MOJE TO CBLAS;

GRANT SELECT ON  LOG_ACTIONS_MOJE TO CBL_MAINTENANCE;

GRANT SELECT ON  LOG_ACTIONS_MOJE TO CBL_READ_ONLY;


