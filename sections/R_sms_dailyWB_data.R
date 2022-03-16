library(sharpshootR)
library(hydromad)
library(soilDB)
library(aqp)
library(sp)
library(rgeos)
library(RColorBrewer)
library(reshape2)

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
  modelDepth = 50,
  MS.style = "default",
  a.ss = 0.01,
  S_0 = 0.5,
  bufferRadiusMeters = 1
)

# dailyWB returns data for Scholten and Poynor components
idx <- which(d.jr$compname == 'Scholten')
d.jr <- d.jr[idx, ]
nrow(d.jr)

# align names to join on Date
names(d.jr) <- c("Date", "P", "E", "U", "S", "ET", "VWC", "compname", "sat", 
"fc", "pwp", "state", "month", "year", "week", "doy")

# assemble joined data - primary set of sms sensors and daily water balance for the same year
d <- merge(x, d.jr, by = 'Date', all.x = TRUE, all.y = FALSE, sort = FALSE)
nrow(d)


# assign a label field
#d$depth <- 'soil moisture'
sensor.depths <- unique(d$depth)


# slice the KSSL data associated with the sensor depths
s1 <- dice(s, sensor.depths ~ ., SPC = TRUE)

# combine sensors of interest
#g <- make.groups('soil moisture'=d)

# generate a better axis for dates
date.axis <- seq.Date(as.Date(min(d$Date)), as.Date(max(d$Date)), by='1 months')


#xyplot(value ~ Date | factor(Site), groups=factor(depth), data=d, as.table=TRUE, type=c('l','g'), auto.key=list(columns=length(sensor.depths), lines=TRUE, points=FALSE), strip=strip.custom(bg=grey(0.80)), scales=list(alternating=3, x=list(at=date.axis, format="%b\n%Y"), y=list(relation='free', rot=0)), ylab='', main='Soil Moisture at sensor depths (cm)')

# invert y-axis
p <- xyplot(value ~ Date | factor(Site), groups=factor(depth), data=d, as.table=TRUE, type=c('l','g'), auto.key=list(columns=length(sensor.depths), lines=TRUE, points=FALSE), strip=strip.custom(bg=grey(0.80)), scales=list(alternating=3, x=list(at=date.axis, format="%b\n%Y"), y=list(relation='free', rot=0)), ylim = c(max(d$value), min(d$value)), ylab='', main='Soil Moisture at sensor depths (cm)')

# update with the same color scheme that is applied to the genhz profile and sensor depths
update(p, par.settings =
         custom.theme(symbol = rev(brewer.pal(10, "Spectral"))[c(1,1,4,7,10)],
                      fill = rev(brewer.pal(10, "Spectral"))[c(1,1,4,7,10)]))
                      
# combine original profile and genhz profile - need to trick profile_id here
profile_id(s.ghl) <- 59535
ss <- combine(s, s.ghl)

# plot profile of lab data horizons with sensors next to genhz profile 
par(mar=c(0,0,3,1))
plotSPC(ss[1], name='hzn_desgn', label='pedon_id', id.style='top', cex.names=0.75, width=0.05, x.idx.offset=0.15, axis.line.offset=-2, space=2, scaling.factor = 1, max.depth = 200, show.legend = FALSE, plot.depth.axis = FALSE )
title(paste('Sensor Depths - Site ', unique(x$Site), sep=" "), line=0.5, cex.main=1.5)

# over plot the sensor depths on the previous plot
lsp <- get("last_spc_plot", envir = aqp.env)
points(x=rep(lsp$x0[1], times=length(sensor.depths)), y=sensor.depths, pch=15, cex=1.5, col=rev(brewer.pal(10, 'Spectral'))[c(1,1,4,7,10)])
text(x=rep(lsp$x0[1], times=length(sensor.depths)), y=sensor.depths, labels = sensor.depths, cex=0.75, pos=4)

# add second profile with filled with genhz colors that correspond to the sensor colors
plotSPC(ss[2], name='genhz', print.id = FALSE, id.style='top', color='genhz', cex.names=0.75, width=0.05, x.idx.offset=-0.65, axis.line.offset=-5, space=2, scaling.factor = 1, relative.pos = 2, max.depth = 200, show.legend = FALSE, add = TRUE)

# TODO: not sure how to get these two figures side by side
# combine precip, utilization from dailyWB over sensor soil moisture
xyplot(c(P, U, -(value)) ~ Date | factor(Site), groups=factor(depth), data=d, as.table=TRUE, type=c('l','g'), scales=list(alternating=3, x=list(at=date.axis, format="%b"), y=list(relation='free', rot=0)), ylim = c(-50, 60), ylab='', main='Soil Moisture at sensor depths (cm)')


## DEB: tinkering

# rescale measured VWC to 0,1
d$value <- d$value / 100


# does modeled VWC track measured?
xyplot(value - VWC ~ Date | factor(depth), data = d, as.table = TRUE)


xyplot(
  value ~ Date | factor(depth), 
  data=d, 
  as.table = TRUE,
  type=c('l','g'), 
  scales=list(alternating=3, x = list(at = date.axis, format = "%b", rot = 90)), 
  ylab='Volumetric Water Content (cm/cm)', 
  xlab = '',
  main='Soil Moisture at sensor depths (cm)',
  strip = strip.custom(bg = grey(0.85)),
  panel = function(...) {
    panel.xyplot(...)
    
    .wbdata <- d[d$depth == 5, ]
    panel.lines(x = .wbdata$Date, y = .wbdata$VWC, col = 'black')
  }
)

xyplot(value ~ Date | factor(Site), groups=factor(depth), data=d, as.table=TRUE, type=c('l','g'), scales=list(alternating=3, x=list(at=date.axis, format="%b"), y=list(relation='free', rot=0)), ylab='', main='Soil Moisture at sensor depths (cm)')

plot(value ~ Date, data = d, subset = depth == 5, type = 'l', las = 1, ylab = 'Volumetric Water Content (cm/cm)')
lines(VWC ~ Date, data = d, col = 2, subset = depth == 5)

xyplot(P ~ Date, data = d, type = 'h', ylab = 'Precipitation')
xyplot(U ~ Date, data = d, type = 'h', ylab = 'Precipitation')


## not a good idea ... 

# here is a crazy idea, take mean measured VWC
d.sub <- subset(d, subset = depth < 50)
d.l <- split(d.sub, d.sub$Date)
d.l <- lapply(d.l, function(i) {
  data.frame(Date = i$Date[1], value = mean(i$value), VWC = i$VWC[1], P = i$P[1], U = i$U[1])
})

d.agg <- do.call('rbind', d.l)

d.long <- melt(d.agg, id.vars = 'Date', measure.vars = c('value', 'VWC', 'P', 'U'))



xyplot(value ~ Date, groups = variable, subset = variable %in% c('value', 'VWC'), data = d.long, type = 'l', ylab = 'Volumetric Water Content (cm/cm)')

xyplot(value ~ Date, groups = variable, subset = variable %in% c('P', 'U'), data = d.long, type = 'l', ylab = 'PPT | U (mm)')


