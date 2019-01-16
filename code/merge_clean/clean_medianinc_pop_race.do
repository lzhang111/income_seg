* Laura Zhang 
* Jan 2017
* This do file will clean the median income (1950, 1980-2010), 
* total population (1950, 1970-2010), and race counts (1950, 1970-2010) data at the census
* tract level from the NHGIS
clear
set more off
program drop _all

global main `"/Users/laurazhang/Documents/income_seg/"'
global temp `"${main}/data/temp/"'

****define program to pad tract fips****
program filltract
	tostring tracta, gen(tractstr)
	gen tractlen = strlen(tractstr)
	summ tractlen
	
	if "`r(max)'"=="4" {
		replace tracta = tracta*100  //earlier tract codes had fewer sig digits
	}
	if "`r(max)'"=="6" & "`r(min)'"=="1" {
		//mix of converted codes with longer format and codes with shorter format
		gen gislen = strlen(gisjoin) //longer formats have longer gisjoin codes
		replace tracta = tracta*100 if strlen(gisjoin)==12 //convert shorter format to longer format
	}
	
	gen str6 tracta2 = string(tracta, "%06.0f") //pad with zeros to create 6 digit code
	gen str2 statea2 = string(statea, "%02.0f") //pad with zeros to create 2 digit
	gen str3 countya2 = string(countya, "%03.0f") //pad with zeros to create 3 digit
	
	drop tractstr tractlen tracta statea countya
	rename (tracta2 statea2 countya2) (tractfips statefips cntyfips)
	
	//create tract fips that contains state and county fips
	gen tractfull =  statefips + cnty + tract
end


* 1950
import delimited "${main}/data/raw/nhgis/median income, counts by race, population/nhgis0010_ds82_1950_tract.csv", encoding(ISO-8859-1) clear
drop pre post areaname
rename bz population
rename (b0j001-b0j003) (white black other)
rename b0f001 medianinc

recode medianinc (99999=.)
replace median = . if median==0 & pop>1000
filltract

save "${temp}/median_pop_race1950.dta", replace


*1970-2010
import delimited "${main}/data/raw/nhgis/median income, counts by race, population/nhgis0010_ts_nominal_tract.csv", encoding(ISO-8859-1)clear
drop *nh nhgiscode av0aam ab2aam name
drop if tracta==0
destring year, replace

ren (av0aa-ab2aa) (population white black amind as two medianinc)
ren (statefp countyfp) (statea countya)
recode white (-2=.)
filltract

** 2010 does not have median inc data, use 2008-2012 data instead
preserve
keep if year=="2008-2012"
replace year="2010"
save "${temp}/2010medianinc.dta", replace
restore

drop if year=="2008-2012"
merge 1:1 year statefips cntyfips tractfips using "${temp}/2010medianinc.dta", update replace
destring year, replace

** append 1950 data
append using "${temp}/median_pop_race1950.dta"

sort year tractfull

*******NOTE THIS CODE IS SLOW*************
***create weighted median****
egen tag=tag(year tractfull)
bys year tractfull: egen tracttag = min(tag)

gen wtmedianinc = .    
egen group = group(year tractfull) if tracttag==0
summ group
quietly forvalues i = 1/`r(max)' { 
	summarize median [w=population] if group == `i', detail 
	replace wtmedianinc = r(p50) if group == `i' 
} 
replace wtmedianinc = medianinc if tracttag==1
***********************************************
     
collapse (sum) pop white-two (max) wtmedianinc, by(year tractfull)
save "${temp}/median_pop_race.dta", replace
