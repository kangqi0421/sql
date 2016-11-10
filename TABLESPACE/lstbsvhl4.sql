set lines 140
set pages 500

column total_space     format 999990.9 heading "Total|[MB]"
column allocated_space format 999990.9 heading "Allocated|[MB]"
column free_space      format 999990.9 heading "Free|[MB]"
column free_pct        format    990.9 heading "Free|[%]"
column allocated_pct   format    990.9 heading "Allocated|[%]"
column available_space format 999990.9 heading "Available|[MB]"
column required_space  format 999990.9 heading "Required|[MB]"

select
  tablespace_category            "Category"
 ,tablespace_name                "Tablespace"
 ,total_space                    total_space
 ,allocated_space                allocated_space
 ,allocated_pct                  allocated_pct
 ,free_space                     free_space
 ,free_pct                       free_pct
 ,case
   when free_pct > warning_limit    then 'OK'
   when free_pct > critical_limit   then 'Warning'
   when free_pct <= critical_limit  then 'Critical'
   else 'OK'
  end as                         "Status"
 ,case
  when (tablespace_category like '%ODS' or tablespace_category like '%DWH' or tablespace_category like '%DMA')
        and free_pct > warning_limit
        and free_space > 1000000000/1024/1024 -- 1GB
  then 'Y'
  else 'N'
  end as                         "Reuse"
 ,case
  when (tablespace_category like '%ODS' or tablespace_category like '%DWH' or tablespace_category like '%DMA')
        and free_pct > warning_limit
        and free_space > 1000000000/1024/1024 -- 1GB
  then free_space-total_space*warning_limit/100
  else 0
  end as                         available_space
 ,case
  when (tablespace_category like '%ODS' or tablespace_category like '%DWH' or tablespace_category like '%DMA')
        and free_pct <= warning_limit
  then 'Y'
  else 'N'
  end as                         "Migrate"
 ,case
  when (tablespace_category like '%ODS' or tablespace_category like '%DWH' or tablespace_category like '%DMA')
        and free_pct <= warning_limit
  then total_space*warning_limit/100-free_space
  else 0
  end as                         required_space
 from (
 select 
  tablespace_category
 ,tablespace_name
 ,total_space
 ,allocated_space
 ,free_space
 ,100*nvl(free_space,0)/total_space                free_pct
 ,100-100*nvl(free_space,0)/total_space            allocated_pct
  ,case
   when tablespace_category like '%Interface' then 3
   when tablespace_category like '%ODS'       then 3
   when tablespace_category like '%DWH'       then 3
   when tablespace_category like '%DMA'       then 3
   when tablespace_category like '%Stage'     then 3
   when tablespace_category like '%System'    then 10
   when tablespace_category like '%External'  then 10
   else null
  end as warning_limit
 ,case
   when tablespace_category like '%Interface' then 1
   when tablespace_category like '%ODS'       then 1
   when tablespace_category like '%DWH'       then 1
   when tablespace_category like '%DMA'       then 1
   when tablespace_category like '%Stage'     then 1
   when tablespace_category like '%System'    then 5
   when tablespace_category like '%External'  then 5
   else null
  end as critical_limit
 from (
 select
   case
      when m.tablespace_name like 'INT%' then '4. Interface'
      when m.tablespace_name like 'ODS%' then '6. ODS'
      when m.tablespace_name like 'DWH%' and m.tablespace_name not like 'DWH%M' and m.tablespace_name not like 'DWH%K' then '9. DWH Facts'
      when m.tablespace_name like 'DWH%' then '8. DWH'
      when m.tablespace_name like 'DMA%' then '7. DMA'
      when m.tablespace_name like 'EXT%' or m.tablespace_name like 'ADR%' then '3. External'
      when m.tablespace_name like 'STAGE%' then '5. Stage'
      when m.tablespace_name like '%TEMP%' then '2. Temporary'
      else '1. System'
   end as tablespace_category,
   m.tablespace_name                                tablespace_name,
   m.total_max_space                                    total_space,
   m.total_space-nvl(s.free_space,0)                allocated_space,
   case 
      when (m.total_max_space - m.total_space) = 0 then nvl(s.free_space,0)
          else nvl(m.total_max_space - m.total_space + s.free_space,0)
   end free_space
  from
  ( select tablespace_name, sum(bytes)/1024/1024 total_space, sum(bytes_total)/1024/1024 total_max_space
   from 
   ( select tablespace_name, bytes, 
           case  
             when autoextensible = 'NO' then bytes
             when autoextensible = 'YES' then maxbytes
           end bytes_total
   from dba_data_files
   ) 
   group by tablespace_name
 ) m,
 (
   select tablespace_name, sum(bytes)/1024/1024 free_space
   from dba_free_space
   group by tablespace_name
 ) s
 where
  m.tablespace_name = s.tablespace_name(+)
 order by
   1, trunc(nvl(s.free_space,0)/m.total_space*100,2)
 )
 )
/


column total_space     clear
column allocated_space clear
column free_space      clear
column free_pct        clear
column allocated_pct   clear
column available_space clear
column required_space  clear
