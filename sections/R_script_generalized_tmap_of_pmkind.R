library(aqp)
library(raster)
library(soilDB)
library(sf)
library(sp)
library(rgeos)
library(dplyr)
library(ggplot2)
library(ggspatial)
library(tmap)
library(tmaptools)

# take the area around a point or several points of KSSL lab data
p <- SpatialPoints(cbind(-91.0777740, 37.1502151), proj4string = CRS('+proj=longlat +datum=WGS84'))
# transform to planar coordinate system for buffering
p.aea <- spTransform(p, CRS('+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=23 +lon_0=-96 +x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs'))
# create 1000 meter buffer
p.aea <- gBuffer(p.aea, width = 2000)
# transform back to WGS84 GCS
p.buff <- spTransform(p.aea, CRS('+proj=longlat +datum=WGS84'))
# convert to sf object
p.buff.sf <- extent(st_as_sf(p.buff))
plot(p.buff.sf)
# convert bbox to polygon
p.bbox <- bb_poly(p.buff)

# request spatial intersection features
p.mu.polys <- SDA_spatialQuery(p.bbox, what = 'mupolygon', geomIntersection = TRUE)
plot(p.mu.polys)

# fetch mu comp data all the mapunits within the buffered area around KSSL point specified
sql_in <- format_SQL_in_statement(unique(p.mu.polys$mukey[1]))

## DEB: maybe set duplicates = TRUE to keep mukey
component_data <- fetchSDA(WHERE = paste("mukey IN", sql_in, sep=""))


### CONFIG: SOIL SURVEY AREA
soil_survey_area <- "MO203"

### CONFIG: TAXONOMIC SUBGROUP (or other grouping)
# NOTE: that these arguments are customization without changing source data
mapunit_level <- "nationalmusym"
group_level <- "pmkind"              
taxonomic_level <- "taxorder"
majors_only <- TRUE


# get spatial data (based on nmusyms in component data)
# NOTE: not the same results returned by fetchSDA_spatial and SDA_spatialQuery
#spatial_data <- st_as_sf(SDA_spatialQuery(component_data[[mapunit_level]], by.col = "nmusym"))
spatial_data <- st_as_sf(fetchSDA_spatial(component_data[[mapunit_level]], by.col = "nmusym")) # takes a while
#spatial_data <- st_as_sf(SDA_spatialQuery(p.bbox, what = 'mupolygon', geomIntersection = TRUE)) 
#SDA_spatialQuery would be faster but doesn't bring in the same columns?  nationalmusym for example
#spatial_data$mukey <- as.character(spatial_data$mukey)



# # save time and stress on SDA server by caching individual SSAs 
#cache_file_name <- paste0(soil_survey_area, ".rda")
# if (!file.exists(cache_file_name)) {
#   # get component data
#   component_data <- fetchSDA(sprintf("areasymbol = '%s'", soil_survey_area))
#   #component_data <- subset(component_data, !is.na(component_data[[group_level]])) # this removes all miscellaneous areas
# 
#     # get spatial data (based on nmusyms in component data)
#   spatial_data <- st_as_sf(fetchSDA_spatial(component_data[[mapunit_level]], by.col = "nmusym"))
#   
#   save(component_data, spatial_data, file = cache_file_name)
# } else {
#   load(cache_file_name)
# }

if (majors_only) {
  major_component_data <- subset(component_data, majcompflag == "Yes")
} else major_component_data <- component_data 

# further pattern matching within the specified group_level
idx <- grep('', site(major_component_data)[[group_level]], ignore.case = TRUE)
length(idx)
major_component_data <- major_component_data[idx, ]
major_component_data[[group_level]] <- droplevels(major_component_data[[group_level]])
table(major_component_data$pmkind)


spc2dominant_condition <-  function(spc,  
                                    weight_field = "comppct_r",
                                    condition_field,
                                    condition_value = NULL,
                                    mapunit_field = "mukey") { 
  
  # NB: dplyr double {{embrace}} for NSE of arguments
  
  step1 <- site(spc)[,c(mapunit_field,condition_field,weight_field)] %>%
    group_by(across(c({{ mapunit_field }}, {{condition_field}}))) %>%
    summarize(across({{ weight_field }}, sum)) %>%
    slice(which({{ weight_field }} == max({{ weight_field }})))
  
  if (!is.null(condition_value))
    return(filter(step1, grepl(x = across(all_of({{ condition_field }})), 
                               pattern = {{ condition_value }})))
  
  return(step1)
}

get_poly_from_SPC <- function(spc, spat, 
                              weight_field = "comppct_r",
                              condition_field,
                              condition_value = NULL,
                              mapunit_field = "mukey") { 
  spat.dominant <- spc2dominant_condition(spc, weight_field, condition_field, condition_value, mapunit_field)
  
  # this compares field levels between spatial and spc
  #  and then determines which of those correspond with a dominant condition
  spat.matches <- spat[[mapunit_field]] %in% spc[[mapunit_field]]
  spat.is_dominant <- spat[[mapunit_field]] %in% spat.dominant[[mapunit_field]]
  
  spat[spat.matches & spat.is_dominant,]
}


