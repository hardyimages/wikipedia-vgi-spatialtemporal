\c hardy_db
set role to hardy;

-- create all unique locations
DROP TABLE IF EXISTS contrib_nodes_yyyymm;
CREATE TABLE contrib_nodes_yyyymm AS
SELECT      lang, yyyy, mm, x, y, COUNT(*) AS n
FROM        (
  SELECT      lang,  yyyy, mm, article_x AS x, article_y AS y
  FROM        contrib_by_month

  UNION
  
  SELECT      lang,  yyyy, mm, contrib_x AS x, contrib_y AS y
  FROM        contrib_by_month
) t
GROUP BY lang, yyyy, mm, x, y
;

ALTER TABLE contrib_nodes_yyyymm ADD COLUMN node_id serial NOT NULL PRIMARY KEY;
ALTER TABLE contrib_nodes_yyyymm ADD CONSTRAINT ux_contrib_nodes_yyyymm UNIQUE(lang, yyyy, mm, x, y);
ALTER TABLE contrib_nodes_yyyymm ADD COLUMN geo_point GEOGRAPHY(POINT, 4326);

UPDATE      contrib_nodes_yyyymm n
SET         geo_point = ST_MakePoint(x, y)
;

SELECT COUNT(*) FROM contrib_nodes_yyyymm;








-- create a table with the line segments for all contributions
DROP TABLE IF EXISTS contrib_paths_yyyymm;
CREATE TABLE contrib_paths_yyyymm AS
SELECT      t.lang,
            t.yyyy, 
            t.mm,
            t1.node_id AS src,
            t2.node_id AS dst,
            COUNT(*) AS n,
            SUM(t.contrib_n) AS n_contrib
FROM        contrib_by_month t
JOIN        contrib_nodes_yyyymm t1 ON (t1.x = t.contrib_x AND t1.y = t.contrib_y AND t1.lang = t.lang)
JOIN        contrib_nodes_yyyymm t2 ON (t2.x = t.article_x AND t2.y = t.article_y AND t2.lang = t.lang)
GROUP BY    t.lang, t.yyyy, t.mm, t1.node_id, t2.node_id
;

ALTER TABLE contrib_paths_yyyymm ADD COLUMN path_id serial NOT NULL PRIMARY KEY;
ALTER TABLE contrib_paths_yyyymm ADD CONSTRAINT ux_contrib_paths_yyyymm UNIQUE(lang, yyyy, mm, src, dst);
ALTER TABLE contrib_paths_yyyymm ADD COLUMN geo_linestring GEOGRAPHY(LINESTRING, 4326);
ALTER TABLE contrib_paths_yyyymm ADD COLUMN distance_km DOUBLE PRECISION;

select count(*) from contrib_paths_yyyymm;

UPDATE    contrib_paths_yyyymm p
SET       geo_linestring = ST_MakeLine(n1.geo_point::geometry, n2.geo_point::geometry)
FROM      contrib_nodes_yyyymm n1, contrib_nodes_yyyymm n2
WHERE     n1.lang = p.lang AND n1.node_id = p.src AND n1.yyyy = p.yyyy AND n1.mm = p.mm AND
          n2.lang = p.lang AND n2.node_id = p.dst AND n2.yyyy = p.yyyy AND n2.mm = p.mm
;

UPDATE    contrib_paths_yyyymm p
SET       distance_km = ST_Length(geo_linestring)/1000.0
;
