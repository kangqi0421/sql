--

- velikost /oradiag

select * from sysman.MGMT$STORAGE_REPORT_DATA
 where target_name = 'dasb7i.vs.csin.cz'
  and name = '/oradiag';


select target_name, usedb/power(1024,3) from sysman.MGMT$STORAGE_REPORT_DATA
 where name = '/oradiag'
  and key_value IS not NULL;
