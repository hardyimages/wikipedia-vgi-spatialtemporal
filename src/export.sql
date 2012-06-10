\c hardy_db

\o ../data/x_contrib_nodes_yyyymm.csv
COPY (SELECT * FROM contrib_nodes_yyyymm) TO STDOUT WITH CSV HEADER
;

\o ../data/x_contrib_paths_yyyymm.csv
COPY (SELECT I FROM contrib_paths_yyyymm) TO STDOUT WITH CSV HEADER
;

\o ../data/x_contrib_flows_yyyymm.csv
COPY (SELECT * FROM contrib_flows_yyyymm) TO STDOUT WITH CSV HEADER
;

-- \o ../data/x_contrib_summary.csv
-- COPY (SELECT * FROM contrib_summary ORDER BY lang, yyyy, mm) TO STDOUT WITH CSV HEADER
-- ;
-- 
-- \o ../data/x_contrib_summary_year.csv
-- COPY (SELECT * FROM contrib_summary_year ORDER BY lang, yyyy) TO STDOUT WITH CSV HEADER
-- ;