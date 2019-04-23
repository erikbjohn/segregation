funDists.google <- function(l.coords){
    l.combs <- list()
    # modes <- c('driving', 'transit', 'walking')
    modes <- 'transit'
    for (i.comb in 1:nrow(l.coords[[1]])){
        #for (i.comb in 1:20){
        if ((i.comb %% 100)==0){
            cat(i.comb, 'of', nrow(l.coords[[1]]),'\n')
        }
        log_status_good <- TRUE
        loc.1 <- l.coords[[1]][i.comb]
        loc.2 <- l.coords[[2]][i.comb]
        pair.name.location <- paste0('RawData/dists_google_new/', loc.1$GEOID, '.', loc.2$GEOID, '.rds')
        
        log_file_exists <- file.exists(pair.name.location)
        if (log_file_exists == TRUE){
            DT <- readRDS(pair.name.location)
            log_status_good <- !(DT$status %in% c('OVER_QUERY_LIMIT','REQUEST_DENIED'))
            if(log_status_good==FALSE){
                cat('OLD STATUS:', DT$status, ': Rerunning', pair.name.location, '\n')
            }
        } 
        if(log_status_good==FALSE | log_file_exists==FALSE) {
            locA <- c(loc.1$Latitude, loc.1$Longitude)
            locB <- c(loc.2$Latitude, loc.2$Longitude)
            funGoogle.call <- function(locA, locB, mode, api.key){
                l <- list()
                l.query <- google_distance(origins = list(locA), destinations=list(locB), mode=mode, units='imperial', key=api.key)
                l[[1]] <- unlist(l.query[which(lapply(l.query, class) != 'data.frame')])
                l[[2]] <- unlist(l.query[which(lapply(l.query, class) == 'data.frame')])
                DT <- as.data.table(t(unlist(l)))
                DT$mode <- mode
                return(DT)
            }
            l.Google.distance <- lapply(modes, function(x) funGoogle.call(locA=locA, locB=locB, mode=x, api.key))
            DT <- rbindlist(l.Google.distance, use.names = TRUE, fill = TRUE)
            DT$GEOID.1 <- loc.1$GEOID
            DT$GEOID.2 <- loc.2$GEOID
            log_status_good <- !(DT$status %in% 'OVER_QUERY_LIMIT')
            if(log_status_good==FALSE){
                cat('STOP: OVER_QUERY_LIMIT ', i.comb)
                stop
            } else { 
                cat('RERUN STATUS: ', DT$status, '\n')
            }
            saveRDS(DT, file=pair.name.location)
        } else {
            cat('GOOD: ', pair.name.location, '\n')
        }
        l.combs[[i.comb]] <- DT
    }
    dt_combs <- rbindlist(l.combs, use.names = TRUE, fill=TRUE)
    saveRDS(dt_combs, 'CleanData/dist.richomnd.new.rds')
    return(dt_combs)
}
