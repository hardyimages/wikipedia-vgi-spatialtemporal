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