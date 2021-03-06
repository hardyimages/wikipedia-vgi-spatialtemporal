\c hardy_db
set role to hardy;

DROP TABLE if exists contrib_by_month CASCADE;
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

drop table if exists contrib_by_month_k1 CASCADE;
create table contrib_by_month_k1 as
SELECT    yyyy, mm, lang, 
          round(article_x)::integer AS article_x,
          round(article_y)::integer AS article_y,
          round(contrib_x)::integer AS contrib_x,
          round(contrib_y)::integer AS contrib_y,
          contrib_n AS contrib_n
FROM      contrib_by_month
;


drop table if exists contrib_by_month_k5 CASCADE;
create table contrib_by_month_k5 as
SELECT    yyyy, mm, lang, 
          5*round(article_x/5.0)::integer AS article_x,
          5*round(article_y/5.0)::integer AS article_y,
          5*round(contrib_x/5.0)::integer AS contrib_x,
          5*round(contrib_y/5.0)::integer AS contrib_y,
          contrib_n
FROM      contrib_by_month
;


drop table if exists contrib_by_month_k10 CASCADE;
create table contrib_by_month_k10 as
SELECT    yyyy, mm, lang, 
          10*round(article_x/10.0)::integer AS article_x,
          10*round(article_y/10.0)::integer AS article_y,
          10*round(contrib_x/10.0)::integer AS contrib_x,
          10*round(contrib_y/10.0)::integer AS contrib_y,
          contrib_n
FROM      contrib_by_month
;