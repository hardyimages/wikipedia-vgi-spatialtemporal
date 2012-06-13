cat('processing lang', l, 'from', nrow(d.flows), 'records...\n')
d <- subset(d.flows, lang == l, select=-lang)
names(d)
cat('  extracted', nrow(d), 'records for', sum(d$n_contrib), 'contributions...\n')
# [1] "adj.r.squared" "aliased"       "call"          "coefficients" 
# [5] "cov.unscaled"  "df"            "fstatistic"    "r.squared"    
# [9] "residuals"     "sigma"         "terms"        
m <- lm(distance_ratio ~ contrib_ratio, data=d)
print(summary(m))
cat('  R2', summary(m)$adj.r.squared, '...\n')
cat('  coef', coef(m)[['contrib_ratio']], '...\n')
cat('  cor', cor(d$contrib_ratio, d$distance_ratio), '...\n')
cat('  d.mean', mean(d$distance_ratio), '...\n')
cat('  d.sd', sd(d$distance_ratio), '...\n')
cat('  d.se', sd(d$distance_ratio)/sqrt(length(d$distance_ratio)), '...\n')
cat('  d.n', length(d$distance_ratio), '...\n')

with(d, {
  plot(density(distance_ratio), main=lang.labels[[l]], xlab='Distance ratio per month')
  abline(v=mean(distance_ratio), lty=2)
  mtext(sprintf('mean = %0.3f +/- %0.3f SE (n = %d; %d - %d)', 
                mean(distance_ratio), 
                sd(distance_ratio)/sqrt(length(distance_ratio)), 
                length(distance_ratio),
                min(yyyy), max(yyyy)), 3, cex=0.8)
  print(density(distance_ratio))
})

with(d, {
  plot(density(contrib_ratio), main=lang.labels[[l]], xlab='Contribution ratio per month')
  abline(v=mean(contrib_ratio), lty=2)
  mtext(sprintf('mean = %0.3f +/- %0.3f SE (n = %d; %d - %d)\ntotal contributions = %d', 
                mean(contrib_ratio), 
                sd(contrib_ratio)/sqrt(length(contrib_ratio)), 
                length(contrib_ratio),
                min(yyyy), max(yyyy), sum(n_contrib)), 3, cex=0.8)
  print(density(contrib_ratio))
})

results[[l]] <- list('r2'=summary(m)$adj.r.squared,
     'coef'=coef(m)[['contrib_ratio']],
     'cor'=cor(d$contrib_ratio, d$distance_ratio),
     'd.mean'=mean(d$distance_ratio), 
     'd.sd'=sd(d$distance_ratio), 
     'd.se'=sd(d$distance_ratio)/sqrt(length(d$distance_ratio)), 
     'd.n'=length(d$distance_ratio))
