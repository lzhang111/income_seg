* Laura Zhang
* Jan 2018
* This do file creates a crosswalk from 2010 counties to 2010 cbsa definitions

clear
set more off
global main `"/Users/laurazhang/Documents/income_seg/"'

import delimited "${main}/data/raw/crosswalks/cbsafips2010.csv", varnames(1) clear 

gen tag = 1 if strpos(name, "Division")>0
egen tagdiv = tag(div10)

//some checks 
assert tag==tagdiv if tagdiv==1
assert tag==tagdiv if tag==1

// create metdiv variable
gen metdivname = name if tagdiv==1 
//fill metdiv
replace metdivname = metdivname[_n-1] if metdivname=="" & div10!=.
drop tag*

//drop empty obs
drop if cbsa10==.

//reshape cbsa manually
egen tagcbsa = tag(cbsa10)
gen cbsaname = name if tagcbsa==1
order cbsaname

//fill cbsa
replace cbsaname = cbsaname[_n-1] if cbsaname==""

** reshape cnty manually **
gen cnty = name if county10!=.
order cnty
drop if county10==.

** drop unnecessary vars **
drop name tagcbsa

** only keep counties in metropolitan statistical areas
keep if strpos(cbsaname, "Metropolitan") > 0

** create 5 digit county code **
gen str5 county = string(county10, "%05.0f") //pad with zeros to create 5 digit county code

** split county name into county and state
split cnty, p(", ")
ren (cnty1 cnty2) (countyname statecode)
drop cnty

gen idno = _n //unique id for use later
save "${main}/data/temp/cbsa_county2010_crosswalk.dta", replace
export delimited "${main}/data/temp/cbsa_county2010_crosswalk.csv", replace
