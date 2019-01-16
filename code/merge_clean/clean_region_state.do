* Laura Zhang 
* Jan 2017
* This do file will clean the region
* and divisions for each state
clear
set more off
program drop _all

global main `"/Users/laurazhang/Documents/income_seg/"'
global temp `"${main}/data/temp/"'

import delimited "${main}/data/raw/crosswalks/reg_div.csv", encoding(ISO-8859-1)
rename (v1 v2) (name statefips)

//reshape data
gen region = name if strpos(name, "REGION") > 0
replace region = region[_n -1] if region ==""
gen division = name if strpos(name, "Division") > 0
replace division = division[_n -1] if division ==""

//clean up strings
replace region = substr(region, 10,.)
replace region = subinstr(region, "*", "",.)
replace division = substr(division, 12,.)

drop if statefips==.

replace name = strtrim(name)
replace division = strtrim(div)
replace region = strtrim(region)

compress name division region
rename name statename

save "${temp}/region_state_xwalk", replace
