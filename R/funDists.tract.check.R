funDists.tracts.check <- function(dt.costs){
    origin.tract.n <- dt.costs[, .(count=.N), by=origin.tract]
    dest.tract.n <- dt.costs[, .(count=.N), by=dest.tract]
    tracts.n <- merge(x=origin.tract.n, y=dest.tract.n, by.x='origin.tract', by.y='dest.tract')
    max.n <- max(c(origin.tract.n$count, dest.tract.n$count))
    tracts.n <- as.data.table(tracts.n)
    dists.tracts.check <- tracts.n[which(tracts.n$count.x != max.n | tracts.n$count.y != max.n)]
    return(dists.tracts.check)
}