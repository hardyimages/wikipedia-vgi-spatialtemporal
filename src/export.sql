\c hardy_db

\o ../data/x_contrib_nodes.csv
COPY (SELECT node_id, lang, x, y FROM contrib_nodes) TO STDOUT WITH CSV HEADER
;

\o ../data/x_contrib_paths.csv
COPY (SELECT path_id, lang, src, dst, distance_km FROM contrib_paths) TO STDOUT WITH CSV HEADER
;

\o ../data/x_contrib_flows.csv
COPY (SELECT * FROM contrib_flows) TO STDOUT WITH CSV HEADER
;
\o ../data/x_contrib_summary.csv
COPY (SELECT * FROM contrib_summary ORDER BY lang, yyyy, mm) TO STDOUT WITH CSV HEADER
;

\o ../data/x_contrib_summary_year.csv
COPY (SELECT * FROM contrib_summary_year ORDER BY lang, yyyy) TO STDOUT WITH CSV HEADER
;