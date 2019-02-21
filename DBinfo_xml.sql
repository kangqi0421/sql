create pfile='DBINFO_init_$ORACLE_SID.ora' from spfile;
host mv $ORACLE_HOME/dbs/DBINFO_init_$ORACLE_SID.ora ./DBINFO_init_$ORACLE_SID.ora

set lines 10000 pages 10000 long 100000 longchunksize 100000 heading off feedback off trimspool on echo off

spool DBINFO_$ORACLE_SID.xml
select '<ROWSET>'from dual;
select '<QUERIES>'from dual;
select xmlelement("instance",xmlattributes(instance_name,instance_role,version)) 
from gv$instance;

select xmlelement("database",xmlattributes(name,log_mode,flashback_on,force_logging,database_role)) 
from v$database;

select XMLElement("nls_database_parameters",XMLAttributes(parameter, value)) 
from nls_database_parameters 
where parameter in ('NLS_CHARACTERSET','NLS_NCHAR_CHARACTERSET') 
order by parameter;

select XMLElement("dba_services",xmlattributes(service_id,name)) 
from dba_services 
order by service_id;

select XMLElement("dba_registry",xmlattributes(comp_id, comp_name, status, version)) 
from dba_registry 
order by modified;

select XMLElement("controlfile",xmlattributes(name,round((block_size*file_size_blks/1024/1024),1) size_mb, is_recovery_dest_file))
from v$controlfile 
order by name;

