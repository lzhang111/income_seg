* Laura Zhang
* April 2018
* Clean 1950 county data

clear
program drop _all
set more off
global main `"/Users/laurazhang/Documents/income_seg/"'
set seed 123

import delimited "${main}/data/raw/nhgis/county 1950 income pop/nhgis0013_ds83_1950_county.csv", delimiter(comma, collapse) encoding(ISO-8859-1)
ren b1n population
ren (b1t001 b1t002) (white nonwhite)

drop if mod(countya, 10)!=0
assert mod(statea, 10)==0

egen totpop = rowtotal(white nonwhite)
assert totpop==population

gen pct_white = white/population
gen pct_nonwhite = nonwhite/population

save "${main}/data/temp/temp_1950pop.dta", replace

import delimited "${main}/data/raw/nhgis/county 1950 income pop/nhgis0013_ds84_1950_county.csv", delimiter(comma, collapse) encoding(ISO-8859-1)clear
ren b2 medianincstr

gen medianinc = 0
replace medianinc = 250 if medianincstr=="$499 or less"
replace medianinc = 4500 if medianincstr=="$4,000 to $4,999"
// remove commas
replace medianincstr = subinstr(medianincstr,",","",.)

foreach income of numlist 500(500)3500 {
	local ub = `income' + 499
	
	replace medianinc = `income' + 250 if medianincstr=="$`income' to $`ub'"
}

assert medianincstr=="" if medianinc==0
drop if medianincstr==""

merge 1:1 statea countya using "${main}/data/temp/temp_1950pop.dta"
drop _merge
assert mod(statea, 10)==0
assert mod(countya, 10)==0

replace statea = statea/10
replace countya = countya/10

ren county countyname

gen str5 county = string(statea, "%02.0f") + string(countya, "%03.0f")
rename (medianinc population pct*) =_1950

save "${main}/data/temp/county1950vars.dta", replace

