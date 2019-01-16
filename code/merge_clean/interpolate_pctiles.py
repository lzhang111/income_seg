
# coding: utf-8

# In[1]:

import numpy as np
import pandas as pd
import math


# In[2]:

# some predefined variables
numpct = 5 # the number of percentiles I would like, so here I am creating quintiles
mainstr = "/Users/laurazhang/Documents/income_seg/data/temp/"


# In[3]:

def calc_weights(raw):
    # m is obs count, n is variable count
    m, n = raw.shape
    
    # create cumulative sum of counts
    raw_cuml = np.zeros((m, n)) 
    
    for i in range(m):
        for j in range(n):
            raw_cuml[i, j] = np.sum(raw[i, 0:j+1])

    #array of  numbers 1-5 repeated over length of data
    repeat = np.tile(np.array(range(1, numpct+1))[np.newaxis, :], (m, 1))

    # population cutoffs for each percentile
    totals = raw_cuml[:, -1][:, np.newaxis]
    pctiles = np.multiply(repeat, totals)/numpct    

    # create weights for dividing up percentiles
    weights = np.zeros((m, n, numpct)) 

    for i in range(m):
        countpctl = 0
        
        # skip over cbsa observations where there are fewer than 1000 people
        if raw_cuml[i, -1] < 1000:
            break
        
        for j in range(n):
            pctl = pctiles[i, countpctl]
            val = raw_cuml[i, j]
            
            #cumulative value is less than pctile cutoff
            if (val - pctl) < 10e-8: 
                weights[i, j, countpctl] = 1     #then use the whole bracket 
            else :
                denom = raw[i,j]
                
                # bracket has no people, skip to next bracket
                if denom==0:
                    weights[i, j, countpctl] = 1
                    break
                
                # if first bracket, take difference between pctile and 0
                if j==0:
                    weights[i, j, countpctl] = (pctl-0)/denom
                else :
                    weights[i, j, countpctl] = (pctl-raw_cuml[i, j-1])/denom
                
                # multiple percentiles in same bracket
                while (pctiles[i, countpctl+1] - val) < 0 and abs((pctiles[i, countpctl+1] - val)) > 10e-8:
                    # skip to next percentiles
                    countpctl += 1
                    
                    # now calculate weights for next percentile in same bracket
                    weights[i, j, countpctl] = (pctiles[i, countpctl] - pctl)/denom
                
                # use rest of weight in next percentile
                weights[i, j, countpctl+1] = 1 - (pctiles[i, countpctl]-raw_cuml[i, j-1])/denom    
                   
                # remove weights that are very small    
                if abs(weights[i, j, countpctl])<10e-8:
                    weights[i, j, countpctl] = 0
                
                ### this is to debug negative weights ###
                if weights[i, j, countpctl]<0:
                    print("negative weights")
                    print(val)
                    print(raw_cuml)[i, j-1]
                    print(pctl)
                    print(pctiles[i, :])
                    print(raw_cuml)[i, :]
                    print(weights[i, :, :])

                countpctl += 1
                
    return weights 


# In[4]:

def adjustdata(weights, datalevel, year, race="None"):
    ## TO DO - cbsa data types ##
    racestr = "incrace" if race!="None" else "inc"
    racesub = "_b" if race=="Black" else "_w" if race=="White" else "" 
    predata = pd.read_table(mainstr + "const" + str(year) + racestr + ".csv", delimiter=",", header=0)
    
    print(year)
    # separate data
    if race=="Black":
        raw = np.array(predata.filter(regex='^b_'))
    elif race=="White":
        raw = np.array(predata.filter(regex='^w_'))
    else:
        raw = np.array(predata.filter(regex='^inc'))
    
    # apply weights
    pctiles = np.dot(raw, weights[0, :, :])
    
    finaldata = pd.DataFrame(pctiles)
    finaldata.columns = ["inc_pctl" + racesub + str(i+1) for i in range(numpct)]
    finaldata['trtid10'] = predata['trtid10']
    
    # check that percentiles have approx same number of people
    print(np.sum(pctiles, axis=0))
    
    # write to csv
    finaldata.to_csv(mainstr + "pctl_" + datalevel + str(year) + racesub +  ".csv", index=False)
    


# In[5]:

datalevel= "total"
#for datalevel in ("cbsa", "total"):
print(datalevel)

for year in np.arange(1950, 2011, 10):
    # read in data
    data = np.loadtxt(mainstr + str(year) + "inc_sum_" + datalevel + ".csv", delimiter=",", skiprows=1)

    # separate data
    if datalevel=="total":
        data = data[np.newaxis, :]
        raw = data[:, 0:-1]
    else:
        raw = data[:, 1:-1]
        cbsa = data[:, 0][:, np.newaxis]
    years = data[:, -1][:, np.newaxis]
    
    # calculate weights
    weights = calc_weights(raw)
    adjustdata(weights, datalevel, year)

    if year >= 1980:
        # read in data
        data_race = np.loadtxt(mainstr + str(year) + "incrace_sum_" + datalevel + ".csv", delimiter=",", skiprows=1)
        
        # separate data
        if datalevel=="total":
            data_race = data_race[np.newaxis, :]
            raw_race = data_race[:, 0:-1]
        else:
            raw_race = data_race[:, 1:-1]
            cbsa = data_race[:, 0][:, np.newaxis]
        years = data_race[:, -1][:, np.newaxis]
    
        # separate by race
        _, n_vars = raw_race.shape
        raw_b = raw_race[:, 0:(n_vars/2)] # first half of data
        raw_w = raw_race[:, (n_vars/2):] # second half of data

        # calc weights
        weights_b = calc_weights(raw_b)
        adjustdata(weights_b, datalevel, year, race="Black")
        weights_w = calc_weights(raw_w)
        adjustdata(weights_w, datalevel, year, race="White")

