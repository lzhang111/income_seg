#!/bin/bash
# Main script to run all files in the correct order
# See README.MD for description of the code files and the order at which they need to be run
# Make sure that Stata, R, and Python are installed and added to your path 
# and that you have execute permission for the script

echo 'starting to process'

# change to the right directory
maindir="/Users/laurazhang/Documents/income_seg"
codedir="${maindir}/code"
Rscript="/usr/local/bin/Rscript" 
# this is if your R packages rgdal and rgeos are not installed in your usual location for R,
# e.g. R installed with conda is on my path, but rgdal and rgeos installed with brew are at the location above

# remove old files
rm ${maindir}/data/clean/*
rm ${maindir}/data/temp/*
rm ${maindir}/log/*

# Cleaning data
Stata -e do ${codedir}/merge_clean/clean_1950_county.do
Stata -e do ${codedir}/merge_clean/clean_commuting.do
Stata -e do ${codedir}/merge_clean/clean_cpi.do
Stata -e do ${codedir}/merge_clean/clean_medianinc_pop_race.do
Stata -e do ${codedir}/merge_clean/clean_migration.do
Stata -e do ${codedir}/merge_clean/clean_region_state.do
Stata -e do ${codedir}/merge_clean/clean_ucrpop1950.do
Stata -e do ${codedir}/merge_clean/convert_leelin_baumsnow.do
Stata -e do ${codedir}/merge_clean/xwalk_cbsa10_county10.do
Stata -e do ${codedir}/merge_clean/xwalk_cbsa10_pcities10.do
Stata -e do ${codedir}/merge_clean/xwalk_msa00_county00.do

${Rscript} "${codedir}/gis R code/gen_gisjoin.R"
${Rscript} "${codedir}/gis R code/gen_tracts.R"
${Rscript} "${codedir}/gis R code/calcdist_highwaytract.R"

Stata -e do ${codedir}/merge_clean/clean_race_inc.do
Stata -e do ${codedir}/merge_clean/gen_tracts2010.do
Stata -e do ${codedir}/merge_clean/merge_ucr_city_cbsa2010.do
Stata -e do ${codedir}/merge_clean/clean_distances.do
Stata -e do ${codedir}/merge_clean/gen_cbsa2010_cbd.do
Stata -e do ${codedir}/merge_clean/xwalk_tracts5060_tracts10.do
Stata -e do ${codedir}/merge_clean/xwalk_msa00_cbsa10.do
Stata -e do ${codedir}/merge_clean/xwalk_countyall_county10.do
Stata -e do ${codedir}/merge_clean/gen_const_commuting.do
Stata -e do ${codedir}/merge_clean/gen_const_tracts2010.do
Stata -e do ${codedir}/merge_clean/gen_temp_sums.do

# generate percentiles
python ${codedir}/merge_clean/interpolate_pctiles.py

# merge all data
Stata -e do ${codedir}/merge_clean/merge_final.do

# Generate tables and figures
Stata -e do ${codedir}/analysis/commuting.do
Stata -e do ${codedir}/analysis/countydissim.do
Stata -e do ${codedir}/analysis/incomegraphs.do
Stata -e do ${codedir}/analysis/incomemaps.do 
Stata -e do ${codedir}/analysis/seggraph.do

${Rscript} "${codedir}/gis R code/testplot.R"

# move all log files to folder
mv ${maindir}/*.log ${maindir}/log/
