# generate a plotprofileDendrogram() example as a chapter figure

library(aqp)
library(soilDB)
library(sharpshootR)
library(cluster)
library(RColorBrewer)

# fetchSDA data example for data used in catena figure
# pull in the component data for two adjacent mapunits to build a combined catena concept
# ridgeline mapunit encompassing summit/shoulder positions 
# and a sideslope unit with overlapping shoulder/backslope/footslope/toeslope positions
x <- fetchSDA(WHERE = "mukey IN(2501629, 2501617)")

table(x$texture)

d <- strsplit(x$texture, '-')
d.fix <- sapply(d, function(i) if(length(i) > 1) i[2] else i[1])
x$texture_class <- d.fix


# order field texture according to particle size
# note: leaving out "in-lieu-of" texture classes for organic soil material and bedrock
x$texture_class <- factor(x$texture_class, ordered = TRUE, levels = SoilTextureLevels())
x$texture_class <- droplevels(x$texture_class)

# make a copy without ordering
x$texture_class_nominal <- factor(x$texture_class, levels=sort(as.character(unique(x$texture_class)), decreasing = TRUE), ordered = FALSE)

# graphical check
par(mar=c(0,1,3,1))
plot(x, color='texture_class', label='compname')

# make a fake horizon-level attr, until #7 is fixed
x$constant <- rep(1, times=nrow(x))

# compute pair-wise distances using texture class (ordered factor)
d.hz <- profile_compare(x, vars=c('texture_class', 'constant'), max_d=100, k=0, rescale.result=TRUE)
# divisive hierarchical clustering
dd.hz <- diana(d.hz)

# plot dendrogram + profiles
par(mar=c(1,0,3,1))
plotProfileDendrogram(x, dd.hz,  width=0.25, color='texture_class', label='compname', cex.name=0.65)

# compute pair-wise distances using:
# hz attributes: texture class (ordered factor) and rock frag volume
# site attributes: surface slope and elevation
d.hz.site <- profile_compare(x, vars=c('texture_class_nominal', 'total_frags_pct', 'slope_r', 'hillslopeprof', 'slopeshape'), max_d=100, k=0)
# divisive hierarchical clustering
dd.hz.site <- diana(d.hz.site)

# plot dendrogram + profiles
par(mar=c(2,1,3,1))
plotProfileDendrogram(x, dd.hz.site, scaling.factor = 0.008, y.offset = 0.1, width=0.15, color='texture_class', label='compname', cex.name=0.75, col.palette=brewer.pal(10, 'Spectral'))
addVolumeFraction(x, 'total_frags_pct')



###############
# similar example from the Clarksville pedons
# pull in saved dataset
x <- readRDS('C:/Github/geopedology-chapter/local-data/clarksville-pedons-final.rds')

# clean-up: remove profiles with gaps in logical horizonation sequence
x <- x[-c(13:14), ]

# subset to first 15 profiles
x <- x[1:15, ]

table(x$texcl)

# d <- strsplit(x$texture, '-')
# d.fix <- sapply(d, function(i) if(length(i) > 1) i[2] else i[1])
# x$texture_class <- d.fix


# order field texture according to particle size
# note: leaving out "in-lieu-of" texture classes for organic soil material and bedrock
x$texture_class <- factor(x$texcl, ordered = TRUE, levels = SoilTextureLevels())
x$texture_class <- droplevels(x$texture_class)

# make a copy without ordering
x$texture_class_nominal <- factor(x$texture_class, levels=sort(as.character(unique(x$texture_class)), decreasing = TRUE), ordered = FALSE)

# graphical check
par(mar=c(0,1,3,1))
plot(x, color='texture_class', label='pedon_id')

# make a fake horizon-level attr, until #7 is fixed
x$constant <- rep(1, times=nrow(x))

# compute pair-wise distances using texture class (ordered factor)
d.hz <- profile_compare(x, vars=c('texture_class', 'constant'), max_d=100, k=0, rescale.result=TRUE)
# divisive hierarchical clustering
dd.hz <- diana(d.hz)

# plot dendrogram + profiles
par(mar=c(1,0,3,1))
plotProfileDendrogram(x, dd.hz,  width=0.25, color='texture_class', label='pedon_id', cex.name=0.65)

# compute pair-wise distances using:
# hz attributes: texture class (ordered factor) and rock frag volume
# site attributes: surface slope and elevation
d.hz.site <- profile_compare(x, vars=c('texture_class_nominal', 'total_frags_pct', 'slope_field', 'hurst.redness'), max_d=100, k=0)
# divisive hierarchical clustering
dd.hz.site <- diana(d.hz.site)

