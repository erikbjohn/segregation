git_commute <- function(){
    git_commute_location <- 'CleanData/commute.rds'
    if(!file.exists(git_commute_location)){
        source('R/funCensus.R')
        dt.census <- funCensus()
        dt_commute <- dt.census[, .(origin.tract = tract, commute.driving.n = car.n + carpool.n, commute.transit.n = bus.n, commute.walking.n=walk.n)]
        dt_commute <- dt_commute[, commute.total.n := commute.driving.n + commute.transit.n + commute.walking.n]
        dt_commute <- dt_commute[, .(origin.tract, share.driving=commute.driving.n/commute.total.n, 
                                     share.transit = commute.transit.n/commute.total.n,
                                     share.walking = commute.walking.n/commute.total.n)]
        saveRDS(dt_commute, file=git_commute_location)
    } else {
        dt_commute <- readRDS(git_commute_location)
    }
    return(dt_commute)
}