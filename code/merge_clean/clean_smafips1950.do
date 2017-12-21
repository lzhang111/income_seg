** Laura Zhang **
** Dec 2017 **
** This do file cleans and reformats the smafips1950.txt file in raw/crosswalks
clear 
set more off
global main `"/Users/laurazhang/Documents/income_seg/"'

** import data **
import excel "${main}/raw/crosswalks/sma1950fips.xlsx", sheet("Sheet1") firstrow clear

** drop towns **
drop if C!=""
drop C

** drop empty obs**
drop if smafips==""

** trim fips codes**
replace smafips = ustrtrim(smafips)
replace countyfips = ustrtrim(countyfips)

** change fips codes to int**
destring smafips, replace
destring countyfips, replace

** reshape sma manually **
egen tagsma = tag(smafips)
order tagsma

gen sma = name if tagsma==1
order sma
//fill sma
replace sma = sma[_n-1] if sma==""

** reshape count manually **
gen county = name if countyfips!=.
order county
drop if countyfips==.

** drop unnecessary vars **
drop name tagsma

** clean up sma string **
gen smaclean = subinstr(sma," SMA","",.)
drop sma
rename smaclean sma

save "${main}/temp/sma1950fips_crosswalk.dta", replace
