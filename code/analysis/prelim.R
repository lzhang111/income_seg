# Laura Zhang 
# August 2017
# some basic plots of data

# load packages
library(sp)  # classes for spatial data
library(raster)  # grids, rasters
library(rasterVis)  # raster visualisation
library(maptools)
library(rgeos)
library(rgdal)
library(dplyr)

# set directory
setwd("~/Documents/income_seg")

# open datasets
raw = read.csv("clean/cleanincrace.csv")
attach(raw)
raw$pct_f30k = (finc10k + finc15k + finc20k + finc25k + finc30k)/totpop
raw$pct_f20k = (finc10k + finc15k + finc20k)/totpop
detach(raw)
incdata = raw[raw$YEAR==1990, c("GISJOIN", "pct_f20k")]

# set crs projection strings
crs_str = CRS("+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=37.5 +lon_0=-96 +x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs")
crswgs84 = CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")

# read shape file and transform
tracts = readOGR(dsn="./raw/nhgis/tract1990/", layer="tracts1990")
tracts_trans = spTransform(tracts, crswgs84)

# join shape file with data
tractsdata = left_join(tracts@data, incdata, by="GISJOIN" )
texas.tracts <- tracts[(tracts$STATE==48) & (!is.na(tracts$STATE)), ]
texas.tracts$pct_f20k <- (tractsdata %>% filter(STATE==48 & !is.na(STATE)))$pct_f20k

# basic plot of poverty
spplot(texas.tracts, "pct_f20k", main = "Percentage of Families with Income <20K", col="transparent")
