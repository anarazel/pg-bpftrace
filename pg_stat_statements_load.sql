WITH json_lines AS (
    SELECT
        line::jsonb line
    FROM
        pg_read_file('/tmp/data.json') input_data(data),
        regexp_matches(input_data.data, '([^\n]+)', 'g') match_array,
        unnest(match_array) lines(line)
)

INSERT INTO pg_stat_statements_extra_data AS de(map, queryid, value)
SELECT
    je.key AS map,
    jt.key::bigint AS queryid,
    jt.value::bigint AS value
FROM
    json_lines jl,
    jsonb_each(jl.line->'data') je,
    jsonb_each_text(je.value) jt
WHERE jl.line->>'type' = 'map'

ON CONFLICT (map, queryid) DO UPDATE SET
    value = de.value + EXCLUDED.value
;
