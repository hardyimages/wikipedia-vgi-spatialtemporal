results <- list()
d.flows <- read.csv('../data/x_contrib_flows_yyyymm.csv')
head(d.flows)
for (l in unique(d.flows$lang)) {
  cat('processing lang', l, '...\n')
  d <- subset(d.flows, lang == l, select=-lang)

  m <- lm(distance_ratio ~ contrib_ratio, data=d)
  print(summary(m))

  plot(distance_ratio ~ contrib_ratio, data=d, pch=20, col='black', cex=1.5,
       main=l, xlab='Contributions per path', ylab='Weighted distance over mean distance')
  abline(m, col='red')

  # [1] "adj.r.squared" "aliased"       "call"          "coefficients" 
  # [5] "cov.unscaled"  "df"            "fstatistic"    "r.squared"    
  # [9] "residuals"     "sigma"         "terms"        
  print(summary(m)$coefficients)  
  mtext(sprintf("R2=%0.3f beta=%0.3f +- %0.3f n=%d", 
                summary(m)$adj.r.squared, 
                summary(m)$coefficients[2,1], 
                summary(m)$coefficients[2,2],
                nrow(d)), 3)
}
results
