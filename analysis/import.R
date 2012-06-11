l <- Sys.getenv('WIKI_LANG', 'da')
cat('processing lang', l, '...\n')
gc()
load('../data/x_contrib_by_month.RData')
gc()
x_contrib_by_month <- subset(x_contrib_by_month, lang == l)
gc()
# x_contrib_by_month <- within(x_contrib_by_month, {
#   lang <- factor(lang)
#   distance_ratio <- distance_km_mean_weighted / distance_km_mean
# })
summary(x_contrib_by_month)

z <- x_contrib_by_month[,c('year','month','article_id','article_x','article_y','contrib_x','contrib_y','contrib_n')]
head(z)

aggregate(year + month ~ contrib_x + contrib_y, data=z)


# m <- lm(distance_km_mean_weighted ~ distance_km_mean, data=d)
# (coef(m)[['distance_km_mean']])
# (summary(m))
# (mean(d$distance_ratio))
# (weighted.mean(d$distance_ratio, w=d$n))
# boxplot(distance_ratio ~ yyyy, data=d)
# plot(distance_km_mean_weighted ~ distance_km_mean, data=d)
# abline(m, col='red')
# hist(d$distance_ratio)
