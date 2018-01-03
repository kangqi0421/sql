--
-- set FRA size to 98% ASM FRA DG
--

select round(value/power(1024,3)) "fra_size_gb"
  from v$parameter
 where name = 'db_recovery_file_dest_size';

DECLARE
  v_fra_size_gb int;
BEGIN
  SELECT round(total_mb/1024 * 0.98) into v_fra_size_gb
    FROM v$asm_diskgroup
    WHERE name in (select ltrim(value,'+')
      from v$parameter where name = 'db_recovery_file_dest');
  execute immediate 'alter system set db_recovery_file_dest_size='
    || v_fra_size_gb || 'G';
END;
/

select round(value/power(1024,3)) "fra_size_gb"
  from v$parameter
 where name = 'db_recovery_file_dest_size';
