# library(tidyverse)
# library(tidycensus)
#  
# api_key<-"f4ea45dde45d543afab05aa7ce86b36d5992a42f"
# census_api_key("f4ea45dde45d543afab05aa7ce86b36d5992a42f")
# study_county_fips <- c('41', '87', '760')
#   tot.race.17<-get_acs(geography = "tract",
#                        state = "VA",
#                        county = study_county_fips,
#                        variables = "DP05_0033E",
#                        output = "wide",                    year='2017')
#   
#   white.race.17<-get_acs(geography = "tract",
#                          state = "VA",
#                          county = study_county_fips,
#                          variables = "DP05_0037E",
#                          output = "wide",                    year='2017')
#   
#   black.race.17<-get_acs(geography = "tract",
#                          state = "VA",
#                          county = study_county_fips,
#                          variables = "DP05_0038E",
#                          output = "wide",                    year='2017')
#   
#   hisp.race.17<-get_acs(geography = "tract",
#                          state = "VA",
#                          county = study_county_fips,
#                          variables = "DP05_0071E",
#                          output = "wide",                    year='2017')
# 
#   asian.race.17<-get_acs(geography = "tract",
#                          state = "VA",
#                          county = study_county_fips,
#                          variables = "DP05_0044E",
#                          output = "wide",                    year='2017')
#   
#  
# 
# total.race<-tot.race.17[,3]
# names(total.race)<-"Total_People"
# white.race<-white.race.17[,3]
# names(white.race)<-"Whites"
# black.race<-black.race.17[,3]
# names(black.race)<-"Blacks"
# hisp.race<-hisp.race.17[,3]
# names(hisp.race)<-"Hispanics"
# asian.race<-asain.race.17[,3]
# names(asian.race)<-"Asians"
# 
# WB<-merge(white.race,black.race)
# HA<-merge.(hisp.race,asian.race)
# WBHA<-merge(WB,HA)
# funCensus.race2<-merge(WBHA,total.race)
# 
# saveRDS(funCensus.race2,"funCensus.race.rds")
# 
#   
#   
# 
# 
#   
#   
#   
#   
# #test.race<-get_acs(geography = "tract",
# #                   state = "VA",
# #                   county = "Richmond City",
# #                   variables = "DP05_0033E",
# #                   output = "wide")
# #test.black<-get_acs(geography = "tract",
# #                    state = "VA",
# #                    county = "Richmond City",
# #                    variables = "DP05_0038E",
# #                    output = "wide")
# #test.hisp<-get_acs(geography = "tract",
# #                   state = "VA",
# #                   county = "Richmond City",
# #                   variables = "DP05_0071E",
# #                   output = "wide")
# #test.asian<-get_acs(geography = "tract",
# #                    state = "VA",
# #                    county = "Richmond City",
# #                    variables = "DP05_0044E",
# #                    output = "wide")
# 
# 
# 
