funCensus <- function(){
    if (file.exists(census.location)){
        load(census.location)
    } else {
        l.census <- list()
        l.census$commute <- readRDS('CleanData/funCensus.commute.RDS')
        l.census$income <- readRDS('CleanData/funCensus.income.RDS')
        l.census$race <- readRDS('CleanData/funCensus.race.RDS')
        l.census$industry <- readRDS('CleanData/funCensus.industry.RDS')
        census <- as.data.table(Reduce(function(...) merge(..., all = T), l.census))
        # Income variables
        setnames(census, 'Median Income', 'income.med.hh')
        
        # Commute Variables
        setnames(census, c('Public Transit', 'Walking', 'Driving Alone', 'Carpooling'),
                 c('bus.n', 'walk.n', 'car.n', 'carpool.n'))
        census <- census[, modes.total.n:=bus.n+walk.n+car.n+carpool.n]
        setnames(census, 'Mean Travel Time', 'mean.census.commute.time')
        
        # Race Variables
        setnames(census, c('Whites', 'Blacks', 'Asians', 'Hispanics'), 
                 c('race.white.n', 'race.black.n', 'race.asian.n', 'race.hispanic.n'))
        census <- census[, race.total.n :=race.white.n + race.black.n + race.asian.n + race.hispanic.n]
        
        # Tract
        census <- census[, tract:=as.character(GEOID)]
       
        # Industry
        industry_names <- c('Total_Industry', 'AFFHM', 'Construction', 'Manufacturing', 'Wholesale',
                            'Retail', 'Transportation_and_Warehouse', 'Information', 'finance', 'Science_Waste',
                            'Education_Healthcare', 'Arts', 'other', 'Public_Admin')
        industry_names_new <- paste0('industry.', stringr::str_to_lower(stringr::str_replace_all(industry_names, ' |_', '.')), '.n')
        
        setnames(census, industry_names, industry_names_new)
        
        census <- census[, .(tract,
                             income.med.hh,
                             bus.n, walk.n, car.n, carpool.n, mean.census.commute.time,
                             race.white.n, race.black.n, race.asian.n, race.hispanic.n, race.total.n,
                             industry.total.industry.n, industry.affhm.n, industry.construction.n,                
                             industry.manufacturing.n, industry.wholesale.n, industry.retail.n,                  
                             industry.transportation.and.warehouse.n, industry.information.n, industry.finance.n,                
                             industry.science.waste.n, industry.education.healthcare.n, industry.arts.n,                        
                             industry.other.n, industry.public.admin.n )]
        
        # Old code from original measures (lost the census data in moving)
        # l.census <- list(commute=funCensus.commute(),income=funCensus.income(), race=funCensus.race())
        # l.census <- lapply(l.census, function(x) setkey(x, tract))
        # census <- Reduce(function(...) merge(..., all = T), l.census)
        # Subset to richmond (study area tracts)
        # richmond.tracts <- funDists.richmond()
        # richmond.tracts <- unique(richmond.tracts$dest.tract)
        # census <- census[tract %in% richmond.tracts]
        # Clean up NAs (it is only tract 51087980100 for richmond)
        census <- census[!is.na(census$income.med.hh)]
        save(census, file=census.location)
  }
    return(census)
}