# make extent map of all Ultic Haploxeralfs (or other target condition value)
display_extent <- get_poly_from_SPC(major_component_data, spatial_data,
                                    condition_field = group_level,
                                    condition_value = taxonomic_level)

# calculate the dominant condition for all nmusyms
dom_group <- spc2dominant_condition(major_component_data, condition_field = group_level)

# set order for dominant condition - order by occurrence or by area extent
dput(dimnames(sort(table(dom_group[[group_level]]), decreasing = FALSE)))
# lev <- paste(dimnames(sort(table(dom_group[[group_level]]), decreasing = FALSE)), sep=', ')
# lev <- gsub('\"', '"', lev)
# lev

# hack! clean this up later.....pasted the above into levels here.....these for pmgroupname are messy! 
# dom_group[[group_level]] <- factor(dom_group[[group_level]], levels = c("gravelly slope alluvium", 
#                                                                         "loess over pedisediment over chert", 
#                                                                         "loess over slope alluvium", 
#                                                                         "residuum weathered from dolomite", 
#                                                                         "residuum weathered from sandstone", 
#                                                                         "sandy and gravelly alluvium", 
#                                                                         "slope alluvium over chert", 
#                                                                         "slope alluvium over gravelly pedisediment over residuum weathered from limestone and sandstone", 
#                                                                         "slope alluvium over residuum weathered from dolomite over dolomite", 
#                                                                         "loess over slope alluvium over residuum weathered from dolomite", 
#                                                                         "slope alluvium over pedisediment over residuum weathered from dolomite", 
#                                                                         "slope alluvium over residuum weathered from cherty limestone", 
#                                                                         "gravelly alluvium", 
#                                                                         "slope alluvium over residuum weathered from dolomite"))
# pmkind levels
dom_group[[group_level]] <- factor(dom_group[[group_level]], levels = c("Loess over Slope alluvium", 
                                                                        "Slope alluvium",
                                                                        "Alluvium", 
                                                                        "Slope alluvium over pedisediment over residuum",
                                                                        "Slope alluvium over Residuum"))
#
# pmorigin levels
#dom_group[[group_level]] <- factor(dom_group[[group_level]], levels = c("Sandstone", "Chert", "Cherty limestone", "Dolomite"))


# calculate those matching user input
dom_group_match <- filter(dom_group, across({{ group_level }}) == taxonomic_level)

table(dom_group_match$pmkind)


# subset the SPC to get just the matching/target components
dominant_components <- subset(major_component_data, 
                              major_component_data[[mapunit_level]] %in% 
                                dom_group_match[[mapunit_level]])

# additional mappings for cleaner legend output
table(major_component_data$pmkind)
idx <- which(major_component_data$pmkind == 'Slope alluvium over Pedisediment over Residuum')
length(idx)
major_component_data$pmkind[idx] <- 'Slope alluvium over Residuum'

# handle nulls for category
idx <- which(is.na(major_component_data$pmkind))
length(idx)
             
# no constraint on condition value; get all the polygons with group_level
display_extent_all <- get_poly_from_SPC(major_component_data, spatial_data, 
                                        condition_field = group_level,
                                        condition_value = NULL)

display_extent_all <- merge(display_extent_all, dom_group)

# clip the mupolygons to the SSA boundary
mu_extent <- st_intersection(display_extent_all, p.bbox)


# create graphic with tmap
library(tmap)
tm_shape(mu_extent) + tm_fill(title = 'Parent Materials', col = group_level, palette="Oranges", legend.reverse = FALSE, alpha= 0.95) + 
  tm_shape(p.bbox) + tm_borders(col = "black", lwd=2) + 
  tm_layout(main.title = "Dominant Parent Materials \nOzark Highlands", main.title.size = 1.25, main.title.position = "center", legend.title.size = 1, title.snap.to.legend = TRUE, legend.bg.color = "white", legend.outside.position = "top")

# TODO: overlay on hillshade?
# get DEM of the bbox area
x <- get_elev_raster(p.bbox, z = 14, src = "aws", clip = "locations")
hs <- raster::hillShade(slope = raster::terrain(x, "slope"), 
                       aspect = raster::terrain(x, "aspect"))

#+ tm_raster(hs, palette = "gray")  # not working

# TODO: add these points to tmap for Lab data sites
p86 <- SpatialPoints(cbind(-91.0777740, 37.1502151), proj4string = CRS('+proj=longlat +datum=WGS84'))
p85 <- SpatialPoints(cbind(-91.0783463, 37.1496849), proj4string = CRS('+proj=longlat +datum=WGS84'))
p84 <- SpatialPoints(cbind(-91.0787048, 37.1487923), proj4string = CRS('+proj=longlat +datum=WGS84'))







