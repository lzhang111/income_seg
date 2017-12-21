** Quick do file to clean NLSY data***
** Laura Zhang **
** December 2017 **
clear
set more off

global main `"/Users/laurazhang/Documents/income_seg/"'
import delimited "${main}/raw/nlsy/income_seg_basic.csv", case(preserve) encoding(ISO-8859-1) clear

do "${main}/raw/nlsy/income_seg_basic-value-labels.do"

*** clean up variable names ****
tolower *
ren version version
ren caseid id
ren sample_id sampleid
ren sample_race race
ren sample_sex sex


ren (q1_3_a_m q1_3_a_y) (dobm doby)
ren (fam_2a fam_8 fam_9a fam_10 fam_11a hgc_mother fam_19 hgc_father fam_26) ///
	(birthcountry rel_fem occ_fem rel_mal occ_mal hgc_mom work_mom hgc_dad work_dad)

#delimit ;
ren (cpsocc70* cpsocc80* occall_emp_01* q13_5_trunc_revised* q13_18_trunc_revised*  
	wkswk_pcy* hrswk_pcy* wksuemp_pcy* wksolf_pcy* tnfi_trunc* povstatus* afqt_3)
	(occ70* occ80* occ00* inctot* inctot_spouse* 
	wks_work* hrs_work* wks_uemp* wks_olf* tnfi* povstat* afqt);
#delimit cr   


ren hgcrev* hgc*

foreach i of numlist 10, 79/93, 94(2)98 {
	ren hgc`i'* hgc*
} 

foreach i of numlist 0(2)8 {
	ren hgc0`i'* hgc*
} 

ren (q13_5_trunc* q13_18_trunc*) (inctot* inctot_spouse*)
ren (q13_5* q13_18*) (inctot* inctot_spouse*)
ren occ80_01_2000 occ80_2000

drop occall* occ00_1998 //extra employment variables

reshape long hgc_ occ70_ occ80_ occ00_ inctot_ inctot_spouse_ ///
	wks_work_ hrs_work_ wks_uemp_ wks_olf_ tnfi_ povstat_, i(id) j(year)
	
ren *_ *

** order variables **
order version year id sampleid race sex dob* birth *mom *dad *fem *mal afqt occ* inc*

** label variables **
label variable hgc_mom "highest grade completed, mom"
label variable hgc_dad "highest grade completed, dad"
label variable work_mom "did mother/stepmother work for pay for all, part, not at all of 1978"
label variable work_dad "did father/stepfather work for pay for all, part, not at all of 1978"
label variable rel_fem "relation to R of adult female in hh at age 14" 
label variable rel_mal "relation to R of adult male in hh at age 14" 
label variable occ_fem "occupation of adult female"
label variable occ_mal "occupation of adult male"
label variable tnfi "total net family income"
label variable inctot "total income, wages and salary"
label variable inctot_spouse "total income, wages and salary of spouse"
label variable hgc "higest grade completed"
label variable wks_olf "weeks out of labor force"
label variable wks_uemp "weeks unemployed"
label variable wks_work "weeks worked"
label variable hrs_work "hours worked"
label variable occ70 "occupation code, 1970 defn"
label variable occ80 "occupation code, 1980 defn"
label variable occ00 "occupation code, 2000 defn"
label variable afqt "armed forces qual test % score in 1981, revised 2006"
label variable povstat "poverty status"


** replace variables with missing code ****
recode * (-5/-1 = .)

** correct highest education ***
sort id year

by id: replace hgc = hgc[_n - 1] if hgc==. & _n!=1 & !mi(hgc[_n - 1])
by id: replace hgc = hgc[_n - 1] if hgc < hgc[_n - 1] & _n!=1 & !mi(hgc[_n - 1])

gen flag2 = .
by id: replace flag2 = 1 if hgc < hgc[_n - 1] & _n!=1 & !mi(hgc[_n - 1])
by id: egen flag2id = min(flag2)

** gen age variable **
replace doby = doby + 1900
gen age = year - doby


