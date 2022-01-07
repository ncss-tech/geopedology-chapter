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
table(x$taxonname)
table(x$taxonkind)

x$taxonname <- toupper(x$taxonname)
z <- subset(x, taxonname == 'CLARKSVILLE' & taxonkind %in% c('series', 'taxadjunct'))
length(z)

table(z$taxsubgrp)

# remove any with taxonname that don't fit the series classification
z <- subset(z, taxsubgrp == 'typic paleudults')
length(z)

table(z$taxpartsize)

# remove any with taxonname that don't fit the series classification
z <- subset(z, taxpartsize == 'loamy-skeletal')
length(z)

# pedons described to 150cm or greater - series is very deep
n.d <- profileApply(z, estimateSoilDepth, name = 'hzname')
idx <- which(n.d >=150)
length(idx)
z <- z[idx, ]

# remove all that do not have hillslopeprof assigned
idx <- which(!is.na(z$hillslopeprof))
z <- z[idx, ]
length(z)

# remove all that do not have geomposhill assigned
idx <- which(!is.na(z$geomposhill))
z <- z[idx, ]
length(z)

# remove all that have null landform info
idx <- which(!is.na(z$landform_string))
z <- z[idx, ]
length(z)

# remove all that have null pmkind info
idx <- which(!is.na(z$pmkind))
z <- z[idx, ]
length(z)

# remove all that have null pmorigin info
idx <- which(!is.na(z$pmorigin))
z <- z[idx, ]
length(z)

# remove all that have null coordinate info
idx <- which(!is.na(z$x_std))
z <- z[idx, ]
length(z)

table(z$pedonpurpose)
table(z$pedontype)  

#remove those tagged with pedontype == 'map unit inclusion', 'taxadjunct to the series', 'undefined observation'
idx <- which(z$pedontype %in% c('map unit inclusion', 'taxadjunct to the series', 'undefined observation'))
z <- z[-idx, ]
length(z)

table(z$taxonkind)

#remove any with taxonkind of 'taxadjunct'
idx <- which(z$taxonkind == 'taxadjunct')
z <- z[-idx, ]
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

#par(mar = c(0, 0, 0, 0))
#plotSPC(z[1:10, ])


# full set of data: color, horizon designations, fine earth texture class
# 395
z$missing.data.summary <- evalMissingData(z, name = hzdesgnname(z), vars = c('moist_soil_color', hzdesgnname(z), 'texture_class'))
summary(z$missing.data.summary)

z <- subset(z, missing.data.summary == 1)
length(z)

#par(mar = c(0, 0, 0, 0))
#plotSPC(z)

# remove pedon that appears to lack surface horizon depths
idx <- which(site(z)$peiid == 1414336)
z <- z[-idx, ]
length(z)

# remove pedon in AR and go with all pedons from MO
idx <- which(site(z)$site_id == "1984AR101004")
z <- z[-idx, ]
length(z)

# still have some ambiguous info in pmorigin - clean out any of these pedons
idx <- which(z$pmorigin %in% c('NA'))
z <- z[-idx, ]
length(z)

# remove lab pedon with dup pedons in the system
idx <- which(site(z)$pedlabsampnum == "M0502305")
z <- z[-idx, ]
length(z)

par(mar = c(0, 0, 0, 0))
plotSPC(z)




# lab pedons
# 167 (including copies)
zz <- subset(z, !is.na(pedlabsampnum))
length(zz)
plotSPC(zz[1:15, ])



# lab copies: which one to pick?
lab.dupes <- names(which(table(z$pedlabsampnum) > 1))
groupedProfilePlot(subset(z, pedlabsampnum %in% lab.dupes), groups = 'pedlabsampnum', group.name.offset = - 12)
groupedProfilePlot(subset(z, pedlabsampnum %in% lab.dupes), groups = 'pedlabsampnum', group.name.offset = - 12, color = 'clay')



### quick look at some of the data

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

p <- colorChart(m, g = g, chip.cex = 2, size = FALSE, annotate = TRUE)
sf <- 1.75

svglite::svglite(filename = 'colorChart.svg', width = nrow(p) * sf, height = ncol(p) * sf, pointsize = 12)
print(update(p, asp = 1))
dev.off()
