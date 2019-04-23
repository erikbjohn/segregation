funDistances_combine <- function(){
    distances_combine_location <- 'CleanData/richmond_distances_combine.rds'
    if(!file.exists(distances_combine_location)){
        load('CleanData/dists.richmond.rdata')
        dt_old <- copy(dists.richmond)
        dt_old$scrapeDate <- '03-2017'
        
        l_old <- list()
        l_old$transit <- dt_old[, .(scrapeDate, origin.tract, dest.tract, mode='transit', distance_meters=transit.meters, distance_seconds=transit.seconds)]
        l_old$walking <- dt_old[, .(scrapeDate, origin.tract, dest.tract, mode='walking', distance_meters=walking.meters, distance_seconds=walking.seconds)]
        l_old$driving <- dt_old[, .(scrapeDate, origin.tract, dest.tract, mode='driving', distance_meters=driving.meters, distance_seconds=driving.seconds)]
        dt_old <- rbindlist(l_old, use.names = TRUE, fill=TRUE)
        
        l_new <- list()
        dt_new <- readRDS('CleanData//dist.richomnd.new.rds')
        dt_new$scrapeDate <- '03-2018'
        setnames(dt_new, c('GEOID.1', 'GEOID.2'), c('origin.tract', 'dest.tract'))
        setnames(dt_new, 'rows.elements.duration.value', 'duration_seconds')
        dt_new <- dt_new[, distance_seconds:=as.numeric(duration_seconds)]
        dt_new <- dt_new[, distance_meters:=as.numeric(rows.elements.distance.value)]
        dt_new <- dt_new[, .(scrapeDate, origin.tract, dest.tract, mode, distance_meters, distance_seconds)]
        
        # If dt_new transit is na, substitute with walking as before
        dt_new_missing <- dt_new[is.na(distance_meters)]
        dt_new_missing$distance_meters <- NULL
        dt_new_missing$distance_seconds <- NULL
        setkey(dt_new_missing, origin.tract, dest.tract)
        dt_new_update <- l_old$walking[, .(origin.tract, dest.tract, distance_meters, distance_seconds)]
        setkey(dt_new_update, origin.tract, dest.tract)
        dt_new_missing <- dt_new_update[dt_new_missing]
        dt_new_not_missing <- dt_new[!is.na(distance_meters)]    
        dt_new <- rbindlist(list(dt_new_missing, dt_new_not_missing), use.names = TRUE, fill=TRUE)
        dt_new <- dt_new[, .(scrapeDate, origin.tract, dest.tract, mode='transit', distance_meters, distance_seconds)]
        l_new$transit <- dt_new
        l_new$walking <- l_old$walking[, scrapeDate:='03-2018']
        l_new$driving <- l_old$driving[, scrapeDate:='03-2018']
        dt_new <- rbindlist(l_new, use.names = TRUE, fill=TRUE)
        
        l_dt <- list(dt_old, dt_new)
        saveRDS(l_dt, file=distances_combine_location)
    } else {
        l_dt <- readRDS(distances_combine_location)
    }
    return(l_dt)
}