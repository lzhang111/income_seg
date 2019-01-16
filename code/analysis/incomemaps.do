* Laura Zhang
* April 2018
* This do file creates data for the income sorting maps in R gis


clear
program drop _all
set more off
global main `"/Users/laurazhang/Documents/income_seg/"'

use "${main}/clean/master_tract.dta", 
rename inc_pctl* inc_qtl* 
rename (inc*_w* inc*_b*)  (inc**_w inc**_b)

gen dist_cbd_mi = dist_cbd/1609.34
gen disthighway_mi = disthighway/1609.34

egen tr_incsum = rowtotal(inc_qtl?)
gen pct_inc_qtl1 = inc_qtl1/tr_incsum
gen pct_inc_qtl5 = inc_qtl5/tr_incsum

keep if dist_cbd_mi <50
keep year geo2010 wtmedianinc cbsaname cbsa10 inc_qtl1 inc_qtl5 dist_cbd_mi disthighway_mi pct_inc_qtl1 pct_inc_qtl5
rename inc_qtl? inc_qtl?_

// Reshape data
reshape wide wtmedianinc inc_qtl1 inc_qtl5 pct_inc_qtl1 pct_inc_qtl5, i(geo2010 cbsaname cbsa10) j(year)

// Recode as missing tracts with zero as median income
recode wtmedianinc1950 wtmedianinc2000 (0=.) 

// Calculate percentage change in median income, 1950 to 2000
gen diff_pct = ( wtmedianinc2000- wtmedianinc1950)/wtmedianinc1950

// Calculate absolute change in % of rich/poor in tract, 1950 to 2000
/*
foreach year in 1950 1980 {
	bys cbsa10: egen sum_qtl1_`year' = total(inc_qtl1_`year')
	bys cbsa10: egen sum_qtl5_`year' = total(inc_qtl5_`year')
	gen trpct_inc_qtl1_`year' = inc_qtl1_`year'/sum_qtl1_`year' if sum_qtl1_`year' > 1000 //need at least 1000 people in bracket in cbsa
	gen trpct_inc_qtl5_`year' = inc_qtl5_`year'/sum_qtl5_`year' if sum_qtl5_`year' > 1000 //need at least 1000 people in bracket in cbsa
}

gen dtrpct_inc_qtl1 = trpct_inc_qtl1_1980 - trpct_inc_qtl1_1950
gen dtrpct_inc_qtl5 = trpct_inc_qtl5_1980 - trpct_inc_qtl5_1950
*/

keep geo2010 cbsaname cbsa10 wtmedianinc1950 wtmedianinc1980 diff_pct pct_inc_qtl* 

replace diff_pct = . if diff_pct > 10 | diff_pct < -.5 //drop 2% of extremes

save "${main}/temp/medianinc_plot", replace
export delimited "${main}/temp/medianinc_plot", replace
