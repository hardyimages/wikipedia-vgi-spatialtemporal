require(reshape)
require(xtable)
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
r <- NULL
for (l in unique(levels(d.flows$lang))) {
  d <- subset(d.flows, lang == l, select=-lang)
  d$log10_d <- log10(d$d + 1)
  m <- gam(pop_dst ~ pop_src + log10_d, data=d)
  r <- rbind(r, data.frame(lang=lang.labels[[l]], 
        n=summary(m)$n,
        r2=summary(m)$r.sq, 
        beta.1=coef(m)[['pop_src']], 
        se.1=summary(m)$se[['pop_src']],
        t.1=summary(m)$p.t[['pop_src']],
        pv.1=summary(m)$p.pv[['pop_src']],
        beta.2=coef(m)[['log10_d']], 
        se.2=summary(m)$se[['log10_d']],
        t.2=summary(m)$p.t[['log10_d']],
        pv.2=summary(m)$p.pv[['log10_d']]))
}
rownames(r) <- r$lang
r <- r[order(-r$n),-1]
write.csv(r, '_xtable_flows.csv')
xtable(r, digits=3)

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
