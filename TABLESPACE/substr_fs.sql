SELECT   SUBSTR (file_name, 1, INSTR (file_name, '/', 1, 2) - 1) AS "FS",
         SUBSTR (file_name, INSTR (file_name, '/', 1, 2) + 1) AS file_name,
         BYTES / 1024 / 1024 AS "MB"
    FROM dba_data_files
   WHERE tablespace_name = 'ODS_ACC_DATA_2M'
ORDER BY 2;

-- oradb/CRMP/d02/system01.dbf > file name
    SUBSTR (name, INSTR (name, '/', -1)+1) AS file_name 

-- +CRMP_D01/crmps/datafile/siebsa_data.451.818579993
    SUBSTR (file_name, INSTR (file_name, '/', -1) + 1) "df_name"
