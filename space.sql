set serveroutput on

def owner = 
def table = 
def lob = 

/* TABLE - free space within a block */
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
       '&owner',
       '&table',
       'TABLE',
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



/* TABLE - free space within a block - partition table */

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
       '&owner',
       '&table',
       'TABLE PARTITION',
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
       v_full_bytes,
       '&partition_name');
     dbms_output.put_line('Unformatted Blocks                       = '||v_unformatted_blocks);
     dbms_output.put_line('Blocks with 00-25% free space   = '||v_fs1_blocks);
     dbms_output.put_line('Blocks with 26-50% free space   = '||v_fs2_blocks);
     dbms_output.put_line('Blocks with 51-75% free space   = '||v_fs3_blocks);
     dbms_output.put_line('Blocks with 76-100% free space = '||v_fs4_blocks);
     dbms_output.put_line('Full Blocks                                        = '||v_full_blocks);

end;
/

*/ TABLE LOB segment - name like 'SYS_LOB000% */
DECLARE
  l_segment_size_blocks  NUMBER;
  l_segment_size_bytes   NUMBER;
  l_used_blocks          NUMBER;
  l_used_bytes           NUMBER;
  l_expired_blocks       NUMBER;
  l_expired_bytes        NUMBER;
  l_unexpired_blocks     NUMBER;
  l_unexpired_bytes      NUMBER;
BEGIN
  DBMS_SPACE.SPACE_USAGE(
    segment_owner         => '&owner',
    segment_name          => '&lob',
    segment_type          => 'LOB',
    segment_size_blocks   => l_segment_size_blocks,
    segment_size_bytes    => l_segment_size_bytes,
    used_blocks           => l_used_blocks,
    used_bytes            => l_used_bytes,
    expired_blocks        => l_expired_blocks,
    expired_bytes         => l_expired_bytes,
    unexpired_blocks      => l_unexpired_blocks,
    unexpired_bytes       => l_unexpired_bytes);

  DBMS_OUTPUT.put_line('segment_size_blocks:' || l_segment_size_blocks);
  DBMS_OUTPUT.put_line('segment_size_bytes :' || l_segment_size_bytes);
  DBMS_OUTPUT.put_line('used_blocks        :' || l_used_blocks);
  DBMS_OUTPUT.put_line('used_bytes         :' || l_used_bytes);
  DBMS_OUTPUT.put_line('expired_blocks     :' || l_expired_blocks);
  DBMS_OUTPUT.put_line('expired_bytes      :' || l_expired_bytes);
  DBMS_OUTPUT.put_line('unexpired_blocks   :' || l_unexpired_blocks);
  DBMS_OUTPUT.put_line('unexpired_bytes    :' || l_unexpired_bytes);
END;
/