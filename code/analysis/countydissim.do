* Laura Zhang
* March 2018
* This do file calculates dissimilarity indices at the county level
* and a measure of segregation using the highway variable and generates 
* all of the tables for the paper 

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
keep year-inc_qtl5_b cbsa10 cbsaname division dist_cbd_mi-sq_disthighway_mi crimerate50 dis_borcoa

** reshape
reshape wide inc_qtl1-inc_qtl5_b, i(geo2010) j(year)

************************ county level estimates ************************
program fillvar_county
	local i = 1
	while "``i''" != "" {
		local var = "``i''"
		bys county: egen min`var' = min(`var')
		replace `var' = min`var'
		drop min`var'
		local ++i
	}
end

* generate controls
local comp_year = 1980
foreach year in 1950 `comp_year' {
	egen sum_inc`year' = rowtotal(inc_qtl?`year')
	bys county: egen county_incpoptot`year' = total(sum_inc`year')
	by county: egen county_avgmedianinc`year' = wtmean(wtmedianinc`year'), weight(population`year')
	by county: egen county_poptot`year' = total(population`year')
	by county: egen county_blacktot`year' = total(black`year')
	by county: egen county_inc_qtl1tot`year' = total(inc_qtl1`year')
	by county: egen county_inc_qtl5tot`year' = total(inc_qtl5`year')

	gen county_pct_black`year'= county_blacktot`year'/county_poptot`year' if county_poptot`year'>500
	gen county_pct_qtl1_`year' = county_inc_qtl1tot`year'/county_incpoptot`year' if county_incpoptot`year'>500
	gen county_pct_qtl5_`year' = county_inc_qtl5tot`year'/county_incpoptot`year' if county_incpoptot`year'>500
	
	// fill control variables
	fillvar_county county_pct_black`year' county_pct_qtl1_`year' county_pct_qtl5_`year'
}
by county: egen county_dist_cbd = mean(dist_cbd_mi)

gen year = 1
gen suburban = 1 if dist_cbd_mi > 5 & dist_cbd_mi < 30 
replace suburban = 0 if suburban==. & dist_cbd_mi!=.
bys county: egen pct_suburban = mean(suburban)

gen nearhh = 1 if disthighway_mi < 6
replace nearhh = 0 if nearhh==. & disthighway_mi!=.
bys county: egen pct_nearhh = mean(nearhh)

program dissim_county
	args group1 group2 race

	bys year county: egen sum_`group1'`race' = sum(`group1'`race') if `group1'`race'>5
	bys year county: egen sum_`group2'`race' = sum(`group2'`race') if `group2'`race'>5
	
	gen pi_`group1'`race' = `group1'`race'/sum_`group1'`race' if sum_`group1'`race'>500
	gen pi_`group2'`race' = `group2'`race'/sum_`group2'`race' if sum_`group2'`race'>500
	
	gen diff_pi`race' = abs(pi_`group1'`race' - pi_`group2'`race')/2
	bys year county: egen dissim`race' = total(diff_pi`race'), missing
	
	fillvar_county dissim`race'
	
	drop sum* pi* diff*
end


// generate dissimilarity indices at the county level
dissim_county inc_qtl11950 inc_qtl51950 
ren dissim dissim_county1950

local comp_year = 1980
dissim_county inc_qtl1`comp_year' inc_qtl5`comp_year'
ren dissim dissim_county`comp_year'

dissim_county inc_qtl1_b`comp_year' inc_qtl5_b`comp_year'
ren dissim dissim_b_county`comp_year'

local comp_year = 1980
dissim_county inc_qtl1_w`comp_year' inc_qtl5_w`comp_year'
ren dissim dissim_w_county`comp_year'

dissim_county white1980  black1980
ren dissim dissim_race1980

dissim_county white1950  black1950
ren dissim dissim_race1950


// replace absolute dissim with normalized dissim
egen dissim1980_std = std(dissim_county1980)
egen dissim1950_std = std(dissim_county1950)
egen dissim1980_b_std = std(dissim_b_county1980)
egen dissim1980_w_std = std(dissim_w_county1980)
egen dissim_race1950_std = std(dissim_race1950)
egen dissim_race1980_std = std(dissim_race1980)

egen tagcounty = tag(county)
keep if tagcounty


*** merge in 1950 control vars ******
merge 1:1 county using "${main}/temp/county1950vars.dta", keep(1 3) keepusing(*1950)
drop _merge

replace medianinc_1950 = medianinc_1950/.241

// replace population with population in thousands
gen county_poptot1980_th = county_poptot1980/1000
gen county_poptot1950_th = county_poptot1950/1000
gen population_1950_th = population_1950/1000

// log population and income
gen logcounty_poptot1980 = log(county_poptot1980)
gen logcounty_poptot1950 = log(county_poptot1950)
gen logcounty_avgmedianinc1980 = log(county_avgmedianinc1980)
gen logcounty_avgmedianinc1950 = log(county_avgmedianinc1950)
gen logcounty_population1950 = log(population_1950)
gen logcounty_medianinc1950 = log(medianinc_1950)

* Label Variables for tables
label var dissim1980_std "Income Dissimilarity, 1980"
label var dissim1980_b_std "Income Dissimilarity, 1980 for Black Families"
label var dissim1980_w_std "Income Dissimilarity, 1980 for While Families"
label var pct_nearhh "% of tracts $<$5 mi from highway"
label var county_avgmedianinc1980 "Median Income, 1980"
label var logcounty_avgmedianinc1980 "Log Median Income, 1980"
label var county_poptot1980 "Population, 1980"
label var county_poptot1980_th "Population (thousands), 1980"
label var logcounty_poptot1980 "Log Population, 1980"
label var county_pct_black1980 "% Black, 1980"
label var county_pct_qtl1_1980 "% Bottom Quintile, 1980"
label var county_pct_qtl5_1980 "% Top Quintile, 1980"
label var dissim1950_std "Income Dissimilarity, 1950"
label var county_avgmedianinc1950 "Median Income, 1950"
label var logcounty_avgmedianinc1950 "Log Median Income, 1950"
label var logcounty_medianinc1950 "Log Median Income, 1950"
label var county_poptot1950 "Population, 1950"
label var county_poptot1950_th "Population (thousands), 1950"
label var logcounty_poptot1950 "Log Population, 1950"
label var logcounty_population1950 "Log Population, 1950"
label var county_pct_black1950 "% Black, 1950"
label var county_pct_qtl1_1950 "% Bottom Quintile, 1950"
label var county_pct_qtl5_1950 "% Top Quintile, 1950"
label var crimerate50 "Crime Rate, 1950"

encode division, gen(ndivision)
local controls1950 "logcounty_medianinc1950 logcounty_population1950 crimerate50 i.ndivision"
local controls2_1950 "logcounty_medianinc1950 logcounty_population1950 crimerate50"
local controls1980 "logcounty_avgmedianinc1980 logcounty_poptot1980 county_pct_black1980 county_pct_qtl1_1980 county_pct_qtl5_1980 i.ndivision"
local controls2_1980 "logcounty_avgmedianinc1980 logcounty_poptot1980 county_pct_black1980 county_pct_qtl1_1980 county_pct_qtl5_1980"


*** First Stage *****
twoway (scatter dissim1980_std pct_nearhh) (lfit dissim1980_std pct_nearhh, lcolor(red)), ///
	xtitle("% of Tracts <5 mi from Highway", size(small) ) ytitle("Standardized Income Dissimilarity", size(small)) ///
	ylabel(-4(1)3) legend(off) ysize(6)

graph export "${main}/plots/firststage.png", replace

reg dissim1980_std pct_nearhh, robust
outreg2 using "${main}/tables/first_all", tex label replace addtext(Division FE, No) 
reg dissim1980_std pct_nearhh `controls2_1950', robust
outreg2 using "${main}/tables/first_all", drop(i.ndivision) tex label append addtext(Division FE, No) ctitle(With Controls, No FE)
reg dissim1980_std pct_nearhh `controls1950', robust
outreg2 using "${main}/tables/first_all", drop(i.ndivision) tex label append addtext(Division FE, Yes) ctitle(With Controls, With FE)

local replace "replace"
foreach race in _b _w {
	reg dissim1980`race'_std pct_nearhh
	outreg2 using "${main}/tables/first_all_race", tex label `replace' addtext(Division FE, No) 
	reg dissim1980`race'_std pct_nearhh `controls2_1950'
	outreg2 using "${main}/tables/first_all_race", drop(i.ndivision) tex label append addtext(Division FE, No) ctitle(With Controls, No FE)
	reg dissim1980`race'_std pct_nearhh `controls1950'
	outreg2 using "${main}/tables/first_all_race", drop(i.ndivision) tex label append addtext(Division FE, Yes) ctitle(With Controls, With FE)

	local replace ""
}

/*
*Weighted version
reg dissim1980_std pct_nearhh [w=county_poptot1980], robust
outreg2 using "${main}/tables/first_all", tex label replace addtext(Division FE, No) 
reg dissim1980_std pct_nearhh `controls2_1980' [w=county_poptot1980], robust
outreg2 using "${main}/tables/first_all", drop(i.ndivision) tex label append addtext(Division FE, No) ctitle(With Controls, No FE)
reg dissim1980_std pct_nearhh `controls1980' [w=county_poptot1980], robust
outreg2 using "${main}/tables/first_all", drop(i.ndivision) tex label append addtext(Division FE, Yes) ctitle(With Controls, With FE)

foreach race in _b _w {
	reg dissim1980`race'_std pct_nearhh [w=county_poptot1980]
	outreg2 using "${main}/tables/first_all`race'", tex label replace addtext(Division FE, No) 
	reg dissim1980`race'_std pct_nearhh `controls2_1980' [w=county_poptot1980]
	outreg2 using "${main}/tables/first_all`race'", drop(i.ndivision) tex label append addtext(Division FE, No) ctitle(With Controls, No FE)
	reg dissim1980`race'_std pct_nearhh `controls1980' [w=county_poptot1980]
	outreg2 using "${main}/tables/first_all`race'", drop(i.ndivision) tex label append addtext(Division FE, Yes) ctitle(With Controls, With FE)

}
*/


***** Placebo Check *******
reg dissim1950_std pct_nearhh , robust
outreg2 using "${main}/tables/first_placebo_all", tex label replace addtext(Division FE, No) 
reg dissim1950_std pct_nearhh `controls2_1950' , robust
outreg2 using "${main}/tables/first_placebo_all", drop(i.ndivision) tex label append addtext(Division FE, No) ctitle(With Controls, No FE)
reg dissim1950_std pct_nearhh `controls1950' , robust
outreg2 using "${main}/tables/first_placebo_all", drop(i.ndivision) tex label append addtext(Division FE, Yes) ctitle(With Controls, With FE)

* using only the counties that also have data in 1950
reg dissim1980_std pct_nearhh if dissim1950_std!=. , robust
outreg2 using "${main}/tables/first_placebo_all", tex label append addtext(Division FE, No) 
reg dissim1980_std pct_nearhh `controls2_1950' if dissim1950_std!=., robust
outreg2 using "${main}/tables/first_placebo_all", drop(i.ndivision) tex label append addtext(Division FE, No) ctitle(With Controls, No FE)
reg dissim1980_std pct_nearhh `controls1950' if dissim1950_std!=., robust
outreg2 using "${main}/tables/first_placebo_all", drop(i.ndivision) tex label append addtext(Division FE, Yes) ctitle(With Controls, With FE)

/*
*Weighted version
reg dissim1950_std pct_nearhh [w=county_poptot1950], robust
outreg2 using "${main}/tables/first_placebo_all", tex label replace addtext(Division FE, No) 
reg dissim1950_std pct_nearhh `controls2_1950' [w=county_poptot1950], robust
outreg2 using "${main}/tables/first_placebo_all", drop(i.ndivision) tex label append addtext(Division FE, No) ctitle(With Controls, No FE)
reg dissim1950_std pct_nearhh `controls1950' [w=county_poptot1950], robust
outreg2 using "${main}/tables/first_placebo_all", drop(i.ndivision) tex label append addtext(Division FE, Yes) ctitle(With Controls, With FE)

* using only the counties that also have data in 1950
reg dissim1980_std pct_nearhh [w=county_poptot1980] if dissim1950_std!=., robust 
outreg2 using "${main}/tables/first_restricted_all", tex label replace addtext(Division FE, No) 
reg dissim1980_std pct_nearhh `controls2_1980' [w=county_poptot1980] if dissim1950_std!=., robust
outreg2 using "${main}/tables/first_restricted_all", drop(i.ndivision) tex label append addtext(Division FE, No) ctitle(With Controls, No FE)
reg dissim1980_std pct_nearhh `controls1980' [w=county_poptot1980] if dissim1950_std!=., robust
outreg2 using "${main}/tables/first_restricted_all", drop(i.ndivision) tex label append addtext(Division FE, Yes) ctitle(With Controls, With FE)
*/

*** Test of Exclusion restriction - Regress Controls on Instrument ***
reg crimerate50 pct_nearhh , robust
outreg2 using "${main}/tables/exclrestrict", tex label replace
reg county_pct_black1950 pct_nearhh , robust
outreg2 using "${main}/tables/exclrestrict", tex label append 
reg county_pct_qtl1_1950 pct_nearhh , robust
outreg2 using "${main}/tables/exclrestrict", tex label append 
reg county_pct_qtl5_1950 pct_nearhh , robust 
outreg2 using "${main}/tables/exclrestrict", tex label append 
reg logcounty_medianinc1950 pct_nearhh, robust
outreg2 using "${main}/tables/exclrestrict", tex label append 


*** Test of Selective Sorting 
merge 1:1 county using "${main}/temp/migration_clean.dta", keep(1 3)

gen diff_w_gender_70 = migrate_wm_1970_25_50 - migrate_wf_1970_25_50
gen diff_n_gender_70 = migrate_nm_1970_25_50 - migrate_nf_1970_25_50
gen diff_race_f_70 = migrate_wf_1970_25_50 - migrate_nf_1970_25_50
gen diff_race_m_70 = migrate_wm_1970_25_50 - migrate_nm_1970_25_50
// gen diff_gender_80 = migrate_tm_1980_25_50 - migrate_tf_1980_25_50


reg migrate_wm_1970_25_50 pct_nearhh `controls2_1950' if dissim1980_std!=., robust
outreg2 using "${main}/tables/migration", tex label replace 
reg migrate_wf_1970_25_50 pct_nearhh `controls2_1950' if dissim1980_std!=., robust
outreg2 using "${main}/tables/migration", tex label 
reg migrate_nm_1970_25_50 pct_nearhh  `controls2_1950' if dissim1980_std!=., robust
outreg2 using "${main}/tables/migration", tex label 
reg migrate_nf_1970_25_50 pct_nearhh  `controls2_1950' if dissim1980_std!=., robust
outreg2 using "${main}/tables/migration", tex label 

/*
reg migrate_tm_1980_25_50 pct_nearhh `controls1980', robust
outreg2 using "${main}/tables/migration", tex label 
reg migrate_tf_1980_25_50 pct_nearhh `controls1980', robust
outreg2 using "${main}/tables/migration", tex label 
*/

reg diff_w_gender_70 pct_nearhh `controls2_1950' if dissim1980_std!=., robust
outreg2 using "${main}/tables/migration_gap", tex label replace 
reg diff_n_gender_70 pct_nearhh `controls2_1950' if dissim1980_std!=., robust
outreg2 using "${main}/tables/migration_gap", tex label 
reg diff_race_m_70 pct_nearhh `controls2_1950' if dissim1980_std!=., robust
outreg2 using "${main}/tables/migration_gap", tex label 
reg diff_race_f_70 pct_nearhh `controls2_1950' if dissim1980_std!=., robust
outreg2 using "${main}/tables/migration_gap", tex label 

/*
reg diff_gender_80 pct_nearhh `controls1980', robust
outreg2 using "${main}/tables/migration_gap", tex label 
*/

**** Test of Growth Effect ****

reg logcounty_avgmedianinc1980 pct_nearhh , robust
outreg2 using "${main}/tables/growth_check", tex label replace

reg logcounty_avgmedianinc1980 pct_nearhh logcounty_medianinc1950 logcounty_population1950 crimerate50, robust
outreg2 using "${main}/tables/growth_check", tex label append 


**** Analysis of effects of seg **
keep county-ndivision
rename county county2010
merge 1:1 county2010 using "${main}/temp/countyxwalk_1980_2010.dta", keepusing(county1980)
replace county1980 = county2010 if county1980==""
drop _merge
merge 1:m county2010 using "${main}/temp/countyxwalk_2000_2010.dta", keepusing(county2000)
drop _merge

* merge in Chetty data
destring county2000, gen(cty2000)
merge m:1 cty2000 using "${main}/raw/chetty/online_table2.dta"
drop _merge

* Label Variables for tables
label var pct_causal_p25_kr26 "25th Percentile"
label var pct_causal_p75_kr26 "75th Percentile"
label var pct_causal_p25_kr26_f "25th Percentile for Girls"
label var pct_causal_p75_kr26_f "75th Percentile for Girls"
label var pct_causal_p25_kr26_m "25th Percentile for Boys"
label var pct_causal_p75_kr26_m "75th Percentile for Boys"

local replace "replace"
foreach income in p25 p75 {
	
	//IV
	ivregress 2sls pct_causal_`income'_kr26 (dissim1980_std=pct_nearhh), vce(robust)
	outreg2 using "${main}/tables/iv_all", `replace' tex label  addtext(Division FE, No) 
	ivregress 2sls pct_causal_`income'_kr26 (dissim1980_std=pct_nearhh) `controls2_1950', vce(robust)
	outreg2 using "${main}/tables/iv_all", drop(i.ndivision) tex label append addtext(Division FE, No) ctitle(With Controls)
	ivregress 2sls pct_causal_`income'_kr26 (dissim1980_std=pct_nearhh) `controls1950', vce(robust)
	outreg2 using "${main}/tables/iv_all", drop(i.ndivision) tex label append addtext(Division FE, Yes) ctitle(With Controls) 
	
	//OLS
	reg pct_causal_`income'_kr26 dissim1980_std, vce(robust)
	outreg2 using "${main}/tables/ols_all", `replace' tex label addtext(Division FE, No) 
	reg pct_causal_`income'_kr26 dissim1980_std `controls2_1950', vce(robust) 
	outreg2 using "${main}/tables/ols_all", drop(i.ndivision) tex label append addtext(Division FE, No) ctitle(With Controls)
	reg pct_causal_`income'_kr26 dissim1980_std `controls1950', vce(robust) 
	outreg2 using "${main}/tables/ols_all", drop(i.ndivision) tex label append addtext(Division FE, Yes) ctitle(With Controls) 
	
	local replace ""
}

* gap estimates
gen diff_income = pct_causal_p75_kr26 - pct_causal_p25_kr26

//IV
ivregress 2sls diff_income (dissim1980_std=pct_nearhh), vce(robust)
outreg2 using "${main}/tables/gap/iv_all", replace tex label  addtext(Division FE, No) 
ivregress 2sls diff_income (dissim1980_std=pct_nearhh) `controls2_1950', vce(robust)
outreg2 using "${main}/tables/gap/iv_controls2", drop(i.ndivision) tex label replace addtext(Division FE, No) ctitle(With Controls)
ivregress 2sls diff_income (dissim1980_std=pct_nearhh) `controls1950', vce(robust)
outreg2 using "${main}/tables/gap/iv_controls", drop(i.ndivision) tex label replace addtext(Division FE, Yes) ctitle(With Controls) 

//OLS
reg diff_income dissim1980_std, vce(robust)
outreg2 using "${main}/tables/gap/ols_all", replace tex label addtext(Division FE, No) 
reg diff_income dissim1980_std `controls2_1950', vce(robust) 
outreg2 using "${main}/tables/gap/ols_controls2", drop(i.ndivision) tex label replace addtext(Division FE, No) ctitle(With Controls)
reg diff_income dissim1980_std `controls1950', vce(robust) 
outreg2 using "${main}/tables/gap/ols_controls", drop(i.ndivision) tex label replace addtext(Division FE, Yes) ctitle(With Controls) 
	

/*
*Weighted version
foreach income in p25 p75 {
	
	//IV
	ivregress 2sls pct_causal_`income'_kr26 (dissim1980_std=pct_nearhh) [w=county_poptot1980], vce(robust)
	outreg2 using "${main}/tables/iv_all_`income'", replace tex label  addtext(Division FE, No) 
	ivregress 2sls pct_causal_`income'_kr26 (dissim1980_std=pct_nearhh) `controls2_1980' [w=county_poptot1980], vce(robust)
	outreg2 using "${main}/tables/iv_all_`income'", drop(i.ndivision) tex label append addtext(Division FE, No) ctitle(With Controls)
	ivregress 2sls pct_causal_`income'_kr26 (dissim1980_std=pct_nearhh) `controls1980' [w=county_poptot1980], vce(robust)  
	outreg2 using "${main}/tables/iv_all_`income'", drop(i.ndivision) tex label append addtext(Division FE, Yes) ctitle(With Controls) 
	
	//OLS
	reg pct_causal_`income'_kr26 dissim1980_std [w=county_poptot1980], vce(robust)
	outreg2 using "${main}/tables/ols_all_`income'", replace tex label addtext(Division FE, No) 
	reg pct_causal_`income'_kr26 dissim1980_std `controls2_1980' [w=county_poptot1980], vce(robust)
	outreg2 using "${main}/tables/ols_all_`income'", drop(i.ndivision) tex label append addtext(Division FE, No) ctitle(With Controls)
	reg pct_causal_`income'_kr26 dissim1980_std `controls1980' [w=county_poptot1980], vce(robust)
	outreg2 using "${main}/tables/ols_all_`income'", drop(i.ndivision) tex label append addtext(Division FE, Yes) ctitle(With Controls) 
	
}
*/

********* split into gender **********
local fp25str "Girls, P25 Parents"
local fp75str "Girls, P75 Parents"
local mp25str "Boys, P25 Parents"
local mp75str "Boys, P75 Parents"

local replace replace
foreach gender in f m {
	foreach income in p25 p75 {
		
		// IV
		ivregress 2sls pct_causal_`income'_kr26_`gender' (dissim1980_std=pct_nearhh) , vce(robust)
		outreg2 using "${main}/tables/iv_all_gender", tex `replace' label addtext(Division FE, No) ctitle(``gender'`income'str')
		ivregress 2sls pct_causal_`income'_kr26_`gender' (dissim1980_std=pct_nearhh) `controls2_1950' , vce(robust)
		outreg2 using "${main}/tables/iv_controls2_gender", drop(i.ndivision) tex `replace' label addtext(Division FE, No) ctitle(``gender'`income'str')
		ivregress 2sls pct_causal_`income'_kr26_`gender' (dissim1980_std=pct_nearhh) `controls1950' , vce(robust)
		outreg2 using "${main}/tables/iv_controls_gender", drop(i.ndivision) tex `replace' label addtext(Division FE, Yes) ctitle(``gender'`income'str') 
		
		
		//OLS
		reg pct_causal_`income'_kr26_`gender' dissim1980_std , vce(robust)
		outreg2 using "${main}/tables/ols_all_gender", tex `replace' label addtext(Division FE, No) ctitle(``gender'`income'str')
		reg pct_causal_`income'_kr26_`gender' dissim1980_std `controls2_1950' , vce(robust)
		outreg2 using "${main}/tables/ols_controls2_gender", drop(i.ndivision) tex `replace' label addtext(Division FE, No) ctitle(``gender'`income'str')
		reg pct_causal_`income'_kr26_`gender' dissim1980_std `controls1950' , vce(robust)
		outreg2 using "${main}/tables/ols_controls_gender", drop(i.ndivision) tex `replace' label addtext(Division FE, Yes) ctitle(``gender'`income'str')
		
		local replace ""
	}
}

