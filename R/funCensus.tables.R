funCensus.tables <- function(){
    files <- list.files('RawData/census/aff_download/')
    files <- paste0('RawData/census/aff_download/', files[which(str_detect(files, 'ACS.*.txt'))])
    f.descr <- lapply(files, function(x) data.table(table = readLines(x)[1], descr = readLines(x)[2]))
    dt.descr <- rbindlist(f.descr, use.names = TRUE)
    dt.descr <- dt.descr[ , descr:= str_to_title(descr)]
    dt.descr <- dt.descr[, descr:=str_trim(str_replace(descr, '\\(In 2015 Inflation-Adjusted Dollars\\)', ''))]
    dt.descr <- dt.descr[, descr:=str_trim(str_replace(descr, 'In The Past 12 Months', ''))]
    dt.descr <- dt.descr[, descr:=str_trim(str_replace(descr, 'Population 16 Years And Over', ''))]
    dt.descr <- dt.descr[descr=='Race', census.prefix := 'race.']
    dt.descr <- dt.descr[table=='S1903', census.prefix := 'income.med.']
    dt.descr <- dt.descr[table=='B08119', census.prefix := 'commute.']
    dt.descr <- dt.descr[is.na(census.prefix), census.prefix:='']
    return(dt.descr)
}