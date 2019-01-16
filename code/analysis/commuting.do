* Laura Zhang
* April 2018
* This do file completes all of the analysis related to commuting and commuting costs

clear
set more off
program drop _all
global main `"/Users/laurazhang/Documents/income_seg/"'

******** use commuting data *********
use "${main}/clean/commuting_clean.dta"
gen year = 1980
ren trtid10 geo2010

******** merge with master data *********
merge 1:1 year geo2010 using "${main}/clean/master_tract.dta", keep(3) nogen

egen disthighway_full = rowmin(disthighway distyellowbook)

// create some useful vars
gen dist_cbd_mi = dist_cbd/1609.34
gen disthighway_mi = disthighway_full/1609.34

egen travtimesum = rowtotal(travtime*)
unab travvars: travtime_*
foreach var in `travvars' {
	gen pct_`var' = `var'/travtimesum
}

egen placeworksum = rowtotal(placework*)
unab placevars: placework_*
foreach var in `placevars' {
	gen pct_`var' = `var'/placeworksum
}

egen meanstranssum = rowtotal(meanstrans_* workedhome)
unab meansvars: meanstrans_*
foreach var in `meansvars' workedhom {
	gen pct_`var' = `var'/meanstranssum
}

*********** some plots and tables ********
egen pct_travtime_p45 = rowtotal(pct_travtime_p60 pct_travtime_45_59)
egen pct_car = rowtotal(pct_meanstrans_car*)

local pct_travtime_p45title "% Travel Time 45+ min"
local pct_placework_smsa_cctitle "% Working in Central City of SMSA"
local pct_cartitle "% Commuting by Car"


local max_dist_highway = 30
// create bins
local numbins = 6
xtile sample = dist_cbd_mi if disthighway_mi < `max_dist_highway', nq(`numbins')

local max_dist_highway = 30
local pct_travtime_p45lab = "0.025(0.025)0.225"
local pct_placework_smsa_cclab = "0.0(0.1)0.7"
local pct_carlab = "0.65(0.05).9"


foreach var in pct_travtime_p45 pct_placework_smsa_cc pct_car {
	local addplot = "graph twoway"
	foreach bin of numlist 1/`numbins' {
		local col_b = 255-`bin'*int(255/`numbins')
		local col_r = `bin'*int(255/`numbins')
		
		xtile xq = disthighway_mi if sample==`bin' & disthighway_mi < `max_dist_highway' , nq(30)
		bys xq: egen ymean = mean(`var')
		bys xq: egen xmean = mean(disthighway_mi)
		
		egen tagxq = tag(xq)
		
		`addplot' mspline ymean xmean if sample==`bin' & tagxq==1  & disthighway_mi < `max_dist_highway',  name(`var', replace)  ///
			ylabel(``var'lab')  xtitle("Distance from Highway (Miles)")  lcolor("`col_r' 0 `col_b'") legend(off) lstyle(p1) ///
			ytitle(``var'title') xlabel(1(5)26)
		//reg `var' disthighway_mi if sample_`bin'==1 & disthighway_mi <15 
			
		drop xq-tagxq	
		local addplot "graph twoway addplot"	
		
	}
	graph export "${main}/plots/commuting/`var'.png", replace
}

********** check that commuting costs is not correlated with instrument
// instrument
gen nearhh = 1 if disthighway_mi < 6
replace nearhh = 0 if nearhh==. & disthighway_mi!=.
bys county: egen pct_nearhh = mean(nearhh)

bys county: egen avgpct_travtime_p45 = wtmean(pct_travtime_p45), weight(population)
bys county: egen avgpct_travtime_p60 = wtmean(pct_travtime_p60), weight(population)
bys county: egen county_dist_cbd = mean(dist_cbd_mi)

bys county: keep if _n ==1
encode division, gen(ndivision)

// 1950 control data
merge 1:1 county using "${main}/temp/county1950vars.dta", keep(1 3) keepusing(*1950)
drop _merge

gen logcounty_population1950 = log(population_1950)
gen logcounty_medianinc1950 = log(medianinc_1950)

label var logcounty_medianinc1950 "Log Median Income, 1950"
label var logcounty_population1950 "Log Population, 1950"
label var avgpct_travtime_p45 "Average % Traveling 45+ Min To Work"
label var avgpct_travtime_p60 "Average % Traveling 60+ Min To Work"
label var pct_nearhh "Highway Instrument"
label var county_dist_cbd "Distance to CBD"


reg avgpct_travtime_p45 pct_nearhh county_dist_cbd , robust
outreg2 using "${main}/tables/commuting_check", tex label replace 
reg avgpct_travtime_p60 pct_nearhh county_dist_cbd , robust
outreg2 using "${main}/tables/commuting_check", tex label append 
