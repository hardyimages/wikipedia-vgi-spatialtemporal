l <- Sys.getenv('WIKI_LANG', 'en')
cat('processing lang', l, '...\n')

d <- read.csv('../data/x_contrib_flows_yyyymm.csv')
d <- subset(d, lang == l)
summary(d)

m <- lm(distance_mean_weighted ~ distance_mean, data=d)
summary(m)

plot(distance_mean ~ distance_mean_weighted, data=d, xlim=c(min(d[,5:6]), max(d[,5:6])))
abline(m, col='red')
abline(a = 0, b = 1, col='blue')

m<- lm(distance_ratio ~ contrib_ratio, data=d)
summary(m)
plot(distance_ratio ~ contrib_ratio, data=d)
