declare
  s varchar2(1000);
  local_index boolean := false;
  cursor c1 is
    select owner, index_name, table_name, tablespace_name,
		   decode(a.index_type, 'NORMAL',Null, a.index_type) as type, 
		   decode(a.uniqueness, 'NONUNIQUE', Null, a.uniqueness) as uniq
	 from all_indexes a
	   	  where table_name = 'MI_CL_DRAWDOWN' and owner = upper('KMDW')
		  and index_name not like '%PK';
begin	
  for rec in c1
  loop
    -- inicializace promennych
    s := '';
	local_index := false;
	-- vyber sloupcu indexu
    for column in (select column_name from all_ind_columns 
			   where index_owner = rec.owner and index_name = rec.index_name
			   order by column_position) 
	   loop
			s := s || column.column_name || ',';
			if column.column_name = 'SYM_RUN_DATE'
			  then local_index := true;
			end if;  
	   end loop;
	s := substr(s,1, length(s)-1);   		    
	-- main()
	dbms_output.put('create ' || rec.uniq || rec.type || ' index ' || rec.owner ||
	    '.' || rec.index_name || ' on ' || rec.owner || '.' || rec.table_name || '(' || s || ') ');
	if local_index = true  then
	  	dbms_output.put('local ');
	end if;	
	dbms_output.put_line('tablespace ' || rec.tablespace_name || ';');
  end loop;
end;
/  	
	
	
