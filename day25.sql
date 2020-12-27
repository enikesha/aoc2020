-- sudo -u postgres psql -f day25.sql
create or replace function secret_loop (pk integer) returns integer
language plpgsql as $$
declare
    sloop integer := 0;
    code integer := 1;
begin
    while code <> pk loop
      code := ((code * 7) % 20201227);
      sloop := sloop + 1;
    end loop;
    return sloop;
end $$;

create or replace function transf(subj integer, sloop integer) returns integer
language plpgsql as $$
declare
    code bigint := 1;
    sl integer;
begin
    for sl in 1..sloop loop
        code := (code * subj) % 20201227;
    end loop;
    return code;
end $$;

select transf(15231938, secret_loop(5290733));
