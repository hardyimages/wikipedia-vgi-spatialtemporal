require(reshape)
require(stringr)
require(ggplot2)

d.lang <- read.table('lang.txt', header=T)
lang.labels <- as.character(d.lang$name)
names(lang.labels) <- str_trim(tolower(as.character(d.lang$alpha2)))
d.flows <- read.csv('data/x_contrib_flows_yyyymm.csv')
d <- merge(d.flows, d.lang[,-1], by.x='lang', by.y='alpha2')

d$name <- factor(d$name)
summary(d)
p <- cast(yyyy + mm ~ name, data=d, value='distance_ratio')
data <- apply.bycol(p, function (x) { as.numeric(na.omit(x))})

plot(density(data$English), main='English', xlab='Distance ratio\n(weighted by contributions : unweighted)')
abline(v=mean(data$English, na.rm=T), lty=2, col='red')


boxplot((p[,3:ncol(p)]), pch=20,
  ylab='Distance ratio\n(weighted by contributions : unweighted)', 
  xlab='', las=3)
abline(h=1.0, lty=2, col='blue')

# pdf(file='Rplots.pdf', width=7, height=7, onefile=T, pointsize=18)
# 
# for (l in unique(d.flows$lang)) {
#   source('model-lang.R')
# }
# save(file='_results.RDdata', results)
# dev.off()