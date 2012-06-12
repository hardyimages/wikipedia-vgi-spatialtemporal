require(reshape)

d.flows <- read.csv('data/x_contrib_flows_yyyymm.csv')
head(d.flows)
results <- list()
for (l in unique(d.flows$lang)) {
  source('model-lang.R')
}
p <- cast(L1 ~ L2, data=melt(results))
names(p)[1] <- 'lang'
p