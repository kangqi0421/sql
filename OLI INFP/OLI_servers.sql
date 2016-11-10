select os, count(*)
from (
SELECT 
    CASE
      WHEN OS LIKE 'AIX%' THEN 'AIX'
      WHEN OS LIKE 'HP-UX%'  THEN 'HP-UX'
      WHEN OS LIKE '%Windows%' THEN 'Microsoft Windows Server'
      WHEN OS LIKE 'RHEL%'  THEN 'Linux'
      WHEN OS LIKE 'CentOS%'  THEN 'Linux'
      WHEN OS LIKE 'SOLARIS%'  THEN 'SOLARIS'      
      ELSE OS
    END "OS"
  FROM OLI_OWNER.SERVERS
)  
    group by OS
    ;