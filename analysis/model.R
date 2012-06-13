require(reshape)
require(stringr)


d.lang <- read.table('../lang.txt', header=T)
lang.labels <- as.character(d.lang$name)
names(lang.labels) <- str_trim(tolower(as.character(d.lang$alpha2)))
d.flows <- read.csv('data/x_contrib_flows_yyyymm.csv')
head(d.flows)
results <- list()
pdf(file='Rplots.pdf', width=7, height=7, onefile=T, pointsize=18)
for (l in unique(d.flows$lang)) {
  source('model-lang.R')
}
save(file='_results.RDdata', results)
dev.off()