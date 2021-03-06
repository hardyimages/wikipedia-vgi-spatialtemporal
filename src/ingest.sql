\c hardy_db
set role to hardy;


-- create all unique locations
DROP TABLE IF EXISTS contrib_nodes;
CREATE TABLE contrib_nodes AS
SELECT      x, y, dir::char(1), count(*)
FROM        (
  SELECT      article_x AS x, article_y AS y, 'I' as dir
  FROM        contrib_by_month

  UNION
  
  SELECT      contrib_x AS x, contrib_y AS y, 'O' as dir
  FROM        contrib_by_month
) t
GROUP BY x, y, dir
;

ALTER TABLE contrib_nodes ADD COLUMN node_id serial NOT NULL PRIMARY KEY;
ALTER TABLE contrib_nodes ADD CONSTRAINT ux_contrib_nodes UNIQUE(x, y, dir);
ALTER TABLE contrib_nodes ADD COLUMN geo_point GEOGRAPHY(POINT, 4326);
ALTER TABLE contrib_nodes ADD COLUMN cluster_id integer NOT NULL DEFAULT 0;
ALTER TABLE contrib_nodes ADD COLUMN popdens00 integer;

UPDATE      contrib_nodes n
SET         geo_point = ST_MakePoint(x, y)
;

UPDATE      contrib_nodes n
SET         popdens00 = t.popdens00
FROM        contrib_nodes_popdens00 t
WHERE       n.node_id = t.node_id AND n.dir = t.dir
RETURNING *
;


-- create a table with the line segments for all contributions
DROP TABLE IF EXISTS contrib_paths;
CREATE TABLE contrib_paths AS
SELECT      t1.node_id AS node_id_src,
            t2.node_id AS node_id_dst
FROM        contrib_by_month t
JOIN        contrib_nodes t1 ON (t1.x = t.contrib_x AND t1.y = t.contrib_y AND t1.dir = 'O')
JOIN        contrib_nodes t2 ON (t2.x = t.article_x AND t2.y = t.article_y AND t2.dir = 'I')
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

