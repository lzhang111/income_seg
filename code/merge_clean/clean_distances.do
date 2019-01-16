* Laura Zhang
* This file cleans the csv files that contain the distances from the
* center of each census tract to the nearest highway and the CBD of
* the tract's CBSA
clear
set more off

global main `"/Users/laurazhang/Documents/income_seg/"'

** import csv files and save to dta ***
//highway
import delimited "${main}/data/raw/highway distances/highway_distances.csv", clear delimiter(" ")
gen trtid10 = string(statefips,"%02.0f") + string(countyfips,"%03.0f") + string(tractce10,"%06.0f")
save "${main}/data/temp/highway_distances.dta", replace

//cbd
import delimited "${main}/data/raw/cbd data/cbd_distances.csv", clear 
gen trtid10 = string(statefp,"%02.0f") + string(countyfp,"%03.0f") + string(tractce,"%06.0f")
save "${main}/data/temp/cbd_distances.dta", replace

** merge data **
use "${main}/data/temp/highway_distances.dta", clear
merge 1:1 trtid10 using "${main}/data/temp/cbd_distances.dta", keepusing(dist_cbd)
gen str5 county = string(statefips,"%02.0f") + string(countyfips,"%03.0f") 
ren min_* *
order state* county* tr* dist*

// add cbsa data to limit tract data to cbsas
merge m:1 county using "${main}/data/temp/cbsa_county2010_crosswalk.dta", keepusing(cbsa*) gen(merge_cbsa)

// only keep data from tracts within cbsa's
assert statefips==72 if merge_cbsa==3 & _merge==1 //only Puerto Rico is missing cbd data
drop if _merge ==1
drop *merge*
order cbsa*

save "${main}/data/temp/compiled_distances.dta", replace
