use aej_maindata

*table 1
reg dism1990 herf lenper, robust
reg area1910 herf lenper, robust
reg count1910 herf lenper, robust
reg ethseg10 herf lenper, robust
reg ethiso10 herf lenper, robust
reg black1910 herf lenper, robust
reg passpc herf lenper, robust
reg black1920 herf lenper, robust
reg  ctyliterate1920 herf lenper, robust
reg  lfp1920 herf lenper, robust
reg  ctytrade_wkrs1920 herf lenper, robust
reg  ctymanuf_wkrs1920 herf lenper, robust
reg  ctyrail_wkrs1920 herf lenper, robust
reg incseg herf lenper, robust

*table 2, panel 1
reg lngini_w dism1990, robust
reg lngini_b dism1990, robust
reg povrate_w dism1990, robust
reg povrate_b dism1990, robust

ivreg lngini_w (dism1990=herf) lenper, robust
ivreg lngini_b (dism1990=herf) lenper, robust
ivreg povrate_w (dism1990=herf) lenper, robust
ivreg povrate_b (dism1990=herf) lenper, robust

reg lngini_w herf lenper if closeness<-400, robust
reg lngini_b herf lenper if closeness<-400, robust
reg povrate_w herf lenper if closeness<-400, robust
reg povrate_b herf lenper if closeness<-400, robust

*table 2, panel 2

reg ln90w90b dism1990, robust
reg ln10w10b dism1990, robust
reg ln90w10b dism1990, robust
reg ln90b10w dism1990, robust

ivreg ln90w90b (dism1990=herf) lenper, robust
ivreg ln10w10b (dism1990=herf) lenper, robust
ivreg ln90w10b (dism1990=herf) lenper, robust
ivreg ln90b10w (dism1990=herf) lenper, robust

reg ln90w90b herf lenper if closeness<-400, robust
reg ln10w10b herf lenper if closeness<-400, robust
reg ln90w10b herf lenper if closeness<-400, robust
reg ln90b10w herf lenper if closeness<-400, robust


*table 3

ivreg lngini_w (dism1990=herf) lenper pop1990, robust
ivreg lngini_b (dism1990=herf) lenper pop1990, robust
ivreg povrate_w (dism1990=herf) lenper pop1990, robust
ivreg povrate_b (dism1990=herf) lenper pop1990, robust

ivreg lngini_w (dism1990=herf) lenper pctbk1990, robust
ivreg lngini_b (dism1990=herf) lenper pctbk1990, robust
ivreg povrate_w (dism1990=herf) lenper pctbk1990, robust
ivreg povrate_b (dism1990=herf) lenper pctbk1990, robust


ivreg lngini_w (dism1990=herf) lenper hsdrop_w- collgrad_b, robust
ivreg lngini_b (dism1990=herf) lenper hsdrop_w- collgrad_b, robust
ivreg povrate_w (dism1990=herf) lenper hsdrop_w- collgrad_b, robust
ivreg povrate_b (dism1990=herf) lenper hsdrop_w- collgrad_b, robust


ivreg lngini_w (dism1990=herf) lenper manshr, robust
ivreg lngini_b (dism1990=herf) lenper manshr, robust
ivreg povrate_w (dism1990=herf) lenper manshr, robust
ivreg povrate_b (dism1990=herf) lenper manshr, robust
 

ivreg lngini_w (dism1990=herf) lenper lfp_w lfp_b, robust
ivreg lngini_b (dism1990=herf) lenper lfp_w lfp_b, robust
ivreg povrate_w (dism1990=herf) lenper lfp_w lfp_b, robust
ivreg povrate_b (dism1990=herf) lenper lfp_w lfp_b, robust


ivreg lngini_w (dism1990=herf) lenper ngov, robust
ivreg lngini_b (dism1990=herf) lenper ngov, robust
ivreg povrate_w (dism1990=herf) lenper ngov, robust
ivreg povrate_b (dism1990=herf) lenper ngov, robust



ivreg lngini_w (dism1990=herf) lenper count1920, robust
ivreg lngini_b (dism1990=herf) lenper count1920, robust
ivreg povrate_w (dism1990=herf) lenper count1920, robust
ivreg povrate_b (dism1990=herf) lenper count1920, robust



ivreg lngini_w (dism1990=herf) lenper black1920, robust
ivreg lngini_b (dism1990=herf) lenper black1920, robust
ivreg povrate_w (dism1990=herf) lenper black1920, robust
ivreg povrate_b (dism1990=herf) lenper black1920, robust




ivreg lngini_w (dism1990=herf) lenper ctyliterate1920, robust
ivreg lngini_b (dism1990=herf) lenper ctyliterate1920, robust
ivreg povrate_w (dism1990=herf) lenper ctyliterate1920, robust
ivreg povrate_b (dism1990=herf) lenper ctyliterate1920, robust

