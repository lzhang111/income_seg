** Laura Zhang **
** Dec 2017 **
** This do file creates a crosswalk from 2010 cbsas to 2010 principal cities
** and cleans and reformats the cbsa_principalcities2010.xlsx file in raw/crosswalks
clear 
set more off
global main `"/Users/laurazhang/Documents/income_seg/"'

** import data **
import excel "${main}/data/raw/crosswalks/cbsa_principalcities2010.xlsx", sheet("Sheet1") firstrow clear

** drop empty obs**
drop if cbsafips==.

** reshape cbsa manually **
egen tagcbsa = tag(cbsafips)
gen cbsa = name if tagcbsa==1
order cbsa

//fill cbsa
replace cbsa = cbsa[_n-1] if cbsa==""

** reshape city manually **
gen city = name if placefips!=.
order city
drop if placefips==.

** drop unnecessary vars **
drop name tagcbsa

** only keep cities in metropolitan statistical areas
keep if strpos(cbsa, "Metropolitan") > 0

** clean up city and cbsa string **
replace city = subinstr(city, " (balance)", "",.)
replace city = subinstr(city, " (part)", "",.)
replace city = subinstr(city, "Sebasti·n", "Sebastian",.)
replace cbsa = subinstr(cbsa, "Sebasti·n", "Sebastian",.)

** split city name into city and state
split city, p(", ")
ren (city1 city2) (cityshort statecode)
gen idno = _n //unique id for use later
save "${main}/data/temp/cbsa_pcities2010_crosswalk.dta", replace

//check that cities are unique
egen tagcity = tag(city)
assert tagcity==1
