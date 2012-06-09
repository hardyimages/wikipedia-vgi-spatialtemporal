\c hardy_dev
DROP TABLE if exists contrib_by_month;
CREATE TABLE contrib_by_month (
    yyyy INTEGER,
    mm INTEGER,
    lang CHAR(2),
    article_id INTEGER,
    article_x DOUBLE PRECISION,
    article_y DOUBLE PRECISION,
    contrib_x DOUBLE PRECISION,
    contrib_y DOUBLE PRECISION,
    contrib_n INTEGER
);

\copy contrib_by_month from '../x_contrib_by_month.txt' with delimiter E'\t' csv header

select count(*) from contrib_by_month;


DROP TABLE if exists contrib_flow;
CREATE TABLE contrib_flow (
    lang CHAR(2),
    yyyymm DATE,
    link GEOGRAPHY(LINESTRING, 4326),
    n_contrib INTEGER
);

INSERT INTO contrib_flow
  SELECT    lang,
            (yyyy || '-' || mm || '-01')::date,
            ST_MakeLine(ST_MakePoint(article_x, article_y), ST_MakePoint(contrib_x, contrib_y)),
            contrib_n
  FROM      contrib_by_month
;

DROP TABLE IF EXISTS contrib_nodes;
CREATE TABLE contrib_nodes AS
SELECT      lang, article_x AS x, article_y AS y
FROM        contrib_by_month
GROUP BY    lang, article_x, article_y
;

ALTER TABLE contrib_nodes ADD PRIMARY KEY (lang, x, y);

INSERT INTO contrib_nodes
SELECT      t.lang, contrib_x, contrib_y
FROM        contrib_by_month t
LEFT JOIN   contrib_nodes t1 ON (t1.lang = t.lang AND t.contrib_x = t1.x AND t.contrib_y = t1.y)
WHERE       t1.lang IS NULL
GROUP BY    t.lang, contrib_x, contrib_y
;

ALTER TABLE contrib_nodes ADD COLUMN node_id serial;


DROP TABLE IF EXISTS contrib_paths;
CREATE TABLE contrib_paths AS
SELECT      t.lang,
            t1.node_id AS src,
            t2.node_id AS dst
FROM        contrib_by_month t
JOIN        contrib_nodes t1 ON (t1.x = t.contrib_x AND t1.y = t.contrib_y AND t1.lang = t.lang)
JOIN        contrib_nodes t2 ON (t2.x = t.article_x AND t2.y = t.article_y AND t2.lang = t.lang)
WHERE       t.lang = 'zh'
GROUP BY    t.lang, t1.node_id, t2.node_id
;

ALTER TABLE contrib_paths ADD COLUMN path_id serial NOT NULL;
ALTER TABLE contrib_paths ADD PRIMARY KEY (lang, src, dst);
ALTER TABLE contrib_paths ADD COLUMN src_geom GEOGRAPHY(POINT, 4326);
ALTER TABLE contrib_paths ADD COLUMN dst_geom GEOGRAPHY(POINT, 4326);
ALTER TABLE contrib_paths ADD COLUMN geo GEOGRAPHY(LINESTRING, 4326);
ALTER TABLE contrib_paths ADD COLUMN distance_km DOUBLE PRECISION;


UPDATE    contrib_paths p
SET       src_geom = ST_MakePoint(x, y)
FROM      contrib_nodes n
WHERE     n.lang = p.lang AND n.node_id = p.src
;

UPDATE    contrib_paths p
SET       dst_geom = ST_MakePoint(x, y)
FROM      contrib_nodes n
WHERE     n.lang = p.lang AND n.node_id = p.dst
;

-- UPDATE    contrib_paths p
-- SET       geo = ST_MakeLine(ST_MakePoint(ST_X(src_geom), ST_Y(src_geom)),
--                             ST_MakePoint(ST_X(dst_geom), ST_Y(dst_geom)))
-- ;

UPDATE    contrib_paths p
SET       distance_km = ST_Distance(src_geom, dst_geom)/1000.0
;


DROP TABLE IF EXISTS contrib_flows;
CREATE TABLE contrib_flows AS
SELECT        t.lang, t.yyyy, t.mm, p1.path_id, SUM(t.contrib_n) AS n, COUNT(*) AS n_flow
FROM          contrib_by_month as t
JOIN          contrib_nodes t1 ON (t1.x = t.contrib_x AND t1.y = t.contrib_y AND t1.lang = t.lang)
JOIN          contrib_nodes t2 ON (t2.x = t.article_x AND t2.y = t.article_y AND t2.lang = t.lang)
JOIN          contrib_paths p1 ON (p1.lang = t.lang AND p1.src = t1.node_id AND p1.dst = t2.node_id)
GROUP BY      t.lang, t.yyyy, t.mm, p1.path_id
;

ALTER TABLE contrib_flows ADD PRIMARY KEY (lang, yyyy, mm, path_id);
ALTER TABLE contrib_flows ADD COLUMN flow_id serial NOT NULL;

drop table if exists contrib_flow_summary;
CREATE TABLE contrib_flow_summary AS
select      lang,
            yyyy,
            mm,
            count(*)        AS n_edge, 
            sum(contrib_n)  AS n_contrib,
            count(distinct(article_x, article_y)) AS n_xy
from        contrib_by_month 
group by    lang, yyyy, mm 
order by    lang, yyyy, mm; 



select      lang,
            yyyy,
            mm,
            sum(n) AS n_contribs,
            sum(n_flow) AS n_trips,
            count(*) AS n_paths
from        contrib_flows cf 
group by    lang, yyyy, mm 
order by    lang, yyyy, mm;  
 
