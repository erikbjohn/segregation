funCensus.commute <- function(){
    if(file.exists(census.commute.location)){
        load(census.commute.location)
    } else {
        dt <- fread('RawData/census/aff_download/ACS_15_5YR_B08119_with_ann.csv', skip = 1)
        dt.cols <- fread('RawData/census/aff_download/ACS_15_5YR_B08119_metadata.csv', header = FALSE)
        setnames(dt.cols, names(dt.cols), c('code', 'descr'))
        setnames(dt, names(dt), dt.cols$code)
        census.commute <- dt[, .(tract = as.character(GEO.id2), bus.n = HD01_VD29, walk.n = HD01_VD38, car.n = HD01_VD11, carpool.n = HD01_VD20)]
        census.commute <- census.commute[, modes.total.n:=(bus.n + walk.n + car.n + carpool.n)]
        cols.names.append <- names(census.commute)[!str_detect(names(census.commute), '(tract|commute)')]
        setnames(census.commute, cols.names.append, paste0('commute.', cols.names.append))
        save(census.commute, file=census.commute.location)
    }
    return(census.commute)
}