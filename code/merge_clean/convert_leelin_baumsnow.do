* Laura Zhang *
* This do file will convert Baum-Snow and Lee & Lin's final data files to csv.
clear
set more off

global main `"/Users/laurazhang/Documents/income_seg/"'
global temp `"${main}/temp"'

// Lee & lin
use "${main}/raw/lee and lin data/DataAndCode/data/Lee_Lin_data.dta"
export delimited "${temp}/leelin_final.csv", replace
save "${temp}/leelin_final.dta", replace

// Baum-Snow
use "${main}/raw/baumsnow/data/msa-final.dta"
export delimited "${temp}/baumsnow_final.csv", replace
save "${temp}/baumsnow_final.dta", replace
