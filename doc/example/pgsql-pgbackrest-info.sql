-- An example of monitoring pgBunker from within PostgreSQL
--
-- Use copy to export data from the pgBunker info command into the jsonb
-- type so it can be queried directly by PostgreSQL.

-- Create monitor schema
create schema monitor;

-- Get pgBunker info in JSON format
create function monitor.pgbunker_info()
    returns jsonb AS $$
declare
    data jsonb;
begin
    -- Create a temp table to hold the JSON data
    create temp table temp_pgbunker_data (data text);

    -- Copy data into the table directly from the pgBunker info command
    copy temp_pgbunker_data (data)
        from program
            'pgbunker --output=json info' (format text);

    select replace(temp_pgbunker_data.data, E'\n', '\n')::jsonb
      into data
      from temp_pgbunker_data;

    drop table temp_pgbunker_data;

    return data;
end $$ language plpgsql;
