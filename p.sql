col p_name head NAME for a40
col p_value head VALUE for a40
col p_descr head DESCRIPTION for a80

select name p_name, value p_value
	from gv$parameter where lower(name) like lower('%&1%');

select n.ksppinm p_name, c.ksppstvl p_value
from sys.x$ksppi n, sys.x$ksppcv c
where n.indx=c.indx
and lower(n.ksppinm) like lower('%&1%');
