* Laura Zhang
* Nov 2017
* prelim analysis

clear
set more off
global main `"/Users/laurazhang/Documents/income_seg/"'

* merge 1980 NHGIS data with Baumsnow data
use "${main}/temp/clean1980incrace.dta"
ren (statefips smsaa) (stfip msa)
replace year = year - 1900
merge m:1 stfip msa year using "${main}/temp/baumsnow_final.dta"
tab msa if _merge==2 & year==80


* create a segregation index
keep if _merge==3

foreach race in w b {
	//dissimilarity index
	bys msa: egen sum_`race'_5k = sum(`race'_5k)
	bys msa: egen sum_`race'_50pk = sum(`race'_50pk)
	gen pi_`race'_5k = `race'_5k/sum_`race'_5k
	gen pi_`race'_50pk = `race'_50pk/sum_`race'_50pk
	gen diff_`race'_pi = abs(pi_`race'_5k-pi_`race'_50pk)
	bys msa: egen seg_`race' = sum(diff_`race'_pi)
	
	preserve
	bys msa: keep if _n==1
	ivregress 2sls seg_`race' (ray = rays_planm), first
	restore
	
}