* gap estimates
gen diff_gender_p25 = pct_causal_p25_kr26_m - pct_causal_p25_kr26_f
gen diff_gender_p75 = pct_causal_p75_kr26_m - pct_causal_p75_kr26_f
gen diff_income_f = pct_causal_p75_kr26_f - pct_causal_p25_kr26_f
gen diff_income_m = pct_causal_p75_kr26_m - pct_causal_p25_kr26_m


foreach income in p25 p75 {
	// IV
	ivregress 2sls diff_gender_`income' (dissim1980_std=pct_nearhh) , vce(robust)
	outreg2 using "${main}/tables/gap/iv_all", tex append label addtext(Division FE, No) ctitle(``gender'`income'str')
	ivregress 2sls diff_gender_`income' (dissim1980_std=pct_nearhh) `controls2_1950' , vce(robust)
	outreg2 using "${main}/tables/gap/iv_controls2", drop(i.ndivision) tex `replace' label addtext(Division FE, No) ctitle(``gender'`income'str')
	ivregress 2sls diff_gender_`income' (dissim1980_std=pct_nearhh) `controls1950' , vce(robust)
	outreg2 using "${main}/tables/gap/iv_controls", drop(i.ndivision) tex `replace' label addtext(Division FE, Yes) ctitle(``gender'`income'str') 
	
	
	//OLS
	reg diff_gender_`income' dissim1980_std , vce(robust)
	outreg2 using "${main}/tables/gap/ols_all", tex `replace' label addtext(Division FE, No) ctitle(``gender'`income'str')
	reg diff_gender_`income' dissim1980_std `controls2_1950' , vce(robust)
	outreg2 using "${main}/tables/gap/ols_controls2", drop(i.ndivision) tex `replace' label addtext(Division FE, No) ctitle(``gender'`income'str')
	reg diff_gender_`income' dissim1980_std `controls1950' , vce(robust)
	outreg2 using "${main}/tables/gap/ols_controls", drop(i.ndivision) tex `replace' label addtext(Division FE, Yes) ctitle(``gender'`income'str')

}



