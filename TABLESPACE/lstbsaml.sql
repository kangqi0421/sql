/* Formatted on 2006/06/13 09:50 (Formatter Plus v4.8.7) */
SELECT   tablespace_name "tablespace", 
		 allocated_space "allocated [MB]",
         free_space "free [MB]", 
		 lpad(min_free,9,' ') "min free [MB]",
         LPAD (DECODE (min_free,' --------', '------',
                       ROUND ((free_space / min_free) * 100)
                      ), 10,' ') pctratio,
         CASE
            WHEN min_free = ' --------'    THEN '------'
            WHEN free_space - min_free > 0 THEN LPAD ('OK', 6, ' ')
            ELSE 'Warning'
         END AS status
    FROM (SELECT f.tablespace_name, f.total_max_space,
                 f.total_space - NVL (s.free_space, 0) allocated_space,
                 CASE
                    WHEN (f.total_max_space - f.total_space) = 0
                       THEN NVL (s.free_space, 0)
                    ELSE NVL (f.total_max_space - f.total_space + s.free_space,
                              0
                             )
                 END free_space,
                 s.min_free
            FROM (SELECT   tablespace_name, SUM (BYTES) / 1048576 total_space,
                           SUM (bytes_total) / 1048576 total_max_space
                      FROM (SELECT tablespace_name, BYTES,
                                   CASE
                                      WHEN autoextensible = 'NO'
                                         THEN BYTES
                                      WHEN autoextensible = 'YES'
                                         THEN maxbytes
                                   END bytes_total
                              FROM dba_data_files)
                  GROUP BY tablespace_name) f,
                 (SELECT   tablespace_name, SUM (BYTES) / 1048576 free_space,
                           DECODE (tablespace_name,
                                   'SYSTEM', '50',
                                   'SYSAUX', '50',
                                   'USERS', '50',
                                   'CAT_CUST', '150',
                                   'CAT_CUST_I', '150',
                                   'CAT_ACCT', '150',
                                   'CAT_ACCT_I', '150',
                                   'CAT_TXN', '650',
                                   'CAT_TXN_I', '650',
                                   'CAT_CUST_AC_LINK', '150',
                                   'CAT_CUST_AC_LINK_I', '150',
                                   'ATP_FACT_DAILY', '350',
                                   'CTP_FACT_DAILY', '350',
                                   'ATP_FACT_WEEKLY', '100',
                                   'CTP_FACT_WEEKLY', '100',
                                   'ATP_FACT_MONTHLY', '150',
                                   'CTP_FACT_MONTHLY', '150',
                                   'AML_ALERT_CASE_LG', '100',
                                   'AML_LOOKUP', '15',
                                   'WL_CUST', '150',
                                   'AML_TABLES', '100',
                                   'AML_ASSOC_INF', '150',
                                   'AML_ASSOC_NAME', '150',
                                   'AML_ADT', '100',
                                   'WL_TABLES', '100',
                                   'AML_ALERT_CASE_LG_I', '10',
                                   'AML_LOOKUP_I', '10',
                                   'WL_CUST_I', '100',
                                   'AML_TABLES_I', '100',
                                   'AML_ASSOC_INF_I', '100',
                                   'AML_ASSOC_NAME_I', '100',
                                   'AML_ADT_I', '10',
                                   'WL_TABLES_I', '100',
                                   'TEXT_INDEX', '100',
                                   'TEXT_INDEX_I', '100',
                                   ' --------'
                                  ) min_free
                      FROM dba_free_space
                  GROUP BY tablespace_name) s
           WHERE s.tablespace_name = f.tablespace_name)
ORDER BY pctratio;
