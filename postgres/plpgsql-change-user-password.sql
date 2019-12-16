
/*
ALTER USER lending WITH PASSWORD 'lending';
ALTER USER process WITH PASSWORD 'process';
...
*/

DO $$ DECLARE
  r   RECORD;
  password VARCHAR(50);
BEGIN
  FOR r IN (SELECT datname FROM pg_database where NOT datistemplate
        AND datname != 'postgres')
  LOOP
    password := md5(random()::text);
    raise notice 'alter role % password %', r.datname, password;
    EXECUTE 'ALTER ROLE ' || quote_ident(r.datname) ||
      ' WITH PASSWORD '|| quote_literal(password);
  END LOOP;
END;
$$ LANGUAGE plpgsql;
