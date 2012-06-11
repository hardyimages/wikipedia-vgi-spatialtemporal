l <- Sys.getenv('WIKI_LANG', 'en')
cat('processing lang', l, '...\n')

x_contrib_summary <- read.csv('data/x_contrib_summary.csv')
x_contrib_summary <- subset(x_contrib_summary, lang == l & n >= 10 & yyyy >= 2003 & yyyy <= 2008)
x_contrib_summary <- within(x_contrib_summary, {
  lang <- factor(lang)
  distance_ratio <- distance_km_mean_weighted / distance_km_mean
})
summary(x_contrib_summary)

z <- x_contrib_summary[,c('yyyy','mm','n','n_contrib','distance_ratio')]
z
# m <- lm(distance_km_mean_weighted ~ distance_km_mean, data=d)
# (coef(m)[['distance_km_mean']])
# (summary(m))
# (mean(d$distance_ratio))
# (weighted.mean(d$distance_ratio, w=d$n))
# boxplot(distance_ratio ~ yyyy, data=d)
# plot(distance_km_mean_weighted ~ distance_km_mean, data=d)
# abline(m, col='red')
# hist(d$distance_ratio)
