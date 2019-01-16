* Laura Zhang
* Feb 2018
* This do file creates consistent crosswalks of counties
* from 1950 to 2000 all to 2010 boundaries

clear
set more off

program drop _all

global main `"/Users/laurazhang/Documents/income_seg/"'
global temp `"${main}/data/temp/"'

foreach year of numlist 1950(10)2000  {
	if `year'<1970 {
		use "${main}/data/temp/crosswalk_`year'_2010", clear
	}
	else {
		use "${main}/data/raw/crosswalks/LTDB crosswalks and code/crosswalk_`year'_2010", clear
	}
	
	local yearsub = substr("`year'", 3, 2)
	
	gen county`year' = substr(trtid`yearsub', 1, 5)
	gen county2010 = substr(trtid10, 1, 5)
	
	bys county`year': egen numtracts`year' = sum(weight)
	
	collapse (mean) numtracts`year' (sum) weight, by(county`year' county2010)
	
	gen countyweight = weight/numtracts`year'
	gsort county`year' -countyweight
	by county`year': gen tag = 1 if abs(countyweight-1)>0.3 & _n==1
	list if tag==1
	*by county`year': assert abs(countyweight-1)<0.3 if _n==1
	by county`year': keep if _n==1 //this is not perfect, but should be close
	
	count
	save "${main}/data/temp/countyxwalk_`year'_2010", replace
}
