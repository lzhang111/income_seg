* Laura Zhang
* Jan 2018
* This is an edited version of interpolate_to_2010.do 
* from raw/crosswalks/LTDB crosswalks and code/ provided
* by the Longitudinal Tract Database at Brown University
* See https://s4.ad.brown.edu/projects/diversity/Researcher/LTDB.htm
* for details
clear
set more off
global main `"/Users/laurazhang/Documents/income_seg/"'


//variables to be converted in each year
local 1980vars "w_* b_* amind_* as_*" 
local 1990vars "w_* b_* amind_* as_* oth_*" 
local 2000vars "w_* b_* amind_* as_* oth_* haw_* two_*" 
local 2010vars "w_* b_* amind_* as_* oth_* haw_* hisp_*" 

*****this is just for 2010*****
use "${main}/data/temp/clean2010inc.dta", clear
rename tractful trtid10
keep trtid10 inc* population-pop2
order trtid10
save "${main}/data/temp/const2010inc.dta", replace
export delimited "${main}/data/temp/const2010inc.csv", replace

use "${main}/data/temp/clean2010incrace.dta", clear
rename tractful trtid10
keep trtid10 `2010vars'
order trtid10
save "${main}/data/temp/const2010incrace.dta", replace
export delimited "${main}/data/temp/const2010incrace.csv", replace

foreach year of numlist 1950(10)2000 {

	local datastr "inc"
	if `year'>=1980{
		local datastr "inc incrace"
	}
	local xwalkstr `"${main}/data/raw/crosswalks/LTDB crosswalks and code/"'
	if `year'<1970{
		local xwalkstr "${main}/data/temp/"
	}
	
	foreach data in `datastr' { 
	
		global input_file "${main}/data/temp/clean`year'`data'.dta"
		global output_file "${main}/data/temp/const`year'`data'"
		global crosswalk_file "`xwalkstr'crosswalk_`year'_2010.dta"
		global crosswalk_year = substr("`year'", 3, 2)
		global input_idvar "tractfull"
		global counts "inc* population white black as amind two"
		global medians "wtmedianinc"
		global median_weights "pop2"
		if "`data'"=="incrace" {
			global counts "``year'vars'"
			global medians ""
			global median_weights ""
		}
		
		  
		//clear globals in for loop
		global allmiss_vars ""
		global missweights ""
		global weight ""
		global median ""
		global missweight ""
		  
		/****************************************************
		 It is not necessary to edit anything below this line.
		 ****************************************************/

		/****************************************************
					 Explanation of user inputs
		 ****************************************************

		 - "input_file" is the name of your data file in
		   STATA format.

		 - "output_file" is the name you would like to give
		   the data file that is produced by this program.

		 - "crosswalk_file" is the name of the crosswalk file
		   that you obtained.

		 - "crosswalk_year" is the 2-digit year that is
		   being interpolated to 2010 by this crosswalk file.
		   It must be either 70, 80, 90, or 00 depending on
		   which crosswalk is being used.

		 - "input_idvar" is the tract identification variable
		   in the input data file.  This must be a string
		   variable with the following 11 digits:
			 1-2  FIPS state code
			 3-5  FIPS county code
			 6-11 Census tract code (without decimals)
		   All codes must be padded with zeros.  For example,
		   state code "1" must be expressed as "01", and
		   tract code "41.5" must be expressed as "004150".

		 - "counts" is a space-separated list of all the
		   count variables that you would like to interpolate.
		   If you do not have any count variables to
		   interpolate, leave these double-quotes empty.

		 - "medians" is a space-separated list of all the
		   median/mean/rate variables that you would like
		   to interpolated as weighted average statistics.
		   If you do not have any medians to interpolate,
		   leave these double-quotes empty.

		 - "median_weights" is a space-separated list of
		   the base variables for the meian/mean/rate
		   variables that are listed in "medians".  For
		   example, the base variable for median household
		   income would be the total number of households.
		   Note that these variables must be listed in
		   the same order that you listed your "medians" on
		   the previous line.  If you do not have any medians
		   to interpolate, leave these double-quotes empty.

		****************************************************/

		/****************************************************
		 Open the user data file, keep the listed variables,
		 and merge with the crosswalk
		 ****************************************************/
		use $input_file
		keep $input_idvar $counts $medians $median_weights
		rename $input_idvar oldid
		rename oldid trtid$crosswalk_year
		
		merge trtid$crosswalk_year using "$crosswalk_file", sort uniqmaster
		tab _merge
		keep if (_merge == 3)
		drop _merge

		/****************************************************
		 Set up flag identifying cases where all segments of
		 a 2010 tract have missing values for a variable.
		 These will be incorrectly set to zero when cases
		 are collapsed into 2010 tracts, so they must be
		 flagged and set back to missing after the collapse.
		 ****************************************************/
		foreach x of varlist $counts $medians $median_weights {
		  bysort trtid$crosswalk_year (`x') : gen allmiss_`x' = mi(`x')
		  global allmiss_vars $allmiss_vars allmiss_`x'
		  
		}
		pause
		/****************************************************
		 Weight the medians by their base variable.
		 Temporarily set the base variable to missing if
		 the median is missing.  Otherwise the value used
		 later to unweight any aggregated medians will be
		 incorrect.
		 ****************************************************/
		global n_medians : word count $medians
		global i = 1
		while $i <= $n_medians {
		  global median : word $i of $medians
		  global weight : word $i of $median_weights
		  gen weight_$median = $weight if ($median != .)
		  replace $median = $median * weight_$median
		  global missweights $missweights weight_$median
		  global i = $i + 1
		}
		
		/****************************************************
		 apply the interpolation weight
		 ****************************************************/
		foreach x of varlist $counts $medians $median_weights $missweights {
		  replace `x' = `x' * weight
		}
		
		/****************************************************
		 collapse into 2010 census tracts
		 ****************************************************/
		collapse (sum) $counts $medians $median_weights $missweights (min) $allmiss_vars, by(trtid10)

		/****************************************************
		 Set each variable to missing if it was missing for
		 all segments before collapsing into 2010 census
		 tracts.  Otherwise they are automatically set to
		 zero, which is incorrect.
		 ****************************************************/
		foreach x of varlist $counts $medians $median_weights {
		  replace `x' = . if (allmiss_`x' == 1)
		}

		/****************************************************
		 unweight the median variables to generate the final
		 weighted averages
		 ****************************************************/
		global i = 1
		while $i <= $n_medians {
		  global median : word $i of $medians
		  global missweight : word $i of $missweights
		  replace $median = $median / $missweight
		  global i = $i + 1
		}
		global i = 1
		while $i <= $n_medians {
		  global median : word $i of $medians
		  global weight : word $i of $median_weights
		  replace $median = . if ($weight == 0)
		  global i = $i + 1
		}

		/****************************************************
		 sort and save
		 ****************************************************/
		drop $missweights $allmiss_vars
		sort trtid10
		save $output_file, replace
		export delimited $output_file, replace
		summ
		exit

		/****************************************************
		 written 10/24/2011 by Brian J. Stults
		 ****************************************************/
	}
}
