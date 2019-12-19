There is no view but if you have an account with:

o select on v_$parameter
o select on v_$thread
o create any directory

(you could remove the dependencies on v$parameter and v$thread but you would 
have to supply the alert log name to this routine) you could use a setup like 
the following:

drop table alert_log;

create global temporary table alert_log
( line   int primary key,
  text   varchar2(4000)
)
on commit preserve rows
/

create or replace procedure load_alert
as
    l_background_dump_dest   v$parameter.value%type;
    l_filename               varchar2(255);
    l_bfile                  bfile;
    l_last                   number;
    l_current                number;
    l_start                  number := dbms_utility.get_time;
begin
    select a.value, 'alert_' || b.instance || '.log'
      into l_background_dump_dest, l_filename
      from v$parameter a, v$thread b
     where a.name = 'background_dump_dest';

    execute immediate
    'create or replace directory x$alert_log$x as
    ''' || l_background_dump_dest || '''';


    dbms_output.put_line( l_background_dump_dest );
    dbms_output.put_line( l_filename );

    delete from alert_log;


    l_bfile := bfilename( 'X$ALERT_LOG$X', l_filename );
    dbms_lob.fileopen( l_bfile );

    l_last := 1;
    for l_line in 1 .. 50000
    loop

        dbms_application_info.set_client_info( l_line || ', ' ||
        to_char(round((dbms_utility.get_time-l_start)/100, 2 ) ) 
        || ', '||
        to_char((dbms_utility.get_time-l_start)/l_line)
        );
        l_current := dbms_lob.instr( l_bfile, '0A', l_last, 1 );
        exit when (nvl(l_current,0) = 0);

        insert into alert_log
        ( line, text )
        values
        ( l_line, 
          utl_raw.cast_to_varchar2( 
              dbms_lob.substr( l_bfile, l_current-l_last+1, 
                                                    l_last ) )
        );
        l_last := l_current+1;
    end loop;

    dbms_lob.fileclose(l_bfile);
end;
/


create directory BDUMP as 'D:\ORACLE\admin\ORCL\bdump';


Next, create the table using the new organization external clause.

create table alert_log_ext ( text varchar2(80) )
organization external (
type oracle_loader
default directory BDUMP
    access parameters (
        records delimited by newline
    )
location('alert_OSM0.log')
)
reject limit 1000;


