library(aqp)
library(sharpshootR)
library(igraph)
library(lattice)
library(tactile)
library(cluster)

## pre-cached/subset data
x <- readRDS('clarksville-pedons-subset.rds')



## modified GHL assignment work-flow
tp <- hzTransitionProbabilities(x, 'hzname')
par(mar=c(1,1,1,1))
g <- plotSoilRelationGraph(tp, graph.mode = 'directed', edge.arrow.size=0.5, edge.scaling.factor=2, vertex.label.cex=0.75, vertex.label.family='sans')

# network-based eval of horizon designation groups
g <- as_data_frame(g, what = 'vertices')

idx <- match(x$hzname, g$name)
x$hz.clust <- g$cluster[idx]

# not immediately useful, but a start
par(mar = c(0, 0, 3, 0))
plotSPC(x, color = 'hz.clust', plot.depth.axis = FALSE, print.id = FALSE, name.style = 'center-center', width = 0.35)




# texture class as ordered factor
x$texcl <- factor(x$texture_class, levels = SoilTextureLevels())
x$texcl <- factor(x$texcl)


# compute horizon mid-points
x$mid <- with(horizons(x), (hzdept + hzdepb) / 2)

# color seems important
x$hurst.redness <- hurst.redness(hue = x$m_hue, value = x$m_value, chroma = x$m_chroma)
x$hue.pos <- factor(factor(x$m_hue, levels = huePosition(returnHues = TRUE)))


par(mar = c(0, 0, 3, 0))
plotSPC(x, color = 'hurst.redness', plot.depth.axis = FALSE, print.id = FALSE, name.style = 'center-center', width = 0.35)

plotSPC(x, color = 'hue.pos', plot.depth.axis = FALSE, print.id = FALSE, name.style = 'center-center', width = 0.35)


## gravel vs cobble
x$gr.gt.cb <- x$gravel > x$cobbles

x$CB <- grepl('CB', x$texture)

plotSPC(x, color = 'gr.gt.cb', plot.depth.axis = FALSE, print.id = FALSE, name.style = 'center-center', width = 0.35)

plotSPC(x, color = 'CB', plot.depth.axis = FALSE, print.id = FALSE, name.style = 'center-center', width = 0.35)





## sort horizon designation by group-wise median values
hz.designation.by.median.depths <- names(sort(tapply(x$mid, x$hzname, median)))

# plot the distribution of horizon mid-points by designation
bwplot(mid ~ factor(hzname, levels=hz.designation.by.median.depths), 
       data=horizons(x), 
       ylim=c(200, -5), ylab='Horizon Mid-Point Depth (cm)', 
       scales=list(y=list(tick.number=10)), 
       panel=function(...) {
         panel.abline(h=seq(0, 140, by=10), v=1:length(hz.designation.by.median.depths), col=grey(0.8), lty=3)
         panel.bwplot(...)
       }, par.settings = tactile.theme()
)


## no clay values

## Hurst RI
bwplot(factor(hzname, levels=hz.designation.by.median.depths) ~ hurst.redness, 
       data=horizons(x), 
       xlab='Hurst Redness Index', 
       scales=list(x=list(tick.number=10)), 
       panel=function(...) {
         panel.abline(v=seq(0, 100, by=10), h=1:length(hz.designation.by.median.depths), col=grey(0.8), lty=3)
         panel.bwplot(...)
       }, par.settings = tactile.theme()
)



## check out rock fragment volume fractions
bwplot(factor(hzname, levels=hz.designation.by.median.depths) ~ total_frags_pct, 
       data=horizons(x), 
       xlab='Total Rock Fragment Volume (%)', 
       scales=list(x=list(tick.number=10)), 
       panel=function(...) {
         panel.abline(v=seq(0, 100, by=15), h=1:length(hz.designation.by.median.depths), col=grey(0.8), lty=3)
         panel.bwplot(...)
       }, par.settings = tactile.theme()
)

bwplot(factor(hzname, levels=hz.designation.by.median.depths) ~ gravel, 
       data=horizons(x), 
       xlab='Gravel Content Volume (%)', 
       scales=list(x=list(tick.number=10)), 
       panel=function(...) {
         panel.abline(v=seq(0, 100, by=15), h=1:length(hz.designation.by.median.depths), col=grey(0.8), lty=3)
         panel.bwplot(...)
       }, par.settings = tactile.theme()
)

bwplot(factor(hzname, levels=hz.designation.by.median.depths) ~ cobbles, 
       data=horizons(x), 
       xlab='Cobble Content Volume (%)', 
       scales=list(x=list(tick.number=10)), 
       panel=function(...) {
         panel.abline(v=seq(0, 65, by=15), h=1:length(hz.designation.by.median.depths), col=grey(0.8), lty=3)
         panel.bwplot(...)
       }, par.settings = tactile.theme()
)



## use texture class
table(x$hzname, x$texcl, useNA = 'always')

# patterns c/o Jay, edited by Dylan

## GHL
# combining 2Bt3 + 2Bt4
n <- c('A', 'E', 'Bt1', 'Bt2', '2Bt3', '3Bt4')

