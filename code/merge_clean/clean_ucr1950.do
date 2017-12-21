** Laura Zhang **
** Dec 2017 **
* This do file cleans the Uniform Crime Reports 1950 data on crimes for
* cities (pop >25k)
clear 
set more off
global main `"/Users/laurazhang/Documents/income_seg/"'

*******create crosswalk dta file at beginning*******
import delimited "${main}/raw/crosswalks/statefips_crosswalk.csv", clear
save "${main}/temp/statefips_crosswalk.dta", replace
****************************************************

import excel using "${main}/raw/ucr/ucr1950.xlsx", sheet("Sheet1") firstrow clear
drop L-P

// drop empty obs
drop if fullname=="" 

// trim spaces
replace state = strltrim(state)

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
merge m:1 statecode using "${main}/temp/statefips_crosswalk.dta", keepusing(statefips) keep(1 3)
drop _merge

** merge in sma 1950 codes for cities**
//note that cities do not exactly correspond to SMAs
//also there are more cities than SMAs since
//cities in UCR have >25k pop while SMAs must have
//>50k pop
/* 
TO DO 
*/

** drop unnecessary vars**
drop fullname state
order city state*


** save file ***
save "${main}/clean/ucr1950.dta", replace
