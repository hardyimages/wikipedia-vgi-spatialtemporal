# gc()
# 
# k <- "x_contrib_by_month"
# bin_fn <- file.path('..', 'data', paste(k, "RData", sep = "."))
# load(bin_fn)
# for (l in unique(x_contrib_by_month$lang)) {
#   cat('processing', l, '...\n')
#   d <- subset(x_contrib_by_month, lang == l)
#   print(summary(d))
# }
