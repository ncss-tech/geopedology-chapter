library(aqp)
library(svglite)

# # hack
# .LAST <- NULL
# .FIRST <- NULL

# this is an example two-pane figure where a small subset of profiles is shown based on i index
# then one profile gets "zoomed in on" and the different [ horizon extraction methods are demonstrated
x <- readRDS("../local-data/clarksville-all-pedons.rds")


## Figure 1



# keep first 5 profiles, kind = series
x <- subset(x, taxonkind == 'series')[1:5, ]

# new ID for simpler explanation
site(x)$newID <- sprintf("Profile %s", 1:5)

# remove O horizon labels for clarity
x$hzname[grep('O', x$hzname)] <- NA

# default color for O horizons
.col <- parseMunsell('10YR 2/2')


svglite(filename = 'figures/SPC-example-1.svg', width = 9.5, height = 5)

par(mar=c(0,0,0,0), mfrow=c(1,2))

# figure of first five profiles
set.seed(101010)
plotSPC(x, cex.names = 0.7, label = 'newID', max.depth = 225, width = 0.25, default.color = .col, plot.depth.axis = FALSE, name.style = 'center-center', hz.depths = TRUE, fixLabelCollisions = TRUE, hz.depths.offset = 0.05, font.id = 1)

# label subfigure
mtext(text = 'A) Original Data', side = 1, line = - 2, font = 2)

# example to subset
idx <- 5

# SPCs to plot
.s <- list(
  x[idx, ], 
  x[idx, 1], 
  x[idx, 3:6], 
  x[idx, , .FIRST],
  x[idx, , .LAST]
)


# using the same set of arguments for each iteration
.arg1 <- list(color = "soil_color", label = 'newID', max.depth = 225, cex.names = 0.7, width = 0.25, name.style = 'center-center', hz.depths = TRUE, fixLabelCollisions = TRUE, hz.depths.offset = 0.05, font.id = 1)

# dumb trick to replicate a list
.a <- list(.arg1)[rep(1, times = 5)]

# labels
.labs <- c(
  sprintf("x[%s, ]", idx), 
  sprintf("x[%s, 1]", idx), 
  sprintf("x[%s, 3:6]", idx), 
  sprintf("x[%s, , .FIRST]", idx),
  sprintf("x[%s, , .LAST]", idx)
)


plotMultipleSPC(
  .s, 
  args = .a,
  plot.depth.axis = FALSE,
  group.labels = .labs,
  label.offset = 20,
  label.cex = 0.75
)

mtext(text = 'B) Subsets of Profile 5', side = 1, line = - 2, font = 2)

dev.off()


## figure 2

svglite(filename = 'figures/SPC-example-2.svg', width = 7, height = 4)

par(mar=c(0,0,0,1))

.top <- 35
.bottom <- 95
idx <- 5

.s <- list(
  x[idx, ], 
  glom(x[idx, ], .top, .bottom), 
  trunc(x[idx, ], .top, .bottom)
)

# all the same
.arg1 <- list(label = 'newID', max.depth = 225, cex.names = 0.75, name.style = 'center-center', width = 0.2)

# dumb trick to replicate a list
.a <- list(.arg1)[rep(1, times = 3)]

.labs <- c(
  sprintf("x[%s, ]", idx), 
  sprintf("glom(x[%s, ], %s, %s)", idx, .top, .bottom), 
  sprintf("trunc(x[%s, ], %s, %s)", idx, .top, .bottom)
)

plotMultipleSPC(
  .s,
  args = .a,
  group.labels = .labs, 
  axis.line.offset = -2.1,
  label.offset = 10, 
  label.cex = 1
)

segments(x0 = 0.66, y0 = .top, x1 = 3.33, y1 = .top, lwd = 2, lty = 2)
segments(x0 = 0.66, y0 = .bottom, x1 = 3.33, y1 = .bottom, lwd = 2, lty = 2)


dev.off()




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

svglite(filename = 'figures/slice-slab-GHL-example.svg', width = 8, height = 4)

n.slices <- 50
par(mar=c(0,0,0.5,2))
plotSPC(s[1:25, 1:n.slices], color='genhz.soil_color', name='', print.id=FALSE, n=32, cex.depth.axis=1, divide.hz = TRUE, lwd = 0.5)
legend('top', legend=hz.names[1:6], col=genzh.cols[1:6], pch=15, bty='n', horiz=TRUE, cex=1.25, pt.cex=2)
lines(27 + (7*p$A[1:n.slices]), p$top[1:n.slices], col=genzh.cols[1], lwd=2)
lines(27 + (7*p$E[1:n.slices]), p$top[1:n.slices], col=genzh.cols[2], lwd=2)
lines(27 + (7*p$Bt1[1:n.slices]), p$top[1:n.slices], col=genzh.cols[3], lwd=2)
lines(27 + (7*p$Bt2[1:n.slices]), p$top[1:n.slices], col=genzh.cols[4], lwd=2)
lines(27 + (7*p$X2Bt3[1:n.slices]), p$top[1:n.slices], col=genzh.cols[5], lwd=2)
lines(27 + (7*p$X3Bt4[1:n.slices]), p$top[1:n.slices], col=genzh.cols[6], lwd=2)

dev.off()

