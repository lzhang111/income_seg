# Laura Zhang
# This will read in the 2010 census tracts shapefile
# and save relevant as csv file

library(sp)  # classes for spatial data
library(rgeos)
library(rgdal)
library(dplyr)

# set directory
setwd("~/Documents/income_seg")

tracts2010 = readOGR(dsn="./raw/nhgis/tract2010 - 2010 TL", layer="US_tract_2010")
tracts2010.df = as.data.frame(tracts2010)
tracts2010.df$trtid10 = paste0(tracts2010.df$STATEFP10, tracts2010.df$COUNTYFP10, tracts2010.df$TRACTCE10)
write.table(tracts2010.df, file="./raw/nhgis/tract2010 - 2010 TL/tracts_data.csv", row.names = F)
