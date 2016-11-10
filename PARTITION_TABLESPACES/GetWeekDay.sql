CREATE OR REPLACE function GetWeekDayNo
	(
		  myDate date
	)
return varchar2
is
dNumber smallint;
begin
	select to_number(to_char(myDate, 'D')) into dNumber from dual;
	return (dNumber);
end;
/
