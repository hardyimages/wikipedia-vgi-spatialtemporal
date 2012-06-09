\c hardy_db

-- create all unique locations
DROP TABLE IF EXISTS contrib_nodes;
CREATE TABLE contrib_nodes AS
SELECT      lang, article_x AS x, article_y AS y
FROM        contrib_by_month
GROUP BY    lang, article_x, article_y
;


INSERT INTO contrib_nodes
SELECT      t.lang, contrib_x AS x, contrib_y AS y
FROM        contrib_by_month t
LEFT JOIN   contrib_nodes t1 ON (t1.lang = t.lang AND t.contrib_x = t1.x AND t.contrib_y = t1.y)
WHERE       t1.lang IS NULL
GROUP BY    t.lang, contrib_x, contrib_y
;

ALTER TABLE contrib_nodes ADD COLUMN node_id serial NOT NULL PRIMARY KEY;
ALTER TABLE contrib_nodes ADD CONSTRAINT ux_contrib_nodes UNIQUE(lang, x, y);
ALTER TABLE contrib_nodes ADD COLUMN geo_point GEOGRAPHY(POINT, 4326);

UPDATE      contrib_nodes n
SET         geo_point = ST_MakePoint(x, y)
;


SELECT COUNT(*) FROM contrib_nodes;

-- create a table with the line segments for all contributions
DROP TABLE IF EXISTS contrib_paths;
CREATE TABLE contrib_paths AS
SELECT      t.lang,
            t1.node_id AS src,
            t2.node_id AS dst
FROM        contrib_by_month t
JOIN        contrib_nodes t1 ON (t1.x = t.contrib_x AND t1.y = t.contrib_y AND t1.lang = t.lang)
JOIN        contrib_nodes t2 ON (t2.x = t.article_x AND t2.y = t.article_y AND t2.lang = t.lang)
GROUP BY    t.lang, t1.node_id, t2.node_id
;

ALTER TABLE contrib_paths ADD COLUMN path_id serial NOT NULL PRIMARY KEY;
ALTER TABLE contrib_paths ADD CONSTRAINT ux_contrib_paths UNIQUE(lang, src, dst);
ALTER TABLE contrib_paths ADD COLUMN geo_linestring GEOGRAPHY(LINESTRING, 4326);
ALTER TABLE contrib_paths ADD COLUMN distance_km DOUBLE PRECISION;

select count(*) from contrib_paths;

UPDATE    contrib_paths p
SET       geo_linestring = ST_MakeLine(n1.geo_point::geometry, n2.geo_point::geometry)
FROM      contrib_nodes n1, contrib_nodes n2
WHERE     n1.lang = p.lang AND n1.node_id = p.src AND
          n2.lang = p.lang AND n2.node_id = p.dst
;

UPDATE    contrib_paths p
SET       distance_km = ST_Length(geo_linestring)/1000.0
;

explain
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


