library(aqp)
library(lattice)
library(soilDB)
library(png)
library(grid)

p <- contrastChart(m = '7.5YR 4/3', hues = c('5YR', '7.5YR', '10YR'))
p <- update(p, scales = list(cex = 1))


svglite::svglite(filename = 'figures/contast-chart.svg', width = 15, height = 6.8)
print(p)
dev.off()


contrastChart(m = '7.5YR 4/3', hues = '7.5YR')
contrastChart(m = '7.5YR 4/3', hues = c('5YR', '7.5YR', '10YR'))

p <- contrastChart(m = '7.5YR 4/3', hues = c('5YR', '7.5YR'), style = 'CC')
latticeExtra::useOuterStrips(p, strip.left = strip.custom(bg = grey(0.85)), strip = strip.custom(bg = grey(0.85)))

p


p <- contrastChart(m = '7.5YR 4/3', hues = c('5YR', '7.5YR', '10YR', '7.5Y'), thresh = 15)
update(p, sub = 'color chips with dE00(7.5YR 4/3) < 15')


##
##



s <- 'musick'
x <- fetchOSD(s, colorState = 'dry')
y <- fetchOSD(s, colorState = 'moist')

idx <- 2:8
x <- x[, idx]
y <- y[, idx]

m1 <- sprintf("%s %s/%s", x$hue, x$value, x$chroma)
m2 <- sprintf("%s %s/%s", y$hue, y$value, y$chroma)

cc <- colorContrast(m1, m2)

svglite::svglite(filename = 'figures/contrast-class-dE00.svg', width = 10, height = 3.5)
colorContrastPlot(m1, m2, labels=c('Dry', 'Moist'), d.cex = 1, col.cex = 1)
dev.off()

# caption with hz designation
x$hzname




##
##

library(aqp)
library(soilDB)

# pull in the component data for two adjacent mapunits to build a combined catena concept
# ridgeline mapunit encompassing summit/shoulder positions 
# and a sideslope unit with overlapping shoulder/backslope/footslope/toeslope positions
d <- fetchSDA(WHERE = "mukey IN(2501629, 2501617)")

# make some labels for ordering the component profiles
#d$profile_label <- paste(d$compname, d$comppct_r, d$hillslopeprof, d$nationalmusym, sep=" - ")


## no need for this: there is only a single profile to remove
# simplify by removing exact duplicates
# d <- (unique(d, vars = c('hzdept_r', 'hzdepb_r', 'compname', 'silttotal_r')))

## remove copy of Taterhill in 2vxq8
d <- subset(d, !(compname == 'Taterhill' & nationalmusym == '2vxq8'))


osds <- fetchOSD(d$compname)
osds <- trunc(osds, 0, 200)

length(d)

# trimmed down but still busy
d$profile_label <- paste(d$compname, d$hillslopeprof, sep=" - ")


# remove annotation for O horizons
horizons(d)$.newname <- d$hzname
d$.newname[grep('O', d$hzname)] <- ''


# simplify pmkind
d$pmkind <- gsub(pattern = ' over ', replacement = '\n', d$pmkind)

# note: 12 profiles

# par(mar = c(0, 0, 3, 0))
# plotSPC(d, name = '.newname', label = 'profile_label', color='silttotal_r', cex.id = 0.66, cex.names = 0.66, name.style = 'center-center', width = 0.25, hz.depths = TRUE, id.style='side', fixLabelCollisions = TRUE, hz.depths.offset = 0.05, plot.depth.axis = FALSE)
# 
# # generate idealized hillslope profile
# .yshift <- c(0, 0, 1, 2, 4, 8, 15, 22, 30, 35, 40, 43) * 5
# 
# # smooth hillslope cross-section
# .xland <- 1:length(.yshift)
# .yland <- .yshift - 30
# 
# # smooth via interpolation
# .landSurface <- splinefun(.xland, .yland)
# .s <- seq(0.5, length(d) + 0.5, by = 0.1)
# .sy <- .landSurface(.s)
# 
# # note, depth-logic is inverted
# plot(.s, -.sy, type = 'l', axes = FALSE)
# 

d$fine_earth_texture_cl <- ssc_to_texcl(sand = d$sandtotal_r, clay = d$claytotal_r)

# convert texture class to names
d$fine_earth_texture_cl <- factor(
  factor(d$fine_earth_texture_cl, 
         levels = SoilTextureLevels(which = 'codes'), 
         labels = SoilTextureLevels(which = 'names'))
)


# soil texture colors
texture.rat <- read.csv('http://soilmap2-1.lawr.ucdavis.edu/800m_grids/RAT/texture_2550.csv')
cols <- texture.rat$hex[match(levels(d$fine_earth_texture_cl), texture.rat$names)]

# image of soil texture triangle + colors
tf <- tempfile()
download.file('https://casoilresource.lawr.ucdavis.edu/soil-properties/images/soil-texture-legend-crop-small.png', destfile = tf, mode = 'wb')
texture.tri.img <- readPNG(tf)

o <- order(as.numeric(d$hillslopeprof), decreasing = TRUE)

# however, this will complicate a manual specification of the landform surface
# now we need an index back to the original order
idx <- match(1:length(d), o)


svglite::svglite(filename = 'figures/cross-section.svg', width = 15, height = 8)

par(mar = c(0, 0, 0.5, 0))

set.seed(101001)
plotSPC(d, name = '.newname', label = 'compname', color='fine_earth_texture_cl', cex.id = 0.75, cex.names = 0.66, name.style = 'center-center', width = 0.2, hz.depths = TRUE, id.style='top', fixLabelCollisions = TRUE, hz.depths.offset = 0.05, plot.depth.axis = FALSE, y.offset = .yshift[idx], plot.order = o, col.label = 'Soil Texture of Fine Earth Fraction (<2mm)', show.legend = FALSE, col.palette = cols)


# add smoothed, idealized land surface
lines(x = .s, y = .sy, lwd = 3)

# # demonstrate full y-range within figure
# axis(side = 4, line = -2, las = 1)

# add title
mtext(text = 'Ozark Highlands Catena Concepts \n Two Adjacent Mapunits', side = 3, at = 10.5, line = -6, font = 2)

# table(d$compname)


## add pmkind
.bottoms <- profileApply(d, max) + .yshift
text(1:length(d), .bottoms, labels = d$pmkind[o], cex = 0.66, pos = 1, offset = 0.5)


## add national map unit symbol
text(1:length(d), .yshift - 35, labels = d$nationalmusym[o], cex = 0.66, font = 3, pos = 1, offset = 1.25)

## annotation for fine earth fraction texture classes
mtext("soil texture classes for fine earth fraction (<2mm)", side = 1, at = 8, line = -2.5, adj = 1)


## splice in soil color
for(i in 1:length(d$compname)) {
  
  series.i <- toupper(d$compname[i])
  osd.i <- subset(osds, profile_id(osds) == series.i)
  
  osd.idx <- which(series.i == toupper(d$compname))
  
  for(j in osd.idx) {
    plotSPC(osd.i, name = NA, print.id = FALSE, add = TRUE, x.idx.offset = match(j, o) - 1.35, width = 0.1, y.offset = .yshift[idx][j], plot.depth.axis = FALSE)
  }
  
  
}


## place soil texture triangle
grid.raster(texture.tri.img, x = 0.18, y = 0.22, width = 0.23)


dev.off()



