# Jan 2018
# Read in latlongs for CBD (central business district) of CBSA in 2010
# info and calculate distances from tract centriods to CBD

library(sp)  # classes for spatial data
library(raster)  # grids, rasters
library(maptools)
library(rgdal)
library(rgeos)

# set directory
setwd("~/Documents/income_seg")

# this is the CRS used by Census
crs_str = CRS("+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=37.5 +lon_0=-96 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs +ellps=GRS80 +towgs84=0,0,0")

# read in CBD
cbd_data <- read.csv(file="./data/raw/cbd data/cbsa2010_cbdcodes_edit.csv", header=TRUE, sep=",")
coordinates(cbd_data)=~cbdlon+cbdlat
proj4string(cbd_data)<- CRS("+init=epsg:4326")
# transform CRS of CBD data to CRS of Census
cbd_transform = spTransform(cbd_data, crs_str)

# read in center of tract data
centertracts2010 = read.csv(file="./data/raw/tract centerpop/cenpop2010_mean_tract.csv", header=TRUE, sep=",")
coordinates(centertracts2010)=~LONGITUDE+LATITUDE # set coordinates
proj4string(centertracts2010)=CRS("+proj=longlat +datum=NAD83") # set CRS
# transform to Census CRS
centertracts2010 = spTransform(centertracts2010, crs_str)

# read in crosswalk from tract to CBSA
cbsa10 <- read.csv(file="./data/temp/cbsa_county2010_crosswalk.csv", header=TRUE, sep=",")
cbsa10['county'] = sprintf("%05d",cbsa10$county)

## prepare tracts data ##
# add coordinate data to dataframe
centertracts2010_df = as.data.frame(centertracts2010)
centertracts2010_df["tractlon"]=centertracts2010@coords[,1]
centertracts2010_df["tractlat"]=centertracts2010@coords[,2]
# add county
centertracts2010_df['county'] = paste(sprintf("%02d", centertracts2010_df$STATEFP), sprintf("%03d", centertracts2010_df$COUNTYFP), sep="")
# merge in cbsa data
centertracts2010_df = merge(centertracts2010_df, cbsa10[, c("cbsa10", "county")], by="county", all.x=T)

# combine data
cbd_df = do.call("cbind", list(cbd_transform@coords[,1], cbd_transform@coords[,2], cbd_transform@data$cbsafips ))
colnames(cbd_df) = c("cbdlon", "cbdlat", "cbsa10")
final_df = merge(centertracts2010_df, cbd_df, by="cbsa10", all.x=T )

# calculate distances
final_df['dist_cbd'] = sqrt((final_df$tractlat - final_df$cbdlat)^2 + (final_df$tractlon - final_df$cbdlon)^2 )

# export to csv
final_df = subset(final_df, (!is.na(final_df[,"dist_cbd"])))
write.csv(final_df[, c(1:5, 13)], file="./data/raw/cbd data/cbd_distances.csv", row.names = FALSE)

