\c hardy_db
set role to hardy;

\o ../data/x_contrib_nodes.csv
COPY (SELECT * FROM contrib_nodes ORDER BY node_id) TO STDOUT WITH CSV HEADER
;

\o ../data/x_contrib_paths.csv
COPY (SELECT * FROM contrib_paths ORDER BY path_id) TO STDOUT WITH CSV HEADER
;

\o ../data/x_contrib_flows.csv
COPY (SELECT * FROM contrib_flows ORDER BY lang, yyyy, mm) TO STDOUT WITH CSV HEADER
;

\o ../data/x_contrib_flows_raw.csv
COPY (SELECT * FROM contrib_flows_raw ORDER BY lang, yyyy, mm) TO STDOUT WITH CSV HEADER
;

\o ../data/x_contrib_flows_yyyymm.csv
COPY (SELECT * FROM contrib_flows_yyyymm ORDER BY lang, yyyy, mm) TO STDOUT WITH CSV HEADER
;

\o ../data/x_contrib_flows_yyyy.csv
COPY (SELECT * FROM contrib_flows_yyyy ORDER BY lang, yyyy) TO STDOUT WITH CSV HEADER
;
