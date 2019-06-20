alter table POPROD.CSD_PP_S disable row movement;
alter table POPROD.DM_SYSOBJECT_S disable row movement;

alter table POPROD.DM_SYSOBJECT_S shrink space;

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
       'POPROD',
       'DM_SYSOBJECT_S',
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