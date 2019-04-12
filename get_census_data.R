#install.packages("tidycensus")
#install.packages("tidyverse")
library(tidyverse)
library(tidycensus)

api_key<-"f4ea45dde45d543afab05aa7ce86b36d5992a42f"
census_api_key("f4ea45dde45d543afab05aa7ce86b36d5992a42f")

#Estimate for total number of households
test<-get_acs(geography = "state", variables = "DP03_0051E")

head(test)

#Website with 2017 acs5 info https://api.census.gov/data/2017/acs/acs5/profile/variables.html

#Code seems to be same for 2015,16,17... how to tell which year I'm using? Default to most recent[2017]?

# DP03_0088E is Per Capita Income, 0086PE is median family income, 0092E is median earnings for workers
# DP03_0021E is number of workers using public transportation to commute to work exluding taxicab
# Check to see if number changes over time?
#saveRDS(study_county_fips, file='CleanData/study_county_fips.rds')

# Create the county fips file:
if(!file.exists('CleanData/study_county_fips.rds')){
    load(shapes.richmond.tracts.location)
    dt_richmond <- as.data.table(shapes.richmond.tracts@data)
    study_county_fips <- unique(dt_richmond$COUNTYFP)
    saveRDS(study_county_fips, 'CleanData/study_county_fips.rds')
} else {
    study_county_fips <- readRDS('CleanData/study_county_fips.rds')  
}




pc.Inc.15<-data.table(get_acs(geography = "tract",
                              state = "VA",
                              county = study_county_fips,
                              variables = "DP03_0088E",
                              output = "wide",                    
                              year=2017)) 

pc.Inc.17<-as.data.table(get_acs(geography = "tract",
                                 state = "VA",
                                 county = study_county_fips,
                                 variables = "DP03_0088E",
                                 output = "wide",
                                 year=2017))

head(pc.Inc.17)
view(pc.Inc.17)

med.Inc.17<-get_acs(geography = "tract",
                    state = "VA",
                    county = study_county_fips,
                    variables = "DP03_0086E",
                    output = "wide",                    year=2017)
#COLUMN NAMES Test
#colnames(med.Inc.17)<- c("GEOID", "Census Tract", "Median Income", "EInc")

head(med.Inc.17)
view(med.Inc.17)

#Total commuting to work
tot.com.17<-get_acs(geography = "tract",
                    state = "VA",
                    county = study_county_fips,
                    variables = "DP03_0018E",
                    output = "wide",
                    year=2017)

carA.com.17<-get_acs(geography = "tract",
                     state = "VA",
                     county = study_county_fips,
                     variables = "DP03_0019E",
                     output = "wide",                    year=2017)

carP.com.17<-get_acs(geography = "tract",
                     state = "VA",
                     county = study_county_fips,
                     variables = "DP03_0020E",
                     output = "wide",                    year=2017)

pub.com.17<-get_acs(geography = "tract",
                    state = "VA",
                    county =study_county_fips,
                    variables = "DP03_0021E",
                    output = "wide",                    year=2017)

walk.com.17<-get_acs(geography = "tract",
                     state = "VA",
                     county = study_county_fips,
                     variables = "DP03_0022E",
                     output = "wide",                    year=2017)

meantime.com.17<-get_acs(geography = "tract",
                         state = "VA",
                         county = study_county_fips,
                         variables = "DP03_0025E",
                         output = "wide",                    year=2017) #in minutes

tot.race.17<-get_acs(geography = "tract",
                     state = "VA",
                     county = study_county_fips,
                     variables = "DP05_0033E",
                     output = "wide",                    
                     year=2017)

tot1.race.17<-get_acs(geography = "tract",
                      state = "VA",
                      county = study_county_fips,
                      variables = "DP05_0034E",
                      output = "wide",                    year=2017) #difference between 0034 and 0036?

white.race.17<-get_acs(geography = "tract",
                       state = "VA",
                       county = study_county_fips,
                       variables = "DP05_0037E",
                       output = "wide",                    year=2017)

black.race.17<-get_acs(geography = "tract",
                       state = "VA",
                       county = study_county_fips,
                       variables = "DP05_0038E",
                       output = "wide",                    year=2017)

asian.race.17<-get_acs(geography = "tract",
                       state = "VA",
                       county = study_county_fips,
                       variables = "DP05_0044E",
                       output = "wide",                    year=2017)

hisp.race.17<-get_acs(geography = "tract",
                      state = "VA",
                      county = study_county_fips,
                      variables = "DP05_0070E",
                      output = "wide",                    year=2017)

#Changing Column Names
#Can't use same name for all of the errors, hence all of the 'E___'

colnames(pc.Inc.17)<- c("GEOID", "Census Tract", "Median Income", "EPC")
colnames(med.Inc.17)<- c("GEOID", "Census Tract", "Median Income", "EInc")

colnames(tot.com.17)<- c("GEOID", "Census Tract", "Total Commute","Et")
colnames(carA.com.17)<- c("GEOID", "Census Tract", "Driving Alone", "Ea")
colnames(carP.com.17)<- c("GEOID", "Census Tract", "Carpooling", "Ec")
colnames(pub.com.17)<- c("GEOID", "Census Tract", "Public Transit", "Ep")
colnames(walk.com.17)<- c("GEOID", "Census Tract", "Walking", "Ew")
colnames(meantime.com.17)<- c("GEOID", "Census Tract", "Mean Travel Time", "Em")


colnames(tot.race.17)<- c("GEOID", "Census Tract", "Total Race", "ERace")
colnames(tot1.race.17)<- c("GEOID", "Census Tract", "Total 1 Race", "E1R")
colnames(white.race.17)<- c("GEOID", "Census Tract", "Whites", "Ewh")
colnames(black.race.17)<- c("GEOID", "Census Tract", "Blacks", "Ebl")
colnames(asian.race.17)<- c("GEOID", "Census Tract", "Asians", "Eas")
colnames(hisp.race.17)<- c("GEOID", "Census Tract", "Hispanics", "Ehi")

#merging

merge.inc.17<-merge(pc.Inc.17, med.Inc.17)

merge.com.17.car<-merge(carA.com.17, carP.com.17)
merge.com.17.noncar<-merge(pub.com.17,walk.com.17)
merge.com.17.part<-merge(merge.com.17.car, merge.com.17.noncar)
merge.com.17.time<-merge(merge.com.17.part,meantime.com.17)

merge.com.17.final<-merge(tot.com.17,merge.com.17.time)

merge.race.17.wb<-merge(white.race.17, black.race.17)
merge.race.17.T1<-merge(tot.race.17,tot1.race.17)
merge.race.17.ah<-merge(asian.race.17,hisp.race.17)

merge.race.17.all<-merge(merge.race.17.wb, merge.race.17.ah)
#merge.race.17.Final<-merge(merge.race.17.T1,merge.race.17.wb)

merge.inc.race.17<-merge(merge.inc.17,merge.race.17.Final)
merge.allthree.17<-merge(merge.inc.race.17,merge.com.17.final)

#updated names, removed the margin of error, did best to try to match what I have with the code from functions.segregation.R
#I only have stuff for fist three functions, nothing after race, so do we need stuff for tables etc.?

###Use these to create Rdata

funCensus.income<-med.Inc.17[,-4]

funCensus.race<-merge.race.17.all[,c(1,2,3,7,9,11,13)]

funCensus.commute<-merge.com.17.final[,c(1,2,3,5,7,9,11,13)]
