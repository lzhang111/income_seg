** Laura Zhang **
** Dec 2017 **
* This do file cleans the Uniform Crime Reports 1950 data on crimes for
* cities (pop >25k)
clear 
set more off
global main `"/Users/laurazhang/Documents/income_seg/"'

*******create state fips crosswalk dta file at beginning*******
import delimited "${main}/data/raw/crosswalks/statefips_crosswalk.csv", clear
save "${main}/data/temp/statefips_crosswalk.dta", replace
****************************************************

import excel using "${main}/data/raw/ucr/ucr_pop_1950.xlsx", sheet("Sheet1") firstrow clear
drop M-P

// drop empty obs
drop if fullname=="" 

// trim spaces
replace state = strltrim(state)

// some city names are incorrect
replace city = "Baton Rouge" if city=="Baton Rouse"
replace city = "Chattanooga" if city=="Chattanooea"
replace city = "Green Bay" if city=="Green Ray"
replace city = "Muncie" if city=="Muneie"
replace city = "Lafayette" if city=="La Fayette"
replace city = "Ogden" if city=="Ogdon"

// replace incorrect state
replace state = "N J" if fullname=="Woodbridge, X J"
replace state = "Ill" if state=="Ill I"
replace state = "Ky" if state=="Ivy"
replace state = "Oreg" if state=="Oreg|"
replace state = "N J" if state=="K J"
replace state = "N H" if state=="N H J"
replace state = "HI" if state=="T II"

// gen state code with official state abbrev
gen statecode = state
replace statecode = "AL" if state=="Ala"
replace statecode = "AZ" if state=="Ariz"
replace statecode = "AR" if state=="Ark"
replace statecode = "CA" if state=="Calif"
replace statecode = "CO" if state=="Colo"
replace statecode = "CT" if state=="Conn"
replace statecode = "DC" if state=="D C"
replace statecode = "DE" if state=="Del"
replace statecode = "FL" if state=="Fla"
replace statecode = "GA" if state=="Ga"
replace statecode = "ID" if state=="Idaho"
replace statecode = "IL" if state=="Ill"
replace statecode = "IN" if state=="Ind"
replace statecode = "IA" if state=="Iowa"
replace statecode = "KS" if state=="Kans"
replace statecode = "KY" if state=="Ky"
replace statecode = "LA" if state=="La"
replace statecode = "ME" if state=="Maine"
replace statecode = "MA" if state=="Mass"
replace statecode = "MD" if state=="Md"
replace statecode = "MI" if state=="Mich"
replace statecode = "MN" if state=="Minn"
replace statecode = "MS" if state=="Miss"
replace statecode = "MO" if state=="Mo"
replace statecode = "MT" if state=="Mont"
replace statecode = "NC" if state=="N C"
replace statecode = "ND" if state=="N Dak"
replace statecode = "NH" if state=="N H"
replace statecode = "NJ" if state=="N J"
replace statecode = "NM" if state=="N Mex"
replace statecode = "NY" if state=="N Y"
replace statecode = "NE" if state=="Nebr"
replace statecode = "NV" if state=="Nev"
replace statecode = "OH" if state=="Ohio"
replace statecode = "OK" if state=="Okla"
replace statecode = "OR" if state=="Oreg"
replace statecode = "PA" if state=="Pa"
replace statecode = "RI" if state=="R I"
replace statecode = "SC" if state=="S C"
replace statecode = "SD" if state=="S Dak"
replace statecode = "TN" if state=="Tenn"
replace statecode = "TX" if state=="Tex"
replace statecode = "UT" if state=="Utah"
replace statecode = "VA" if state=="Va"
replace statecode = "VT" if state=="Vt"
replace statecode = "WV" if state=="W Va"
replace statecode = "WA" if state=="Wash"
replace statecode = "WI" if state=="Wis"
replace statecode = "WY" if state=="Wyo"

** merge in state fips codes**
merge m:1 statecode using "${main}/data/temp/statefips_crosswalk.dta", keepusing(statefips) keep(1 3)
drop _merge

** drop unnecessary vars**
drop fullname state
order city state*

** gen total crime var **
egen crimetot = rowtotal(murder-autotheft), missing

** recode missing values to 0 **
recode murder-autotheft (.=0)

//exception for where larcenies are combined
replace larcenytheft_p50 = . if notes=="Larcenies combined"

***Create variable labels***
label variable murder "# of murders"
label variable robbery "# of robberies"
label variable aggassault "# of aggravated assaults"
label variable burglary "# of burglaries"
label variable larcenytheft_p50 "# of larcenies or thefts with val 50+ dollars"
label variable larcenytheft_u50 "# of larcenies or thefts with val <50 dollars"
label variable autotheft "# of autothefts"
label variable notes "# notes on missing data"
label variable pop1950 "population of urbanized area/city in 1950 from census"
label variable statecode "state 2-char abbreviation"
label variable crimetot "sum of # of crimes for each city"


** save file ***
save "${main}/data/temp/ucr1950.dta", replace
