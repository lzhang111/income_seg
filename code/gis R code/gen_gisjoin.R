# Laura Zhang
# This script will open some GIS shapefiles (years 1950, 1960, 2010)
# and save the gisjoin codes to csv files 
# for use later. 

library(sp)  # classes for spatial data
library(raster)  # grids, rasters
library(rgeos)
library(rgdal)
library(dplyr)

# set directory
setwd("~/Documents/income_seg")

# read in shapefiles
tracts2010 = readOGR(dsn="./data/raw/nhgis/tract2010 - 2010 TL/", layer="US_tract_2010")
tracts2010.df <- as(tracts2010, "data.frame")

tracts1960 = readOGR(dsn="./data/raw/nhgis/tract1960 - 2000 TL/", layer="US_tract_1960")
tracts1960.df <- as(tracts1960, "data.frame")

tracts1950 = readOGR(dsn="./data/raw/nhgis/tract1950 - 2000 TL/", layer="US_tract_1950")
tracts1950.df <- as(tracts1950, "data.frame")

# output csv files with gisjoin codes and tract codes
output2010 = do.call("cbind", list(tracts2010.df['GISJOIN'], tracts2010.df['TRACTCE10'], tracts2010.df['STATEFP10'], tracts2010.df['COUNTYFP10'], tracts2010.df['Shape_area']) )
colnames(output2010) = c("gisjoin", "tractfips", "state", "county", "area")
write.table(output2010, file="./data/temp/gisjoin2010.csv", row.names = F)

output1960 = do.call("cbind", list(tracts1960.df['GISJOIN'], tracts1960.df['NHGISST'], tracts1960.df['NHGISCTY'], tracts1960.df['SHAPE_AREA']) )
colnames(output1960) = c("gisjoin", "state", "county", "area")
write.table(output1960, file="./data/temp/gisjoin1960.csv", row.names = F)

output1950 = do.call("cbind", list(tracts1950.df['GISJOIN'], tracts1950.df['NHGISST'], tracts1950.df['NHGISCTY'], tracts1950.df['SHAPE_AREA']) )
colnames(output1950) = c("gisjoin", "state", "county", "area")
write.table(output1950, file="./data/temp/gisjoin1950.csv", row.names = F)
