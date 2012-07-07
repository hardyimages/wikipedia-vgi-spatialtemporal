cat('loading...\n')
d <- read.table(gzfile('data/x_contrib_by_month.txt.gz', open='r'), header=T)
nrow(d)
for (k in levels(d$lang)) {
  d.lang <- subset(d, lang==k)
  cat('processing', k, nrow(d.lang), '...\n')
  save(d.lang, file=sprintf('data/d.lang.%s.RData', k))
}
