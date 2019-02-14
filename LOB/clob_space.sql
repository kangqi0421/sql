

-- CLOB size
-- pozor vraci v chars, nikoliv bytes

select dbms_lob.getlength(CERTIFICATEREVOCATIONLIST)/1024 from CSCERT_OWNER_USER.CACERTIFICATES
  where id = 227256
;

-- length v bytes
LENGTHB(TO_CHAR(SUBSTR(<clob-column>,1,4000)))

--
select
     l.table_owner, l.partition_name, s.bytes
  FROM dba_segments s inner join dba_lob_partitions l
   on (   s.owner = l.table_owner
      AND s.partition_name = l.lob_partition_name)
  where l.table_owner = 'SIEBEL'
    AND l.table_name = 'CX_RT_LOG_XM'
    AND s.segment_type = 'LOB PARTITION'
 order by l.partition_name desc
;



create function get_clob_length
     ( p_clob clob
     ) return number is
  l_no_of_pieces     number := null;
  l_bufsize          number := 2000;
  l_string           varchar2(10000) := null;
  l_start            number := 1;
  l_length           number := null;
  l_amount           number := null;
  l_return           number := 0;
begin
  l_length := dbms_lob.getlength(p_clob);
  l_no_of_pieces := trunc(l_length/l_bufsize) + sign(mod(l_length,l_bufsize));
  for i in 1..l_no_of_pieces loop
    l_amount := least(l_bufsize,l_length-l_start+1);
    l_string := dbms_lob.substr(p_clob,l_amount,l_start);
    l_return := l_return + lengthb(l_string);
    l_start := l_start + l_bufsize;
  end loop;
  return(l_return);
end;
/


-- shrink clob-u
alter table CSCERT_OWNER_USER.CACERTIFICATES modify lob(CERTIFICATEREVOCATIONLIST) (shrink space);

-- shrink LOB
alter table REV.PRILOHA modify lob (OBSAH) (shrink space cascade);

-- move LOB
alter table REV.PRILOHA move lob (OBSAH) store as (tablespace REV);


-- space within the LOB blocks

set serveroutput on

declare
v_unformatted_blocks number;
v_unformatted_bytes number;
v_fs1_blocks number;
v_fs1_bytes number;
v_fs2_blocks number;
v_fs2_bytes number;
v_fs3_blocks number;
v_fs3_bytes number;
v_fs4_blocks number;
v_fs4_bytes number;
v_full_blocks number;
v_full_bytes number;
begin
     dbms_space.space_usage(
       'REV',
       'SYS_LOB0000042748C00004$$',
       'LOB',
       v_unformatted_blocks,
       v_unformatted_bytes,
       v_fs1_blocks,
       v_fs1_bytes,
       v_fs2_blocks,
       v_fs2_bytes,
       v_fs3_blocks,
       v_fs3_bytes,
       v_fs4_blocks,
       v_fs4_bytes,
       v_full_blocks,
       v_full_bytes);
     dbms_output.put_line('Unformatted Blocks   = '||v_unformatted_blocks);
     dbms_output.put_line('Blocks with 00-25% free space   = '||v_fs1_blocks);
     dbms_output.put_line('Blocks with 26-50% free space   = '||v_fs2_blocks);
     dbms_output.put_line('Blocks with 51-75% free space   = '||v_fs3_blocks);
     dbms_output.put_line('Blocks with 76-100% free space = '||v_fs4_blocks);
     dbms_output.put_line('Full Blocks = '||v_full_blocks);
end;
/