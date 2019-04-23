funCensus.race<- function(){
    if(file.exists(census.race.location)){
        load(census.race.location)
    } else {
        dt <- fread('RawData/census/aff_download/ACS_15_5YR_B02001.csv', skip = 2)
        dt.cols <- suppressWarnings(fread('RawData/census/aff_download/ACS_15_5YR_B02001_metadata.csv', header = FALSE))
        setnames(dt.cols, names(dt.cols), c('code', 'descr'))
        setnames(dt, names(dt), dt.cols$code)
        census.race <- dt[, .(tract = as.character(GEO.id2), race.total.n=HD01_VD01, white.n=HD01_VD02, black.n=HD01_VD03, native.n = HD01_VD04, 
                              asian.n=HD01_VD05, hawaiian.n=HD01_VD06, race.mix.other.n = HD01_VD07 + HD01_VD08 + HD01_VD09 + HD01_VD10)]
        cols.names.append <- names(census.race)[!str_detect(names(census.race), '(tract|race)')]
        setnames(census.race, cols.names.append, paste0('race.', cols.names.append))
        save(census.race, file=census.race.location)
    }
    return(census.race)
}