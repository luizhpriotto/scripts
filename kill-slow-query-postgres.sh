#!/bin/bash
echo "Limpeza de query + 40m"


echo -e "postgres\ndatabase1\ndatabase2" > databases

lines=$(cat databases)
for line in $lines
do
psql postgresql://postgres:@option.postgres@@10.0.0.1/$line << EOF
    WITH sessoes_para_matar AS (
        SELECT
          pid,
          now() - pg_stat_activity.query_start AS duration,
          query,
          state
        FROM pg_stat_activity
        WHERE (now() - pg_stat_activity.query_start) > interval '40 minutes' and (query not like 'autovacuum%' and query not like 'vacuum%')
    )
    SELECT pg_terminate_backend(pid) FROM sessoes_para_matar; 
EOF
echo '.'
echo $line
done
cat databases
rm -f databases
