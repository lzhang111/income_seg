* Laura Zhang
* Nov 2017
* prelim analysis

clear
program drop _all
set more off
global main `"/Users/laurazhang/Documents/income_seg/"'

* merge 1980 NHGIS data with Baumsnow data
use "${main}/temp/clean1980incrace.dta"
ren (statefips smsaa) (stfip msa)
replace year = year - 1900
merge m:1 stfip msa year using "${main}/temp/baumsnow_final.dta"
tab msa if _merge==2 & year==80
keep if _merge==3


* create dissimilarity index
program dissim 
	args race group1 group2

	bys msa: egen sum_`race'_`group1' = sum(`race'_`group1')
	bys msa: egen sum_`race'_`group2' = sum(`race'_`group2')
	gen pi_`race'_`group1' = `race'_`group1'/sum_`race'_`group1'
	gen pi_`race'_`group2' = `race'_`group2'/sum_`race'_`group2'
	gen diff_`race'_pi = abs(pi_`race'_`group1'-pi_`race'_`group2')/2
	bys msa: egen dissim_`race' = sum(diff_`race'_pi)
	drop sum* pi* diff*
end

* create isolation index
program isol
	args race group

	bys msa: egen sum_`race'_`group' = sum(`race'_`group')	//count of race, group in MSA
	egen `race'_tot = rowtotal(`race'_*)						//count of race in census tract
	bys msa: egen sum_`race'_tot = sum(`race'_tot)   			//count of race in MSA

	//calculate some fractions
	gen p1 = `race'_`group'/sum_`race'_`group'
	gen p2 = `race'_`group'/`race'_tot
	gen p3 = sum_`race'_`group'/sum_`race'_tot 

	gen f_`race' = (p1*p2-p3)/(1-p3)
	bys msa: egen isol_`race'_`group' = sum(f_`race')
	drop sum* *_tot p? min_* f_*
end



foreach race in w b {
	preserve

	dissim `race' 5k 50k
	isol `race' 5k
	isol `race' 50k

	bys msa: keep if _n==1
	sum dissim_`race'
	sum isol_`race'_5k
	sum isol_`race'_50k
	sum rays_planm
	
	reg dissim_`race' rays_planm
	reg isol_`race'_5k rays_planm
	reg isol_`race'_50k rays_planm

	restore
}

