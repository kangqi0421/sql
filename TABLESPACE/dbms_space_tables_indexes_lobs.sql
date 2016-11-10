set serveroutput on
set pagesize 20000

set lin 32767 trims on pages 999

declare
  cursor c_seg is
    select *
    from dba_segments
    where segment_name in (
      'AEALARM',
      'AEATTACHMENT',
      'AEB4PTASK',
      'AEB4PTASKEVENTDETAIL',
      'AEB4PTASKPA',
      'AECOORDINATION',
      'AEINDEXEDPROPERTYVALUE',
      'AEPOJO',
      'AEPROCESS',
      'AEPROCESSATTACHMENT',
      'AEPROCESSJOURNAL',
      'AEPROCESSLOG',
      'AEPROCESSLOGDATA',
      'AEQUEUEDRECEIVE',
      'AEVARIABLE'
    );
  cursor c_idx(p_owner varchar2, p_table_name varchar2) is
    select s.*
    from dba_segments s join dba_indexes i on (s.owner = i.table_owner and s.segment_name = i.index_name)
    where i.table_owner = p_owner
      and i.table_name = p_table_name;
  cursor c_lob(p_owner varchar2, p_table_name varchar2) is
    select s.*
    from dba_segments s join dba_lobs b on (s.owner = b.owner and s.segment_name = b.segment_name)
    where b.owner = p_owner
      and b.table_name = p_table_name;

  type t_obj_rec is record (
    owner           dba_segments.owner%TYPE,
    segment_name    dba_segments.segment_name%TYPE,
    segment_type    dba_segments.segment_type%TYPE,
    bytes           dba_segments.bytes%TYPE,
    tablespace_name dba_segments.tablespace_name%TYPE
  );

  type t_obj is table of t_obj_rec index by pls_integer;

  m_obj t_obj;

  unformated_bytes      number;
  unformated_blocks     number;
  free_076_100_bytes    number;
  free_076_100_blocks   number;
  free_051_075_bytes    number;
  free_051_075_blocks   number;
  free_026_050_bytes    number;
  free_026_050_blocks   number;
  free_000_025_bytes    number;
  free_000_025_blocks   number;
  full_bytes            number;
  full_blocks           number;
  m_obj_index           pls_integer;
  m_obj_type            dba_segments.segment_type%TYPE;
begin
  dbms_output.enable(1000000);
  m_obj_index := 0;
  for m_seg in c_seg loop
    m_obj(m_obj_index).owner := m_seg.owner;
    m_obj(m_obj_index).segment_name := m_seg.segment_name;
    m_obj(m_obj_index).segment_type := m_seg.segment_type;
    m_obj(m_obj_index).tablespace_name := m_seg.tablespace_name;
    m_obj(m_obj_index).bytes := m_seg.bytes;
    m_obj_index := m_obj_index + 1;
    continue when m_seg.segment_type != 'TABLE';
    for m_idx in c_idx(m_seg.owner, m_seg.segment_name) loop
      m_obj(m_obj_index).owner := m_idx.owner;
      m_obj(m_obj_index).segment_name := m_idx.segment_name;
      m_obj(m_obj_index).segment_type := m_idx.segment_type;
      m_obj(m_obj_index).tablespace_name := m_idx.tablespace_name;
      m_obj(m_obj_index).bytes := m_idx.bytes;
      m_obj_index := m_obj_index + 1;
    end loop;
    for m_lob in c_lob(m_seg.owner, m_seg.segment_name) loop
      m_obj(m_obj_index).owner := m_lob.owner;
      m_obj(m_obj_index).segment_name := m_lob.segment_name;
      m_obj(m_obj_index).segment_type := m_lob.segment_type;
      m_obj(m_obj_index).tablespace_name := m_lob.tablespace_name;
      m_obj(m_obj_index).bytes := m_lob.bytes;
      m_obj_index := m_obj_index + 1;
    end loop;
  end loop;
  dbms_output.put('owner;name;type;tablespace;segment size[MB];unformatted;25% free;50% free;75% free;100% free;full;');
  for i in m_obj.first .. m_obj.last loop
    dbms_output.put_line('');
    dbms_output.put(m_obj(i).owner ||';'||m_obj(i).segment_name ||';'||m_obj(i).segment_type||';');
    dbms_output.put(m_obj(i).tablespace_name||';'||round(m_obj(i).bytes/1024/1024)||';');
    m_obj_type := m_obj(i).segment_type;
    if m_obj(i).segment_type = 'LOBSEGMENT' then 
	m_obj_type := 'LOB'; 
    end if;
    continue when  m_obj(i).segment_type = 'LOBINDEX'; -- ORA-03200
    begin
      dbms_space.space_usage(m_obj(i).owner, m_obj(i).segment_name, m_obj_type,
        unformated_blocks, unformated_bytes,
        free_000_025_blocks, free_000_025_bytes,
        free_026_050_blocks, free_026_050_bytes,
        free_051_075_blocks, free_051_075_bytes,
        free_076_100_blocks, free_076_100_bytes,
        full_blocks, full_bytes,
        NULL);
      dbms_output.put(to_char(round(unformated_bytes/1024/1024), '9999999')||';');
      dbms_output.put(to_char(round(free_000_025_bytes/1024/1024), '9999999') ||';');
      dbms_output.put(to_char(round(free_026_050_bytes/1024/1024), '9999999') ||';');
      dbms_output.put(to_char(round(free_051_075_bytes/1024/1024), '9999999') ||';');
      dbms_output.put(to_char(round(free_076_100_bytes/1024/1024), '9999999') ||';');
      dbms_output.put(to_char(round(full_bytes/1024/1024), '9999999') ||';');
    exception
      when OTHERS then
        dbms_output.put_line('ERROR: ' || SQLERRM);
    end;
  end loop;
  dbms_output.put_line('');
end;
/
