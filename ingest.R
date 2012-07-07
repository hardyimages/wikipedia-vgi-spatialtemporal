require(reshape)
load('data/x_contrib_by_month.RData')
d <- cast(lang ~ year + month ~ contrib_x + contrib_y,
	  data=subset(x_contrib_by_month, lang == 'de')[1:1000,])
summary(d)
nrow(d)
d
