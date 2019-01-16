* Jan 2018
* Laura Zhang
* This do file creates a crosswalk from 2000 MSA definitions 
* to 2010 CSBA definitions

clear
set more off
global main `"/Users/laurazhang/Documents/income_seg/"'

** prepare a cleaned version of baumsnow data to merge **
use "${main}/data/temp/baumsnow_final.dta", clear
keep if year==90
keep msa name
//clean up name
replace name = subinstr(name, " city", "",.)

gen idno = _n
save "${main}/data/temp/baumsnow_msa.dta", replace

** create crosswalk from msa to cbsa **
use "${main}/data/temp//msa_county00_crosswalk.dta", clear

merge m:1 county using "${main}/data/temp/cbsa_county2010_crosswalk.dta", keepusing(cbsa* state* county10)
sort _merge msafips countyfips
drop if _merge!=3

// drop puerto rico
drop if statecode=="PR" & _merge==2
drop if strpos(msaname, ", PR")>0

** try merging to baumsnow
keep cbsa* msafips msafinal msaname
keep if cbsaname!=""
bys cbsaname msafinal: keep if _n==1 //only keep one obs
rename msafinal msa
drop if msa==.
gen id = _n

// clean up name
replace cbsaname = subinstr(cbsaname, " Metropolitan Statistical Area", "",.)
rename cbsaname name
compress name

// use reclink to merge
reclink name msa using "${main}/data/temp/baumsnow_msa.dta", gen(mscore) idm(id) idu(idno)
rename (msa Umsa) (cbsa_msa msa)

// some manual edits
replace msa = 733 if cbsa_msa==730 & msa==.   //Bangor, ME
replace msa = 1123 if cbsa_msa==1120 & msa==. //Boston, MA
replace msa = 1303 if cbsa_msa==1305 & msa==. //Burlington, VT
replace msa = 3283 if cbsa_msa==3280 & msa==. //Hartford, CT
replace msa = 4243 if cbsa_msa==4240 & msa==. //Lewiston, ME
replace msa = 5483 if cbsa_msa==5480 & msa==. //Lewiston, ME
replace msa = 5523 if cbsa_msa==5520 & msa==. //New London, CT
replace msa = 5660 if cbsa_msa==5660 & msa==. & cbsa10==39100 //Newburgh, NY
replace msa = 5720 if cbsa_msa==5720 & msa==. //Norfolk, VA
replace msa = 6323 if cbsa_msa==6320 & msa==. //Pittsfield, MA
replace msa = 6403 if cbsa_msa==6400 & msa==. //Portland, ME
replace msa = 6483 if cbsa_msa==6480 & msa==. //Providence, RI
replace msa = 8003 if cbsa_msa==8000 & msa==. //Springfield, MA
replace msa = 8960 if cbsa_msa==8960 & msa==. //West Palm Beach, FL
replace msa = 9160 if cbsa_msa==9160 & msa==. //Wilmington, De

//clean up mismatches
drop if name=="Ocean City, NJ" & msaname=="Atlantic-Cape May, NJ PMSA"
drop if name=="Hartford-West Hartford-East Hartford, CT" & msaname=="New London-Norwich, CT-RI MSA"
drop if name=="Hartford-West Hartford-East Hartford, CT" & msaname=="New Haven-Meriden, CT PMSA"
drop if name=="Miami-Fort Lauderdale-Pompano Beach, FL" & msaname=="New Haven-Meriden, CT PMSA"
drop if name=="Norwich-New London, CT" & msaname=="Hartford, CT MSA"
drop if name=="Providence-New Bedford-Fall River, RI-MA" & msaname=="New London-Norwich, CT-RI MSA"
drop if name=="Providence-New Bedford-Fall River, RI-MA" & msaname=="Boston, MA-NH PMSA"
drop if name=="Worcester, MA" //not in baumsnow data
drop if name=="Holland-Grand Haven, MI" //not in baumsnow data

// rename variables
rename (name Uname) (cbsaname name)

//check merge with baum-snow
merge m:1 msa using "${main}/data/temp/baumsnow_msa.dta", gen(merge_bs) keepusing(name) update
keep if merge_bs==3 | merge_bs==4 | merge_bs==5
rename (name msa) (bs_name bs_msa)

//label variables
label variable msaname "MSA/PMSA title in 2000"
label variable cbsaname "CBSA title in 2010"
label variable bs_name "MSA name from baumsnow data"
label variable bs_msa "MSA fips from baumsnow data"
label variable cbsa_msa "MSA/PMSA fips that matches to CBSA (using counties)"
label variable msafips "CMSA/MSA fips depending on if MSA is in CMSA or not"
label variable cbsa10 "CBSA fips"
drop *merge* mscore id*

// split large CBSAs into MetDiv
gen metdiv10 = .
replace metdiv10 = 19124 if cbsa_msa==1920 //Dallas
replace metdiv10 = 23104 if cbsa_msa==2800 //Fort Worth
replace metdiv10 = 42044 if cbsa_msa==5945 //Santa Ana
replace metdiv10 = 31084 if cbsa_msa==4480 //Los Angeles
replace metdiv10 = 22744 if cbsa_msa==2680 //Fort Lauderdale
replace metdiv10 = 33124 if cbsa_msa==5000 //Miami
replace metdiv10 = 48424 if cbsa_msa==8960 //West Palm Beach
replace bs_name ="West Palm Beach, FL" if cbsa_msa==8960
replace metdiv10 = 37964 if cbsa_msa==6160 //Philadelphia
replace metdiv10 = 48864 if cbsa_msa==9160 //Wilmington
replace bs_name ="Wilmington, DE" if cbsa_msa==9160

// split large CBSAs into counties to match MSA
gen county10 =.
replace county10 = 36027 if cbsa_msa==2281 //Dutchess County, NY
replace county10 = 36071 if cbsa_msa==5660 //Orange County, NY/Newburgh, NY

// make sure areas are uniquely id'ed
egen tagcbsa = tag(cbsa10 metdiv10 county), missing
egen tagmsa = tag(cbsa_msa)
egen tagbs_msa = tag(bs_msa)
assert tagcbsa==1
assert tagmsa==1
assert tagbs_msa==1
drop tag*

//create variables that designate the 2010 area definition used for "city"
//which will be cbsa, metdiv, or county depending
//on what matches up best with baumsnow msa definitions
gen areacode = cbsa10 if metdiv==. & county10==.
replace areacode = metdiv if metdiv!=. 
replace areacode = county10 if county10!=.
gen areaflag = "cbsa" if metdiv==. & county10==.
replace areaflag = "metdiv" if metdiv!=. 
replace areaflag = "county" if county10!=.

** add county data to merge on
gen str5 county = string(county10, "%05.0f") 
ren metdiv10 div10

//note we have to split the dataset into 3 parts to properly merge data
//cbsa data
preserve
keep if areaflag=="cbsa"
merge 1:m cbsa10 using "${main}/data/temp/cbsa_county2010_crosswalk.dta", keep(1 3 4 5) keepusing(county div10) update replace
save "${main}/data/temp/cbsa_temp", replace
restore
//metdiv data
preserve
keep if areaflag=="metdiv"
merge 1:m cbsa10 div10 using "${main}/data/temp/cbsa_county2010_crosswalk.dta", keep(1 3 4 5) keepusing(county) update replace
save "${main}/data/temp/metdiv_temp", replace
restore
//append to county data
keep if areaflag=="county"
append using "${main}/data/temp/cbsa_temp"
append using "${main}/data/temp/metdiv_temp"

egen tagcnty = tag(county)
assert county!=""
assert tagcnty==1
drop _merge tag

save "${main}/data/temp/baumsnow_msa_cbsa_xwalk", replace


/*********************** NOTES ********************
**MSA -> Micro SA in 2010**
Enid, OK 
Jamestown, NY

**MSA combined with larger MSA in 2010
Galveston, TX combined with Houston MSA
Hamilton, OH combined with Cincinnati-Middletown MSA
Beloit, WI was previously under Janesville-Beloit MSA -> Janesville MSA (Beloit removed)
Kenosha, WI combined with Chicago-Joliet-Naperville MSA
Tacoma, WA combined into Seattle-Tacoma-Bellevue MSA

We have to drop the MSAs above since they are hard to
separate in 2010 CBSA boundary definitions, and I only have
consistent tract boundaries within 2010 CBSAs
***************************************************/



