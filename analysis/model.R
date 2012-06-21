require(reshape)
require(xtable)
require(stringr)

d.lang <- read.table('../lang.txt', header=T)
lang.labels <- as.character(d.lang$name)
names(lang.labels) <- as.character(d.lang$alpha2)

if (FALSE) {
  d.flows <- read.csv('../data/x_contrib_flows_yyyymm.csv')
  head(d.flows)
  results <- list()
  pdf(file='Rplots.pdf', width=7, height=7, onefile=T, pointsize=18)
  for (l in unique(d.flows$lang)) {
    source('model-lang.R')
  }
  save(file='_results.RDdata', results)
  dev.off()
}

# Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1 
pv.to.str <- function(x) {
  if (x < 0.001) {
    '***'
  } else if (x < 0.01) {
    '**'
  } else if (x < 0.05) {
    '*'
  } else if (x < 0.1) {
    '.'
  } else {
    ' '
  }
}
##
#
d.flows <- within(read.csv('data/x_contrib_flows_raw.csv'), {
  log10_d <- log10(d + 1)
  log10_pop_src <- log10(pop_src)
  log10_pop_dst <- ifelse(is.na(pop_dst), log10(pop_dst), 1)
  log10_pop_ratio <- log10_pop_src/log10_pop_dst
})




r <- NULL
rr <- NULL
for (l in sort(lang.labels[unique(levels(d.flows$lang))])) {
  print(l)
  ll <- names(lang.labels)[lang.labels == l]
  print(ll)
  d.lang <- subset(d.flows, lang == ll, select=-lang)
  print(nrow(d.lang))
  dp <- list()
  xlim <- c(0, 1)
  ylim <- c(0, 1)
  for (yr in unique(d.lang$yyyy)) {
    d <- subset(d.lang, yyyy == yr, select=-yyyy)
    k.yr <- as.character(yr)
    if (length(unique(d$mm)) == 12 && nrow(d) >= 100) { # enforce min n=100 and 12 months      
      dp[[k.yr]] <- density(d$log10_d)
      xlim[1] <- min(xlim[1], min(dp[[k.yr]]$x))
      ylim[1] <- min(ylim[1], min(dp[[k.yr]]$y))
      xlim[2] <- max(xlim[2], max(dp[[k.yr]]$x))
      ylim[2] <- max(ylim[2], max(dp[[k.yr]]$y))
      
      
      m <- lm(pop_dst ~ pop_src + log10_d, data=d)
      # print(summary(m))
      rr <- rbind(rr, data.frame(lang=l, yyyy=yr,
            n=nrow(d),
            n.n=sum(d$n),
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
  print(summary(dp))
  m <- lm(pop_dst ~ pop_src + log10_d, data=d.lang)
  # print(summary(m))
  r <- rbind(r, data.frame(lang=l, yyyy=NA,
        n=nrow(d.lang),
        n.n=sum(d.lang$n),
        r2=summary(m)$adj.r.squared, 
        beta.pop_src=summary(m)$coefficients['pop_src','Estimate'], 
        se.pop_src=summary(m)$coefficients['pop_src','Std. Error'], 
        t.pop_src=summary(m)$coefficients['pop_src','t value'], 
        pv.pop_src=summary(m)$coefficients['pop_src','Pr(>|t|)'], 
        beta.d=summary(m)$coefficients['log10_d','Estimate'], 
        se.d=summary(m)$coefficients['log10_d','Std. Error'], 
        t.d=summary(m)$coefficients['log10_d','t value'], 
        pv.d=summary(m)$coefficients['log10_d','Pr(>|t|)']))
  

  # dm <- matrix(unlist(dp), nrow=(length(unlist(dp))/length(dp)/2)*length(dp), ncol=2, byrow=F)
  if (length(dp) > 1) {
    pdf(file=sprintf('_%s_temporal.pdf', l))
    cat('xlim', xlim, 'ylim', ylim, '\n')
    print(dp[[1]]$x)
    print(dp[[1]]$y)
    plot(x=dp[[1]]$x, dp[[1]]$y, lty=1, xlim=xlim, ylim=ylim, main=l, xlab='', ylab='')
    for (ii in 2:length(dp)) {
      print(dp[[ii]]$x)
      lines(x=dp[[ii]]$x, y=dp[[ii]]$y, pch=20, cex=0.5)
    }
    dev.off()
    
  }
  
  pdf(file=sprintf('_%s.pdf', l))
  
  z <- ifelse(d.lang$pop_dst==0,0,log10(d.lang$pop_src+1) / log10(d.lang$pop_dst + 1))
  z <- na.omit(z)
  plot(density(z), 
      main=l, xlab='Ratio of log10(population density)\n(Contributors:Articles)', ylab='', lwd=2)
  dev.off()

}
r
rr
rownames(r) <- r$lang
rownames(rr) <- paste(rr$lang, rr$yyyy)
write.csv(rbind(r, rr), '_xtable_flows.csv')

r$nr <- r$n.n/r$n
summary(r)
r <- r[order(-r$n),]
r <- r[,c(6,10,14,5)]
summary(r)
xtable(r, digits=3)

rr$nr <- rr$n.n/rr$n
rr <- rr[order(rr$lang, rr$yyyy),]
rr <- rr[,c(6,10,14,5)]
summary(rr)
xtable(rr, digits=3)

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
