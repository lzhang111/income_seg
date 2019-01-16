* Laura Zhang
* April 2018
* This do files generates a graph showing income segregation over time

clear
program drop _all
set more off
global main `"/Users/laurazhang/Documents/income_seg/"'
set seed 123

use "${main}/clean/master_tract.dta", 
rename inc_pctl* inc_qtl* 
rename (inc*_w* inc*_b*)  (inc**_w inc**_b)

gen dist_cbd_mi = dist_cbd/1609.34
gen disthighway_mi = disthighway/1609.34
gen sq_disthighway_mi = disthighway_mi^2

** keep only necessary variables
keep year-inc_qtl5_b cbsa10 cbsaname division dist_cbd_mi-sq_disthighway_mi 

program fillvar_county
	local i = 1
	while "``i''" != "" {
		local var = "``i''"
		bys year county: egen min`var' = min(`var')
		replace `var' = min`var'
		drop min`var'
		local ++i
	}
end

program dissim_county
	args group1 group2 race

	bys year county: egen sum_`group1'`race' = sum(`group1'`race') if `group1'`race'>1
	bys year county: egen sum_`group2'`race' = sum(`group2'`race') if `group2'`race'>1
	
	gen pi_`group1'`race' = `group1'`race'/sum_`group1'`race' if sum_`group1'`race'>500
	gen pi_`group2'`race' = `group2'`race'/sum_`group2'`race' if sum_`group2'`race'>500
	
	gen diff_pi`race' = abs(pi_`group1'`race' - pi_`group2'`race')/2
	bys year county: egen dissim`race' = total(diff_pi`race'), missing
	
	fillvar_county dissim`race'
	
	drop sum* pi* diff*
end

// generate dissimilarity indices
dissim_county inc_qtl1 inc_qtl5
rename dissim dissim_county

dissim_county inc_qtl1_w inc_qtl5_w
rename dissim dissim_county_w

dissim_county inc_qtl1_b inc_qtl5_b
rename dissim dissim_county_b

dissim_county white black
rename dissim dissim_county_race

// keep only one obs for each county
bys county year: keep if _n==1
keep dissim* county year
reshape wide dissim_county dissim_county_b dissim_county_w dissim_county_race, i(county) j(year)
keep if dissim_county1950!=.
reshape long dissim_county dissim_county_b dissim_county_w dissim_county_race, i(county) j(year)

foreach var in " " "_b" "_w" "_race" {
	egen mean_dissim`var' = mean(dissim_county`var'), by(year)
	egen sd_dissim`var' = sd(dissim_county`var'), by(year)
	egen count_dissim`var' = count(dissim_county`var'!=.), by(year) 
	replace sd_dissim`var' = sd_dissim`var'/sqrt(count_dissim`var')
	
	gen ub`var' = mean_dissim`var'+1.96*sd_dissim`var'
	gen lb`var' = mean_dissim`var'-1.96*sd_dissim`var'
}

bys year: keep if _n ==1

label var year "Year"

twoway (line mean_dissim year) (rcap ub lb year) (line mean_dissim_b year) (rcap ub_b lb_b year) ///
	(line mean_dissim_w year) (rcap ub_w lb_w year) /*(line mean_dissim_race year, lcolor(blue)) (rcap ub_race lb_race year, lcolor(ltblue))*/, ///
	legend (label(1 "All Families") label(2 "95% CI") label(3 "Black Families") ///
	label(4 "95% CI") label(5 "White Families") label(6 "95% CI") /*label(7 "Racial Dissimilarity") label(8 "95% CI")*/) ///
	xlabel(1950(10)2010) ylabel(0.25(.05).55) legend(pos(6) col(3) order(1 3 5 2 4 6) ) ysize(8) xsize(9)

graph export "${main}/plots/dissim_time.png", replace
