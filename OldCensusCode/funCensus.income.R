funCensus.income <- function(){
    if(file.exists(census.income.location)){
        load(census.income.location)
    } else {
        dt <- fread('RawData/census/aff_download/ACS_15_5YR_S1903_with_ann.csv', skip = 2)
        dt.cols <- fread('RawData/census/aff_download/ACS_15_5YR_S1903_metadata.csv', header = FALSE)
        setnames(dt.cols, names(dt.cols), c('code', 'descr'))
        setnames(dt, names(dt), dt.cols$code)
        census.income <- suppressWarnings(dt[, .(tract = as.character(GEO.id2), income.med.hh=as.integer(HC02_EST_VC02))])
        save(census.income, file=census.income.location)
    }
    return(census.income)
}