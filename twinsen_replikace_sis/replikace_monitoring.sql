# Show Master Group
SELECT GNAME, DBLINK, MASTERDEF
    FROM DBA_REPSITES 
    WHERE MASTER = 'Y' 
    AND GNAME NOT IN (SELECT GNAME FROM DBA_REPSITES WHERE SNAPMASTER = 'Y')    
    ORDER BY GNAME;


#Show Materialized Views
SELECT DISTINCT LOG_TABLE, 
       LOG_OWNER, 
       MASTER, 
       ROWIDS, 
       PRIMARY_KEY, 
       OBJECT_ID,
       FILTER_COLUMNS 
    FROM DBA_MVIEW_LOGS 
    ORDER BY 1;



select * from all_repconflict;
select * from all_represolution;

select * from ALL_REPRESOLUTION_STATISTICS 