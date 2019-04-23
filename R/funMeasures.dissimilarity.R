funMeasures.dissimlarity <- function(dt){
    # Calculate all of the dissimilarity indices in the seq package
    l.dissim <- list()
    # Create race combinations
    cols.race <- names(dt)[str_detect(names(dt),'race.*.n') & names(dt)!='race.total.n']
    # Subset to only be reasonably large
    l.race.n.total <- unlist(lapply(cols.race, function(x) sum(dt[,(x), with=FALSE])))
    l.race.share.total <- l.race.n.total/sum(l.race.n.total)
    # Only include race who are at least 1 percent of the area
    cols.race <- cols.race[which(l.race.share.total>0.01)]
    race.pairs <- combn(cols.race, 2, simplify=FALSE)
    funRace.clean <- function(race){
        race.clean <- str_replace_all(race, '(race\\.|\\.n)', '')
    }
    l.dissim <- lapply(race.pairs, function(x) data.table(race.1 = funRace.clean(x[1]),
                                                          race.2 = funRace.clean(x[2]),
                                                          D = dissim(data=dt[, (x), with=FALSE])$d))
    measure.dissimilarity <- rbindlist(l.dissim, use.names=TRUE)
    measure.dissimilarity <- measure.dissimilarity[order(-D)]
    return(measure.dissimilarity)
}