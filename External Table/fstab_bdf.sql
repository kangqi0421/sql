
create table hp3n_fstab (
  vg		char(4),
  lvol		char(6),
  filesystem    char(16),
  bytes		int,
  bytes_used	int,
  bytes_avail	int,
  used_pct	int,
  mount_point varchar(30)
)
/			

create table bdf_ext (
  filesystem	char(16), 
  bytes_k	int,
  used		int,
  available	int,
  used_pct	char(3),
  mount_point	varchar(30)
  )
  organization external (
  type		oracle_loader
  default directory srba_dir
  access parameters (
	records delimited by newline
	badfile 'bdf.bad'
	logfile 'bdf.log'
	skip 1
	fields terminated by whitespace
	optionally enclosed by '"' and '"'
   	)
  location ('bdf.txt')
)  
parallel
/

select * from bdf_ext
/

insert into hp3n_fstab 
  select substr(filesystem,6,4),
	 substr(filesystem,11,6),
	 filesystem,
	 bytes_k * 1024,
	 used * 1024,
	 available * 1024,
	 to_number(rtrim(substr(used_pct,1,2),'%')),
	 mount_point
     from bdf_ext
/

commit
/

