DROP VIEW pg_stat_statements_extra;DROP TABLE pg_stat_statements_extra_data ;

-- data storage
CREATE TABLE pg_stat_statements_extra_data (
    map text NOT NULL,
    queryid bigint not null,
    value bigint not null,
    unique(map, queryid)
);

-- view definition
CREATE OR REPLACE VIEW pg_stat_statements_extra AS
SELECT
    pgss.*,
    stat_send.value AS socket_send,
    stat_recv.value AS socket_recv,
    stat_read.value AS disk_read,
    stat_lwlock_wait.value / 1000 AS lwlock_wait
FROM
    pg_stat_statements pgss
    LEFT JOIN pg_stat_statements_extra_data AS stat_send ON (pgss.queryid = stat_send.queryid AND stat_send.map = '@stat_send')
    LEFT JOIN pg_stat_statements_extra_data AS stat_recv ON (pgss.queryid = stat_recv.queryid AND stat_recv.map = '@stat_recv')
    LEFT JOIN pg_stat_statements_extra_data AS stat_lwlock_wait ON (pgss.queryid = stat_lwlock_wait.queryid AND stat_lwlock_wait.map = '@stat_lwlock_wait')
    LEFT JOIN pg_stat_statements_extra_data AS stat_read ON (pgss.queryid = stat_read.queryid AND stat_read.map = '@stat_read')
;
