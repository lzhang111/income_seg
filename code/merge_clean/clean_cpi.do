* Laura Zhang
* Feb 2018
* This do file cleans the annual cpi data 
clear
set more off
global main `"/Users/laurazhang/Documents/income_seg/"'


import excel "${main}/data/raw/cpi/cpi1950-2010.xlsx", sheet("BLS Data Series") cellrange(A12:P10000) clear firstrow
drop if Year==.
keep Year Annual
rename (Year Annual) (year cpi)
replace cpi = cpi/100 //change into %

save "${main}/data/temp/cpi.dta", replace
