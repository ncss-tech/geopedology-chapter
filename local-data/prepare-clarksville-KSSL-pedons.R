library(aqp)
library(soilDB)

## read local copy
x <- readRDS(file = 'clarksville-all-KSSL.rds')

# normalize / subset taxonname
# 166
table(x$taxonname)

# keep only those profiles with > 3 horizons 
# 165
n.hz <- profileApply(x, nrow)
idx <- which(n.hz > 3)
length(idx)
x <- x[idx, ]

# unique profiles
# 165
v <- c(horizonDepths(x), hzdesgnname(x))
x <- unique(x, vars = v, SPC = TRUE)
length(x)

# depth errors
# 147
z <- HzDepthLogicSubset(x, byhz = FALSE)
length(z)

# most horizons contain key soil properties
# 100
z$missing.data.summary <- evalMissingData(z, name = 'hzn_desgn', vars = c('sand', 'clay', 'estimated_ph_h2o', 'estimated_oc', 'moist_soil_color', 'cec7'))
summary(z$missing.data.summary)

z <- subset(z, missing.data.summary == 1)
length(z)

par(mar = c(0, 0, 3, 0))
plotSPC(z[1:60, ], color = 'moist_soil_color', name = NA, print.id = FALSE)
plotSPC(z[1:60, ], color = 'clay', name = NA, print.id = FALSE)
plotSPC(z[1:60, ], color = 'estimated_oc', name = NA, print.id = FALSE)
plotSPC(z[1:60, ], color = 'cec7', name = NA, print.id = FALSE)

## save
saveRDS(z, file = 'clarksville-KSSL-subset.rds')


