#set lines 2000
set lines 155
set pages 50
COLUMN min_free format   a9 jus r heading "MIN_FREE"
COLUMN status format   a6 jus r heading "STATUS"
COLUMN pctratio format   a10 jus r heading "Free/Req|ratio[%]"
SELECT   tablespace_name, total_size, free_size, lpad(min_free,9,' ') min_free,
         lpad(decode(min_free, ' --------','------',round((free_size/min_free)*100)),10,' ') pctratio,
         CASE
            WHEN min_free = ' --------'
               THEN '------'
            WHEN free_size - min_free > 0
               THEN lpad('OK',6,' ')
            ELSE 'Warning'
         END AS status
    FROM (SELECT t.tablespace_name, f.total total_size,
                 ROUND (s.consumed) free_size, min_free
            FROM dba_tablespaces t,
                 (SELECT   tablespace_name, SUM (BYTES / 1024 / 1024) total
                      FROM dba_data_files
                  GROUP BY tablespace_name) f,
                 (SELECT   tablespace_name, SUM (BYTES / 1024 / 1024)
                                                                     consumed,
                           DECODE (tablespace_name,
                                   'ARCHBASE_DATA'   ,'   2000',
                                   'ARCHEIM_DATA'    ,'   2000',
                                   'ARCHEIM_INDX'    ,'   2000',
                                   'REPOSITORY_DATA' ,'    100',
                                   'REPOSITORY_INDEX','    100',
                                   'SIEB_DATA_BIG'   ,'   2000',
                                   'SIEB_DATA_MED'   ,'   2000',
		                   'SIEB_DATA_SML'   ,'    500',
                                   'SIEB_INDEX_BIG'  ,'   2000',
                                   'SIEB_INDEX_MED'  ,'   2000',
                                   'SIEB_INDEX_SML'  ,'    500',
                                   'SIEBEIM_DATA'    ,'   2000',
                                   'SIEBEIM_INDX'    ,'   2000',
                                   'SIEBELS_USERS'   ,' --------',
                                   'SIEBSA_DATA'     ,'   2000',
                                   'SIEBSA_INDX'     ,'   2000',
                                   'SYSTEM'          ,'    100',
                                   'TOOLS'           ,'    500',
                                   ' --------'
                                  ) min_free
                      FROM dba_free_space
                  GROUP BY tablespace_name) s
           WHERE t.tablespace_name = f.tablespace_name
             AND t.tablespace_name = s.tablespace_name (+) )
ORDER BY pctratio;

