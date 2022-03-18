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
  x[idx, 2], 
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
  sprintf("x[%s, 2]", idx), 
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

svglite(filename = 'figures/SPC-example-2.svg', width = 7, height = 3.5)

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
  label.cex = 0.85
)

segments(x0 = 0.66, y0 = .top, x1 = 3.33, y1 = .top, lwd = 2, lty = 2)
segments(x0 = 0.66, y0 = .bottom, x1 = 3.33, y1 = .bottom, lwd = 2, lty = 2)


dev.off()


