variable i number;

begin
  select job into :i from dba_jobs where what like '%statspack.snap%';
    dbms_ijob.what (
       :i,
       'MakeSnap();'
       );
  commit;
end;
/

-- interval v definici pocet_minut / 1440

exec sys.dbms_ijob.next_date(374, to_date('08.03.2004 12:40', 'dd.mm.yyyy hh24:mi'));

-- 10 minut bez korekce
exec sys.dbms_ijob.interval(374, 'trunc(sysdate + 1/144, ''mi'')');

-- 10 minut s korekci
exec sys.dbms_ijob.interval(374, 'trunc(sysdate) + floor((sysdate - trunc(sysdate)) * 144) / 144 + 1/144');

-- 1x za hodinu s korekci
exec sys.dbms_ijob.interval(374, 'trunc(sysdate) + floor((sysdate - trunc(sysdate)) * 24) / 24+ 1/24');

-- 1x za 15 minut
exec sys.dbms_ijob.interval(374, 'trunc(sysdate) + floor((sysdate - trunc(sysdate)) * 96) / 96+ 1/96');
