\c hardy_dev


drop table if exists contrib_flow_summary;
CREATE TABLE contrib_flow_summary AS
select      lang,
            yyyy,
            mm,
            count(*)        AS n, 
            sum(contrib_n)  AS n_contrib,
            count(distinct(article_x, article_y)) AS n_dst_xy,
            count(distinct(contrib_x, contrib_y)) AS n_src_xy
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
where       lang = 'zh' and yyyy = 2006
group by    lang, yyyy, mm 
order by    lang, yyyy, mm;  
 
