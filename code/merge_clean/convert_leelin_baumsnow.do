* Laura Zhang *
* This do file will convert Baum-Snow and Lee & Lin's final data files to dta.
clear
set more off

global main `"/Users/laurazhang/Documents/income_seg/"'
global temp `"${main}/data/temp"'

// Lee & lin
use "${main}/data/raw/lee and lin data/DataAndCode/data/Lee_Lin_data.dta"
export delimited "${temp}/leelin_final.csv", replace
save "${temp}/leelin_final.dta", replace

// Baum-Snow
* get the variable indicating the % of highways completed in each year
use "${main}/data/raw/baumsnow/data/hwy-allyr-state.dta", clear

sort year
collapse (sum) lenc, by(year)
sort year
gen sshrc = lenc/lenc[_N]

save "${temp}/bs_sshrc.dta", replace

* main baumsnow file
use "${main}/data/raw/baumsnow/data/msa-final.dta", clear
export delimited "${temp}/baumsnow_final.csv", replace
save "${temp}/baumsnow_final.dta", replace

merge m:1 year using "${temp}/bs_sshrc.dta", keepusing(sshrc) keep(1 3)
drop _merge

***keep variable labels of collapsed vars*****
foreach v of var racc* ray* dis_borcoa { 
	local l`v' : variable label `v' 
} 

collapse (mean) racc* ray* dis_borcoa sshrc, by(msa year) 

foreach v of var racc* ray* dis_borcoa { 
	label var `v' "`l`v''" 
} 

replace year = year + 1900

* actual rays are provided by year
preserve
drop *plan* dis_borcoa
save "${temp}/baumsnow_rays.dta", replace
restore

* planned rays do not vary by year
keep msa *plan* dis_borcoa
bys msa: keep if _n==1
save "${temp}/baumsnow_rays_plan.dta", replace
