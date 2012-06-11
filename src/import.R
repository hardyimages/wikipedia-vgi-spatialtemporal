# # load data sets and convert into binary data frames
# gc()
# for (k in c("x_article_signatures", "x_contrib_by_month", "x_geoip_cache")) {
#   bin_fn <- file.path('..', 'data', paste(k, "RData", sep = "."))
#   csv_fn <- file.path('..', 'data', paste(k, "csv", sep = "."))
#   txt_fn <- file.path('..', paste(k, "txt", sep="."))
#   if (!file.exists(bin_fn) || file_test("-nt", txt_fn, bin_fn)) {
#     cat("processing", k, "...\n")
#     assign(k, read.delim(txt_fn))
#     save(list = c(k), file = bin_fn)
#     write.csv(get(k), csv_fn, row.names=F)
#   }
#   stopifnot(file.exists(bin_fn))
# }
# gc()
# 
# k <- "x_contrib_by_month"
# bin_fn <- file.path('..', 'data', paste(k, "RData", sep = "."))
# load(bin_fn)
# for (l in unique(x_contrib_by_month$lang)) {
#   cat('processing', l, '...\n')
# }
