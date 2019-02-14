begin
  Dbms_Redefinition.can_redef_table('ARM11', 'ARM_AUD$11');
end;
/

BEGIN  
DBMS_REDEFINITION.start_redef_table(  
uname => 'ARM11',   
orig_table => 'ARM_AUD$11',  
int_table => 'ARM_AUD$11_EXCH');  
END;  
/ 

-- na tohle jsem zapomnìl <<indexy, PK, triggery
BEGIN  
  DBMS_REDEFINITION.COPY_TABLE_DEPENDENTS ...
END;
/


BEGIN  
dbms_redefinition.finish_redef_table(  
uname => 'ARM11',   
orig_table => 'ARM_AUD$11',  
int_table => 'ARM_AUD$11_EXCH');  
END;  
/ 

BEGIN
  DBMS_STATS.gather_table_stats('ARM11', 'ARM_AUD$11', cascade => TRUE);
end;
/  


drop table ARM11.ARM_AUD$11_EXCH
/



---






CREATE TABLE ARM11.ARM_AUD$11_EXCH
(
  ARM_AUDID        NUMBER,
  ARM_TIMESTAMP    DATE                         NOT NULL,
  ARM_FULLID       VARCHAR2(25 BYTE)            NOT NULL,
  ARM_DBID         NUMBER                       NOT NULL,
  ARM_DB_NAME      VARCHAR2(9 BYTE)             NOT NULL,
  ARM_DB_VERSION   NUMBER                       NOT NULL,
  ARM_DB_INCARNATION NUMBER                     NOT NULL,
  ARM_ACTION_NAME  VARCHAR2(28 BYTE)            NOT NULL,
  SESSIONID        NUMBER                       NOT NULL,
  ENTRYID          NUMBER                       NOT NULL,
  STATEMENT        NUMBER                       NOT NULL,
  TIMESTAMP#       DATE,
  USERID           VARCHAR2(30 BYTE),
  USERHOST         VARCHAR2(128 BYTE),
  TERMINAL         VARCHAR2(255 BYTE),
  ACTION#          NUMBER                       NOT NULL,
  RETURNCODE       NUMBER                       NOT NULL,
  OBJ$CREATOR      VARCHAR2(30 BYTE),
  OBJ$NAME         VARCHAR2(128 BYTE),
  AUTH$PRIVILEGES  VARCHAR2(16 BYTE),
  AUTH$GRANTEE     VARCHAR2(30 BYTE),
  NEW$OWNER        VARCHAR2(30 BYTE),
  NEW$NAME         VARCHAR2(128 BYTE),
  SES$ACTIONS      VARCHAR2(19 BYTE),
  SES$TID          NUMBER,
  LOGOFF$LREAD     NUMBER,
  LOGOFF$PREAD     NUMBER,
  LOGOFF$LWRITE    NUMBER,
  LOGOFF$DEAD      NUMBER,
  LOGOFF$TIME      DATE,
  COMMENT$TEXT     VARCHAR2(4000 BYTE),
  CLIENTID         VARCHAR2(64 BYTE),
  SPARE1           VARCHAR2(255 BYTE),
  SPARE2           NUMBER,
  OBJ$LABEL        RAW(255),
  SES$LABEL        RAW(255),
  PRIV$USED        NUMBER,
  SESSIONCPU       NUMBER,
  NTIMESTAMP#      TIMESTAMP(6),
  PROXY$SID        NUMBER,
  USER$GUID        VARCHAR2(32 BYTE),
  INSTANCE#        NUMBER,
  PROCESS#         VARCHAR2(16 BYTE),
  XID              RAW(8),
  AUDITID          VARCHAR2(64 BYTE),
  SCN              NUMBER,
  DBID             NUMBER,
  SQLBIND          CLOB,
  SQLTEXT          CLOB,
  OBJ$EDITION      VARCHAR2(30 BYTE),
  IPADDRESS        VARCHAR2(20 BYTE)
)
PARTITION BY RANGE (ARM_TIMESTAMP)
INTERVAL( NUMTODSINTERVAL(1,'DAY'))
SUBPARTITION BY LIST (ARM_FULLID)
  SUBPARTITION TEMPLATE
      (SUBPARTITION SOTHER VALUES (DEFAULT ))
(
  PARTITION P0 VALUES LESS THAN (TO_DATE('2000-01-01','YYYY-MM-DD'))
    LOGGING
    COMPRESS
)
TABLESPACE ARM_DATA
COMPRESS;
