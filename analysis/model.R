require(reshape)
require(stringr)
require(mgcv)

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


##
#
d.flows <- read.csv('data/x_contrib_flows_raw.csv')
r <- list()
for (l in unique(levels(d.flows$lang))) {
  d <- subset(d.flows, lang == l, select=-lang)
  m <- gam(pop_dst ~ pop_src + log10(d+1), data=d)
  print(l)
  print(summary(m))
  r[[l]] <- list(model=m, n=nrow(d))
}
r

# lm(formula = pop_dst ~ pop_src + log(d + 1) + 0, data = z)
# 
# Residuals:
#     Min      1Q  Median      3Q     Max 
# -7469.6     6.1   120.7   245.3  8171.8 
# 
# Coefficients:
#             Estimate Std. Error t value Pr(>|t|)    
# pop_src     0.838645   0.001575  532.34   <2e-16 ***
# log(d + 1) 38.003199   0.412388   92.15   <2e-16 ***
# ---
# Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1 
# 
# Residual standard error: 605.9 on 132663 degrees of freedom
#   (6373 observations deleted due to missingness)
# Multiple R-squared: 0.7099, Adjusted R-squared: 0.7099 
# F-statistic: 1.623e+05 on 2 and 132663 DF,  p-value: < 2.2e-16 


d.flows <- within(d.flows, {
  yyyymm <- sprintf('%04d%02d', yyyy, mm)
  yyyy <- NULL
  mm <- NULL
})
d <- melt(d.flows, id.vars=c('lang', 'yyyymm'), variable_name='metric')
p <- cast(lang ~ metric ~ yyyymm, data=d)