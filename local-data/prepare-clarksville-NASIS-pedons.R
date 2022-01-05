library(aqp)
library(soilDB)

## All clarksville pedons
# x <- fetchNASIS(from = 'pedons', SS = TRUE, rmHzErrors = TRUE, nullFragsAreZero = TRUE, soilColorState = 'moist', lab = FALSE, fill = FALSE)

# saveRDS(x, file = 'clarksville-all-pedons.rds')

## read local copy
x <- readRDS(file = 'clarksville-all-pedons.rds')


# 1208
length(x)

## filtering / subset / cleaning

# normalize / subset taxonname
# 902
table(x$taxonname)
table(x$taxonkind)

x$taxonname <- toupper(x$taxonname)
z <- subset(x, taxonname == 'CLARKSVILLE' & taxonkind %in% c('series', 'taxadjunct'))
length(z)


# keep only those profiles with > 3 horizons 
# 739
n.hz <- profileApply(z, nrow)
idx <- which(n.hz > 3)
length(idx)
z <- z[idx, ]

# unique profiles
# 620
v <- c(horizonDepths(z), hzdesgnname(z))
z <- unique(z, vars = v, SPC = TRUE)
length(z)

par(mar = c(0, 0, 0, 0))
plotSPC(z[1:10, ])


# full set of data: color, horizon designations, fine earth texture class
# 395
z$missing.data.summary <- evalMissingData(z, name = hzdesgnname(z), vars = c('moist_soil_color', hzdesgnname(z), 'texture_class'))
summary(z$missing.data.summary)

z <- subset(z, missing.data.summary == 1)
length(z)

par(mar = c(0, 0, 0, 0))
plotSPC(z[1:20, ])




# lab pedons
# 167 (including copies)
zz <- subset(z, !is.na(pedlabsampnum))
length(zz)
plotSPC(zz[1:15, ])



# lab copies: which one to pick?
lab.dupes <- names(which(table(z$pedlabsampnum) > 1))
groupedProfilePlot(subset(z, pedlabsampnum %in% lab.dupes), groups = 'pedlabsampnum', group.name.offset = - 12)
groupedProfilePlot(subset(z, pedlabsampnum %in% lab.dupes), groups = 'pedlabsampnum', group.name.offset = - 12, color = 'clay')




previewColors(zz$moist_soil_color, method = 'MDS', pt.cex = 1.5)
title('Clarksville Soil Colors')


x$genhz <- generalize.hz(x$hzname, c('A', 'E', 'Bt', '2Bt', '3Bt'), pat=c('A', 'E', '^Bt', '2B', '3B'), non.matching.code = NA)
x$genhz <- factor(x$genhz, levels = guessGenHzLevels(x, "genhz")$levels)

table(x$genhz, useNA = 'always')

# prepare vectors of Munsell chips + groups (generalized horizon labels)
m <- paste0(x$m_hue, ' ', x$m_value, '/', x$m_chroma)
g <- x$genhz

colorChart(m, g = g, chip.cex = 2)
colorChart(m, g = g, chip.cex = 2, size = FALSE, annotate = TRUE)

