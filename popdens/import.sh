rast=data/gldens00.tif
nodes=data/x_contrib_nodes.csv
glnodes=data/gl_contrib_nodes.csv

#gdalinfo -nomd -noct $rast

echo 'x,y,z' > $glnodes
cut -d, -f 1-2 < $nodes | tail -n +2 | tr , ' ' |
    cs2cs `cat wgs84.proj4` +to `cat mollweide.proj4` | tr '[:blank:]' ,  >> $glnodes

echo "converted `wc -l $glnodes` coordinate points"

