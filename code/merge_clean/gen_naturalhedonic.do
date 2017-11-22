* Edited Lee and Lin code to create natural amenities hedonic index
	
clear all
pause off
capture log close
set graphics on

*** Change directory to put results here
*** Note that this code automatically creates a sub-directory structure
global main `"/Users/laurazhang/Documents/income_seg/"'
global prjfolder `"${main}/raw/lee and lin data/DataAndCode"'
global clean `"${main}/clean/"'

cd "$prjfolder"		


use "$prjfolder/data/Lee_Lin_data.dta", clear
capture gen insample = ma_tracts>1 & lndens!=. & dpri!=.
capture replace insample = ma_tracts>1 & lndens!=. & dpri!=.


* hedonic value - USE STAND DEV VALUE 
forvalues n = 8/8 {
	bysort mayear: egen sd_ahat`n' = sd(ahat`n')
	gen var_ahat`n' = sd_ahat`n'^2
	qui sum var_ahat`n' if mytag
	gen ma_ahat`n' = var_ahat`n'>r(mean)
}

keep year statefips cbsa ma* ma_ahat8
by mayear: keep if _n ==1

save "${clean}/naturalhedonic.dta", replace
