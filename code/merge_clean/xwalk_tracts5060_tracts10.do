* Laura Zhang
* This do file creates the census tract crosswalks for the 
* years 1950 and 1960 to be consistent with 2010 tract boundaries
* in a similar way to the LTDB (see code/merge_clean/create_const_tracts2010.do)
* using partial crosswalks created by Lee & Lin (2017). See raw/lee and lin data/
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
	gen tractfull =  statefips + cntyfips + tractfips  //concatenate to create full tract code
end


****define program to build xwalk****
program buildxwalk
	args year
	local yearabbr = substr("`year'", 3, 2)
	
	bys gisjoin`year': egen sum`year' = sum(area)
	gen weight = area/sum`year' //calc weights for gisjoin1950 to gisjoin2010
	
	bys gisjoin`year': egen w`year' = sum(weight)
	assert (w`year'-1) < 10e-7 //all weights should sum to 1
	drop w`year'
	
	
	//note below that gisjoin areas are contained within census tracts
	// i.e. gisjoin 12 can only be within one census tract. However
	// census tracts can be made up of multiple gisjoin areas
	
	sort tractfull`year' gisjoin`year'
	egen taggis`year' = tag(gisjoin`year')
	egen tagtract`year' = tag(tractfull`year')
	
	by tractfull`year': egen sumarea`year' = sum(area`year') if taggis`year'==1 //calculate area of tract
	by tractfull`year': egen areatract`year' = max(sumarea`year') //copy into empty cells
	gen weight`year' = area`year'/areatract`year' //get the weight of each gisjoin area within its census tract
	
	by tractfull`year': egen sumweight`year' = sum(weight`year') if taggis`year'==1
	assert sumweight`year'-1 < 10e-7 if !mi(sumweight`year') //all weights should sum to 1
	
	gen weightmult = weight`year'*weight // multiply probabilities (weights)
	collapse (sum) weightmult, by(tractfull`year' tractfull2010) //turn dataset into tract1950 to tract2010
	
	by tractfull`year': egen sum = sum(weightmult)
	assert sum-1<10e-7 //all weights should sum to 1
	
	//clean up and match format of LTDB crosswalks
	drop sum
	rename (tractfull`year' tractfull2010 weightmult) (trtid`yearabbr' trtid10 weight)
	save "${temp}/crosswalk_`year'_2010.dta", replace
end


*** first convert csv xwalk files to dta files***
//lee and lin gisjoin area weights
import delimited "${main}/data/raw/lee and lin data/DataAndCode/tract_xwalk_files/1950.csv", encoding(ISO-8859-1)clear
save "${temp}/leelin_xwalk50.dta", replace

import delimited "${main}/data/raw/lee and lin data/DataAndCode/tract_xwalk_files/1960.csv", encoding(ISO-8859-1)clear
save "${temp}/leelin_xwalk60.dta", replace

//2010 gisjoin to census tract codes
import delimited "${temp}/gisjoin2010.csv", delimiter(space) encoding(ISO-8859-1)clear
rename (tractfips state county) (tracta statea countya)
filltract
rename * *2010
save "${temp}/gisjoin2010.dta", replace

//1950 gisjoin to census tract codes
import delimited "${main}/data/raw/nhgis/income 1950-2010/nhgis0005_ds82_1950_tract.csv", encoding(ISO-8859-1)clear
save "${temp}/raw1950.dta", replace

//1960 gisjoin to census tract codes
import delimited "${main}/data/raw/nhgis/income 1950-2010/nhgis0005_ds92_1960_tract.csv", encoding(ISO-8859-1)clear
save "${temp}/raw1960.dta", replace


****start creating crosswalk********
foreach year in 1950 1960 {
	local yearabbr = substr("`year'", 3, 2)

	import delimited "${temp}/gisjoin`year'.csv", delimiter(space) encoding(ISO-8859-1)clear
	drop state county
	ren area area`year'
	
	if "`year'"=="1960" {
		drop if strpos(gisjoin, "nodata")>0 //drop obs that say nodata
	}
	
	//merge in census tract codes for `year'
	merge 1:1 gisjoin using "${temp}/raw`year'.dta", keepusing(tracta statea countya) gen(m1)
	filltract
	ren (gisjoin tractfips tractfull statefips cntyfips) (gisjoin`year' tractfips`year' tractfull`year' statefips`year' cntyfips`year') 

	di "`yearabbr'"
	//merge in gisjoin area weights from 1950 to 2010
	merge 1:m gisjoin`year' using "${temp}/leelin_xwalk`yearabbr'.dta", gen(m2)

	//merge in census tract codes for 2010
	merge m:1 gisjoin2010 using "${temp}/gisjoin2010.dta", gen(m3)
	keep if m1==3 & m2==3 & m3==3  //only keep matches
	drop m?
	buildxwalk `year'
}
