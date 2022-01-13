library(aqp)
library(sharpshootR)
library(cluster)
library(lattice)
library(tactile)

## pre-cached/subset data
x <- readRDS('clarksville-pedons-subset.rds')



## modified GHL assignment work-flow
tp <- hzTransitionProbabilities(x, 'hzname')
par(mar=c(1,1,1,1))
plotSoilRelationGraph(tp, graph.mode = 'directed', edge.arrow.size=0.5, edge.scaling.factor=2, vertex.label.cex=0.75, vertex.label.family='sans')


# compute horizon mid-points
x$mid <- with(horizons(x), (hzdept + hzdepb) / 2)

# sort horizon designation by group-wise median values
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

## total RF volume
bwplot(total_frags_pct ~ factor(hzname, levels=hz.designation.by.median.depths), 
       data=horizons(x), 
       ylab='Total Rock Fragment Volume (%)', 
       scales=list(y=list(tick.number=10)), 
       panel=function(...) {
         panel.abline(h=seq(0, 100, by=10), v=1:length(hz.designation.by.median.depths), col=grey(0.8), lty=3)
         panel.bwplot(...)
       }, par.settings = tactile.theme()
)



## use texture class
x$texcl <- factor(x$texture_class, levels = SoilTextureLevels())


table(x$hzname, x$texcl, useNA = 'always')


## TODO: check patterns for overlap, no matches in Bt2 group

# patterns c/o Jay
# apply to all pedons
x$genhz <- generalize.hz(
  x = x$hzname, 
  new = c('A', 'E', 'Bt1', 'Bt2', '2Bt', '3Bt'), 
  pat = c('A', 'E|BE|Bw', 'Bt|Bt1|Bt2', 'Bt3|Bt4|Bt5|Bt6', '2Bt2|2Bt3|2Bt4|Bt3|Bt4|Bt5|Bt6', '3Bt|2Bt5|2Bt6|2Bt7|2Bt8'), 
  non.matching.code = NA
)

x$genhz <- factor(x$genhz, levels = guessGenHzLevels(x, "genhz")$levels)
table(x$genhz, useNA = 'always')





### quick look at some of the data

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


