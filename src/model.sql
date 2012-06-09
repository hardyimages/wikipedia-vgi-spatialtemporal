\c hardy_db

-- integrate all together into path summary table
DROP TABLE IF EXISTS contrib_flows;
CREATE TABLE contrib_flows AS
SELECT        t.lang, 
              t.yyyy, 
              t.mm, 
              p1.path_id, 
              SUM(t.contrib_n) AS n, 
              COUNT(*) AS n_flow
FROM          contrib_by_month as t
JOIN          contrib_nodes t1 ON (t1.x = t.contrib_x AND t1.y = t.contrib_y AND t1.lang = t.lang)
JOIN          contrib_nodes t2 ON (t2.x = t.article_x AND t2.y = t.article_y AND t2.lang = t.lang)
JOIN          contrib_paths p1 ON (p1.lang = t.lang AND p1.src = t1.node_id AND p1.dst = t2.node_id)
GROUP BY      t.lang, t.yyyy, t.mm, p1.path_id
;

ALTER TABLE contrib_flows ADD COLUMN flow_id serial NOT NULL PRIMARY KEY;
ALTER TABLE contrib_flows ADD CONSTRAINT ux_contrib_flows UNIQUE(lang, yyyy, mm, path_id);


-- integrate all together into summary table
DROP TABLE IF EXISTS contrib_summary;
CREATE TABLE contrib_summary AS
SELECT        t.lang, 
              yyyy, 
              mm, 
              COUNT(*) AS n_paths,
              AVG(distance_km) AS distance_km_mean,
              STDDEV(distance_km) AS distance_km_sd,
              SUM(n * distance_km)/SUM(n) AS distance_km_mean_weighted,
              SUM(n) AS n, 
              SUM(n_flow) AS n_flow
FROM          contrib_flows t
JOIN          contrib_paths USING (path_id)
GROUP BY      t.lang, yyyy, mm
;

ALTER TABLE contrib_summary ADD PRIMARY KEY(lang, yyyy, mm);


-- drop table if exists contrib_flow_summary;
-- CREATE TABLE contrib_flow_summary AS
-- select      lang,
--             yyyy,
--             mm,
--             count(*)        AS n, 
--             sum(contrib_n)  AS n_contrib,
--             count(distinct(article_x, article_y)) AS n_dst_xy,
--             count(distinct(contrib_x, contrib_y)) AS n_src_xy
-- from        contrib_by_month 
-- group by    lang, yyyy, mm 
-- order by    lang, yyyy, mm; 
-- 
-- 
-- select      lang,
--             yyyy,
--             mm,
--             sum(n) AS n_contribs,
--             sum(n_flow) AS n_trips,
--             count(*) AS n_paths
-- from        contrib_flows cf 
-- where       lang = 'zh' and yyyy = 2006
-- group by    lang, yyyy, mm 
-- order by    lang, yyyy, mm;  
--  
