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
library(ggplot2)
library(ggspatial)

# get basic sensor metadata for SCAN/SNOTEL site
m <- SCAN_site_metadata(site.code=c(2194))

p.jr <- SpatialPoints(cbind(m$Longitude, m$Latitude), proj4string = CRS('+proj=longlat +datum=WGS84'))

# fetchSCAN 
x <- fetchSCAN(site.code=c(2194), year=c(2018))

# comes in with multiple sensors - pair this down to one set for simplicity
idx <- grep('-', x$SMS$sensor.id)
x <- x$SMS[-idx, ]
nrow(x)

#x$doy <- strftime(x$SMS$date, format = "%j")

head(x$SMS)

# get KSSL data - soil sampled here is Scholten
s <- fetchKSSL(pedon_id = 'S2012MO067001')


# run water balance on SCAN site station locations
d.jr <- dailyWB_SSURGO(
  p.jr,
  cokeys = NULL,
  start = 2018,
  end = 2018,
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

# idea - tag sensor depth with hzname from the SCAN site lab sampled pedon
# TODO: add column with concat of sensor depth and hzname, use this column for the plotting group legend for SMS
# slab/slice at sensor depths to attach hzn_desgn and any other data clay, whc, water retention, etc to the joined SCAN and WB data


# combine sensors of interest
#g <- make.groups('soil moisture'=d)

# generate a better axis for dates
date.axis <- seq.Date(as.Date(min(d$Date)), as.Date(max(d$Date)), by='1 months')

# assign a label field
#d$depth <- 'soil moisture'
sensor.depths <- unique(d$depth)

xyplot(value ~ Date | factor(Site), groups=factor(depth), data=d, as.table=TRUE, type=c('l','g'), auto.key=list(columns=length(sensor.depths), lines=TRUE, points=FALSE), strip=strip.custom(bg=grey(0.80)), scales=list(alternating=3, x=list(at=date.axis, format="%b\n%Y"), y=list(relation='free', rot=0)), ylab='', main='Soil Moisture at sensor depths (cm)')


