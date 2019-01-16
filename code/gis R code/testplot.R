# Laura Zhang 
# Feb 2018
# some test plots of income and highways lines

# load packages
library(sp)  # classes for spatial data
library(raster)  # grids, rasters
library(rasterVis)  # raster visualisation
library(maptools)
library(rgeos)
library(rgdal)
library(dplyr)
library(stringr)
library(classInt)
library(RColorBrewer)

# set directory
setwd("~/Documents/income_seg")

# shapefiles
tracts2010 = readOGR(dsn="./raw/nhgis/tract2010 - 2010 TL", layer="US_tract_2010")
highways = readOGR(dsn="/Volumes/lzhang96/income_seg", layer="highway_lines")
bs_highway = readOGR(dsn="/Volumes/lzhang96/income_seg", layer="baumsnow_final")

# CRS used by census
crs_str = CRS("+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=37.5 +lon_0=-96 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs +ellps=GRS80 +towgs84=0,0,0")

# transform highways CRS
highways = spTransform(highways, crs_str)
bs_highway = spTransform(bs_highway, crs_str)

# median income data
trmedianinc = read.csv(file="./temp/medianinc_plot.csv", header=TRUE, sep=",")
trmedianinc$GEOID10 = str_pad(trmedianinc$geo2010, width = 11, side="left", pad="0") 
tracts2010@data = left_join(tracts2010@data, trmedianinc, by ="GEOID10")

# this is just a plot for the paper showing the highway lines
chicago_all.tracts <- tracts2010[(tracts2010$cbsa10==16980) & (!is.na(tracts2010$cbsa10)), ]
trellis.par.set(axis.line=list(col=NA)) 
spplot(chicago_all.tracts, "Shape_area", 
       col="gray83", lwd=0.2, col.regions = "white", colorkey=FALSE, sp.layout = list(list("sp.lines", highways, col="green", first=FALSE), 
                        list("sp.lines", bs_highway, col="purple", first=FALSE) ), 
       par.settings = list(panel.background=list(col="gray90")) )

# plots for cities
stlouis.tracts <- tracts2010[(tracts2010$cbsa10==41180) & (!is.na(tracts2010$diff_pct)), ]
losangeles.tracts <- tracts2010[(tracts2010$cbsa10==31100) & (!is.na(tracts2010$dtrpct_inc_qtl1)), ]
chicago.tracts <- tracts2010[(tracts2010$cbsa10==16980) & (!is.na(tracts2010$cbsa10)), ]
newyork.tracts <- tracts2010[(tracts2010$cbsa10==35620) & (!is.na(tracts2010$diff_pct)), ]
austin.tracts <- tracts2010[(tracts2010$cbsa10==12420) & (!is.na(tracts2010$diff_pct)), ]
seattle.tracts <- tracts2010[(tracts2010$cbsa10==42660) & (!is.na(tracts2010$diff_pct)), ]
boston.tracts <- tracts2010[(tracts2010$cbsa10==14460) & (!is.na(tracts2010$dtrpct_inc_qtl5)), ]

# houston data
houston.tracts1950 <- tracts2010[(tracts2010$cbsa10==26420) & (!is.na(tracts2010$pct_inc_qtl11950)), ]
houston.tracts1980 <- tracts2010[(tracts2010$cbsa10==26420) & (!is.na(tracts2010$pct_inc_qtl11980)), ]
houston.qt1950 <- classIntervals(houston.tracts1950$pct_inc_qtl11950, n = 9, style = "quantile", intervalClosure = "left")
houston.qt1980 <- classIntervals(houston.tracts1980$pct_inc_qtl11980, n = 9, style = "quantile", intervalClosure = "left")

my.palette <- brewer.pal(n = 9, name = "OrRd")

# houston plots
spplot(houston.tracts1950, "pct_inc_qtl11950", 
       col="transparent", col.regions = my.palette,
       at = houston.qt1950$brks,
       par.settings = list(panel.background=list(col="grey")) )

spplot(houston.tracts1980, "pct_inc_qtl11980", 
       col="transparent", col.regions = my.palette,
       at = houston.qt1980$brks,
       sp.layout = list(list("sp.lines", highways, col="green", first=FALSE), 
                        list("sp.lines", bs_highway, col="purple", first=FALSE) ), 
       par.settings = list(panel.background=list(col="grey")) )



# not used
spplot(stlouis.tracts, "diff_pct", 
       main = "% Change in Median Income from 1950-2000", 
       col="transparent", at = breaks.qt$brks, col.regions = my.palette,
       sp.layout = list(list("sp.lines", highways, col="green", first=FALSE), 
                        list("sp.lines", bs_highway, col="purple", first=FALSE) ), 
       par.settings = list(panel.background=list(col="grey")) )

spplot(losangeles.tracts, "dtrpct_inc_qtl1", 
       main = "Absolute Change in % of Lowest Quintile Families in Tract, from 1950-2000",
       col="transparent", at = breaks_dtrpct$brks, col.regions = my.palette,
       sp.layout = list(list("sp.lines", highways, col="green", first=FALSE), 
                        list("sp.lines", bs_highway, col="purple", first=FALSE) ),
       par.settings = list(panel.background=list(col="grey")) )


spplot(newyork.tracts, "diff_pct", 
       main = "% Change in Median Income from 1950-2000", 
       col="transparent", at = breaks.qt$brks, col.regions = my.palette,
       sp.layout = list(list("sp.lines", highways, col="green", first=FALSE), 
                        list("sp.lines", bs_highway, col="purple", first=FALSE) ),
       par.settings = list(panel.background=list(col="grey")) )

spplot(houston.tracts, "dtrpct_inc_qtl1", 
       main = "Absolute Change in % of Lowest Quintile Families in Tract, from 1950-2000",
       col="transparent", at = breaks_dtrpct$brks, col.regions = my.palette,
       sp.layout = list(list("sp.lines", highways, col="green", first=FALSE), 
                        list("sp.lines", bs_highway, col="purple", first=FALSE) ),
       par.settings = list(panel.background=list(col="grey")) )


spplot(austin.tracts, "diff_pct", 
       main = "% Change in Median Income from 1950-2000", 
       col="transparent", at = breaks.qt$brks, col.regions = my.palette,
       sp.layout = list(list("sp.lines", highways, col="green", first=FALSE), 
                        list("sp.lines", bs_highway, col="purple", first=FALSE) ),
       par.settings = list(panel.background=list(col="grey")) )

spplot(seattle.tracts, "diff_pct", 
       main = "% Change in Median Income from 1950-2000", 
       col="transparent", at = breaks.qt$brks, col.regions = my.palette,
       sp.layout = list(list("sp.lines", highways, col="green", first=FALSE), 
                        list("sp.lines", bs_highway, col="purple", first=FALSE) ),
       par.settings = list(panel.background=list(col="grey")) )

spplot(boston.tracts, "dtrpct_inc_qtl5", 
       main = "Absolute Change in % of Highest Quintile Families in Tract, from 1950-2000", 
       col="transparent", at = breaks_dtrpct$brks, col.regions = my.palette,
       sp.layout = list(list("sp.lines", highways, col="green", first=FALSE), 
                        list("sp.lines", bs_highway, col="purple", first=FALSE) ),
       par.settings = list(panel.background=list(col="grey")) )