# plot dendrogram + profiles
par(mar=c(2,1,3,1))
plotProfileDendrogram(x, dd.hz.site, scaling.factor = 0.008, y.offset = 0.1, width=0.15, color='hurst.redness', label='pedon_id', cex.name=0.75, col.palette=brewer.pal(10, 'Spectral'))
#addVolumeFraction(x, 'total_frags_pct')


###############
# similar example from the Clarksville lab data
# pull in saved dataset
x <- readRDS('C:/Github/geopedology-chapter/local-data/clarksville-KSSL-subset.rds')

x$hurst.redness <- hurst.redness(hue = x$m_hue, value = x$m_value, chroma = x$m_chroma)
x$hue.pos <- factor(factor(x$m_hue, levels = huePosition(returnHues = TRUE)))

# add depth to argillic
x$depth_to_argillic <- profileApply(x, FUN=function(p) minDepthOf(p, "Bt", na.rm=TRUE))

# add first discontinuity
x$depth_to_discont <- profileApply(x, FUN=function(p) minDepthOf(p, "2B", na.rm=TRUE))

# clean-up: remove profiles with gaps in logical horizonation sequence
#x <- x[-c(13:14), ]

# subset to first 15 profiles
#x <- x[1:30, ]

# subset to profiles described to >=150cm
x$depth_class <- profileApply(x, estimateSoilDepth, name = 'hzn_desgn')
table(x$depth_class)
idx <- which(x$depth_class >=150)
length(idx)
x <- x[idx, ]

x <- x[1:30, ]

# subset for all that have al_sat
# table(is.na(x$al_sat))
# idx <- which(!is.na(x$al_sat))
# length(idx)
# x <- x[idx, ]

table(tolower(x$lab_texture_class))

# d <- strsplit(x$texture, '-')
# d.fix <- sapply(d, function(i) if(length(i) > 1) i[2] else i[1])
# x$texture_class <- d.fix


# order field texture according to particle size
# note: leaving out "in-lieu-of" texture classes for organic soil material and bedrock
x$texture_class <- factor(tolower(x$lab_texture_class), ordered = TRUE, levels = SoilTextureLevels())
x$texture_class <- droplevels(x$texture_class)

# make a copy without ordering
x$texture_class_nominal <- factor(x$texture_class, levels=sort(as.character(unique(x$texture_class)), decreasing = TRUE), ordered = FALSE)

# graphical check
par(mar=c(0,1,3,1))
plot(x, color='texture_class', label='pedon_id')

# make a fake horizon-level attr, until #7 is fixed
x$constant <- rep(1, times=nrow(x))

# compute pair-wise distances using texture class (ordered factor)
d.hz <- profile_compare(x, vars=c('texture_class', 'constant'), max_d=100, k=0, rescale.result=TRUE)
# divisive hierarchical clustering
dd.hz <- diana(d.hz)

# plot dendrogram + profiles
par(mar=c(1,0,3,1))
plotProfileDendrogram(x, dd.hz,  width=0.25, color='texture_class', label='pedon_id', cex.name=0.65)

# compute pair-wise distances using:
# hz attributes: texture class (ordered factor) and rock frag volume
# site attributes: surface slope and elevation
d.hz.site <- profile_compare(x, vars=c('texture_class_nominal', 'frags', 'silt', 'hurst.redness'), max_d=150, k=0)
# divisive hierarchical clustering
dd.hz.site <- diana(d.hz.site)

# plot dendrogram + profiles
par(mar=c(2,1,3,1))
plotProfileDendrogram(x, dd.hz.site, scaling.factor = 0.5, y.offset = 0.1, width=0.15, color='texture_class_nominal', label='pedon_id', cex.name=0.75, col.palette=brewer.pal(10, 'Spectral'), order.plot = 'depth_to_discont')
#addVolumeFraction(x, 'total_frags_pct')

##############################################################
# lithology split grouped profile plot
# pull in saved dataset
#x <- readRDS('C:/Github/geopedology-chapter/local-data/clarksville-KSSL-subset.rds')
x <- fetchKSSL('clarksville') # some of these are tagged with lithology.....

# pattern match for formation names in pmgroupname strings
idx.g <- grep('Gasconade', x$pmgroupname)
length(idx.g)

idx.r <- grep('Roubidoux', x$pmgroupname)
length(idx.r)

site(x)$lithology <- NA
x$lithology[idx.g] <- 'Gasconade'
x$lithology[idx.r] <- 'Roubidoux'

idx <- which(!is.na(x$lithology))
groupedProfilePlot(x[idx, ], groups = 'lithology', group.name.cex=0.65, color='ex_k', name='hzn_desgn', id.style='side', label='pedon_id', max.depth=200)

