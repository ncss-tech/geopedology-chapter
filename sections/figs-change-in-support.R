

##
## change in support figure
##

library(aqp)
library(lattice)
library(rms)
library(reshape2)

## pre-cached/subset data
x <- readRDS('../local-data/clarksville-pedons-final.rds')

x$genhz


genzh.cols <- c("#3288BD", "#99D594", "#E6F598", "#FEE08B", "#FC8D59", "#D53E4F")


# keep track of generalized horizon names for later
hz.names <- levels(x$genhz)

# associate GHL colors
x$genhz.soil_color <- genzh.cols[match(x$genhz, hz.names)]

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

svglite(filename = 'figures/slice-slab-GHL-example.svg', width = 8, height = 3.5)

n.slices <- 50
par(mar=c(0,0,0.5,2))
plotSPC(s[1:25, 1:n.slices], color='genhz.soil_color', name='', print.id=FALSE, n=32, cex.depth.axis=1, divide.hz = TRUE, lwd = 0.5)
legend('top', legend=hz.names[1:6], col=genzh.cols[1:6], pch=15, bty='n', horiz=TRUE, cex=1, pt.cex=2)
lines(27 + (7*p$A[1:n.slices]), p$top[1:n.slices], col=genzh.cols[1], lwd=2)
lines(27 + (7*p$E[1:n.slices]), p$top[1:n.slices], col=genzh.cols[2], lwd=2)
lines(27 + (7*p$Bt1[1:n.slices]), p$top[1:n.slices], col=genzh.cols[3], lwd=2)
lines(27 + (7*p$Bt2[1:n.slices]), p$top[1:n.slices], col=genzh.cols[4], lwd=2)
lines(27 + (7*p$X2Bt3[1:n.slices]), p$top[1:n.slices], col=genzh.cols[5], lwd=2)
lines(27 + (7*p$X3Bt4[1:n.slices]), p$top[1:n.slices], col=genzh.cols[6], lwd=2)

dev.off()



