prompt
prompt Rebuilding Unusable Indexes
prompt



prompt unusable DBA_INDEXES
select owner, index_name, table_owner, table_name, status from dba_indexes where status = 'UNUSABLE';


prompt unusable DBA_IND_PARTITIONS
select index_owner, index_name, partition_name, status from dba_ind_partitions where status = 'UNUSABLE';

prompt unusable DBA_IND_SUBPARTITIONS
select index_owner, index_name, subpartition_name, status from dba_ind_subpartitions where status = 'UNUSABLE';

-- rebuild DBA_INDEXES
set serverout on
DECLARE
sql_stmt varchar2(1024);
cursor get_ind is
   select owner,index_name from dba_indexes
   where 1=1
   and (index_type not like 'IOT%'
   AND index_type not like 'LOB%')  /* this operation is not supported on IOT/LOB indexes */
   and status = 'UNUSABLE'
   --and owner = 'RUSB_OWNER'
   -- již dropnutý indexy nerebuilduju
   and dropped='NO';
BEGIN
   FOR ind_rec in get_ind LOOP
      sql_stmt := 'alter index '||ind_rec.owner||'.'||ind_rec.index_name
               ||' rebuild PARALLEL online ';
      --dbms_output.put_line(sql_stmt);
      EXECUTE IMMEDIATE sql_stmt;
   END LOOP;
END;
/

-- rebuild unusable local indexes
-- ALTER TABLE TABLE_OWNER.TABLE_NAME MODIFY PARTITION PARTITION_NAME REBUILD UNUSABLE LOCAL INDEXES;

BEGIN
for rec IN (
select i.owner, table_name, p.partition_name
  from dba_indexes i join dba_ind_partitions p
    on (i.owner = p.index_owner AND i.index_name = p.index_name)
where p.status = 'UNUSABLE'
          )
LOOP
  execute immediate 'ALTER TABLE '||rec.owner||'.'||rec.table_name||
  ' MODIFY PARTITION '||rec.partition_name|| ' REBUILD UNUSABLE LOCAL INDEXES';
  end loop;
END;
/
