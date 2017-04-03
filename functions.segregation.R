funCombs.richmond.centroids <- function(){
    if(file.exists(combs.richmond.centroids.location)){
        load(combs.richmond.centroids.location)
    } else {
        shapes.richmond.centroids <- funShapes.richmond.centroids()
        combs.richmond.centroids <- combn(shapes.richmond.centroids@data$GEOID, 2, simplify=FALSE)
        combs.richmond.centroids <- rbindlist(lapply(combs.richmond.centroids, function(x) list(GEOID.1=x[1], GEOID.2=x[2])))
        save(combs.richmond.centroids, file=combs.richmond.centroids.location)
    }
    return(combs.richmond.centroids)
}
funDists.google <- function(l.coords){
    l.combs <- list()
    modes <- c('driving', 'transit', 'walking')
    for (i.comb in 1:nrow(l.coords[[1]])){
        if ((i.comb %% 100)==0){
            cat(i.comb, 'of', nrow(l.coords[[1]]),'\n')
        }
        loc.1 <- l.coords[[1]][i.comb]
        loc.2 <- l.coords[[2]][i.comb]
        pair.name.location <- paste0('RawData/dists.google/', loc.1$GEOID, '.', loc.2$GEOID, '.rds')
        # Check to see if exists
        if (file.exists(pair.name.location)){
            DT <- readRDS(pair.name.location)
        } else {
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
            saveRDS(DT, file=pair.name.location)
        }
        l.combs[[i.comb]] <- DT
    }
    return(rbindlist(l.combs, use.names = TRUE, fill=TRUE))
}
funDists.richmond <- function(){
    if (file.exists(dists.richmond.location)){
        load(dists.richmond.location)
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
        save(dists.richmond, file = dists.richmond.location)
    }
    return(dists.richmond)
}
funShapes.coords2points <- function(DT){
    coords <- cbind(Longitude = as.numeric(as.character(DT$long)),
                    Latitude = as.numeric(as.character(DT$lat)))
    proj.env <- funShapes.proj.env()
    Location.pts <- SpatialPointsDataFrame(coords, dplyr::select(DT,-long, -lat),
                                           proj4string = CRS("+init=epsg:3687"))
    return(spTransform(Location.pts, CRS(proj.env)))
}
funShapes.proj.env <- function(){
    if(file.exists(shapes.proj.env.location)){
        shapes.proj.env <- readRDS(shapes.proj.env.location)
    } else {
        projUrl <- 'http://spatialreference.org/ref/epsg/3687/proj4js/' #Common projection
        shapes.proj.env <- scan(projUrl, what = "character")[3]
        saveRDS(shapes.proj.env, file=shapes.proj.env.location)
    }
    return(shapes.proj.env)
}
funShapes.richmond.centroids <- function(){
    if(file.exists(shapes.richmond.centroids.location)){
        load(shapes.richmond.centroids.location)
    } else {
        shapes.richmond.tracts <- funShapes.richmond.tracts()
        l.polygons <- lapply(shapes.richmond.tracts@polygons, function(x) slot(x, 'Polygons'))
        l.centroids <- lapply(l.polygons, function(x) slot(x[[1]], 'labpt'))
        l.centroids <- lapply(l.centroids, function(x) data.table(lat=x[2], long=x[1]))
        centroids <- rbindlist(l.centroids)
        centroids$GEOID <- shapes.richmond.tracts@data$GEOID
        shapes.richmond.centroids <- funShapes.coords2points(centroids)
        save(shapes.richmond.centroids, file=shapes.richmond.centroids.location)
    }
    return(shapes.richmond.centroids)
}
funShapes.richmond.tracts <- function(){
    if(file.exists(shapes.richmond.tracts.location)){
        load(shapes.richmond.tracts.location)
    } else {
        shapes.tract <- readOGR(dsn = 'RawData/cb_2015_51_tract_500k/', layer = 'cb_2015_51_tract_500k', verbose = FALSE)
        shapes.tract@data$STATEFP <- as.character(shapes.tract@data$STATEFP)
        shapes.tract@data$COUNTYFP <- as.integer(shapes.tract@data$COUNTYFP)
        shapes.tract@data$GEOID <- as.character(shapes.tract@data$GEOID)
        # Richmond specific shape files
        county <- fread('RawData/countyFips.csv')
        setnames(county, names(county),c('state', 'state.fips', 'county.fips', 'crap', 'county.crap', 'county.name', 'entity.description'))
        county$county.fips <- as.integer(county$county.fips)
        county$state <- as.character(county$state)
        county <- county[, .(state, county.fips, county.name)]
        setkey(county, state, county.fips, county.name)
        county <- unique(county)
        
        load('RawData/CMSAS.rdata')
        CMSAS$county <- as.integer(CMSAS$county)
        setkey(CMSAS, state, county)
        setkey(county, state, county.fips)
        counties <- county[CMSAS, allow.cartesian=TRUE]
        counties.richmond <- counties[msa=='40060']
        counties.examine <- unique(counties.richmond[, .(county.name, county.fips)])
        richmond.county.fips <- c(41, 87, 760)
        state.fips <- '51'
        richmond.inds <- which(shapes.tract@data$STATEFP %in% state.fips & shapes.tract@data$COUNTYFP %in% richmond.county.fips) 
        shapes.richmond.tracts <- shapes.tract[richmond.inds,]
        save(shapes.richmond.tracts, file=shapes.richmond.tracts.location)
    }
    return(shapes.richmond.tracts)
}
