l <- Sys.getenv('WIKI_LANG', 'en')
cat('processing lang', l, '...\n')

d <- read.csv('../data/x_contrib_flows.csv')
d <- subset(d, lang == l)
d <- within(d, {
  distance_ratio <- distance_mean_weighted / distance_mean
})
summary(d)

m <- lm(distance_mean_weighted ~ distance_mean, data=d)
summary(m)

plot(distance_mean ~ distance_mean_weighted, data=d, xlim=c(min(d[,5:6]), max(d[,5:6])))
abline(m, col='red')
abline(a = 0, b = 1, col='blue')