foreach gender in f m {
	// IV
	ivregress 2sls diff_income_`gender' (dissim1980_std=pct_nearhh) , vce(robust)
	outreg2 using "${main}/tables/gap/iv_all", tex append label addtext(Division FE, No) ctitle(``gender'`income'str')
	ivregress 2sls diff_income_`gender' (dissim1980_std=pct_nearhh) `controls2_1950' , vce(robust)
	outreg2 using "${main}/tables/gap/iv_controls2", drop(i.ndivision) tex `replace' label addtext(Division FE, No) ctitle(``gender'`income'str')
	ivregress 2sls diff_income_`gender' (dissim1980_std=pct_nearhh) `controls1950' , vce(robust)
	outreg2 using "${main}/tables/gap/iv_controls", drop(i.ndivision) tex `replace' label addtext(Division FE, Yes) ctitle(``gender'`income'str') 
	
	
	//OLS
	reg diff_income_`gender' dissim1980_std , vce(robust)
	outreg2 using "${main}/tables/gap/ols_all", tex append label addtext(Division FE, No) ctitle(``gender'`income'str')
	reg diff_income_`gender' dissim1980_std `controls2_1950' , vce(robust)
	outreg2 using "${main}/tables/gap/ols_controls2", drop(i.ndivision) tex `replace' label addtext(Division FE, No) ctitle(``gender'`income'str')
	reg diff_income_`gender' dissim1980_std `controls1950' , vce(robust)
	outreg2 using "${main}/tables/gap/ols_controls", drop(i.ndivision) tex `replace' label addtext(Division FE, Yes) ctitle(``gender'`income'str')
	

}


