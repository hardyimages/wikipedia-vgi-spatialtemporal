require(reshape)
require(stringr)
require(ggplot2)

d.lang <- read.table('../lang.txt', header=T)
lang.labels <- as.character(d.lang$name)
names(lang.labels) <- str_trim(tolower(as.character(d.lang$alpha2)))
d.flows <- read.csv('../data/x_contrib_flows_yyyymm.csv')
d <- merge(d.flows, d.lang[,-1], by.x='lang', by.y='alpha2')

d$name <- factor(d$name)
summary(d)
# p <- cast(yyyy + mm ~ name, data=d, value='distance_ratio')
# data <- apply.bycol(p, function (x) { as.numeric(na.omit(x))})
# 
# plot(density(data$English), main='English', xlab='Distance ratio\n(weighted by contributions : unweighted)')
# abline(v=mean(data$English, na.rm=T), lty=2, col='red')
# 
# 
# boxplot((p[,3:ncol(p)]), pch=20,
#   ylab='Distance ratio\n(weighted by contributions : unweighted)', 
#   xlab='', las=3)
# abline(h=1.0, lty=2, col='blue')

gp <- ggplot(d, aes(x=name, y=distance_ratio)) + geom_boxplot()
gp <- gp + scale_y_continuous("Distance ratio\nweighted by contributions : unweighted")
gp <- gp + scale_x_discrete("Language")
gp <- gp + opts(axis.text.x=theme_text(angle=90, size=8, hjust=1))
plot(gp)
