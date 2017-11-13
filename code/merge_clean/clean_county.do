* Laura Zhang
* November 2017 
* This do file uses some of the code from BS's file make-xwalks.do to recode counties
* to consistent 2000 boundaries and creates the crosswalk to MSAs (I think 1990s) 

clear
set more off
global main `"/Users/laurazhang/Documents/income_seg/"'
cd ${main}

****** 1. Define the counties in each MSA ***************
clear
insheet using "${main}/raw/baumsnow/data/ccdb/msa-to-county.txt"
gen cmsa = .
replace cmsa = msacmsa if pmsa~=9999
replace msacmsa = pmsa if pmsa~=9999
rename msacmsa msa
gen statefips = int(county/1000)
gen cntyfips = county-1000*statefips

*drop AK and HI and counties not part of an MSA
drop if statefips==2|statefips==15
rename msaname name
replace name = pmsaname if cmsa~=.

keep name msa cmsa statefips cntyfips

**** Merge in Laura's data files ********************




** recode counties to be consistent over time
do "${main}/raw/baumsnow/xwalks/county-change-code.do"

**Build New England MSA Equivalents
*http://www.census.gov/population/estimates/metro-city/93nfips.txt
replace msa = 733 if statefips==23 & cntyfips==19
replace name = "Bangor, ME" if msa==733
replace msa = 743 if statefips==25 & cntyfips==1
replace name = "Barnstable-Yarmouth, MA" if msa==743
replace msa = 1123 if statefips==25 & cntyfips==5
replace msa = 1123 if statefips==25 & cntyfips==9
replace msa = 1123 if statefips==25 & cntyfips==17
replace msa = 1123 if statefips==25 & cntyfips==21
replace msa = 1123 if statefips==25 & cntyfips==23
replace msa = 1123 if statefips==25 & cntyfips==25
replace msa = 1123 if statefips==25 & cntyfips==27
replace name = "Boston, MA" if msa==1123
replace msa = 4760 if statefips==33 & cntyfips==11
replace msa = 4760 if statefips==33 & cntyfips==13
replace msa = 4760 if statefips==33 & cntyfips==15
replace name = "Manchester, NH" if msa==4760
replace msa = 1303 if statefips==50 & cntyfips==7
replace msa = 1303 if statefips==50 & cntyfips==11
replace msa = 1303 if statefips==50 & cntyfips==13
replace name = "Burlington, VT" if msa==1303
replace msa = 3283 if statefips==9 & cntyfips==3
replace msa = 3283 if statefips==9 & cntyfips==7
replace msa = 3283 if statefips==9 & cntyfips==13
replace name = "Hartford, CT" if msa==3283
replace msa = 4243 if statefips==23 & cntyfips==1
replace name = "Lewiston-Auburn, ME" if msa==4243
replace msa = 5483 if statefips==9 & cntyfips==1
replace msa = 5483 if statefips==9 & cntyfips==9
replace name = "New Haven, CT" if msa==5483
replace msa = 5523 if statefips==9 & cntyfips==11
replace name = "New London-Norwich, CT" if msa==5523
replace msa = 6323 if statefips==25 & cntyfips==3
replace name = "Pittsfield, MA" if msa==6323
replace msa = 6403 if statefips==23 & cntyfips==5
replace name = "Portland, ME" if msa==6403
replace msa = 6483 if statefips==44 & cntyfips==1
replace msa = 6483 if statefips==44 & cntyfips==3
replace msa = 6483 if statefips==44 & cntyfips==7
replace msa = 6483 if statefips==44 & cntyfips==9
replace name = "Providence, RI" if msa==6483
replace msa = 8003 if statefips==25 & cntyfips==13
replace msa = 8003 if statefips==25 & cntyfips==15
replace name = "Springfield, MA" if msa==8003

**Thiese counties does not belong in an MSA
drop if statefips==9 & cntyfips==15
drop if statefips==9 & cntyfips==5

*/
