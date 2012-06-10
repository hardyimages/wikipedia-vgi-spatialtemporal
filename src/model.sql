\c hardy_db
set role to hardy;

-- -- integrate all together into path summary table
-- -- each path is the link plus contributions that traveled on it
-- DROP TABLE IF EXISTS contrib_flows_yyyymm;
-- CREATE TABLE contrib_flows_yyyymm AS
-- SELECT        t.lang, 
--               t.yyyy, 
--               t.mm, 
--               p1.path_id,
--               SUM(p1.n_contrib)   AS n_contrib,
--               SUM(p1.n)           AS n_path,
--               COUNT(*)            AS n
-- FROM          contrib_by_month as t
-- JOIN          contrib_nodes_yyyymm t1 ON (t1.x = t.contrib_x AND t1.y = t.contrib_y AND t1.lang = t.lang)
-- JOIN          contrib_nodes_yyyymm t2 ON (t2.x = t.article_x AND t2.y = t.article_y AND t2.lang = t.lang)
-- JOIN          contrib_paths_yyyymm p1 ON (p1.lang = t.lang AND p1.src = t1.node_id AND p1.dst = t2.node_id)
-- GROUP BY      t.lang, t.yyyy, t.mm, p1.path_id
-- ;
-- 
-- ALTER TABLE contrib_flows_yyyymm ADD COLUMN flow_id serial NOT NULL PRIMARY KEY;
-- ALTER TABLE contrib_flows_yyyymm ADD CONSTRAINT ux_contrib_flows_yyyymm UNIQUE(lang, yyyy, mm, path_id);
-- 

-- integrate all together into summary table
DROP TABLE IF EXISTS contrib_summary_yyyymm;
CREATE TABLE contrib_summary_yyyymm AS
SELECT        lang, 
              yyyy, 
              mm, 
              COUNT(*)                AS n,
              SUM(n_contrib)          AS n_contrib,
              COUNT(DISTINCT src)     AS n_src,
              COUNT(DISTINCT dst)     AS n_dst,
              AVG(distance_km)        AS d,
              SUM(n_contrib * distance_km)/SUM(n_contrib) AS d_w
FROM          contrib_paths_yyyymm
GROUP BY      lang, yyyy, mm
;


DROP TABLE IF EXISTS contrib_summary_yyyy;
CREATE TABLE contrib_summary_yyyy AS
SELECT        lang, 
              yyyy, 
              COUNT(*)                AS n,
              SUM(n_contrib)          AS n_contrib,
              COUNT(DISTINCT src)     AS n_src,
              COUNT(DISTINCT dst)     AS n_dst,
              AVG(distance_km)        AS d,
              SUM(n_contrib * distance_km)/SUM(n_contrib) AS d_w
FROM          contrib_paths_yyyymm
GROUP BY      lang, yyyy
;


DROP TABLE IF EXISTS contrib_summary_yyyy;
CREATE TABLE contrib_summary_yyyy AS
SELECT        lang, 
              COUNT(*)                AS n,
              SUM(n_contrib)          AS n_contrib,
              COUNT(DISTINCT src)     AS n_src,
              COUNT(DISTINCT dst)     AS n_dst,
              AVG(distance_km)        AS d,
              SUM(n_contrib * distance_km)/SUM(n_contrib) AS d_w
FROM          contrib_paths_yyyymm
GROUP BY      lang
;