/*
local replace replace
* Weighted version
foreach gender in f m {
	foreach income in p25 p75 {
		
		// IV
		ivregress 2sls pct_causal_`income'_kr26_`gender' (dissim1980_std=pct_nearhh) [w=county_poptot1980], vce(robust)
		outreg2 using "${main}/tables/iv_all_gender", tex `replace' label addtext(Division FE, No) ctitle(``gender'`income'str')
		ivregress 2sls pct_causal_`income'_kr26_`gender' (dissim1980_std=pct_nearhh) `controls2_1980' [w=county_poptot1980], vce(robust)
		outreg2 using "${main}/tables/iv_controls2_gender", drop(i.ndivision) tex `replace' label addtext(Division FE, No) ctitle(``gender'`income'str')
		ivregress 2sls pct_causal_`income'_kr26_`gender' (dissim1980_std=pct_nearhh) `controls1980' [w=county_poptot1980] , vce(robust)
		outreg2 using "${main}/tables/iv_controls_gender", drop(i.ndivision) tex `replace' label addtext(Division FE, Yes) ctitle(``gender'`income'str') 
		
		
		//OLS
		reg pct_causal_`income'_kr26_`gender' dissim1980_std [w=county_poptot1980], vce(robust)
		outreg2 using "${main}/tables/ols_all_gender", tex `replace' label addtext(Division FE, No) ctitle(``gender'`income'str')
		reg pct_causal_`income'_kr26_`gender' dissim1980_std `controls2_1980' [w=county_poptot1980], vce(robust)
		outreg2 using "${main}/tables/ols_controls2_gender", drop(i.ndivision) tex `replace' label addtext(Division FE, No) ctitle(``gender'`income'str')
		reg pct_causal_`income'_kr26_`gender' dissim1980_std `controls1980' [w=county_poptot1980], vce(robust)
		outreg2 using "${main}/tables/ols_controls_gender", drop(i.ndivision) tex `replace' label addtext(Division FE, Yes) ctitle(``gender'`income'str')
		
		local replace ""
	}
}
*/


********** Summary Statistics **********
estpost sum dissim_county1980 dissim_b_county1980 dissim_w_county1980 county_poptot1980_th county_avgmedianinc1980 county_pct_black1980 county_pct_qtl1_1980 county_pct_qtl5_1980 
esttab using "${main}/tables/summstats/1980summstats.tex", cell((mean(label(Mean) fmt(%9.2f)) ///
	sd(label(Standard Deviation) fmt(%9.3f)) count(label(Count) fmt(%9.0f)) )) label ///
	nonumber nomtitle noobs replace


estpost sum dissim_county1950 population_1950_th medianinc_1950 county_pct_black1950 county_pct_qtl1_1950 county_pct_qtl5_1950 
esttab using "${main}/tables/summstats/1950summstats.tex", cell((mean(label(Mean) fmt(%9.2f)) ///
	sd(label(Standard Deviation) fmt(%9.3f)) count(label(Count) fmt(%9.0f)) )) label ///
	nonumber nomtitle noobs replace



