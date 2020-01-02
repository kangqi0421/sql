-- owner
do $$
begin
  if not exists (select rolname from pg_roles where rolname = 'riskengine') then
    create role riskengine;
    alter role riskengine with login password 'CLuTVhIk' valid until 'infinity';
    raise notice 'role riskengine created with password CLuTVhIk';
  else
    raise notice 'role riskengine already exists';
  end if;
end
$$;
alter role riskengine in database :db set search_path = riskengine,public;

-- app
do $$
begin
  if not exists (select rolname from pg_roles where rolname = 'riskengine_app') then
    create role riskengine_app;
    alter role riskengine_app with login password '2zaeeioL' valid until 'infinity';
    raise notice 'role riskengine_app created with password 2zaeeioL';
  else
    raise notice 'role riskengine_app already exists';
  end if;
end
$$;
alter role riskengine_app in database :db set search_path = riskengine,public;

-- read only access
do $$
begin
  if not exists (select rolname from pg_roles where rolname = 'riskengine_ro') then
    create role riskengine_ro with nologin;
    raise notice 'role riskengine_ro created';
  else
    raise notice 'role riskengine_ro already exists';
  end if;
end
$$;

-- read write access
do $$
begin
  if not exists (select rolname from pg_roles where rolname = 'riskengine_rw') then
    create role riskengine_rw with nologin;
    raise notice 'role riskengine_rw created';
  else
    raise notice 'role riskengine_rw already exists';
  end if;
end
$$;

-- user access = read write
do $$
begin
  if not exists (select rolname from pg_roles where rolname = 'riskengine_users') then
    create role riskengine_users with nologin valid until 'infinity';
    raise notice 'role riskengine_users created';
  else
    raise notice 'role riskengine_users already exists';
  end if;
end
$$;

\connect :db

-- role
create schema riskengine authorization riskengine;
revoke all on schema riskengine from public;

-- roles/privs
grant all on schema riskengine to riskengine;
grant usage on schema riskengine to riskengine_ro;
grant usage on schema riskengine to riskengine_rw;
grant usage on schema riskengine to riskengine_users;

alter default privileges in schema riskengine grant select, insert, update, delete, truncate, references, trigger on tables to riskengine_users;
alter default privileges in schema riskengine grant select, update, usage on sequences to riskengine_users;
alter default privileges in schema riskengine grant execute on functions to riskengine_users;
alter default privileges in schema riskengine grant usage on types to riskengine_users;

alter default privileges in schema riskengine grant select, insert, update, delete, truncate, references, trigger on tables to riskengine_rw;
alter default privileges in schema riskengine grant select, update, usage on sequences to riskengine_rw;
alter default privileges in schema riskengine grant execute on functions to riskengine_rw;
alter default privileges in schema riskengine grant usage on types to riskengine_rw;

alter default privileges in schema riskengine grant select on tables to riskengine_ro;

-- grant
grant riskengine_rw to riskengine_app;
