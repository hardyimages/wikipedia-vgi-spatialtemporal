\c hardy_db
set role to hardy;


-- create all unique locations
DROP TABLE IF EXISTS contrib_nodes;
CREATE TABLE contrib_nodes AS
SELECT      x, y, COUNT(*) AS n
FROM        (
  SELECT      article_x AS x, article_y AS y
  FROM        contrib_by_month_k1

  UNION
  
  SELECT      contrib_x AS x, contrib_y AS y
  FROM        contrib_by_month_k1
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
FROM        contrib_by_month_k1 t
JOIN        contrib_nodes t1 ON (t1.x = t.contrib_x AND t1.y = t.contrib_y)
JOIN        contrib_nodes t2 ON (t2.x = t.article_x AND t2.y = t.article_y)
GROUP BY    t1.node_id, t2.node_id
;

ALTER TABLE contrib_paths ADD COLUMN path_id serial NOT NULL PRIMARY KEY;
ALTER TABLE contrib_paths ADD CONSTRAINT ux_contrib_paths UNIQUE(node_id_src, node_id_dst);
ALTER TABLE contrib_paths ADD COLUMN geo_linestring GEOGRAPHY(LINESTRING, 4326);
ALTER TABLE contrib_paths ADD COLUMN distance_km INTEGER;

select count(*) from contrib_paths;

UPDATE    contrib_paths p
SET       geo_linestring = ST_MakeLine(n1.geo_point::geometry, n2.geo_point::geometry)
FROM      contrib_nodes n1, contrib_nodes n2
WHERE     n1.node_id = p.node_id_src AND
          n2.node_id = p.node_id_dst
;

UPDATE    contrib_paths p
SET       distance_km = round(ST_Length(geo_linestring)/1000.0)
;

