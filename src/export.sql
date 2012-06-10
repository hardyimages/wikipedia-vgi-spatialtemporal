\c hardy_db
set role to hardy;

\o ../data/x_contrib_nodes_yyyymm.csv
COPY (SELECT * FROM contrib_nodes_yyyymm) TO STDOUT WITH CSV HEADER
;

\o ../data/x_contrib_paths_yyyymm.csv
COPY (SELECT I FROM contrib_paths_yyyymm) TO STDOUT WITH CSV HEADER
;

\o ../data/x_contrib_summary_yyyymm.csv
COPY (SELECT * FROM contrib_summary_yyyymm) TO STDOUT WITH CSV HEADER
;

\o ../data/x_contrib_summary_yyyy.csv
COPY (SELECT * FROM contrib_summary_yyyy) TO STDOUT WITH CSV HEADER
;

\o ../data/x_contrib_summary.csv
COPY (SELECT * FROM contrib_summary) TO STDOUT WITH CSV HEADER
;
