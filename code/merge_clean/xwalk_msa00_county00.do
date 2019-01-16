* Jan 2018
* Laura Zhang
* This do file creates a crosswalk from 2000 MSA definitions 
* to 2000 county definitions
clear 
set more off

global main `"/Users/laurazhang/Documents/income_seg/"'

import delimited "${main}/data/raw/crosswalks/msafips2000.csv", clear

//drop empty obs
drop if name==""

**reshape cbsa manually
egen tagpmsa = tag(pmsafips)
egen tagcmsa = tag(cmsafips)
assert cmsafips!=. if pmsafips!=.

gen cmsaname = name if tagcmsa==1
replace cmsaname = cmsaname[_n-1] if cmsaname=="" & cmsafips!=. //fill cmsa
drop if tagcmsa==1 //drop cmsa obs, we'll use pmsa instead

egen tagmsa = tag(msafips)
gen msaname = name if tagmsa==1 | tagpmsa==1
replace msaname = msaname[_n-1] if msaname==""  //fill msa

// create the msa variable that uses pmsa
gen msafinal = msafips if pmsafips==.
replace msafinal = pmsafips if pmsafips!=.
order msafinal

**reshape cnty manually
gen cnty = name if countyfips!=.
order cnty
drop if countyfips==.

//drop cities within counties
egen tagcnty = tag(countyfips)
assert tagcnty==0 if cityfips!=. //if obs is city, should not be first county obs
drop if cityfips!=.

//drop unnecessary vars **
drop name tag* cityfips flag

**create 5 digit county code **
gen str5 county = string(countyfips, "%05.0f") //pad with zeros to create 5 digit county code

** clean up county name
replace cnty = subinstr(cnty, " (pt.)", "",.)

** split county name into county and state
split cnty, p(", ")
ren (cnty1 cnty2) (countyname statecode)
drop cnty statecode //don't need statecode

save "${main}/data/temp/msa_county00_crosswalk.dta", replace




