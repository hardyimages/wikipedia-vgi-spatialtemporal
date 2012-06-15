\c hardy_db
set role to hardy;

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

\copy contrib_by_month from '../data/x_contrib_by_month.csv' with csv header

select count(*) from contrib_by_month;

drop view if exists v_contrib_by_month_k1;
create view v_contrib_by_month_k1 as
SELECT    yyyy, mm, lang, 
          1.0*round(article_x/1.0) AS article_x,
          1.0*round(article_y/1.0) AS article_y,
          1.0*round(contrib_x/1.0) AS contrib_x,
          1.0*round(contrib_y/1.0) AS contrib_y,
          SUM(contrib_n) AS contrib_n,
          COUNT(*) AS article_n
FROM      contrib_by_month
GROUP BY  yyyy, mm, lang, 
          1.0*round(article_x/1.0), 
          1.0*round(article_y/1.0), 
          1.0*round(contrib_x/1.0), 
          1.0*round(contrib_y/1.0)
;








drop table if exists contrib_by_month_k1;
create table contrib_by_month_k1 as
SELECT    yyyy, mm, lang, 
          1.0*round(article_x/1.0) AS article_x,
          1.0*round(article_y/1.0) AS article_y,
          1.0*round(contrib_x/1.0) AS contrib_x,
          1.0*round(contrib_y/1.0) AS contrib_y,
          SUM(contrib_n) AS contrib_n,
          COUNT(*) AS article_n
FROM      contrib_by_month
GROUP BY  yyyy, mm, lang, 
          1.0*round(article_x/1.0), 
          1.0*round(article_y/1.0), 
          1.0*round(contrib_x/1.0), 
          1.0*round(contrib_y/1.0)
;

ALTER TABLE contrib_by_month_k1 ADD PRIMARY KEY (yyyy, mm, lang, article_x, article_y, contrib_x, contrib_y);


drop table if exists contrib_by_month_k5;
create table contrib_by_month_k5 as
SELECT    yyyy, mm, lang, 
          5.0*round(article_x/5.0) AS article_x,
          5.0*round(article_y/5.0) AS article_y,
          5.0*round(contrib_x/5.0) AS contrib_x,
          5.0*round(contrib_y/5.0) AS contrib_y,
          SUM(contrib_n) AS contrib_n,
          COUNT(*) AS article_n
FROM      contrib_by_month
GROUP BY  yyyy, mm, lang, 
          5.0*round(article_x/5.0), 
          5.0*round(article_y/5.0), 
          5.0*round(contrib_x/5.0), 
          5.0*round(contrib_y/5.0)
;

ALTER TABLE contrib_by_month_k5 ADD PRIMARY KEY (yyyy, mm, lang, article_x, article_y, contrib_x, contrib_y);


drop table if exists contrib_by_month_k10;
create table contrib_by_month_k10 as
SELECT    yyyy, mm, lang, 
          10.0*round(article_x/10.0) AS article_x,
          10.0*round(article_y/10.0) AS article_y,
          10.0*round(contrib_x/10.0) AS contrib_x,
          10.0*round(contrib_y/10.0) AS contrib_y,
          SUM(contrib_n) AS contrib_n,
          COUNT(*) AS article_n
FROM      contrib_by_month
GROUP BY  yyyy, mm, lang, 
          10.0*round(article_x/10.0), 
          10.0*round(article_y/10.0), 
          10.0*round(contrib_x/10.0), 
          10.0*round(contrib_y/10.0)
;

ALTER TABLE contrib_by_month_k10 ADD PRIMARY KEY (yyyy, mm, lang, article_x, article_y, contrib_x, contrib_y);


