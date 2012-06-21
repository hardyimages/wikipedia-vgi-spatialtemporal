require(ohi)
require(foreign)
options(width=60)


d <- read.dbf('data/gl_contrib_nodes_dens00.dbf')
names(d) <- tolower(names(d))
stopifnot(max(d$join_count) == 1)
stopifnot(min(d$count) == 1 && max(d$count) == 1)
# names(d)
#  [1] "join_count" "target_fid" "x"          "y"         
#  [5] "dir"        "count"      "node_id"    "cluster_id"
#  [9] "id"         "gridcode"  

d <- d[,c('node_id','x','y','dir','count','gridcode','join_count')]
d <- d[order(d$node_id),]
names(d)[6] <- 'popdens00'
d$popdens00[d$join_count == 0] <- NA
d$join_count <- NULL
d$count <- NULL
summary(d)
nrow(d)
ohi.write.csv(d, 'data/contrib_nodes_popdens00.csv')
