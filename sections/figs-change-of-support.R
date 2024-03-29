

##
## change in support figure
##

library(aqp)
library(lattice)
library(rms)
library(reshape2)
library(MetBrewer)
library(svglite)

## pre-cached/subset data
x <- readRDS('../local-data/clarksville-pedons-final.rds')

table(x$genhz)


# this is nice
genhz.cols <- rev(met.brewer('Hiroshige', n = length(levels(x$genhz))))

# keep track of generalized horizon names for later
hz.names <- levels(x$genhz)

# associate GHL colors
x$genhz.soil_color <- genhz.cols[match(x$genhz, hz.names)]

# slice out color and horizon name into 1cm intervals: no aggregation
max.depth <- 180
slice.resolution <- 1
slice.vect <- seq(from = 0, to = max.depth, by = slice.resolution)
s <- slice(x, slice.vect ~ genhz.soil_color + genhz)

# convert horizon name to factor
s$genhz <- factor(s$genhz, levels = hz.names)

# compute slice-wise probability: slice-wise P always sum to 1
a <- slab(x, ~ genhz, cpm = 1)

# convert to long-format for plotting
a.long <- melt(a, id.vars='top', measure.vars = make.names(hz.names))

# proportional-odds logistics regression: fits well, ignore standard errors
# using sliced data properly weights observations... but creates optimistic SE
# rcs required when we include depths > 100 cm...
# should we use penalized PO-LR? see pentrace()

# work with a non-NA subset of the sliced data
# this way we can splice-in residuals, etc.
idx <- which(complete.cases(horizons(s)[, c('genhz', 'hzdept')]))
s.sub <- horizons(s)[idx, ]

## TODO: how many knots and where should we put them?
## 4 knots seems about right, by default they are spaced along quantiles of hzdept
## linear -> rcs with 4 knots: R2 0.888 -> 0.893
dd <- datadist(s.sub) ; options(datadist="dd")
l.genhz <- orm(genhz ~ rcs(hzdept, parms=c(knots=4)), data=s.sub, x=TRUE, y=TRUE)

# predict along same depths: columns are the class-wise probability
# fitted.ind --> return all probability estimates
p <- data.frame(predict(l.genhz, data.frame(hzdept=slice.vect), type='fitted.ind'))

# re-name, rms model output give funky names
names(p) <- make.names(hz.names)

# add depths
p$top <- slice.vect

# melt to long format for plotting
p.long <- melt(p, id.vars='top', measure.vars = make.names(hz.names))

# combine sliced data / predictions
g <- make.groups(sliced.mode.1 = a.long, PO.model = p.long)
g$which <- factor(g$which, labels=c('empirical probabilities', 'PO-logistic regression'))

# remove P(hz) < 1%
g$value[which(g$value < 0.01)] <- NA

# re-shape to wide format, for comparison of fitted vs. empirical probabilities
g.wide <- dcast(g, top + variable ~ which, value.var = 'value')
names(g.wide) <- make.names(names(g.wide))



## categorical slice + slab figure

## ... generalize this someday


## PO-LR curves

svglite(filename = 'figures/slice-slab-GHL-PO-LR.svg', width = 8, height = 3.5)

n.slices <- 50
par(mar=c(0,0,0.5,2))
plotSPC(s[1:25, 1:n.slices], color='genhz.soil_color', name='', print.id=FALSE, n=32, cex.depth.axis=1, divide.hz = TRUE, lwd = 0.5)
legend('top', legend=hz.names[1:6], col=genhz.cols[1:6], pch=15, bty='n', horiz=TRUE, cex=1, pt.cex=2)
lines(27 + (7*p$A[1:n.slices]), p$top[1:n.slices], col=genhz.cols[1], lwd=2)
lines(27 + (7*p$E[1:n.slices]), p$top[1:n.slices], col=genhz.cols[2], lwd=2)
lines(27 + (7*p$Bt1[1:n.slices]), p$top[1:n.slices], col=genhz.cols[3], lwd=2)
lines(27 + (7*p$Bt2[1:n.slices]), p$top[1:n.slices], col=genhz.cols[4], lwd=2)
lines(27 + (7*p$X2Bt3[1:n.slices]), p$top[1:n.slices], col=genhz.cols[5], lwd=2)
lines(27 + (7*p$X3Bt4[1:n.slices]), p$top[1:n.slices], col=genhz.cols[6], lwd=2)

dev.off()


## empirical proportions

svglite(filename = 'figures/slice-slab-GHL-empirical.svg', width = 8, height = 3.5)

n.slices <- 50
par(mar=c(0,0,0.5,2))
plotSPC(s[1:25, 1:n.slices], color='genhz.soil_color', name='', print.id=FALSE, n=32, cex.depth.axis=1, divide.hz = TRUE, lwd = 0.5)
legend('top', legend=hz.names[1:6], col=genhz.cols[1:6], pch=15, bty='n', horiz=TRUE, cex=1, pt.cex=2)
lines(27 + (7*a$A[1:n.slices]), a$top[1:n.slices], col=genhz.cols[1], lwd=2)
lines(27 + (7*a$E[1:n.slices]), a$top[1:n.slices], col=genhz.cols[2], lwd=2)
lines(27 + (7*a$Bt1[1:n.slices]), a$top[1:n.slices], col=genhz.cols[3], lwd=2)
lines(27 + (7*a$Bt2[1:n.slices]), a$top[1:n.slices], col=genhz.cols[4], lwd=2)
lines(27 + (7*a$X2Bt3[1:n.slices]), a$top[1:n.slices], col=genhz.cols[5], lwd=2)
lines(27 + (7*a$X3Bt4[1:n.slices]), a$top[1:n.slices], col=genhz.cols[6], lwd=2)