# REGEX rules
p <- c(
  'A', 
  'E|BE|Bw', 
  'Bt|Bt1|Bt2', 
  '^Bt3|^Bt4|^Bt5|^Bt6', 
  '2Bt2|2Bt3|2Bt4', 
  '3Bt|2Bt5|2Bt6|2Bt7|2Bt8|Bt9|2Bt9'
)

x$genhz <- generalize.hz(
  x = x$hzname, 
  new = n, 
  pat = p, 
  non.matching.code = NA
)

par(mar = c(0, 0, 3, 0))
plotSPC(x, color = 'genhz', plot.depth.axis = FALSE, print.id = FALSE, name.style = 'center-center', width = 0.35)


tab <- table(x$genhz, x$hzname)
addmargins(tab)

# convert contingency table -> adj. matrix
m <- genhzTableToAdjMat(tab)
# plot using a function from the sharpshootR package
par(mar=c(1,1,1,1))
plotSoilRelationGraph(m, graph.mode = 'directed', edge.arrow.size=0.5)


# slice profile collection from 0-150 cm
s <- slice(x, 0:200 ~ genhz + total_frags_pct)

# convert horizon name back to factor, using original levels
s$genhz <- factor(s$genhz, levels = n)

# plot depth-ranges of generalized horizon slices
bwplot(hzdept ~ genhz, data=horizons(s), 
       ylim=c(max(s), -5), ylab='Generalized Horizon Depth (cm)', 
       varwidth = TRUE,
       scales=list(y=list(tick.number=10)), asp=1, 
       panel=function(...) {
         panel.abline(h=seq(0, max(s), by=20), v=1:length(n),col=grey(0.8), lty=3)
         panel.bwplot(...)
       },
       par.settings = tactile.theme()
)

bwplot(genhz ~ total_frags_pct, 
       data=horizons(x), 
       varwidth = TRUE,
       xlab='Total Rock Fragment Volume (%)', 
       scales=list(x=list(tick.number=10)), 
       panel=function(...) {
         panel.abline(v=seq(0, 100, by=15), h=1:length(n), col=grey(0.8), lty=3)
         panel.bwplot(...)
       }, par.settings = tactile.theme()
)

bwplot(genhz ~ gravel, 
       data=horizons(x),
       varwidth = TRUE,
       xlab='Gravel Content Volume (%)', 
       scales=list(x=list(tick.number=10)), 
       panel=function(...) {
         panel.abline(v=seq(0, 100, by=15), h=1:length(hz.designation.by.median.depths), col=grey(0.8), lty=3)
         panel.bwplot(...)
       }, par.settings = tactile.theme()
)

bwplot(genhz ~ cobbles, 
       data=horizons(x), 
       varwidth = TRUE,
       xlab='Cobble Content Volume (%)', 
       scales=list(x=list(tick.number=10)), 
       panel=function(...) {
         panel.abline(v=seq(0, 65, by=15), h=1:length(hz.designation.by.median.depths), col=grey(0.8), lty=3)
         panel.bwplot(...)
       }, par.settings = tactile.theme()
)

bwplot(genhz ~ hurst.redness, 
       data=horizons(x), 
       varwidth = TRUE,
       xlab='Hurst Redness Index', 
       scales=list(x=list(tick.number=10)), 
       panel=function(...) {
         panel.abline(v=seq(0, 100, by=10), h=1:length(hz.designation.by.median.depths), col=grey(0.8), lty=3)
         panel.bwplot(...)
       }, par.settings = tactile.theme()
)




## Iterate: there is some confusion between 'Bt2' and '2Bt3'


## Silhouette Width for a quick eval

# store the column names of our variables of interest
vars <- c('total_frags_pct', 'hurst.redness', 'mid')
# result is a list of several items
hz.eval <- evalGenHZ(x, 'genhz', vars)

# extract silhouette widths and neighbor
x$sil.width <- hz.eval$horizons$sil.width
x$neg.sil.width <- x$sil.width < -0.2

par(mar = c(0, 0, 3, 0))
plotSPC(x, color = 'sil.width', plot.depth.axis = FALSE, print.id = FALSE, name.style = 'center-center', width = 0.35)

plotSPC(x, color = 'neg.sil.width', plot.depth.axis = FALSE, print.id = FALSE, name.style = 'center-center', width = 0.35)




## save when happy
saveRDS(x, file = 'clarksville-pedons-final.rds')








### move / organize

previewColors(x$moist_soil_color, method = 'MDS', pt.cex = 1.5)
title('Clarksville Soil Colors')



# quick check on NAs
tab <- table(x$genhz, x$hzname, useNA = 'always')
sort(tab[5, ], decreasing = TRUE)

# many Oi, some 2BC

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


# apply to subset
z$genhz <- generalize.hz(
  x = z$hzname, 
  new = c('A', 'E', 'Bt1', 'Bt2', '2Bt', '3Bt'), 
  pat = c('A', 'E|BE|Bw', 'Bt|Bt1|Bt2', 'Bt3|Bt4|Bt5|Bt6', '2Bt2|2Bt3|2Bt4|Bt3|Bt4|Bt5|Bt6', '3Bt|2Bt5|2Bt6|2Bt7|2Bt8'), 
  non.matching.code = NA
)

z$genhz <- factor(z$genhz, levels = guessGenHzLevels(z, "genhz")$levels)
table(z$genhz, useNA = 'always')


plotSPC(z, color = 'genhz')