ivreg lngini_w (dism1990=herf) lenper ctymanuf_wkrs1920, robust
ivreg lngini_b (dism1990=herf) lenper ctymanuf_wkrs1920, robust
ivreg povrate_w (dism1990=herf) lenper ctymanuf_wkrs1920, robust
ivreg povrate_b (dism1990=herf) lenper ctymanuf_wkrs1920, robust



ivreg lngini_w (dism1990=herf) lenper lfp1920, robust
ivreg lngini_b (dism1990=herf) lenper lfp1920, robust
ivreg povrate_w (dism1990=herf) lenper lfp1920, robust
ivreg povrate_b (dism1990=herf) lenper lfp1920, robust



ivreg lngini_w (dism1990=herf) lenper herfscore, robust
ivreg lngini_b (dism1990=herf) lenper herfscore, robust
ivreg povrate_w (dism1990=herf) lenper herfscore, robust
ivreg povrate_b (dism1990=herf) lenper herfscore, robust


*table 4

reg mv_st_winus_w dism1990, robust
reg mv_st_winus_b dism1990, robust
reg medgrent_w dism1990, robust
reg medgrent_b dism1990, robust
reg medgrentpinc_w dism1990, robust
reg medgrentpinc_b dism1990, robust
reg mt1proom_w dism1990, robust
reg mt1proom_b dism1990, robust


ivreg mv_st_winus_w (dism1990=herf) lenper, robust
ivreg mv_st_winus_b (dism1990=herf) lenper, robust
ivreg medgrent_w (dism1990=herf) lenper, robust
ivreg medgrent_b (dism1990=herf) lenper, robust
ivreg medgrentpinc_w (dism1990=herf) lenper, robust
ivreg medgrentpinc_b (dism1990=herf) lenper, robust
ivreg mt1proom_w (dism1990=herf) lenper, robust
ivreg mt1proom_b (dism1990=herf) lenper, robust

reg mv_st_winus_w herf lenper if closeness<-400, robust
reg mv_st_winus_b herf lenper if closeness<-400, robust
reg medgrent_w herf lenper if closeness<-400, robust
reg medgrent_b herf lenper if closeness<-400, robust
reg medgrentpinc_w herf lenper if closeness<-400, robust
reg medgrentpinc_b herf lenper if closeness<-400, robust
reg mt1proom_w herf lenper if closeness<-400, robust
reg mt1proom_b herf lenper if closeness<-400, robust

*table 5

use table_5

reg hsdrop dism1980 agedum* if black==0, cluster(name)
reg hsdrop dism1980 agedum* if black==1, cluster(name)
reg hsgrad dism1980 agedum* if black==0, cluster(name)
reg hsgrad dism1980 agedum* if black==1, cluster(name)
reg somecoll dism1980 agedum* if black==0, cluster(name)
reg somecoll dism1980 agedum* if black==1, cluster(name)
reg collgrad dism1980 agedum* if black==0, cluster(name)
reg collgrad dism1980 agedum* if black==1, cluster(name)


ivreg hsdrop (dism1980=herf) lenper agedum* if black==0, cluster(name)
ivreg hsdrop (dism1980=herf) lenper  agedum* if black==1, cluster(name)
ivreg hsgrad (dism1980=herf) lenper  agedum* if black==0, cluster(name)
ivreg hsgrad (dism1980=herf) lenper  agedum* if black==1, cluster(name)
ivreg somecoll (dism1980=herf) lenper  agedum* if black==0, cluster(name)
ivreg somecoll (dism1980=herf) lenper  agedum* if black==1, cluster(name)
ivreg collgrad (dism1980=herf) lenper  agedum* if black==0, cluster(name)
ivreg collgrad (dism1980=herf) lenper  agedum* if black==1, cluster(name)


reg hsdrop herf lenper agedum* if black==0 & closeness<-400, cluster(name)
reg hsdrop herf lenper agedum* if black==1 & closeness<-400, cluster(name)
reg hsgrad herf lenper agedum* if black==0 & closeness<-400, cluster(name)
reg hsgrad herf lenper agedum* if black==1 & closeness<-400, cluster(name)
reg somecoll herf lenper agedum* if black==0 & closeness<-400, cluster(name)
reg somecoll herf lenper agedum* if black==1 & closeness<-400, cluster(name)
reg collgrad herf lenper agedum* if black==0 & closeness<-400, cluster(name)
reg collgrad herf lenper agedum* if black==1 & closeness<-400, cluster(name)
*table A1

use table_A1.dta
*all data from CGV, except indicator for "in my sample"

for var pop1890-central: ttest X, by(sample)
