SELECT   SUBSTR (file_name, 2, 3) file_system,
         SUM (BYTES) / 1024 / 1024 tablespace_size, 
		 tablespace_name
    FROM dba_data_files
GROUP BY ROLLUP (SUBSTR (file_name, 2, 3), tablespace_name)