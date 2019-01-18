* Laura Zhang
* March 2018
* This do files generates graphs showing income sorting at the tract level

clear
program drop _all
set more off
global main `"/Users/laurazhang/Documents/income_seg/"'
set seed 123

use "${main}/data/clean/master_tract.dta", 
rename inc_pctl* inc_qtl* 
rename (inc*_w* inc*_b*)  (inc**_w inc**_b)

gen dist_cbd_mi = dist_cbd/1609.34
gen disthighway_mi = disthighway/1609.34
gen sq_disthighway_mi = disthighway_mi^2

// calculate percentages of tract that is poor/rich
egen tr_incsum = rowtotal(inc_qtl?)
gen pct_inc_qtl1 = inc_qtl1/tr_incsum
gen pct_inc_qtl5 = inc_qtl5/tr_incsum
* by race
egen tr_incsum_w = rowtotal(inc_qtl?_w)
egen tr_incsum_b = rowtotal(inc_qtl?_b)
gen pct_inc_qtl1_w = inc_qtl1_w/tr_incsum_w
gen pct_inc_qtl5_w = inc_qtl5_w/tr_incsum_w
gen pct_inc_qtl1_b = inc_qtl1_b/tr_incsum_b
gen pct_inc_qtl5_b = inc_qtl5_b/tr_incsum_b

// generate scatter plots
cap drop sample_*
local 15_30str "15 to 30 miles"
local 5_15str "5 to 15 miles"
local 0_5str "less than 5 miles"
local wtmedianincstr "Median Income"
local pct_inc_qtl1str "% of Tract that is Poor"
local pct_inc_qtl5str "% of Tract that is Rich"

local max_dist_highway = 25
local comp_year = 1980

// create bins
gen sample_15_30 = 1 if dist_cbd_mi < 30 & dist_cbd_mi > 15 & disthighway_mi < `max_dist_highway' 
gen sample_5_15 = 1 if dist_cbd_mi < 15 & dist_cbd_mi > 5 & disthighway_mi < `max_dist_highway' 
gen sample_0_5 = 1 if dist_cbd_mi < 5 & disthighway_mi < `max_dist_highway' 


// locals for the y-scale
local 15_30pct_inc_qtl11950lab "0.1(0.05)0.3"
local 15_30pct_inc_qtl51950lab "0.1(0.05)0.3"
local 5_15pct_inc_qtl11950lab "0.1(0.05)0.3"
local 5_15pct_inc_qtl51950lab "0.1(0.05)0.3"
local 0_5pct_inc_qtl11950lab "0.1(0.05)0.3"
local 0_5pct_inc_qtl51950lab "0.1(0.05)0.3"


local 15_30pct_inc_qtl11980lab "0.1(0.05)0.3"
local 15_30pct_inc_qtl51980lab "0.1(0.05)0.3"
local 5_15pct_inc_qtl11980lab "0.1(0.05)0.3"
local 5_15pct_inc_qtl51980lab "0.1(0.05)0.3"
local 0_5pct_inc_qtl11980lab "0.2(0.05)0.4"
local 0_5pct_inc_qtl51980lab "0.1(0.05)0.3"


foreach var in /*wtmedianinc */ pct_inc_qtl1 pct_inc_qtl5 {
	foreach year in 1950 `comp_year' {
		foreach bin in 15_30 5_15  0_5 {
			
			xtile xq = disthighway_mi if sample_`bin'==1 & year==`year', nq(25)
			bys xq: egen ymean = mean(`var')
			bys xq: egen xmean = mean(disthighway_mi)
			bys xq: egen count = count(1)
			bys xq: egen ystd = sd(`var')
			replace ystd = ystd/sqrt(count)
			gen ub = ymean + 1.96*ystd
			gen lb = ymean - 1.96*ystd
		
			egen tagxq = tag(xq)
			
			twoway (rcap ub lb xmean) (scatter ymean xmean) if sample_`bin'==1 & year==`year' & tagxq==1,  ///
				xlabel(0(5)`max_dist_highway' ) ylabel(``bin'`var'`year'lab') ysize(5) ///
				name(`var'_`bin'_`year', replace)  /*linetype(none) nq(25) ytitle("``var'str'") */ ///
				xtitle("Distance from Highway (Miles)") legend(label(1 "95% CI") label(2 "Mean"))
				
			graph export "${main}/output/plots/incomesort/`var'`bin'_`year'.png", replace
				
			drop xq-tagxq
		}
	}
}

