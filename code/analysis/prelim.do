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

	bys msa: egen sum_`race'_`group' = sum(`race'_`group')	//count of group in MSA
	egen `race'_tot = rowtotal(`race'_*)					//count of pop in census tract
	bys msa: egen sum_`race'_tot = sum(`race'_tot)   		//count of pop in MSA

	//calculate some fractions
	gen p1 = `race'_`group'/sum_`race'_`group'
	gen p2 = `race'_`group'/`race'_tot
	gen p3 = sum_`race'_`group'/sum_`race'_tot 

	gen n = p1*p2
	bys msa: egen f = sum(n)
	gen isol_`race'_`group' = (f-p3)/(1-p3)
	pause
	drop sum* *_tot p? f n
end


local group1 5k
local group2 50pk 

foreach race in w b {
	preserve

	dissim `race' `group1' `group2'
	isol `race' `group1'
	isol `race' `group2'

	bys msa: keep if _n==1
	keep if rays_planm<5 & rays_planm>0
	tab rays_planm
	
	sum dissim_`race'
	sum isol_`race'_`group1'
	sum isol_`race'_`group2'
	sum rays_planm
	
	reg dissim_`race' rays_planm
	reg isol_`race'_`group1' rays_planm
	reg isol_`race'_`group2' rays_planm
	
	scatter dissim_`race' rays_planm || lfit dissim_`race' rays_planm, name(dissim_`race', replace) 
	scatter isol_`race'_`group1' rays_planm || lfit isol_`race'_`group1' rays_planm, name(isol_`race'_`group1', replace) 
	scatter isol_`race'_`group2' rays_planm || isol_`race'_`group2' rays_planm, name(isol_`race'_`group2', replace) 
	
	restore
}

