\c hardy_db
set role to hardy;


-- create all unique locations
DROP TABLE IF EXISTS contrib_nodes;
CREATE TABLE contrib_nodes AS
SELECT      x, y
FROM        (
  SELECT      article_x AS x, article_y AS y
  FROM        contrib_by_month

  UNION
  
  SELECT      contrib_x AS x, contrib_y AS y
  FROM        contrib_by_month
) t
GROUP BY x, y
;

ALTER TABLE contrib_nodes ADD COLUMN node_id serial NOT NULL PRIMARY KEY;
ALTER TABLE contrib_nodes ADD CONSTRAINT ux_contrib_nodes UNIQUE(x, y);
ALTER TABLE contrib_nodes ADD COLUMN geo_point GEOGRAPHY(POINT, 4326);

UPDATE      contrib_nodes n
SET         geo_point = ST_MakePoint(x, y)
;


-- create a table with the line segments for all contributions
DROP TABLE IF EXISTS contrib_paths;
CREATE TABLE contrib_paths AS
SELECT      t1.node_id AS node_id_src,
            t2.node_id AS node_id_dst
FROM        contrib_by_month t
JOIN        contrib_nodes t1 ON (t1.x = t.contrib_x AND t1.y = t.contrib_y)
JOIN        contrib_nodes t2 ON (t2.x = t.article_x AND t2.y = t.article_y)
GROUP BY    t1.node_id, t2.node_id
;

ALTER TABLE contrib_paths ADD COLUMN path_id serial NOT NULL PRIMARY KEY;
ALTER TABLE contrib_paths ADD CONSTRAINT ux_contrib_paths UNIQUE(node_id_src, node_id_dst);
ALTER TABLE contrib_paths ADD COLUMN geo_linestring GEOGRAPHY(LINESTRING, 4326);
ALTER TABLE contrib_paths ADD COLUMN distance_km DOUBLE PRECISION;

select count(*) from contrib_paths;

UPDATE    contrib_paths p
SET       geo_linestring = ST_MakeLine(n1.geo_point::geometry, n2.geo_point::geometry)
FROM      contrib_nodes n1, contrib_nodes n2
WHERE     n1.node_id = p.node_id_src AND
          n2.node_id = p.node_id_dst
;

UPDATE    contrib_paths p
SET       distance_km = ST_Length(geo_linestring)/1000.0
;

DROP TABLE IF EXISTS contrib_flows;
CREATE TABLE contrib_flows AS
SELECT    lang, yyyy, mm, 
          COUNT(path_id) AS n_path,
          SUM(contrib_n * distance_km)/SUM(contrib_n) AS distance_mean_weighted,
          AVG(distance_km) AS distance_mean,
          SUM(contrib_n) AS n_contrib
FROM      contrib_by_month t
JOIN      contrib_nodes t1 ON (t1.x = t.contrib_x AND t1.y = t.contrib_y)
JOIN      contrib_nodes t2 ON (t2.x = t.article_x AND t2.y = t.article_y)
JOIN      contrib_paths p1 ON (p1.node_id_src = t1.node_id AND p1.node_id_dst = t2.node_id)
GROUP BY  lang, yyyy, mm
;

ALTER TABLE contrib_flows ADD COLUMN flow_id serial NOT NULL PRIMARY KEY;
ALTER TABLE contrib_flows ADD CONSTRAINT ux_contrib_flows UNIQUE(lang, yyyy, mm);


