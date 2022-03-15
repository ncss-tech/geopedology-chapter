
# inspiration: http://ncss-tech.github.io/AQP/aqp/genhz-distance-eval.html

# more ideas: http://ncss-tech.github.io/AQP/soilDB/competing-series.html

library(aqp)
library(soilDB)
library(sharpshootR)
library(cluster)
library(dendextend)
library(svglite)

## pre-cached/subset data
x <- readRDS('../local-data/clarksville-pedons-final.rds')

# clean-up: remove profiles with gaps in logical horizon sequence
x <- x[-c(13:14), ]

x <- x[1:20, ]

x$hzd <- hzDistinctnessCodeToOffset(x$bounddistinct)

x <- trunc(x, 0, 175)

par(mar = c(0, 0, 0, 0))
plotSPC(x[1:10,], hz.distinctness.offset = 'hzd', print.id = FALSE, name.style = 'center-center', cex.names = 0.66, width = 0.3, plot.depth.axis = FALSE, x.idx.offset = 0.25, hz.depths = TRUE, hz.depths.offset = 0.08, fixLabelCollisions = TRUE)



par(mar = c(0, 0, 3, 0))
plotSPC(x, color = 'genhz', col.label = 'Generalized Horizon Label', hz.distinctness.offset = 'hzd', print.id = FALSE, name.style = 'center-center', cex.names = 0.66, width = 0.4, cex.depth.axis = 0.75, axis.line.offset = -4.5, max.depth = 175, n.depth.ticks = 8)


# depth to first 3Bt4 genhz
# 0cm if missing
z.1 <- depthOf(x, pattern = '3Bt4', hzdesgn = 'genhz', no.contact.assigned = 0, top = TRUE, FUN = min)

# depth to first 2Bt3 genhz
# 0cm if missing
z.2 <- depthOf(x, pattern = '2Bt3', hzdesgn = 'genhz', no.contact.assigned = 0, top = TRUE, FUN = min)

# ordering based on both criteria
idx <- order(z.1$hzdept, z.2$hzdept)

# check
par(mar = c(0, 0, 3, 0))
plotSPC(x, color = 'genhz', col.label = 'Generalized Horizon Label', hz.distinctness.offset = 'hzd', print.id = FALSE, name.style = 'center-center', cex.names = 0.66, width = 0.4, cex.depth.axis = 0.75, axis.line.offset = -4.5, max.depth = 175, n.depth.ticks = 8, plot.order = idx)




## GHL figure

svglite::svglite(filename = 'figures/sketch-demo.svg', width = 10, height = 5)

par(mar = c(0, 0, 3, 0))

plotSPC(x, color = 'genhz', col.label = 'Generalized Horizon Label', hz.distinctness.offset = 'hzd', print.id = FALSE, name.style = 'center-center', cex.names = 0.66, width = 0.4, cex.depth.axis = 0.75, axis.line.offset = -4.5, max.depth = 175, n.depth.ticks = 8, plot.order = idx, y.offset = -15)

dev.off()


##
### num. taxonomy figures here
##


d <- profile_compare(x, vars = c('genhz', 'genhz'),  max_d = 175, k = 0, rescale.result = TRUE)

# divisive hierarchical clustering
h <- as.hclust(diana(d))

# attempt sorting dendrogram by depth to genhz
h <- dendextend::rotate(h, order = idx)


svglite::svglite(filename = 'figures/genhz-dendrogram.svg', width = 10, height = 5.5)

par(mar = c(0, 0, 3, 1))

plotProfileDendrogram(x, clust = h, scaling.factor = 0.008, y.offset = 0.05, color = 'genhz', col.label = 'Generalized Horizon Label', print.id = FALSE, name.style = 'center-center', cex.names = 0.66, width = 0.4, cex.depth.axis = 0.75, axis.line.offset = -2.75, max.depth = 175, n.depth.ticks = 8)

!dev.off()



## OSD soil taxonomy

## too messy

# sib <- siblings('Clarksville')
# s <- c('Clarksville', sib$sib$sibling)
# 
# x <- fetchOSD(s)
# x <- subset(x, soilorder != 'alfisols')

