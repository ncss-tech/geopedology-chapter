
# inspiration: http://ncss-tech.github.io/AQP/aqp/genhz-distance-eval.html

# more ideas: http://ncss-tech.github.io/AQP/soilDB/competing-series.html

library(aqp)
library(sharpshootR)
library(cluster)
library(dendextend)

## pre-cached/subset data
x <- readRDS('clarksville-pedons-final.rds')

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
z <- depthOf(x, pattern = '2Bt', hzdesgn = 'genhz', no.contact.assigned = 0, top = TRUE, FUN = min)

idx <- order(z$hzdept)

par(mar = c(0, 0, 3, 0))
plotSPC(x, color = 'genhz', col.label = 'Generalized Horizon Label', hz.distinctness.offset = 'hzd', print.id = FALSE, name.style = 'center-center', cex.names = 0.66, width = 0.4, cex.depth.axis = 0.75, axis.line.offset = -4.5, max.depth = 175, n.depth.ticks = 8, plot.order = idx)



d <- profile_compare(x, vars = c('genhz', 'genhz'),  max_d = 175, k = 0, rescale.result = TRUE)

# divisive hierarchical clustering
h <- as.hclust(diana(d))

# attempt sorting dendrogram by soil depth
h <- dendextend::rotate(h, order = idx)


## possible figure for sketches section

svglite::svglite(filename = '../sections/figures/sketch-demo.svg', width = 10, height = 5)

par(mar = c(0, 0, 3, 0))

plotSPC(x, color = 'genhz', col.label = 'Generalized Horizon Label', hz.distinctness.offset = 'hzd', print.id = FALSE, name.style = 'center-center', cex.names = 0.66, width = 0.4, cex.depth.axis = 0.75, axis.line.offset = -4.5, max.depth = 175, n.depth.ticks = 8, plot.order = h$order, y.offset = -15)

dev.off()


par(mar = c(0, 0, 3, 1))
plotProfileDendrogram(x, clust = h, scaling.factor = 0.008, y.offset = 0.05, color = 'genhz', col.label = 'Generalized Horizon Label', hz.distinctness.offset = 'hzd', print.id = FALSE, name.style = 'center-center', cex.names = 0.66, width = 0.4, cex.depth.axis = 0.75, axis.line.offset = -2.75, max.depth = 175, n.depth.ticks = 8)





