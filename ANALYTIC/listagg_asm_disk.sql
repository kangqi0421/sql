select LISTAGG(''''||path||'''', ','||chr(10)) WITHIN GROUP (ORDER BY path)  -- path do uvozovek, kazdy disk na samostatny radek
  from v$asm_disk
 where header_status = 'CANDIDATE'
/

-- listagg nefunguje, nahraženo za XMLELEMENT
-- ORA-01489: result of string concatenation is too long
select  rtrim(xmlagg(XMLELEMENT(e,name,',')
        .EXTRACT('//text()') ).GetClobVal(), ',')
  from V$BACKUP_COPY_DETAILS;

-- DG a disky dle DG z v$asm_disk
SELECT
      regexp_replace(path, '/dev/rlvo(\w+)(D01|FRA)\d+','\1_\2') AS dg,
      LISTAGG(''''||path||'''', ','||chr(10)) WITHIN GROUP (ORDER BY path) disk
    FROM V$ASM_DISK
    WHERE
      header_status = 'CANDIDATE'
    GROUP BY
      regexp_replace(path, '/dev/rlvo(\w+)(D01|FRA)\d+','\1_\2')