test -d data || mkdir data

for fn in ../data/x_contrib_{summary,flows,nodes,paths}.csv.gz; do
    cp $fn data
done
gunzip -v data/*.gz
