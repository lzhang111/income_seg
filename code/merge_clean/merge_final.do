* Jan 2018
* This do file merges together several files 
* to create a master dataset

clear
set more off
program drop _all

global main `"/Users/laurazhang/Documents/income_seg/"'

*******************************************
***** convert interpolated pctile tract data to dta files *****
foreach year of numlist 1950(10)2010 {
	import delimited "${main}/data/temp/pctl_total`year'.csv", clear
	tostring trtid10, format("%011.0f") replace
	
	merge 1:1 trtid10 using "${main}/data/temp/const`year'inc.dta", keepusing(population-wtmedianinc) nogen 
	
	gen year = `year'
	
	save "${main}/data/temp/pctl_total`year'", replace
	
	if `year'>=1980 {
		foreach var in _w _b {
			import delimited "${main}/data/temp/pctl_total`year'`var'.csv", clear
			tostring trtid10, format("%011.0f") replace
			gen year = `year'
		
			save "${main}/data/temp/pctl_total`year'`var'", replace
		}
	}
}

******************************************
***** append interpolated pctile tract data ******************
use "${main}/data/temp/pctl_total1950.dta", clear

foreach year of numlist 1960(10)2010 {
	append using "${main}/data/temp/pctl_total`year'"
	
	if `year'>=1980 {
		foreach var in _w _b{
			merge 1:1 year trtid10 using "${main}/data/temp/pctl_total`year'`var'", gen(merge_`year'`var') update 
		}
	}
}

drop merge*

* create county variable
gen str5 county = substr(trtid10, 1, 5)

order year county trtid 


************************************************
************add cpi data******************
merge m:1 year using "${main}/data/temp/cpi.dta", keep(1 3) 
drop _merge
replace wtmedianinc = wtmedianinc/cpi //adjust medianincome to constant 1982-84 dollars

************************************************
************add tract area data******************
merge m:1 trtid10 using "${main}/data/temp/tracts2010.dta", keepusing(aland10)
drop if _merge!=3 //these seem to be empty observations
drop _merge

********* gen pop density ***************
gen tr_pop_dens = population/(aland10/2589988)

************************************************
************add distances data******************
merge m:1 trtid10 using "${main}/data/temp/compiled_distances.dta"
drop if _merge!=3 //if only in master, this means tract not located in cbsa
drop _merge

**************************************************
*************add region and division indicators****
merge m:1 statefips using "${main}/data/temp/region_state_xwalk", keep(1 3)
drop _merge

************************************************
************add lee and lin data**************
rename trtid10 geo2010
merge m:1 year geo2010 using "${main}/data/temp/leelin_final.dta", keepusing(d2* share* downtown* WRLURI) gen(merge_leelin)
//not all tract data I have is in leelin data! they must have some sample restrictions
keep if merge!=2

************************************************
************add baumsnow data**************
merge m:1 county using "${main}/data/temp/baumsnow_msa_cbsa_xwalk.dta", gen(merge_bs)
//some merge==1 since baumsnow only has data for 240 cities, but around 350+ CBSAs

//Camden, NJ is a metdiv that was split from Philadelphia MSA
//in 2010, but did not exist in 2000 so is not in the Baumsnow
//data. We need to add its observation back in
replace div10=15804 if cbsa10==37980 & div10==.
replace areacode=div10 if div10==15804
replace areaflag="metdiv" if div10==15804

rename bs_msa msa

//merge baumsnow data
merge m:1 msa year using "${main}/data/temp/baumsnow_rays.dta", gen(merge_bshighway) 
tab year if merge_bshighway==1 //some cbsas are not included in baumsnow
keep if merge_bshighway!=2

merge m:1 msa using "${main}/data/temp/baumsnow_rays_plan.dta", gen(merge_bshighway_plan) keep(1 3)

*******************************************
*******add crime data*************
merge m:1 cbsa10 using "${main}/data/temp/ucr1950_cbsa2010.dta", gen(merge_ucr) keepusing(murder-crimerate50)

*******************************************
* * * * clean up observations * * * *
*******************************************

//fill in obs with empty data (data for tract should be the same for all years)
program define fillobs
	local i = 1
	while "``i''" != "" {
		local var = "``i''"
		by geo2010: egen min`var' = min(`var')
		replace `var' = min`var'
		drop min`var'
		local ++i
	}
end
sort geo2010 year
fillobs d2river d2lake d2shore d2cbdkm d2cbddd d2cbd d2port WRLURI dis_borcoa

// drop Hawaii and Alaska
drop if statefips==15 | statefips==2

save "${main}/data/clean/master_tract.dta", replace

****** MSA level data only ***********
preserve
keep year cbsaname cbsa10 statefips statename-division dis_borcoa cbsa_msa ///
	msaname racc-rayatot rays_plan* murder-crimerate50
duplicates drop
bys cbsa10 year: keep if _n==1
save "${main}/data/clean/master_cbsa.dta", replace

drop ra* year
duplicates drop
bys cbsa10: keep if _n == 1
save "${main}/data/clean/master_cbsa_noyear.dta", replace
	
restore
