--
-- INFP postgres
--

select distinct INSTANCE
 from postgres.database
  where hostname = 'pedb01'
 order by 1;

select * from postgres.database
  where hostname = 'pedb01';
