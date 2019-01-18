* Laura Zhang
* This do files merges the city level UCR crime data 
* to 2010 CBSA definitions using the principal cities of
* the cbsa's as defined by the census
clear
set more off

global main `"/Users/laurazhang/Documents/income_seg/"'

use "${main}/data/temp/ucr1950.dta"


//check that cities are unique
egen tagcity = tag(city statecode)
assert tagcity==1
drop tagcity
gen id = _n //unique id

//try to merge using cityname to cbsa's principal cities
ren city cityshort
reclink cityshort statecode using "${main}/data/temp/cbsa_pcities2010_crosswalk.dta", idmaster(id) ///
	idusing(idno) required(statecode) gen(mscore)

//some of the matches are wrong
gsort -mscore
drop if Ucityshort=="Millville"
drop if Ucityshort=="Marietta"
drop if Ucityshort=="Hammonton"
drop if Ucityshort=="Naperville"
drop if Ucityshort=="Portage"
drop if Ucityshort=="South San Francisco"
drop if mscore<0.7 | mscore==.


*******THIS CODE USED FOR DATASET USED ELSEWHERE******************************
******************************************************************************

//save crosswalk of pop 1950 to cbsa 2010
preserve
ren Ucityshort cityname
keep cityname city statecode statefips pop1950 cbsa cbsafips

egen tag = tag(city cbsafips) 
drop if city=="Union, NJ" & pop1950==.
drop tag

merge 1:1 city cbsafips using "${main}/data/temp/cbsa_pcities2010_crosswalk.dta"
assert cityname==cityshort if cityname!=""
drop idno cityname _merge
drop if statecode=="PR" // drop puerto rico

** mark which cbsas need population data to order by population
sort cbsafips city
by cbsafips: egen countcity = count(1)
gen mark = 0
//cbsas with only one city do not have an order
replace mark =1 if countcity!=1 & pop1950==.
drop countcity

order city* state* cbsa*

export delimited "${main}/data/raw/population1950/pop1950_cbsa2010.csv", replace
restore
******************************************************************************

//drop unnecessary vars
drop id* mscore _merge Ucityshort statecode
rename Ustatecode statecode //statecode is more accurate from using data

//keep cbsa level data
order city* cbsa* place*
collapse (sum) murder-autotheft pop1950 crimetot, by(cbsafips cbsa)

//generate state variables (or combination of states)
gen state = substr(cbsa, strpos(cbsa, ", ") + 2, .)
replace state = subinstr(state, " Metropolitan Statistical Area", "",.)
compress state
order state

//calculate crime rate
gen crimerate50 = crimetot/pop1950 //crime counts and population is absolute
replace crimerate50 = crimerate50*1000 //crimes per 1000 people

rename cbsafips cbsa10
save "${main}/data/temp/ucr1950_cbsa2010.dta", replace
