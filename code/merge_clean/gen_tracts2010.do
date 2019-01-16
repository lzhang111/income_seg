* Laura Zhang
* This do file converts the dataframes of the shapefiles into
* dta files for use in Stata

clear
set more off

global main `"/Users/laurazhang/Documents/income_seg/"'
import delimited "${main}/data/raw/nhgis/tract2010 - 2010 TL/tracts_data.csv", clear delimiter(" ")

drop trtid10
gen str11 trtid10 = string(geoid10, "%011.0f")

save "${main}/data/temp/tracts2010.dta", replace
