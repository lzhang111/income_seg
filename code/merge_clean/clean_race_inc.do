* Laura Zhang Nov 2017
* This do file will combine the race and income data from the NHGIS

global main `"/Users/laurazhang/Documents/income_seg/"'
global temp `"${main}/temp/"'

****** declare some string locals *****
local wstr "white"
local bstr "black"
local amindstr "american indian"
local asstr "asian"
local othstr "other"
local hawstr "hawaiian"
local twostr "two or more races"
local hispstr "hispanic or latino"
local 500str "less than 500"
local 1kstr "less than 1k"
local 1_5kstr "less than 1.5k"
local 2kstr "less than 2k"
local 2_5kstr "less than 2.5k"
local 3kstr "less than 3k"
local 3_5str "less than 3.5k"
local 4kstr "less than 4k"
local 4_5kstr "less than 4.5k"
local 5kstr "less than 5k"
local 6kstr "less than 6k"
local 7kstr "less than 7k"
local 7_5kstr "less than 7.5k"
local 10kstr "less than 10k"
local 10pkstr "more than 10k"
local 15kstr "less than 15k"
local 20kstr "less than 20k"
local 25kstr "less than 25k"
local 30kstr "less than 30k"
local 35kstr "less than 35k"
local 40kstr "less than 40k"
local 45kstr "less than 45k"
local 50kstr "less than 50k"
local 60kstr "less than 60k"
local 50pkstr "more than 50k"
local 75kstr "less than 75k"
local 100kstr "less than 100k"
local 100pkstr "more than 100k"
local 125kstr "less than 125k"
local 150kstr "less than 150k"
local 200kstr "less than 200k"
local 200pkstr "more than 200k"
local totalstr "all incomes"

***** import yearly datasets *****
//1950
import delimited "${main}/raw/nhgis/income 1950-1970/nhgis0005_ds82_1950_tract.csv", encoding(ISO-8859-1)clear
ren (b0e001-b0e015) (inc500 inc1k inc1_5k inc2k inc2_5k inc3k inc3_5k inc4k inc4_5k inc5k inc6k inc7k inc10k inc10pk incmissing)

//rename variables
foreach income in 500 1k 1_5k 2k 2_5k 3k 3_5k 4k 4_5k 5k 6k 7k 10k 10pk {
	label variable inc`income' "income ``income'str'"
}

rename (countya statea tracta) (cntyfips statefips tractfips)

//gisjoin code doesn't correspond exactly to tracts
keep year state* cnty* county *tract* inc* 
collapse (sum) inc*, by(year state* cnty* county tract*)
save "${temp}/clean1950inc.dta", replace
export delimited "${temp}/clean1950inc.csv", replace



//1980
import delimited "${main}/raw/nhgis/income by race 1980-2010/nhgis0004_ds107_1980_tract.csv", encoding(ISO-8859-1)clear
ren (dim001-dim009) (w_5k w_7_5k w_10k w_15k w_20k w_25k w_35k w_50k w_50pk)
ren (dim010-dim018) (b_5k b_7_5k b_10k b_15k b_20k b_25k b_35k b_50k b_50pk)
ren (dim019-dim027) (amind_5k amind_7_5k amind_10k amind_15k amind_20k amind_25k amind_35k amind_50k amind_50pk)
ren (dim028-dim036) (as_5k as_7_5k as_10k as_15k as_20k as_25k as_35k as_50k as_50pk)

//rename variables
foreach race in w b amind as {
	foreach income in 5k 7_5k 10k 15k 20k 25k 35k 50k 50pk {
		label variable `race'_`income' "``race'str', income ``income'str'"
	}
}

* rename county and state fips
rename (countya statea tracta) (cntyfips statefips tractfips)

//gisjoin code doesn't correspond exactly to tracts
keep year state* cnty* county tract smsaa *k 
collapse (sum) *k, by(year state* cnty* county tract smsaa) 
save "${temp}/clean1980incrace.dta", replace
export delimited "${temp}/clean1980incrace.csv", replace

//1990
import delimited "${main}/raw/nhgis/income by race 1980-2010/nhgis0004_ds123_1990_tract.csv", encoding(ISO-8859-1)clear
ren (e4w001-e4w009) (w_5k w_10k w_15k w_25k w_35k w_50k w_75k w_100k w_100pk)
ren (e4w010-e4w018) (b_5k b_10k b_15k b_25k b_35k b_50k b_75k b_100k b_100pk)
ren (e4w019-e4w027) (amind_5k amind_10k amind_15k amind_25k amind_35k amind_50k amind_75k amind_100k amind_100pk)
ren (e4w028-e4w036) (as_5k as_10k as_15k as_25k as_35k as_50k as_75k as_100k as_100pk)
ren (e4w037-e4w045) (oth_5k oth_10k oth_15k oth_25k oth_35k oth_50k oth_75k oth_100k oth_100pk)

//rename variables
foreach race in w b amind as oth {
	foreach income in 5k 10k 15k 25k 35k 50k 75k 100k 100pk {
		label variable `race'_`income' "``race'str', income ``income'str'"
	}
}

rename (countya statea) (cntyfips statefips)