select XMLElement("logfile",xmlattributes(x.thread#,x.group#,y.member,round(x.bytes/1024/1024) SIZE_MB,y.TYPE))
from v$log x, v$logfile y
where x.group# = y.group#
union all
select XMLElement("logfile",xmlattributes(a.thread#,a.group#,b.member,round(a.bytes/1024/1024) SIZE_MB,b.TYPE))
from v$standby_log a, v$logfile b
where a.group#  = b.group#;

select xmlelement("hrslogs",xmlattributes(to_char(FIRST_TIME,'YYMMDD-HH24') DAYDATE, 
count(*) switches))
from v$log_history
group by to_char(FIRST_TIME,'YYMMDD-HH24') 
order by to_char(FIRST_TIME,'YYMMDD-HH24');

select XMLElement("datafiles",xmlattributes(x.tablespace_name,x.file_name,y.status,y.enabled,x.status astatus,
round(y.bytes/1024/1024) SIZE_MB, x.autoextensible,round(x.maxbytes/1024/1024) MAX_MB,round(x.increment_by*y.block_size/1024/1024,3) INC_MB,y.block_size))
from dba_data_files x,v$datafile y, v$tablespace tmp
where y.file#=x.file_id and y.ts#=tmp.ts#
order by tmp.ts#,x.file_id;

select XMLElement("tempfiles",xmlattributes(x.tablespace_name,x.file_name,y.status,y.enabled,x.status astatus,
round(y.bytes/1024/1024) SIZE_MB, x.autoextensible,round(x.maxbytes/1024/1024) MAX_MB,round(x.increment_by*y.block_size/1024/1024,3) INC_MB,y.block_size))
from dba_temp_files x,v$tempfile y, v$tablespace tmp
where y.file#=x.file_id and y.ts#=tmp.ts#
order by tmp.ts#,x.file_id;

select XMLElement("permanent_tbs",xmlattributes(x.tablespace_name,x.status,y.bigfile,x.extent_management, x.segment_space_management,x.allocation_type, x.logging, x.force_logging, 
y.flashback_on,tmp.SIZE_MB,x.block_size))
from dba_tablespaces x,v$tablespace y, (select ts#,round(sum(bytes)/1024/1024)SIZE_MB from v$datafile group by ts#) tmp
where x.tablespace_name=y.name and y.ts#=tmp.ts# and x.contents='PERMANENT'
order by y.ts#;

select XMLElement("undo_tbs",xmlattributes(x.tablespace_name,x.retention,x.status,y.bigfile,x.extent_management, x.segment_space_management,x.allocation_type, x.logging, x.force_logging, 
y.flashback_on,tmp.SIZE_MB,x.block_size))
from dba_tablespaces x,v$tablespace y, (select ts#,round(sum(bytes)/1024/1024)SIZE_MB from v$datafile group by ts#) tmp
where x.tablespace_name=y.name and y.ts#=tmp.ts# and x.contents!='PERMANENT'
order by y.ts#;

select XMLElement("temp_tbs",xmlattributes(x.tablespace_name,x.status,y.bigfile,x.extent_management, x.segment_space_management,x.allocation_type, x.logging, x.force_logging, 
y.flashback_on,tmp.SIZE_MB,x.block_size))
from dba_tablespaces x,v$tablespace y, (select ts#,round(sum(bytes)/1024/1024)SIZE_MB from v$tempfile group by ts#) tmp
where x.tablespace_name=y.name and y.ts#=tmp.ts#
order by y.ts#;

select XMLElement("TABLESPACE_SPACE",xmlattributes( 
 d.tablespace_name, 
count(1) "files_count",
round(sum(d.bytes)/1048576,2) "alloc_MB",
round(sum(decode(autoextensible,'YES',d.maxbytes,d.bytes))/1048576,2) "maxsize_MB",
ROUND(SUM(DECODE(AUTOEXTENSIBLE,'YES',D.MAXBYTES,D.BYTES)-D.BYTES)/1048576,2) "extd_MB",
round((sum(decode(autoextensible,'YES',d.maxbytes,d.bytes)-d.bytes)/sum(decode(autoextensible,'YES',d.maxbytes,d.bytes)))*100,0) "extd_proc",
FREE_MB "free_MB_tbs",
free_perc "free_proc_tbs"))
from dba_data_files d, 
     (select fi.tablespace_name, round(sum(fi.bytes)/1048576,2) "size(MB)", 
	 		 nvl(free_by,0) free_mb,
			 nvl(round((free_by/(sum(fi.bytes)/1048576))*100,0),0) free_perc 
	  from dba_data_files fi, 
	       (select tablespace_name, round(sum(bytes)/1048576) free_by 
	        from dba_free_space
	        group by tablespace_name) fr
	  where fi.tablespace_name=fr.tablespace_name  (+)
	  group by fi.tablespace_name, free_by) f
where D.TABLESPACE_NAME=F.TABLESPACE_NAME
group by D.TABLESPACE_NAME, FREE_MB, FREE_PERC
order by D.tablespace_name --"Disk"; 

select xmlelement("resource_limit",xmlattributes(resource_name,current_utilization , max_utilization ,
initial_allocation, limit_value ,(round((max_utilization/to_number(initial_allocation)*100),0)) utilization)) 
from v$resource_limit
where resource_name in ('processes','sessions','enqueue_locks','enqueue_resources'
,'dml_locks','transactions','branches','cmtcallbk','max_rollback_segments','parallel_max_servers');

select xmlelement("invalid_objects",xmlattributes(owner,object_name, 
object_type,status)) 
from dba_objects where status<>'VALID';


SELECT xmlelement("nondefault_params",xmlattributes(a.ksppinm parameter_name,
b.ksppstvl parameter_value,a.ksppdesc parameter_desc))  
 FROM sys.x$ksppi a,sys.x$ksppsv b
 WHERE a.indx = b.indx
   AND UPPER(b.ksppstdf) = 'FALSE'
 ORDER BY a.ksppinm;  



select '</QUERIES>'from dual;

spool off

host echo '' >> DBINFO_$ORACLE_SID.xml
host echo '<pfile><VALS>' >> DBINFO_$ORACLE_SID.xml
host cat DBINFO_init_$ORACLE_SID.ora >> DBINFO_$ORACLE_SID.xml
host echo '</VALS></pfile>' >> DBINFO_$ORACLE_SID.xml
host echo '' >> DBINFO_$ORACLE_SID.xml
host echo '</ROWSET>' >> DBINFO_$ORACLE_SID.xml
--host rm -f DBINFO_init_$ORACLE_SID.ora
exit


