* Laura Zhang
* April 2018
* This do file cleans the migration data

clear
set more off
program drop _all
global main `"/Users/laurazhang/Documents/income_seg/"'

import delimited "${main}/data/raw/migration/1970-1980/migration.csv", delimiter(comma, collapse) encoding(ISO-8859-1) clear

* 1970s
//white
egen net_wm_1970_25_50 = rowtotal(m7wtm25-m7wtm50)
egen net_wf_1970_25_50 = rowtotal(m7wtf25-m7wtf50)
egen exp_wm_1970_25_50 = rowtotal(e7wtm25-e7wtm50)
egen exp_wf_1970_25_50 = rowtotal(e7wtf25-e7wtf50)

gen migrate_wm_1970_25_50 = net_wm_1970_25_50/exp_wm_1970_25_50*100
gen migrate_wf_1970_25_50 = net_wf_1970_25_50/exp_wf_1970_25_50*100

//non white
egen net_nm_1970_25_50 = rowtotal(m7ntm25-m7ntm50)
egen net_nf_1970_25_50 = rowtotal(m7ntf25-m7ntf50)
egen exp_nm_1970_25_50 = rowtotal(e7ntm25-e7ntm50)
egen exp_nf_1970_25_50 = rowtotal(e7ntf25-e7ntf50)

gen migrate_nm_1970_25_50 = net_nm_1970_25_50/exp_nm_1970_25_50*100
gen migrate_nf_1970_25_50 = net_nf_1970_25_50/exp_nf_1970_25_50*100


*1980s
egen net_tm_1980_25_50 = rowtotal(m8ttm25-m8ttm50)
egen net_tf_1980_25_50 = rowtotal(m8ttf25-m8ttf50)
egen exp_tm_1980_25_50 = rowtotal(e8ttm25-e8ttm50)
egen exp_tf_1980_25_50 = rowtotal(e8ttf25-e8ttf50)

gen migrate_tm_1980_25_50 = net_tm_1980_25_50/exp_tm_1980_25_50*100
gen migrate_tf_1980_25_50 = net_tf_1980_25_50/exp_tf_1980_25_50*100

* clean up data
keep st name fips mig*
gen county = substr(fips, 2, 5)

save "${main}/data/temp/migration_clean.dta", replace
