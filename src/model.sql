\c hardy_db
set role to hardy;

DROP TABLE IF EXISTS contrib_flows;
CREATE TABLE contrib_flows AS
SELECT    lang, yyyy, mm, path_id, contrib_n
FROM      contrib_by_month_k1 t
JOIN      contrib_nodes t1 ON (t1.x = t.contrib_x AND t1.y = t.contrib_y AND t1.dir = 'O')
JOIN      contrib_nodes t2 ON (t2.x = t.article_x AND t2.y = t.article_y AND t2.dir = 'I')
JOIN      contrib_paths p1 ON (p1.node_id_src = t1.node_id AND p1.node_id_dst = t2.node_id)
;

ALTER TABLE contrib_flows ADD COLUMN flow_id serial NOT NULL PRIMARY KEY;

DROP TABLE IF EXISTS contrib_flows_yyyymm;
CREATE TABLE contrib_flows_yyyymm AS
SELECT    lang, yyyy, mm, 
          COUNT(*) AS n_path,
          ROUND(SUM(contrib_n * distance_km)/SUM(contrib_n)) AS distance_mean_weighted,
          ROUND(AVG(distance_km)) AS distance_mean,
          SUM(contrib_n) AS n_contrib,
          CASE WHEN AVG(distance_km) < 1 THEN 0 ELSE
            (SUM(contrib_n * distance_km)/SUM(contrib_n))/AVG(distance_km) END AS distance_ratio,
          SUM(1.0*contrib_n)/COUNT(*) AS contrib_ratio
FROM      contrib_flows t
JOIN      contrib_paths p1 USING (path_id)
GROUP BY  lang, yyyy, mm
;

ALTER TABLE contrib_flows_yyyymm ADD CONSTRAINT ux_contrib_flows_yyyymm UNIQUE(lang, yyyy, mm);


DROP TABLE IF EXISTS contrib_flows_yyyy;
CREATE TABLE contrib_flows_yyyy AS
SELECT    lang, yyyy, 
          COUNT(*) AS n_path,
          COUNT(DISTINCT mm) AS n_month,
          ROUND(SUM(contrib_n * distance_km)/SUM(contrib_n)) AS distance_mean_weighted,
          ROUND(AVG(distance_km)) AS distance_mean,
          SUM(contrib_n) AS n_contrib,
          CASE WHEN AVG(distance_km) < 1 THEN 0 ELSE
          (SUM(contrib_n * distance_km)/SUM(contrib_n))/AVG(distance_km) END AS distance_ratio,
          SUM(1.0*contrib_n)/COUNT(*) AS contrib_ratio
FROM      contrib_flows t
JOIN      contrib_paths p1 USING (path_id)
GROUP BY  lang, yyyy
;

ALTER TABLE contrib_flows_yyyy ADD CONSTRAINT ux_contrib_flows_yyyy UNIQUE(lang, yyyy);

DROP TABLE IF EXISTS contrib_flows_yyyymm_extent;
CREATE TABLE contrib_flows_yyyymm_extent AS
SELECT    lang, yyyy, mm, SetSRID(ST_ConvexHull(ST_Collect(geo_linestring::geometry)),4326)::geography AS geo, COUNT(*) AS n
FROM      contrib_flows t
JOIN      contrib_paths p1 USING (path_id)
GROUP BY  lang, yyyy, mm
;

ALTER TABLE contrib_flows_yyyymm_extent ADD CONSTRAINT ux_contrib_flows_yyyymm_extent UNIQUE(lang, yyyy, mm);


