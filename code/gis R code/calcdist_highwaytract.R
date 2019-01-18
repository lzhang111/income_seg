# Jan 2018
# read in census tract gis files and highway lines gis files
# to calculate distance from census tract (centroid) to
# nearest highway

library(sp)  # classes for spatial data
library(raster)  # grids, rasters
library(rasterVis)  # raster visualisation
library(maptools)
library(rgeos)
library(rgdal)
library(dplyr)

# set directory
setwd("~/Documents/income_seg")

# this is the CRS used by Census
crs_str = CRS("+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=37.5 +lon_0=-96 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs +ellps=GRS80 +towgs84=0,0,0")

# read in files
centertracts2010 = read.csv(file="./data/raw/tract centerpop/cenpop2010_mean_tract.csv", header=TRUE, sep=",")
coordinates(centertracts2010)=~LONGITUDE+LATITUDE # set coordinates
proj4string(centertracts2010)=CRS("+proj=longlat +datum=NAD83") # set CRS

highways = readOGR(dsn="./data/raw/gis", layer="highway_lines")
yellowbook = readOGR(dsn="./data/raw/gis", layer="yellowbook_lines")
bs_highway = readOGR(dsn="./data/raw/gis", layer="baumsnow_final")

# change data CRS
highways = spTransform(highways, crs_str)
bs_highway = spTransform(bs_highway, crs_str)
centertracts2010 = spTransform(centertracts2010, crs_str)

# calculate distances from tracts to nearest highway lines
dist_highway = gDistance(centertracts2010, highways, byid=TRUE)
dist_yellowbook = gDistance(centertracts2010, yellowbook, byid=TRUE)
dist_bs_highway = gDistance(centertracts2010, bs_highway, byid=TRUE)
  
# get minimum distances
min_disthighway = apply(dist_highway, 2, min)
min_distyellowbook = apply(dist_yellowbook, 2, min)
min_distbshighway = apply(dist_bs_highway, 2, min)

# generate output files
distances = do.call("cbind", list(min_disthighway, min_distyellowbook, min_distbshighway, centertracts2010@data$STATEFP, centertracts2010@data$COUNTYFP, centertracts2010@data$TRACTCE) )
colnames(distances) = c("min_disthighway", "min_distyellowbook", "min_distbshighway", "statefips", "countyfips","TRACTCE10")

# save to csv file
write.table(distances, file="./data/raw/highway distances/highway_distances.csv", row.names = F)