//gisjoin code doesn't correspond exactly to tracts
keep year state* cnty* county tract msa_cmsaa *k 
collapse (sum) *k, by(year state* cnty* county tract msa_cmsaa)
save "${temp}/clean1990incrace.dta", replace
export delimited "${temp}/clean1990incrace.csv", replace

//2000
import delimited "${main}/raw/nhgis/income by race 1980-2010/nhgis0004_ds151_2000_tract.csv", encoding(ISO-8859-1)clear
ren (gtd001-gtd016) (w_10k w_15k w_20k w_25k w_30k w_35k w_40k w_45k w_50k w_60k w_75k w_100k w_125k w_150k w_200k w_200pk)
ren (gtd017-gtd032) (b_10k b_15k b_20k b_25k b_30k b_35k b_40k b_45k b_50k b_60k b_75k b_100k b_125k b_150k b_200k b_200pk)
ren (gtd033-gtd048) (amind_10k amind_15k amind_20k amind_25k amind_30k amind_35k amind_40k amind_45k amind_50k amind_60k amind_75k amind_100k amind_125k amind_150k amind_200k amind_200pk)
ren (gtd049-gtd064) (as_10k as_15k as_20k as_25k as_30k as_35k as_40k as_45k as_50k as_60k as_75k as_100k as_125k as_150k as_200k as_200pk)
ren (gtd065-gtd080) (haw_10k haw_15k haw_20k haw_25k haw_30k haw_35k haw_40k haw_45k haw_50k haw_60k haw_75k haw_100k haw_125k haw_150k haw_200k haw_200pk)
ren (gtd081-gtd096) (oth_10k oth_15k oth_20k oth_25k oth_30k oth_35k oth_40k oth_45k oth_50k oth_60k oth_75k oth_100k oth_125k oth_150k oth_200k oth_200pk)
ren (gtd097-gtd112) (two_10k two_15k two_20k two_25k two_30k two_35k two_40k two_45k two_50k two_60k two_75k two_100k two_125k two_150k two_200k two_200pk)

//rename variables
foreach race in w b amind as oth haw two {
	foreach income in 10k 15k 20k 25k 30k 35k 40k 45k 50k 60k 75k 100k 125k 150k 200k 200pk {
		label variable `race'_`income' "``race'str', income ``income'str'"
	}
}

rename (countya statea) (cntyfips statefips)

//gisjoin code doesn't correspond exactly to tracts
keep year state* cnty* county tract msa_cmsaa *k 
collapse (sum) *k, by(year state* cnty* county tract msa_cmsaa)
save "${temp}/clean2000incrace.dta", replace
export delimited "${temp}/clean2000incrace.csv", replace

//2010
import delimited "${main}/raw/nhgis/income by race 1980-2010/nhgis0004_ds177_20105_2010_tract.csv", encoding(ISO-8859-1)clear
drop j*m* name_m j41e*
ren (j4ue001-j4ue017) (w_total w_10k w_15k w_20k w_25k w_30k w_35k w_40k w_45k w_50k w_60k w_75k w_100k w_125k w_150k w_200k w_200pk)
ren (j4ve001-j4ve017) (b_total b_10k b_15k b_20k b_25k b_30k b_35k b_40k b_45k b_50k b_60k b_75k b_100k b_125k b_150k b_200k b_200pk)
ren (j4we001-j4we017) (amind_total amind_10k amind_15k amind_20k amind_25k amind_30k amind_35k amind_40k amind_45k amind_50k amind_60k amind_75k amind_100k amind_125k amind_150k amind_200k amind_200pk)
ren (j4xe001-j4xe017) (as_total as_10k as_15k as_20k as_25k as_30k as_35k as_40k as_45k as_50k as_60k as_75k as_100k as_125k as_150k as_200k as_200pk)
ren (j4ye001-j4ye017) (haw_total haw_10k haw_15k haw_20k haw_25k haw_30k haw_35k haw_40k haw_45k haw_50k haw_60k haw_75k haw_100k haw_125k haw_150k haw_200k haw_200pk)
ren (j4ze001-j4ze017) (oth_total oth_10k oth_15k oth_20k oth_25k oth_30k oth_35k oth_40k oth_45k oth_50k oth_60k oth_75k oth_100k oth_125k oth_150k oth_200k oth_200pk)
ren (j40e001-j40e017) (two_total two_10k two_15k two_20k two_25k two_30k two_35k two_40k two_45k two_50k two_60k two_75k two_100k two_125k two_150k two_200k two_200pk)
ren (j42e001-j42e017) (hisp_total hisp_10k hisp_15k hisp_20k hisp_25k hisp_30k hisp_35k hisp_40k hisp_45k hisp_50k hisp_60k hisp_75k hisp_100k hisp_125k hisp_150k hisp_200k hisp_200pk)

//rename variables
foreach race in w b amind as oth haw two hisp {
	foreach income in 10k 15k 20k 25k 30k 35k 40k 45k 50k 60k 75k 100k 125k 150k 200k 200pk total {
		label variable `race'_`income' "``race'str', income ``income'str'"
	}
}

rename (countya statea) (cntyfips statefips)

//gisjoin code doesn't correspond exactly to tracts
keep year state* cnty* county tract cbsaa *k 
collapse (sum) *k, by(year state* cnty* county tract cbsaa)
save "${temp}/clean2010incrace.dta", replace
export delimited "${temp}/clean2010incrace.csv", replace

