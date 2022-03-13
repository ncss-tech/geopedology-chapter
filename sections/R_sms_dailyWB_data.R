library(sharpshootR)
library(hydromad)
library(sf)
library(sp)
library(curl)
library(soilDB)
library(aqp)
library(sf)
library(sp)
library(rgeos)
library(raster)
library(dplyr)
library(plyr)
library(ggplot2)
library(ggspatial)
library(RColorBrewer)

# parameters
yr <- 2018

# get basic sensor metadata for SCAN/SNOTEL site
m <- SCAN_site_metadata(site.code=c(2194))

p.jr <- SpatialPoints(cbind(m$Longitude, m$Latitude), proj4string = CRS('+proj=longlat +datum=WGS84'))

# fetchSCAN 
x <- fetchSCAN(site.code=c(2194), year=yr)

# comes in with multiple sensors - pair this down to one set for simplicity
idx <- grep('-', x$SMS$sensor.id)
x <- x$SMS[-idx, ]
nrow(x)

#x$doy <- strftime(x$SMS$date, format = "%j")

head(x$SMS)

# get KSSL data - soil sampled here is Scholten series
s <- fetchKSSL(pedon_id = 'S2012MO067001')

s.ghl <- s

s.ghl$genhz <- generalize.hz(s.ghl$hzn_desgn, new = c('Ap', 'Bt', '2Btx', '3Bt'), pat=c('Ap', '^Bt', '2Btx', '3Bt'), non.matching.code = NA)
s.ghl$genhz <- factor(s.ghl$genhz, levels = guessGenHzLevels(s.ghl, "genhz")$levels)

table(s.ghl$genhz, useNA = 'always')


# run water balance on SCAN site station locations
d.jr <- dailyWB_SSURGO(
  p.jr,
  cokeys = NULL,
  start = yr,
  end = yr,
  modelDepth = 100,
  MS.style = "default",
  a.ss = 0.1,
  S_0 = 0.5,
  bufferRadiusMeters = 1
)

# dailyWB returns data for Scholten and Poyner components
idx <- which(d.jr$compname == 'Scholten')
d.jr <- d.jr[idx, ]
nrow(d.jr)

# align names to join on Date
names(d.jr) <- c("Date", "P", "E", "U", "S", "ET", "VWC", "compname", "sat", 
"fc", "pwp", "state", "month", "year", "week", "doy")

# assemble joined data - primary set of sms sensors and daily water balance for the same year
d <- join(x, d.jr, by='Date', type='inner')
nrow(d)

# slice the KSSL data associated with the sensor depths
s1 <- aqp::slice(s, sensor.depths ~ .)

# combine sensors of interest
#g <- make.groups('soil moisture'=d)

# generate a better axis for dates
date.axis <- seq.Date(as.Date(min(d$Date)), as.Date(max(d$Date)), by='1 months')

# assign a label field
#d$depth <- 'soil moisture'
sensor.depths <- unique(d$depth)

#xyplot(value ~ Date | factor(Site), groups=factor(depth), data=d, as.table=TRUE, type=c('l','g'), auto.key=list(columns=length(sensor.depths), lines=TRUE, points=FALSE), strip=strip.custom(bg=grey(0.80)), scales=list(alternating=3, x=list(at=date.axis, format="%b\n%Y"), y=list(relation='free', rot=0)), ylab='', main='Soil Moisture at sensor depths (cm)')

# invert y-axis
p <- xyplot(value ~ Date | factor(Site), groups=factor(depth), data=d, as.table=TRUE, type=c('l','g'), auto.key=list(columns=length(sensor.depths), lines=TRUE, points=FALSE), strip=strip.custom(bg=grey(0.80)), scales=list(alternating=3, x=list(at=date.axis, format="%b\n%Y"), y=list(relation='free', rot=0)), ylim = c(max(d$value), min(d$value)), ylab='', main='Soil Moisture at sensor depths (cm)')

# update with the same color scheme that is applied to the genhz profile and sensor depths
update(p, par.settings =
         custom.theme(symbol = rev(brewer.pal(10, "Spectral"))[c(1,1,4,7,10)],
                      fill = rev(brewer.pal(10, "Spectral"))[c(1,1,4,7,10)]))
                      
# combine original profile and genhz profile - need to trick profile_id here
profile_id(s.ghl) <- 59535
ss <- aqp::combine(s, s.ghl)

# plot profile of lab data horizons with sensors next to genhz profile 
par(mar=c(0,0,3,1))
plotSPC(ss[1], name='hzn_desgn', label='pedon_id', id.style='top', cex.names=0.75, width=0.05, x.idx.offset=0.15, axis.line.offset=-2, space=2, scaling.factor = 1, max.depth = 200, show.legend = FALSE)
title(paste('Sensor Depths - Site ', unique(x$Site), sep=" "), line=0.5, cex.main=1.5)

# over plot the sensor depths on the previous plot
lsp <- get("last_spc_plot", envir = aqp.env)
points(x=rep(lsp$x0[1], times=length(sensor.depths)), y=sensor.depths, pch=15, cex=1.5, col=rev(brewer.pal(10, 'Spectral'))[c(1,1,4,7,10)])
text(x=rep(lsp$x0[1], times=length(sensor.depths)), y=sensor.depths, labels = sensor.depths, cex=0.75, pos=1)

# add second profile with filled with genhz colors that correspond to the sensor colors
plotSPC(ss[2], name='genhz', print.id = FALSE, id.style='top', color='genhz', cex.names=0.75, width=0.05, x.idx.offset=-0.65, axis.line.offset=-15, space=2, scaling.factor = 1, relative.pos = 2, max.depth = 200, show.legend = FALSE, add = TRUE)

# TODO: not sure how to get these two figures side by side
