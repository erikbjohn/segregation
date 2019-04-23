funDists.richmond <- function(){
    if (file.exists(dists.richmond.new.location)){
        load(dists.richmond.new.location)
    } else {
        if (file.exists(dists.richmond.raw.new.location)){
            dists.richmond <- readRDS(dists.richmond.raw.new.location)
        } else {
            combs.richmond.centroids <- funCombs.richmond.centroids()
            shapes.richmond.centroids <- funShapes.richmond.centroids()
            lookup.table <- data.table(shapes.richmond.centroids@data, as.data.table(shapes.richmond.centroids@coords))
            funLookup.assign <- function(DT){
                setkey(DT, GEOID)
                setkey(lookup.table, GEOID)
                DT.return <- lookup.table[DT][order(id)]
                DT.return$id <- NULL
                return(DT.return)
            }
            id = 1:nrow(combs.richmond.centroids)
            l.GEOIDS <- list(data.table(id = id, GEOID = combs.richmond.centroids$GEOID.1),
                             data.table(id = id, GEOID = combs.richmond.centroids$GEOID.2))
            l.coords <- lapply(l.GEOIDS, function(x) funLookup.assign(x))
            dists.google <- funDists.google(l.coords)
            dists.richmond <- dists.google
            # Location for query result description:
            # https://developers.google.com/maps/documentation/distance-matrix/intro#DirectionsResponseElements
            setnames(dists.richmond, names(dists.richmond), c('dest.address', 'origin.address', 'status', 'miles.text', 'meters',
                                                              'minutes.text', 'seconds', 'minutes.text.traffic', 'seconds.traffic',
                                                              'row.element.status', 'mode', 'origin.tract', 'dest.tract'))
            saveRDS(dists.richmond, file=dists.richmond.raw.location)
        }
        dists.list <- list()
        dists.richmond <- dists.richmond[, meters:=as.numeric(meters)]
        dists.richmond <- dists.richmond[, seconds:=as.numeric(seconds)]
        dists.list$meters <- spread(dists.richmond[, .(origin.tract, dest.tract, mode, meters)], mode, meters)
        dists.list$meters <- dists.list$meters[is.na(transit), transit:=walking]
        modes <- c('driving', 'transit', 'walking')
        setnames(dists.list$meters, modes, paste0(modes, '.meters'))
        dists.list$seconds <- spread(dists.richmond[, .(origin.tract, dest.tract, mode, seconds)], mode, seconds)
        dists.list$seconds <- dists.list$seconds[is.na(transit), transit:=walking]
        setnames(dists.list$seconds, modes, paste0(modes, '.seconds'))
        dists.list <- lapply(dists.list, function(x) setkey(x, origin.tract, dest.tract))
        dists.richmond <- Reduce(function(...) merge(..., all = T), dists.list)
        dists.richmond <- dists.richmond[, .(origin.tract, dest.tract, driving.meters, driving.seconds,
                                             transit.meters, transit.seconds,
                                             walking.meters, walking.seconds)]
        save(dists.richmond, file = dists.richmond.location)
    }
    return(dists.richmond)
}