/*
******* Binned by city, and then averaged across cities

local comp_year = 1980
foreach var in /*wtmedianinc */ pct_inc_qtl1 pct_inc_qtl5 {
	foreach year in 1950 `comp_year' {
		foreach bin in 15_30 5_15  0_5 {
		
			xtile xq = disthighway_mi if sample_`bin'==1 & year==`year', nq(50)
			bys cbsa10 xq: egen ymean = mean(`var')
			bys cbsa10 xq: egen xmean = mean(disthighway_mi)
			egen tagcty = tag(cbsa10) if xq!=.
			bys xq: egen cbsa_ymean = wtmean(ymean) if tagcty==1
			bys xq: egen cbsa_xmean = wtmean(xmean) if tagcty==1
			egen tagxq = tag(xq) if tagcty==1
			
			scatter cbsa_ymean cbsa_xmean if tagxq==1
			
			drop xq-tagxq

		}
	}
}
*/


local 15_30pct_inc_qtl1_wlab "0.0(0.05)0.3"
local 15_30pct_inc_qtl5_wlab "0.0(0.05)0.3"
local 5_15pct_inc_qtl1_wlab "0.1(0.05)0.4"
local 5_15pct_inc_qtl5_wlab "0.0(0.05)0.3"
local 0_5pct_inc_qtl1_wlab "0.15(0.05)0.45"
local 0_5pct_inc_qtl5_wlab "0.0(0.05)0.3"

local 15_30pct_inc_qtl1_blab "0.0(0.05)0.3"
local 15_30pct_inc_qtl5_blab "0.15(0.05)0.45"
local 5_15pct_inc_qtl1_blab "0.0(0.05)0.3"
local 5_15pct_inc_qtl5_blab "0.15(0.05)0.45"
local 0_5pct_inc_qtl1_blab "0.0(0.05)0.3"
local 0_5pct_inc_qtl5_blab "0.0(0.05)0.3"

******** Split by Race *********
local year = 1980
foreach race in _w _b {
	foreach var in /*wtmedianinc */ pct_inc_qtl1 pct_inc_qtl5 {
		foreach bin in 15_30 5_15  0_5 {
			
			xtile xq = disthighway_mi if sample_`bin'==1 & year==`year', nq(25)
			bys xq: egen ymean = mean(`var'`race')
			bys xq: egen xmean = mean(disthighway_mi)
			bys xq: egen count = count(1)
			bys xq: egen ystd = sd(`var'`race')
			replace ystd = ystd/sqrt(count)
			gen ub = ymean + 1.96*ystd
			gen lb = ymean - 1.96*ystd
		
			egen tagxq = tag(xq)
			
			twoway (rcap ub lb xmean) (scatter ymean xmean) if sample_`bin'==1 & year==`year' & tagxq==1, ///
				xlabel(0(5)`max_dist_highway') ylabel(``bin'`var'`race'lab') ysize(6) ///
				name(`var'`race'_`bin'_`year', replace) /* linetype(none) nq(25) ytitle("``var'str'") */ ///
				xtitle("Distance from Highway (Miles)") legend(label(1 "95% CI") label(2 "Mean"))
				
			graph export "${main}/output/plots/incomesort/`var'`race'`bin'_`year'.png", replace
				
			drop xq-tagxq

		}
	}
}



******** Difference over Time *********

// keep only necessary variables
keep year-inc_qtl5_b dist* dist_cbd_mi-sample_0_5
reshape wide inc_qtl1-inc_qtl5_b tr_incsum-sample_0_5, i(geo2010) j(year)

// generate variables for difference over time
local comp_year = 1980
gen d_medianinc = wtmedianinc`comp_year' - wtmedianinc1950
gen d_pct_inc_qtl1 = pct_inc_qtl1`comp_year' - pct_inc_qtl11950
gen d_pct_inc_qtl5 = pct_inc_qtl5`comp_year' - pct_inc_qtl51950

// scatter plots
local comp_year = 1980
local 15_30str "15 to 30 miles"
local 5_15str "5 to 15 miles"
local 0_5str "less than 5 miles"
local d_medianincstr "Difference in Median Income"
local d_pct_inc_qtl1str "Difference in % of Tract that is Poor"
local d_pct_inc_qtl5str "Difference in % of Tract that is Rich"


// locals for the y-scale
local 15_30d_pct_inc_qtl1lab "-0.1(0.05)0.05"
local 15_30d_pct_inc_qtl5lab "0.0(0.05)0.15 "
local 5_15d_pct_inc_qtl1lab "-0.05(0.05)0.1"
local 5_15d_pct_inc_qtl5lab "-0.075(0.05)0.075 0"
local 0_5d_pct_inc_qtl1lab "0.05(0.05)0.2"
local 0_5d_pct_inc_qtl5lab "-0.15(0.05)0"

local max_dist_highway = 25
local comp_year = 1980

foreach var in /* d_medianinc */ d_pct_inc_qtl1 d_pct_inc_qtl5 {
	foreach bin in 15_30 5_15  0_5 {
		
		xtile xq = disthighway_mi if sample_`bin'1950==1 | sample_`bin'`comp_year'==1, nq(25)
		bys xq: egen ymean = mean(`var')
		bys xq: egen xmean = mean(disthighway_mi)
		bys xq: egen count = count(1)
		bys xq: egen ystd = sd(`var')
		replace ystd = ystd/sqrt(count)
		gen ub = ymean + 1.96*ystd
		gen lb = ymean - 1.96*ystd
	
		egen tagxq = tag(xq)
		
		twoway (rcap ub lb xmean) (scatter ymean xmean) if (sample_`bin'1950==1 | sample_`bin'`comp_year'==1) & tagxq==1,  ///
			xlabel(0(5)`max_dist_highway') ylabel(``bin'`var'`race'lab') ysize(5) ///
			name(`var'_`bin', replace) yline(0) /*linetype(none)  nq(30) ytitle("``var'str'") */ ///
			xtitle("Distance from Highway (Miles)") legend(label(1 "95% CI") label(2 "Mean"))
		
		graph export "${main}/output/plots/incomesort/`var'`bin'_`comp_year'.png", replace
		
		drop xq-tagxq

	}
}
