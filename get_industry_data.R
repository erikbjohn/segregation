library(tidyverse)
library(tidycensus)

api_key<-"f4ea45dde45d543afab05aa7ce86b36d5992a42f"
census_api_key("f4ea45dde45d543afab05aa7ce86b36d5992a42f")


#Website with 2017 acs5 info https://api.census.gov/data/2017/acs/acs5/profile/variables.html
study_county_fips <- readRDS('CleanData/study_county_fips.rds')

total.ind<-get_acs(geography = "tract",
                    state = "VA",
                    county = study_county_fips,
                    variables = "DP03_0032E",
                    output = "wide",                    year=2017)

agr.for.fish.hunt.mine.ind<-get_acs(geography = "tract",
                   state = "VA",
                   county = study_county_fips,
                   variables = "DP03_0033E",
                   output = "wide",                    year=2017)

const.ind<-get_acs(geography = "tract",
                   state = "VA",
                   county = study_county_fips,
                   variables = "DP03_0034E",
                   output = "wide",                    year=2017)

manu.ind<-get_acs(geography = "tract",
                   state = "VA",
                   county = study_county_fips,
                   variables = "DP03_0035E",
                   output = "wide",                    year=2017)

wholesale.trade.ind<-get_acs(geography = "tract",
                   state = "VA",
                   county = study_county_fips,
                   variables = "DP03_0036E",
                   output = "wide",                    year=2017)

retail.trade.ind<-get_acs(geography = "tract",
                   state = "VA",
                   county = study_county_fips,
                   variables = "DP03_0037E",
                   output = "wide",                    year=2017)

trans.ware.util.ind<-get_acs(geography = "tract",
                   state = "VA",
                   county = study_county_fips,
                   variables = "DP03_0038E",
                   output = "wide",                    year=2017)

info.ind<-get_acs(geography = "tract",
                   state = "VA",
                   county = study_county_fips,
                   variables = "DP03_0039E",
                   output = "wide",                    year=2017)

finance.ind<-get_acs(geography = "tract",
                   state = "VA",
                   county = study_county_fips,
                   variables = "DP03_0040E",
                   output = "wide",                    year=2017)

pro.science.waste.ind<-get_acs(geography = "tract",
                   state = "VA",
                   county = study_county_fips,
                   variables = "DP03_0041E",
                   output = "wide",                    year=2017)

edu.healthcare.ind<-get_acs(geography = "tract",
                   state = "VA",
                   county = study_county_fips,
                   variables = "DP03_0042E",
                   output = "wide",                    year=2017)

arts.ind<-get_acs(geography = "tract",
                   state = "VA",
                   county = study_county_fips,
                   variables = "DP03_0043E",
                   output = "wide",                    year=2017)

other.ind<-get_acs(geography = "tract",
                   state = "VA",
                   county = study_county_fips,
                   variables = "DP03_0044E",
                   output = "wide",                    year=2017)

public.ind<-get_acs(geography = "tract",
                   state = "VA",
                   county = study_county_fips,
                   variables = "DP03_0045E",
                   output = "wide",                    year=2017)


colnames(total.ind)<- c("GEOID", "Census Tract", "Total_Industry","Et")
colnames(agr.for.fish.hunt.mine.ind)<- c("GEOID", "Census Tract", "AFFHM","Ea")
colnames(const.ind)<- c("GEOID", "Census Tract", "Construction","Eb")
colnames(manu.ind)<- c("GEOID", "Census Tract", "Manufacturing","Ec")
colnames(wholesale.trade.ind)<- c("GEOID", "Census Tract", "Wholesale","Ed")
colnames(retail.trade.ind)<- c("GEOID", "Census Tract", "Retail","Ee")
colnames(trans.ware.util.ind)<- c("GEOID", "Census Tract", "Transportation_and_Warehouse","Ef")
colnames(info.ind)<- c("GEOID", "Census Tract", "Information","Eg")
colnames(finance.ind)<- c("GEOID", "Census Tract", "finance","Eh")
colnames(pro.science.waste.ind)<- c("GEOID", "Census Tract", "Science_Waste","Ei")
colnames(edu.healthcare.ind)<- c("GEOID", "Census Tract", "Education_Healthcare","Ej")
colnames(arts.ind)<- c("GEOID", "Census Tract", "Arts","Ek")
colnames(other.ind)<- c("GEOID", "Census Tract", "other","El")
colnames(public.ind)<- c("GEOID", "Census Tract", "Public_Admin","Em")


m1<-merge(total.ind,agr.for.fish.hunt.mine.ind)
m2<-merge(const.ind,manu.ind)
m3<-merge(wholesale.trade.ind,retail.trade.ind)
m4<-merge(trans.ware.util.ind,info.ind)
m5<-merge(finance.ind,pro.science.waste.ind)
m6<-merge(edu.healthcare.ind,arts.ind)
m7<-merge(other.ind,public.ind)

m8<-merge(m1,m2)
m9<-merge(m3,m4)
m10<-merge(m5,m6)
m11<-merge(m10,m7)
m12<-merge(m8,m9)
mfinal<-merge(m12,m11)

funCensus.industry<-mfinal[,c(1,2,3,5,7,9,11,13,15,17,19,21,23,25,27,29)]


saveRDS(funCensus.industry,"funCensus.industry.RDS")


