\set ON_ERROR_STOP on
\set ECHO all

do $$
begin
  if not exists ( select from pg_catalog.pg_roles where rolname = 'zfin_owner' ) then
    create role zfin_owner;
    alter role zfin_owner with login password 'md54d819749b354caa5f0f00fff87950d78' valid until 'infinity';
    raise notice 'zfin_owner created';
  else
    raise notice 'zfin_owner is already exists';
  end if;
end $$;

do $$
begin
  if not exists ( select from pg_catalog.pg_roles where rolname = 'zfin_app' ) then
    create role zfin_app;
    alter role zfin_app with login password 'md59e7f2c5dd0a3662ed6be7f3afdf4bdf8' valid until 'infinity';
    raise notice 'zfin_app created';
  else
    raise notice 'zfin_app is already exists';
  end if;
end $$;
