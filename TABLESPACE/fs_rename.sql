
SELECT    'ALTER DATABASE RENAME FILE '''
       || file_name
       || ''''
       || ' TO '
       || ''''
       || REPLACE (file_name, fs, new_fs)
       || ''';'
  FROM (SELECT   file_name, fs,
                 CASE
                    WHEN fs = '/u30'     THEN '/u108'
                    WHEN fs = '/u33'     THEN '/u108'
                    WHEN fs = '/u36'     THEN '/u108'
                    WHEN fs = '/u38'     THEN '/u108'
                    WHEN fs = '/u39'     THEN '/u108'
                    WHEN fs = '/u31'     THEN '/u109'
                    WHEN fs = '/u32'     THEN '/u109'
                    WHEN fs = '/u34'     THEN '/u109'
                    WHEN fs = '/u35'     THEN '/u109'
                    WHEN fs = '/u37'     THEN '/u109'
                    ELSE 'ERR'
	          END AS new_fs
            FROM (SELECT file_name,
                         SUBSTR (file_name, 1, (INSTR (file_name, '/', 1, 2) - 1)) fs
                    FROM dba_data_files)
           WHERE fs IN
                    ('/u30',
                     '/u33',
                     '/u36',
                     '/u38',
                     '/u39',
                     '/u31',
                     '/u32',
                     '/u34',
                     '/u35',
                     '/u37'
                    )
        ORDER BY fs ASC)
where new_fs <> 'ERR'		
