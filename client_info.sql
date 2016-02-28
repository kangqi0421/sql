-- V$SESSION_CONNECT_INFO
select client_driver, client_version, count(*)
  --inst_id, sid, osuser, client_oci_library, client_version, client_driver
  from GV$SESSION_CONNECT_INFO
where NETWORK_SERVICE_BANNER like '%TCP/IP%'  -- pouze TCP/IP spojení
--  and client_driver like 'jdbcthin'
group by client_driver, client_version
order by count(*) desc
  ;
  
-- SYS.x$ksusecon
 SELECT x.sid,
   DECODE(to_c,'0','Unknown',TO_NUMBER(SUBSTR(v,8,2),'xx') || '.' ||  -- maj_rel
             SUBSTR(v,10,1)      || '.' ||  -- mnt_rel
             SUBSTR(v,11,2)      || '.' ||  -- ias_rel
             SUBSTR(v,13,1)      || '.' ||  -- ptc_set
             SUBSTR(v,14,2)) client_version,  -- port_mnt
   username,program, module
 FROM x, v$session s
 WHERE x.sid like s.sid AND type != 'BACKGROUND'
/
  