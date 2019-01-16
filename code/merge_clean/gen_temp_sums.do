* Laura Zhang
* Jan 2018
* This do file will calculate total counts of each income bracket for years 1950 - 2010
clear
set more off

global main `"/Users/laurazhang/Documents/income_seg/"'

foreach year of numlist 1950(10)2010 {
	if `year'==2010 {
		use "${main}/data/temp/clean`year'inc.dta", clear
		rename tractfull trtid10
	}
	else {
		use "${main}/data/temp/const`year'inc.dta", clear
	}
	
	cap drop incmissing

	//first time is national sum
	preserve
	collapse (sum) inc*  //get sums for each bracket
	gen year = `year'
	
	export delimited using "${main}/data/temp/`year'inc_sum_total.csv", replace
	restore
	
	//second time is sum by cbsa
	gen county = substr(trtid10, 1, 5)
	merge m:1 county using  "${main}/data/temp/cbsa_county2010_crosswalk.dta", keep(1 3) keepusing(cbsa10)
	drop if _merge==1
	drop _merge
	
	collapse (sum) inc*, by(cbsa10)
	gen year = `year'
	
	export delimited using "${main}/data/temp/`year'inc_sum_cbsa.csv", replace
}

foreach year of numlist 1980(10)2010 {
	if `year'==2010 {
		use "${main}/data/temp/clean`year'incrace.dta", clear
		rename tractfull trtid10
	}
	else {
		use "${main}/data/temp/const`year'incrace.dta", clear
	}
	keep b_* w_* trtid //only keep counts for black and white populations
	
	//first time is national sum
	preserve
	collapse (sum) b_* w_*  //get sums for each bracket
	gen year = `year'
	
	
	export delimited using "${main}/data/temp/`year'incrace_sum_total.csv", replace
	restore
	
	//second time is sum by cbsa
	gen county = substr(trtid10, 1, 5)
	merge m:1 county using  "${main}/data/temp/cbsa_county2010_crosswalk.dta", keep(1 3) keepusing(cbsa10)
	drop if _merge==1
	drop _merge
	
	collapse (sum) b_* w_*, by(cbsa10)
	gen year = `year'
	
	export delimited using "${main}/data/temp/`year'incrace_sum_cbsa.csv", replace
}




