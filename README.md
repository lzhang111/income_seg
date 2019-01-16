## Overview 
Income Segregation is a project started by Laura Zhang in September 2017 to measure the effects of rising income segregation in U.S. cities during the 1960-80s. It uses data on the placement of highways and the resulting effects on neighborhood sorting as a source of variation in segregation levels across cities. 

**The below file describes the necessary data and code to implement the results of the paper**

## Basic Intro
main.sh is the shell script you need to run in order to generate all the results automatically without much additional work. If you would like to read more about the specific files, continue below


Folder structure
------

The files are separated into three high-level folders: code, data, and output
### code:
analysis: subfolder containing code files to generate any figures or tables in the paper

gis R code: subfolder containing code files that handle the spatial data

merge_clean: subfolder containing code files to clean and merge raw datasets

### data:
clean: subfolder containing master datasets and cleaned data

raw: subfolder containing all of the raw data 
        - see sources.txt for more information on where to find the data

temp: temporary files used in generation of master datasets
### output:
plots: subfolder containing generated graphs and figures

tables: subfolder containing tables in the paper and appendix tables


Code files in detail
------
The order at which files must be run follows the numbering below. If files share the same number, it does not matter which of them goes first.

## Cleaning and Merging Data

1.
+ **merge_clean/clean_1950_county.do** - cleans data on population and income from NHGIS at the county level for 1950
+ **merge_clean/clean_commuting.do** - cleans the commuting data from the NHGIS in 1980 (data from 1960-2010 are available)
+ **merge_clean/clean_cpi.do** - cleans the annual cpi data
+ **merge_clean/clean_medianinc_pop_race.do** - cleans the median income (1950, 1980-2010), total population (1950, 1970-2010), and race counts (1950, 1970-2010) data at the census tract level from the NHGIS
+ **merge_clean/clean_migration.do** - cleans the migration data
+ **merge_clean/clean_region_state.do** - generates crosswalk from state to region
+ **merge_clean/clean_ucrpop1950.do** - cleans the Uniform Crime Reports 1950 data on crimes for cities (pop>25k) and the data on population in 1950
+ **merge_clean/convert_leelin_baumsnow.do** - cleans the raw data from the papers Baumsnow (2007) and Lee & Lin (2017). I do not believe any of this data is used in the final version of the paper.
+ **merge_clean/xwalk_cbsa10_county10.do** - creates a crosswalk from 2010 counties to 2010 cbsa definitions
+ **merge_clean/xwalk_cbsa10_pcities10.do** - creates a crosswalk from 2010 cbsas to 2010 principal cities
+ **merge_clean/xwalk_msa00_county00.do** - creates a crosswalk from 2000 MSA definitions to 2000 county definitions
+ **gis R code/gen_gisjoin.R** - opens GIS shapefiles (years 1950, 1960, 2010) and save the gisjoin codes to csv files
+ **gis R code/gen_tracts.R** - reads in the 2010 census tracts shapefile and save tract ids as csv file

2. 
+ **gis R code/calcdist_highwaytract.R** - reads in census tract gis files and highway lines gis files to calculate distance from census tract (centroid) to nearest highway
+ **gis R code/calcdist_cbd.R** - read in data on latlogs for CBD and calculate distances from tract centroids to CBD. Needs the cbsa10_county10 xwalk to be made first to merge tracts to their CBD. 
+ **merge_clean/clean_race_inc.do** - clean the income (1950-2010 decennial years) and income by race (1980-2010 decennial years) data at the census tract level from the NHGIS. Merges in data generated by merge_clean/clean_medianinc_pop_race.do
+ **merge_clean/gen_temp_sums.do** - calculates total counts of each income bracket for years 1950 - 2010
+ **merge_clean/gen_tracts2010.do** - converts the dataframes of the shapefiles into dta files for use in Stata. Shows the trtid of tracts in 2010
+ **merge_clean/merge_ucr_city_cbsa2010.do** - merges the city level UCR crime data to 2010 CBSA definitions using the principal cities of the cbsa's as defined by the census

3. 
+ **merge_clean/clean_distances.do** - cleans csv files that contain data on distance from tract centroids to nearest highway and to CBD using the output from gis R code/calcdist_highwaytract.R and gis R code/calcdist_cbd.R
+ **merge_clean/gen_cbsa2010_cbd.do** - selects the main city (city with the highest population in 1950) in 1950 for each cbsa (2010 definitions) 
+ **merge_clean/xwalk_tracts5060_tracts10.do** - creates the census tract crosswalks for the years 1950 and 1960 to be consistent with 2010 tract boundaries in a similar way to the LTDB (see code/merge_clean/create_const_tracts2010.do) using partial crosswalks created by Lee & Lin (2017). See raw/lee and lin data/
+ **merge_clean/xwalk_msa00_cbsa10.do** - creates a crosswalk from 2000 MSA definitions to 2010 CSBA definitions. Relies on merge_clean/xwalk_msa00_county00.do

4.** merge_clean/xwalk_countyall_county10.do** - creates consistent crosswalks of counties from 1950 to 2000 all to 2010 boundaries

5.
+ **merge_clean/gen_const_commuting.do** - uses tract crosswalks to create normalized weighted averages and counts for commuting data of tracts defined in earlier years to be consistent with tract boundaries in 2010. This is an edited version of interpolate_to_2010.do from raw/crosswalks/LTDB crosswalks and code/ provided by the Longitudinal Tract Database at Brown University. See https://s4.ad.brown.edu/projects/diversity/Researcher/LTDB.htm for details(5) 
+ **merge_clean/gen_const_tracts2010.do** - uses tract crosswalks to create normalized weighted averages and counts for income data of tracts defined in earlier years to be consistent with tract boundaries in 2010. Same process as above

6. **merge_clean/interpolate_pctiles.py** - interpolates the numbers of households in each income quintile 

7.** merge_clean/merge_final.do** - merges all the data together (except for commuting data)


## Analyzing data
All files can be run separately. No ordering is necessary, but all files must come after the section above.


**analysis/commuting.do** - creates all of the plots and tables related to commuting costs
**analysis/countydissim.do** - calculates dissimilarity indices at the county level and a measure of segregation using the highway variable and generates all of the tables for the paper 
**analysis/incomegraphs.do** - generates graphs showing income sorting at the tract level
**analysis/incomemaps.do** - creates data for the income sorting maps in R gis
**analysis/seggraph.do** - generates a graph showing income segregation over time
**gis R code/testplot.R** - some test plots of income and highways lines, and creates a plot of planned and actual highway lines in chicago

Data descriptions
------

These descriptions are only for files under the data/clean/ folder

**commuting_clean.dta** - data in 1980 at the tract level on the place of work, means of transportation, and travel time for survey repondents
**master_tract.dta** - data from 1950 to 2010 every decade at the tract level (normalized to 2010 tract boundaries) with variables on the number of families in each income quintile in each tract in total and split by race, total population, population by race, land area of tract in 2010 tract boundaries, distances to highway and cbd, distances to natural amenites such as river/lake/ocean, number of rays emanating from CBD from Baumsnow (2007), crime counts at city-level matched to CBSA of tract
**master_cbsa.dta** - drop all variables above that are not common at the cbsa level
**master_cbsa_noyear.dta** - drop all variables above that are not common at the year level
