library(aqp)
library(sharpshootR)
library(cluster)

x <- readRDS('clarksville-pedons-final.rds')

x <- trunc(x, 0, 200)

x$hzd <- hzDistinctnessCodeToOffset(x$bounddistinct, codes = c('abrupt', 'clear', 'gradual', 'diffuse'))

par(mar = c(0, 0, 3, 1))

plotSPC(x, width = 0.4, name.style = 'center-center', col.label = 'Generalized Horizon Label', name = 'hzname', print.id = FALSE, axis.line.offset = -3, cex.depth.axis = 0.66, hz.distinctness.offset = 'hzd', max.depth = 200)


plotSPC(x, color = 'genhz', width = 0.4, name.style = 'center-center', col.label = 'Generalized Horizon Label', name = 'hzname', print.id = FALSE, axis.line.offset = -3, cex.depth.axis = 0.66, hz.distinctness.offset = 'hzd', max.depth = 200)
