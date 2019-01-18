* Laura Zhang
* February 2018
* This do file cleans the commuting data from the NHGIS in 1980 (data from 1960-2010 are available)

clear
set more off
program drop _all
global main `"/Users/laurazhang/Documents/income_seg/"'


**** define program to pad tract fips ****
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

****** start cleaning data ***********
import delimited "${main}/data/raw/nhgis/commuting 1960-2010/nhgis0011_ds107_1980_tract.csv", encoding(ISO-8859-1)clear varnames(1)
ren (dhb001-dhb005) (placework_smsa_cc placework_smsa_rem placework_out_smsa placework_notrep placework_notsmsa)
ren (dhd001-dhd006) (meanstrans_car meanstrans_carpool meanstrans_public meanstrans_walk meanstrans_other workedhome)
ren (dhe001-dhe008) (travtime_l5 travtime_5_9 travtime_10_14 travtime_15_19 travtime_20_29 travtime_30_44 travtime_45_59 travtime_p60)

drop blck_grpa-zipa
filltract

save "${main}/data/temp/commuting_temp.dta", replace

***** adjust data *******
do "${main}/code/merge_clean/gen_const_commuting.do"