dev.off()


## both!

svglite(filename = 'figures/slice-slab-GHL-both.svg', width = 9, height = 3.5)

n.slices <- 50
par(mar=c(0.75, 0.05, 0.3, 1))

plotSPC(s[1:25, 1:n.slices], color='genhz.soil_color', name='', print.id=FALSE, n = 40, cex.depth.axis=1, divide.hz = TRUE, lwd = 0.5, x.idx.offset = -1, axis.line.offset = -3)

legend('top', legend=hz.names[1:6], col=genhz.cols[1:6], pch=15, bty='n', horiz=TRUE, cex=1, pt.cex=2)

lines(26 + (7*a$A[1:n.slices]), a$top[1:n.slices], col=genhz.cols[1], lwd=2)
lines(26 + (7*a$E[1:n.slices]), a$top[1:n.slices], col=genhz.cols[2], lwd=2)
lines(26 + (7*a$Bt1[1:n.slices]), a$top[1:n.slices], col=genhz.cols[3], lwd=2)
lines(26 + (7*a$Bt2[1:n.slices]), a$top[1:n.slices], col=genhz.cols[4], lwd=2)
lines(26 + (7*a$X2Bt3[1:n.slices]), a$top[1:n.slices], col=genhz.cols[5], lwd=2)
lines(26 + (7*a$X3Bt4[1:n.slices]), a$top[1:n.slices], col=genhz.cols[6], lwd=2)

lines(35 + (7*p$A[1:n.slices]), p$top[1:n.slices], col=genhz.cols[1], lwd=2)
lines(35 + (7*p$E[1:n.slices]), p$top[1:n.slices], col=genhz.cols[2], lwd=2)
lines(35 + (7*p$Bt1[1:n.slices]), p$top[1:n.slices], col=genhz.cols[3], lwd=2)
lines(35 + (7*p$Bt2[1:n.slices]), p$top[1:n.slices], col=genhz.cols[4], lwd=2)
lines(35 + (7*p$X2Bt3[1:n.slices]), p$top[1:n.slices], col=genhz.cols[5], lwd=2)
lines(35 + (7*p$X3Bt4[1:n.slices]), p$top[1:n.slices], col=genhz.cols[6], lwd=2)

mtext(side = 1, at = 0, line = - 0.5, text = 'A)', font = 2)
mtext(side = 1, at = 26.25, line = - 0.5, text = 'B)', font = 2)
mtext(side = 1, at = 35.25, line = - 0.5, text = 'C)', font = 2)

dev.off()



## both and deeper

svglite(filename = 'figures/slice-slab-GHL-both-full.svg', width = 10, height = 8)

n.slices <- 180
par(mar=c(0.75, 0.05, 0.3, 1))

plotSPC(s[1:25, 1:n.slices], color='genhz.soil_color', name='', print.id=FALSE, n = 40, cex.depth.axis=1, divide.hz = TRUE, lwd = 0.5, x.idx.offset = -1, axis.line.offset = -3)

legend('top', legend=hz.names[1:6], col=genhz.cols[1:6], pch=15, bty='n', horiz=TRUE, cex=1, pt.cex=2)

lines(26 + (7*a$A[1:n.slices]), a$top[1:n.slices], col=genhz.cols[1], lwd=2)
lines(26 + (7*a$E[1:n.slices]), a$top[1:n.slices], col=genhz.cols[2], lwd=2)
lines(26 + (7*a$Bt1[1:n.slices]), a$top[1:n.slices], col=genhz.cols[3], lwd=2)
lines(26 + (7*a$Bt2[1:n.slices]), a$top[1:n.slices], col=genhz.cols[4], lwd=2)
lines(26 + (7*a$X2Bt3[1:n.slices]), a$top[1:n.slices], col=genhz.cols[5], lwd=2)
lines(26 + (7*a$X3Bt4[1:n.slices]), a$top[1:n.slices], col=genhz.cols[6], lwd=2)

lines(35 + (7*p$A[1:n.slices]), p$top[1:n.slices], col=genhz.cols[1], lwd=2)
lines(35 + (7*p$E[1:n.slices]), p$top[1:n.slices], col=genhz.cols[2], lwd=2)
lines(35 + (7*p$Bt1[1:n.slices]), p$top[1:n.slices], col=genhz.cols[3], lwd=2)
lines(35 + (7*p$Bt2[1:n.slices]), p$top[1:n.slices], col=genhz.cols[4], lwd=2)
lines(35 + (7*p$X2Bt3[1:n.slices]), p$top[1:n.slices], col=genhz.cols[5], lwd=2)
lines(35 + (7*p$X3Bt4[1:n.slices]), p$top[1:n.slices], col=genhz.cols[6], lwd=2)

mtext(side = 1, at = 0, line = - 0.5, text = 'A)', font = 2)
mtext(side = 1, at = 26.25, line = - 0.5, text = 'B)', font = 2)
mtext(side = 1, at = 35.25, line = - 0.5, text = 'C)', font = 2)

dev.off()




