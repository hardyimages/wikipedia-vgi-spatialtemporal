# this writes jflowview outputs
##
#   year month lang article_id article_x article_y contrib_x contrib_y contrib_n
# 1 2004    10   no         65      11.4      48.8      11.8      60.7         1
# 2 2004    10   no        140       5.6      58.7       5.7      58.7         4
# 3 2004    10   no        173     -53.0     -10.6      10.4      59.3         1
# 4 2004    10   no        185      14.4      67.3      11.8      60.7         1
# 5 2004    10   no        185      14.4      67.3      13.7      66.9         2
# 6 2004    10   no        260      10.2      59.7      10.8      59.9         1
doit <- function(d) {
    nodes <- rbind(data.frame(x=d$article_x, y=d$article_y), data.frame(x=d$contrib_x, y=d$contrib_y))
    nodes <- unique(nodes)
    rownames(nodes) <- NULL
    names(nodes) <- c('Lon','Lat')
    nodes$Code <- paste('N', 1:nrow(nodes), sep='')
    nodes$Name <- paste('Node', 1:nrow(nodes))
    nodes <- nodes[,c(3,4,1,2)]

    find.node.code <- function(lon, lat) {
      nodes$Code[nodes$Lat == lat & nodes$Lon == lon]
    }
    a <- NULL
    b <- NULL
    for (i in 1:nrow(d)) {
       a <- c(a, find.node.code(d$article_x[i], d$article_y[i]))
       b <- c(b, find.node.code(d$contrib_x[i], d$contrib_y[i]))
    }
    edges <- data.frame(Origin=b, Dest=a, Contrib=d$contrib_n)
    list(nodes=nodes, edges=edges)
}

for (lang in c("ca", "cs", "da", "de", "en", "eo", "es", "fi", "fr", "is", "it", "ja", "nl", "no", "pl", "pt", "ru", "sk", "sv", "tr", "zh")) {
    for (yr in 2002:2008 ) {
        for (month in 1:12 ) {
            fn <- sprintf('../data/%s/contrib_by_month_%s_%d_%d.csv', lang, lang, yr, month)
            cat('processing', fn, '...\n')
            if (file.exists(fn)) {
                d <- read.csv(fn)
                ne <- doit(d)
                cat('writing', nrow(ne$nodes), nrow(ne$edges), 'records...\n')
                write.csv(ne$nodes, sprintf('../data/%s/nodes_%s_%d_%d.csv', lang, lang, yr, month), row.names=F, quote=F)
                write.csv(ne$edges, sprintf('../data/%s/edges_%s_%d_%d.csv', lang, lang, yr, month), row.names=F, quote=F)
                ne <- NULL
            }
        }
    }
}
