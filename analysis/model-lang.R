cat('processing lang', l, 'from', nrow(d.flows), 'records...\n')
d <- subset(d.flows, lang == l, select=-lang)
cat('  extracted', nrow(d), 'records for', sum(d$n_contrib), 'contributions...\n')
# [1] "adj.r.squared" "aliased"       "call"          "coefficients" 
# [5] "cov.unscaled"  "df"            "fstatistic"    "r.squared"    
# [9] "residuals"     "sigma"         "terms"        
m <- lm(distance_ratio ~ contrib_ratio, data=d)
cat('  R2', summary(m)$adj.r.squared, '...\n')
cat('  coef', coef(m)[['contrib_ratio']], '...\n')
cat('  cor', cor(d$contrib_ratio, d$distance_ratio), '...\n')
cat('  d.mean', mean(d$distance_ratio), '...\n')
cat('  d.sd', sd(d$distance_ratio), '...\n')
cat('  d.se', sd(d$distance_ratio)/sqrt(length(d$distance_ratio)), '...\n')
cat('  d.n', length(d$distance_ratio), '...\n')

with(d, {
  plot(density(distance_ratio), main=l, xlab='Distance ratio')
  abline(v=mean(distance_ratio), lty=2)
  print(density(distance_ratio))
})

results[[l]] <- list('r2'=summary(m)$adj.r.squared,
     'coef'=coef(m)[['contrib_ratio']],
     'cor'=cor(d$contrib_ratio, d$distance_ratio),
     'd.mean'=mean(d$distance_ratio), 
     'd.sd'=sd(d$distance_ratio), 
     'd.se'=sd(d$distance_ratio)/sqrt(length(d$distance_ratio)), 
     'd.n'=length(d$distance_ratio))
