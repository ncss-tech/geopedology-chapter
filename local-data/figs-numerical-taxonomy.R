# http://ncss-tech.github.io/AQP/aqp/genhz-distance-eval.html


library(aqp)
library(sharpshootR)
library(cluster)

x <- readRDS('clarksville-pedons-final.rds')

x <- trunc(x, 0, 150)

# note funky syntax required to trick profile_compare... will be fixed soon
d <- profile_compare(x, vars = c('genhz', 'genhz'), max_d = 150, k = 0, rescale.result = TRUE)

# divisive hierarchical clustering
h <- as.hclust(diana(d))

par(mar = c(0, 0, 3, 1))
plotProfileDendrogram(x, clust = h, scaling.factor = 0.009, y.offset = 0.05, color = 'genhz', width = 0.4, name.style = 'center-center', col.label = 'Generalized Horizon Label', name = NA, print.id = FALSE, axis.line.offset = -2.25, cex.depth.axis = 0.66)

plotProfileDendrogram(x, clust = h, scaling.factor = 0.009, y.offset = 0.05, color = 'hurst.redness', width = 0.4, name.style = 'center-center', col.label = 'Hurst Redness Index', name = NA, print.id = FALSE, axis.line.offset = -2.25, cex.depth.axis = 0.66)

plotProfileDendrogram(x, clust = h, scaling.factor = 0.009, y.offset = 0.05, width = 0.4, name.style = 'center-center', col.label = 'Generalized Horizon Label', name = NA, print.id = FALSE, axis.line.offset = -2.25, cex.depth.axis = 0.66)

plotSPC(x, color = 'genhz', width = 0.4, name.style = 'center-center', col.label = 'Generalized Horizon Label', name = NA, print.id = FALSE, axis.line.offset = -2.25, cex.depth.axis = 0.66, plot.order = h$order)


# groupedProfilePlot(x, groups = 'hillslopeprof', color = 'genhz', width = 0.3, name.style = 'center-center', col.label = 'Generalized Horizon Label', name = NA, print.id = FALSE, axis.line.offset = -2.25, cex.depth.axis = 0.66)
