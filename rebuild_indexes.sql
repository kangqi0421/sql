prompt
prompt Rebuilding Unusable Indexes 
prompt

set serverout on

DECLARE	

sql_stmt varchar2(1024);	

cursor get_ind is
   select owner,index_name from dba_indexes
   where 1=1
   and (index_type not like 'IOT%' 
   AND index_type not like 'LOB%')  /* this operation is not supported on IOT/LOB indexes */
   and status = 'UNUSABLE' ;
   /* and dropped='NO' ;   (10g) exclude objects in the recyclebin */

BEGIN

   FOR ind_rec in get_ind LOOP

      sql_stmt := 'alter index '||ind_rec.owner||'.'||ind_rec.index_name
               ||' rebuild online ';

      dbms_output.put_line(sql_stmt);
  
      EXECUTE IMMEDIATE sql_stmt;

   END LOOP;

END;
/