## use series from catena figure + some additional siblings of clarksville
s <- c(
  c("Clarksville", "Firebaugh", "Gepp", "Goss", "Poynor", "Scholten", "Taterhill", "Tilk"),
  c("Lee", "LOWASSIE", "CEDARGAP")
)

## use Clarksville + couple of pals, other colorful soils
s <- c("Clarksville", "Lee", "Lowassie", "Zook", "Leon", "Musick", "Tristan")

x <- fetchOSD(s)
x$hzd <- hzDistinctnessCodeToOffset(x$distinctness)


svglite(filename = 'figures/OSD-ST-dendrogram.svg', width = 10, height = 5.5)

SoilTaxonomyDendrogram(x, cex.taxon.labels = 0.75, width = 0.33, name.style = 'center-center', plot.depth.axis = TRUE, hz.distinctness.offset = 'hzd', axis.line.offset = -3.5, n.depth.ticks = 8, cex.names = 0.66)

dev.off()


## this won't work so well with soils of drastically different depths

## OSD color via d(L,A,B)

.lab <- munsell2rgb(x$hue, x$value, x$chroma, returnLAB = TRUE)
x$L <- .lab$L
x$A <- .lab$A
x$B <- .lab$B

d <- profile_compare(x, vars = c('L', 'A', 'B'),  max_d = 150, k = 0, rescale.result = TRUE)

# divisive hierarchical clustering
h <- as.hclust(diana(d))

## TODO: do these colors look OK? CIE2000 may have been a better approach..

svglite(filename = 'figures/OSD-soil-color-dendrogram.svg', width = 10, height = 5.5)

par(mar = c(0, 0, 0, 1.5))

plotProfileDendrogram(x, clust = h, scaling.factor = 0.007, y.offset = 0.125, color = 'soil_color', hz.distinctness.offset = 'hzd', name.style = 'center-center', cex.names = 0.66, width = 0.35, cex.id = 0.75, cex.depth.axis = 0.75, axis.line.offset = -2.75, n.depth.ticks = 8)

# abline(h = 150)

dev.off()


# 
# # plotProfileDendrogram(x, clust = h, scaling.factor = 0.008, y.offset = 0.05, color = 'hurst.redness', col.label = 'Generalized Horizon Label', hz.distinctness.offset = 'hzd', print.id = FALSE, name.style = 'center-center', cex.names = 0.66, width = 0.4, cex.depth.axis = 0.75, axis.line.offset = -2.75, max.depth = 175, n.depth.ticks = 8)
# 
# 
# 
# 
# 
# 
# par(mar = c(0, 0, 3, 1))
# plotProfileDendrogram(x, clust = h, scaling.factor = 0.009, y.offset = 0.05, color = 'genhz', width = 0.4, name.style = 'center-center', col.label = 'Generalized Horizon Label', name = NA, print.id = FALSE, axis.line.offset = -2.25, cex.depth.axis = 0.66)
# 
# plotProfileDendrogram(x, clust = h, scaling.factor = 0.009, y.offset = 0.05, color = 'hurst.redness', width = 0.4, name.style = 'center-center', col.label = 'Hurst Redness Index', name = NA, print.id = FALSE, axis.line.offset = -2.25, cex.depth.axis = 0.66)
# 
# plotProfileDendrogram(x, clust = h, scaling.factor = 0.009, y.offset = 0.05, width = 0.4, name.style = 'center-center', color = 'genhz', col.label = 'Generalized Horizon Label', name = NA, print.id = FALSE, axis.line.offset = -2.25, cex.depth.axis = 0.66)
# 
# plotSPC(x, color = 'genhz', width = 0.4, name.style = 'center-center', col.label = 'Generalized Horizon Label', name = NA, print.id = FALSE, axis.line.offset = -2.25, cex.depth.axis = 0.66, plot.order = h$order)
# 
# 
# # groupedProfilePlot(x, groups = 'hillslopeprof', color = 'genhz', width = 0.3, name.style = 'center-center', col.label = 'Generalized Horizon Label', name = NA, print.id = FALSE, axis.line.offset = -2.25, cex.depth.axis = 0.66)

