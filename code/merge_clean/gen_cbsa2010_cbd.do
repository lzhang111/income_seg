* Laura Zhang
* Jan 2018
* This do file selects the main city (city with the highest population in 1950) in 1950
* for each cbsa (2010 definitions) 
global main `"/Users/laurazhang/Documents/income_seg/"'

** first clean up cbd codes csv file and convert to dta **
import excel "${main}/data/raw/cbd data/CBD_geocodes", firstrow clear
drop J-BB
replace CBSA_name = strtrim(CBSA_name)
rename *, lower
rename (cbsa_code uniqueplace) (cbsafips placecode)
keep cbsafips placecode principlecity cbd* central*

save "${main}/data/temp/cbdcodes.dta", replace

** start merging data **
import delimited "${main}/data/raw/population1950/pop1950_cbsa2010.csv", clear

gsort cbsafips -pop1950

by cbsafips: gen imaincity = 1 if _n ==1
by cbsafips: egen countcity = count(1)

// check that city is not chosen because no population data is available
gen error = 1 if  pop1950==. & countcity>1 & imaincity==1
by cbsafips: egen errorfill = total(error)
drop if errorfill==1 //drop cbsas where no population data is available, and there are multiple cities
drop error* mark countcity

keep if imaincity==1

// create unique placefips value
gen placecode = statefips*10e+4 + placefips

//merge in cbsa cbd codes 
merge 1:1 cbsafips placecode using "${main}/data/temp/cbdcodes.dta", keep (1 3) keepusing(cbd* central*)
/* note: for cities not matched in using, this is because the main city in 2010
did not exist in 1950 or had lower population in 1950 than the calculated main
city in 1950 */


export delimited "${main}/data/raw/cbd data/cbsa2010_cbdcodes.csv", replace

** add in cbd info for cities that were not matched **
