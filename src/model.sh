# export PGDATABASE=hardy_dev
# 
# echo '\copy (select distinct yyyy, mm, lang from contrib_by_month order by lang, yyyy, mm) to stdout with csv header' | psql -Xq | while read x; do
#     y=`echo $x | cut -d, -f1`
#     m=`echo $x | cut -d, -f2`
#     l=`echo $x | cut -d, -f3`
#     echo running $y $m $l
#     psql -Xq << EOM
# \! test -d ../data/${l} || mkdir ../data/${l}
# \o ../data/${l}/contrib_by_month_${l}_${y}_${m}.csv
# copy (select * from contrib_by_month where yyyy = $y and mm = $m and lang = '$l') to stdout with csv header
# EOM
# done
