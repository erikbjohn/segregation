# #install.packages("tidycensus")
# #install.packages("tidyverse")
# library(tidyverse)
# library(tidycensus)
# 
# api_key<-"f4ea45dde45d543afab05aa7ce86b36d5992a42f"
# census_api_key("f4ea45dde45d543afab05aa7ce86b36d5992a42f")
# 
# ##############################
# ###TESTING STUFF (IGNORE, just messing around. keeping here in case I need to refer to it)
# #state_income <- get_acs(geography = "state", variables = "B19013_001")
# #head(state_income)
# #or_wide <- get_acs(geography = "county", 
# #                   state = "OR",
# #                  variables = c(hhincome = "B19013_001", 
# #                               medage = "B01002_001"), 
# #                output = "wide",                    year='2017')
# #head(or_wide)
# # Create a scatterplot
# #plot(or_wide$hhincomeE, or_wide$medageE)
# #v16<-load_variables(year = 2016,
# #                   dataset = "acs5",
# #                  cache = TRUE)
# #v16
# # Filter for table B19001
# #filter(v16, str_detect(name, "B19001"))
# # Use public transportation to search for related variables
# #filter(v16, str_detect(label, fixed("public transportation", 
# #                                     ignore_case = TRUE)))
# #filter(v16, str_detect(label,fixed("race",ignore_case=TRUE)))
# #v15 <- load_variables(2016, "acs5", cache = TRUE)
# #View(v15)
# #B19001_001 is the estimate for household income in 2016
# ##############################
# 
# 
# #Estimate for total number of households
# test<-get_acs(geography = "state", variables = "DP03_0051E")
# 
# head(test)
# 
# #Website with 2017 acs5 info https://api.census.gov/data/2017/acs/acs5/profile/variables.html
# 
# #Code seems to be same for 2015,16,17... how to tell which year I'm using? Default to most recent[2017]?
# 
# # DP03_0088E is Per Capita Income, 0086PE is median family income, 0092E is median earnings for workers
# # DP03_0021E is number of workers using public transportation to commute to work exluding taxicab
# # Check to see if number changes over time?
# #saveRDS(study_county_fips, file='CleanData/study_county_fips.rds')
# 
# study_county_fips <- readRDS('CleanData/study_county_fips.rds')
# 
# pc.Inc.15<-data.table(get_acs(geography = "tract",
#                               state = "VA",
#                               county = study_county_fips,
#                               variables = "DP03_0088E",
#                               output = "wide",                    year='2017',                    year='2017') 
#                       year='2015'))
# 
# 
# 
# pc.Inc.17<-as.data.table(get_acs(geography = "tract",
#                                  state = "VA",
#                                  county = study_county_fips,
#                                  variables = "DP03_0088E",
#                                  output = "wide",                    year='2017',                    year='2017')
#                          year='2017'))
# 
# head(pc.Inc.17)
# view(pc.Inc.17)
# 
# med.Inc.17<-get_acs(geography = "tract",
#                     state = "VA",
#                     county = study_county_fips,
#                     variables = "DP03_0086E",
#                     output = "wide",                    year="2017")
# 
# head(med.Inc.17)
# view(med.Inc.17)
# 
# 
# 
# #Total Number of families?
# #test.Inc.17 <-get_acs(geography = "tract",
# #                        state = "VA",
# #                        county = study_county_fips,
# #                        variables = "DP03_0075E",
# #                        output = "wide",                    year='2017')
# ##roughly 5x as much as tot.race.17 with roughly half a dozen outliers?
# 
# #Total commuting to work
# 
# tot.com.17<-get_acs(geography = "tract",
#                     state = "VA",
#                     county = study_county_fips,
#                     variables = "DP03_0018E",
#                     output = "wide",                    year='2017')
# 
# carA.com.17<-get_acs(geography = "tract",
#                      state = "VA",
#                      county = study_county_fips,
#                      variables = "DP03_0019E",
#                      output = "wide",                    year='2017')
# carP.com.17<-get_acs(geography = "tract",
#                      state = "VA",
#                      county = study_county_fips,
#                      variables = "DP03_0020E",
#                      output = "wide",                    year='2017')
# 
# 
# pub.com.17<-get_acs(geography = "tract",
#                     state = "VA",
#                     county =study_county_fips,
#                     variables = "DP03_0021E",
#                     output = "wide",                    year='2017')
# 
# walk.com.17<-get_acs(geography = "tract",
#                      state = "VA",
#                      county = study_county_fips,
#                      variables = "DP03_0022E",
#                      output = "wide",                    year='2017')
# 
# meantime.com.17<-get_acs(geography = "tract",
#                          state = "VA",
#                          county = study_county_fips,
#                          variables = "DP03_0025E",
#                          output = "wide",                    year='2017') #in minutes
# 
# 
# tot.race.17<-get_acs(geography = "tract",
#                      state = "VA",
#                      county = study_county_fips,
#                      variables = "DP05_0033E",
#                      output = "wide",                    year='2017')
# 
# tot1.race.17<-get_acs(geography = "tract",
#                       state = "VA",
#                       county = study_county_fips,
#                       variables = "DP05_0034E",
#                       output = "wide",                    year='2017') #difference between 0034 and 0036?
# white.race.17<-get_acs(geography = "tract",
#                        state = "VA",
#                        county = study_county_fips,
#                        variables = "DP05_0037E",
#                        output = "wide",                    year='2017')
# 
# black.race.17<-get_acs(geography = "tract",
#                        state = "VA",
#                        county = study_county_fips,
#                        variables = "DP05_0038E",
#                        output = "wide",                    year='2017')
# 
# #Other races are after DP05_0038E if we want to add them too.
# 
# 
# merge.inc.17<-merge(pc.Inc.17, med.Inc.17)
# 
# merge.com.17.car<-merge(carA.com.17, carP.com.17)
# merge.com.17.noncar<-merge(pub.com.17,walk.com.17)
# merge.com.17.part<-merge(merge.com.17.car, merge.com.17.noncar)
# merge.com.17.time<-merge(merge.com.17.part,meantime.com.17)
# 
# merge.com.17.final<-merge(tot.com.17,merge.com.17.time)
# 
# merge.race.17.wb<-merge(white.race.17, black.race.17)
# merge.race.17.T1<-merge(tot.race.17,tot1.race.17)
# 
# merge.race.17.Final<-merge(merge.race.17.T1,merge.race.17.wb)
# 
# merge.inc.race.17<-merge(merge.inc.17,merge.race.17.Final)
# merge.allthree.17<-merge(merge.inc.race.17,merge.com.17.final)
# #####
# ##### stuff with 10 year census, shouldn't need
# #Census apparently doesn't track income, use it for race? https://api.census.gov/data/2010/dec/sf1/variables.html
# #This is for blacks only, see webiste to get other races
# test3<-get_decennial(geography = "block",
#                      state = "VA",
#                      county = study_county_fips,
#                      variables = "H006003", 
#                      output = "wide",                    year='2017')
# head(test3)
# view(test3)
# 
# #updated names, removed the margin of error, did best to try to match what I have with the code from functions.segregation.R
# 
# #I only included black and white for race. Go back and add other races?
# #I only have stuff for fist three functions, nothing after race, so do we need stuff for tables etc.?
# 
# funCensus.income<-med.Inc.17[,-4]
# 
# funCensus.race<-merge.race.17.Final[,c(1,2,3,7,9)]
# 
# funCensus.commute<-merge.com.17.final[,1,2,3,5,7,9,11]
# 
# 
# 
# 
