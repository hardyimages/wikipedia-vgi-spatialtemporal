# load data sets and convert into binary data frames
require(utils)
gc()
t <- factor(sort(sprintf("%04d-%02d-01", rep(2003:2007, 12), rep(1:12, 5))), ordered=T)
for (k in c("x_article_signatures", "x_contrib_by_month", "x_geoip_cache")) {
  bin_fn <- file.path('..', 'data', paste(k, "RData", sep = "."))
  csv_fn <- file.path('..', 'data', paste(k, "csv", sep = "."))
  txt_fn <- file.path('..', paste(k, "txt", sep="."))
  if (!file.exists(bin_fn) || file_test("-nt", txt_fn, bin_fn)) {
    cat("processing", k, "...\n")
    assign(k, read.delim(txt_fn))
    if (all(c('year','month') %in% names(get(k)))) {
        assign(k, within(get(k), {
            t_date <- sprintf("%04d-%02d-%02d", year, month, 1)
            t <- factor(t_date, ordered=T)
        }))
        assign(k, get(k)[order(with(get(k), t, lang, article_id)),])
        save(list = c(k), file = bin_fn)
        write.csv(get(k)[,1:9], csv_fn, row.names=F)
    } else {
        save(list = c(k), file = bin_fn)
        write.csv(get(k), csv_fn, row.names=F)
    }
    assign(k, NULL)
  }
  stopifnot(file.exists(bin_fn))
}
gc()

