require(reshape)
require(xtable)
require(stringr)

d.lang <- read.table('../lang.txt', header=T)
lang.labels <- as.character(d.lang$name)
names(lang.labels) <- str_trim(tolower(as.character(d.lang$alpha2)))

if (FALSE) {
  d.flows <- read.csv('data/x_contrib_flows_yyyymm.csv')
  head(d.flows)
  results <- list()
  pdf(file='Rplots.pdf', width=7, height=7, onefile=T, pointsize=18)
  for (l in unique(d.flows$lang)) {
    source('model-lang.R')
  }
  save(file='_results.RDdata', results)
  dev.off()
}


##
#
d.flows <- read.csv('data/x_contrib_flows_raw.csv')
d.flows$log10_d <- log10(d.flows$d + 1)
r <- NULL
for (l in unique(levels(d.flows$lang))) {
  d.lang <- subset(d.flows, lang == l, select=-lang)
  m <- lm(pop_dst ~ pop_src + log10_d, data=d.lang)
  r <- rbind(r, data.frame(lang=lang.labels[[l]], yyyy=0,
        n=nrow(d.lang),
        r2=summary(m)$adj.r.squared, 
        beta.pop_src=summary(m)$coefficients['pop_src','Estimate'], 
        se.pop_src=summary(m)$coefficients['pop_src','Std. Error'], 
        t.pop_src=summary(m)$coefficients['pop_src','t value'], 
        pv.pop_src=summary(m)$coefficients['pop_src','Pr(>|t|)'], 
        beta.d=summary(m)$coefficients['log10_d','Estimate'], 
        se.d=summary(m)$coefficients['log10_d','Std. Error'], 
        t.d=summary(m)$coefficients['log10_d','t value'], 
        pv.d=summary(m)$coefficients['log10_d','Pr(>|t|)']))
  
  for (yr in unique(d.lang$yyyy)) {
    d <- subset(d.lang, yyyy == yr, select=-yyyy)
    if (length(unique(d$mm)) == 12) {
      m <- lm(pop_dst ~ pop_src + log10_d, data=d)
      r <- rbind(r, data.frame(lang=lang.labels[[l]], yyyy=yr,
            n=nrow(d),
            r2=summary(m)$adj.r.squared, 
            beta.pop_src=summary(m)$coefficients['pop_src','Estimate'], 
            se.pop_src=summary(m)$coefficients['pop_src','Std. Error'], 
            t.pop_src=summary(m)$coefficients['pop_src','t value'], 
            pv.pop_src=summary(m)$coefficients['pop_src','Pr(>|t|)'], 
            beta.d=summary(m)$coefficients['log10_d','Estimate'], 
            se.d=summary(m)$coefficients['log10_d','Std. Error'], 
            t.d=summary(m)$coefficients['log10_d','t value'], 
            pv.d=summary(m)$coefficients['log10_d','Pr(>|t|)']))
    }
  }
}
rownames(r) <- NULL
r <- r[order(r$lang, r$yyyy),]
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
