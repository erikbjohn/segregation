funDists.tracts.check <- function(dt.cost){
    origin.tract.n <- dt.cost %>%
        group_by(origin.tract) %>%
        summarise(count=.N)
    dest.tract.n <- dt.cost %>%
        group_by(dest.tract) %>%
        summarise(count=.N)
    tracts.n <- merge(x=origin.tract.n, y=dest.tract.n, by.x='origin.tract', by.y='dest.tract')
    max.n <- max(c(origin.tract.n$count, dest.tract.n$count))
    tracts.n <- as.data.table(tracts.n)
    dists.tracts.check <- tracts.n[which(tracts.n$count.x != max.n | tracts.n$count.y != max.n)]
    return(dists.tracts.check)
}