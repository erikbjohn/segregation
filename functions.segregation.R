funCensus <- function(){
    if (file.exists(census.location)){
        load(census.location)
    } else {
        l.census <- list(commute=funCensus.commute(),income=funCensus.income(), race=funCensus.race())
        l.census <- lapply(l.census, function(x) setkey(x, tract))
        census <- Reduce(function(...) merge(..., all = T), l.census)
        # Subset to richmond (study area tracts)
        richmond.tracts <- funDists.richmond()
        richmond.tracts <- unique(richmond.tracts$dest.tract)
        census <- census[tract %in% richmond.tracts]
        # Clean up NAs (it is only tract 51087980100 for richmond)
        census <- census[!is.na(census$income.med.hh)]
        save(census, file=census.location)
    }
    return(census)
}
funCensus.commute <- function(){
    if(file.exists(census.commute.location)){
        load(census.commute.location)
    } else {
        dt <- fread('RawData/census/aff_download/ACS_15_5YR_B08119_with_ann.csv', skip = 1)
        dt.cols <- fread('RawData/census/aff_download/ACS_15_5YR_B08119_metadata.csv', header = FALSE)
        setnames(dt.cols, names(dt.cols), c('code', 'descr'))
        setnames(dt, names(dt), dt.cols$code)
        census.commute <- dt[, .(tract = as.character(GEO.id2), bus.n = HD01_VD29, walk.n = HD01_VD38, car.n = HD01_VD11, carpool.n = HD01_VD20)]
        census.commute <- census.commute[, modes.total.n:=(bus.n + walk.n + car.n + carpool.n)]
        cols.names.append <- names(census.commute)[!str_detect(names(census.commute), '(tract|commute)')]
        setnames(census.commute, cols.names.append, paste0('commute.', cols.names.append))
        save(census.commute, file=census.commute.location)
    }
    return(census.commute)
}
funCensus.income <- function(){
    if(file.exists(census.income.location)){
        load(census.income.location)
    } else {
        dt <- fread('RawData/census/aff_download/ACS_15_5YR_S1903_with_ann.csv', skip = 2)
        dt.cols <- fread('RawData/census/aff_download/ACS_15_5YR_S1903_metadata.csv', header = FALSE)
        setnames(dt.cols, names(dt.cols), c('code', 'descr'))
        setnames(dt, names(dt), dt.cols$code)
        census.income <- suppressWarnings(dt[, .(tract = as.character(GEO.id2), income.med.hh=as.integer(HC02_EST_VC02))])
        save(census.income, file=census.income.location)
    }
    return(census.income)
}
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
        pair.name.location <- paste0('RawData/dists_google_new/', loc.1$GEOID, '.', loc.2$GEOID, '.rds')
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
        if (file.exists(dists.richmond.raw.location)){
            dists.richmond <- readRDS(dists.richmond.raw.location)
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
funMeasures.wasserstein <- function(dt.census, dt.costs){
    if (file.exists(measures.wasserstein.location)){
        load(measures.wasserstein.location)
    } else {
        # Clean and prepare dt.census
        cols.race <- names(dt)[str_detect(names(dt),'race.*.n') & names(dt)!='race.total.n']
        ## Subset to only include races with at least 1% of the total population
        l.race.n.total <- unlist(lapply(cols.race, function(x) sum(dt[,(x), with=FALSE])))
        l.race.share.total <- l.race.n.total/sum(l.race.n.total)
        cols.race <- cols.race[which(l.race.share.total>0.01)]
        race.pairs <- combn(cols.race, 2, simplify=FALSE)
        race.pairs <- rbind(race.pairs, lapply(race.pairs, function(x) c(x[2], x[1])))
        
        # Clean, prepare, and check dt.costs
        ## Subset distance matrix (dt.costs) to only include tracts that were not NA on census dimensions
        dt.census.tracts <- unique(dt.census$tract)
        dt.costs <- dt.costs[origin.tract %in% dt.census.tracts & dest.tract %in% dt.census.tracts]
        ## Check that all tract pairs have a distance cost calculated
        dists.tracts.check <- funDists.tracts.check(dt.costs)
        if (nrow(dists.tracts.check)>0){
            stop(paste0('dists.tracts.check not length 0. See funDists.tracts.check() to debug'))
        }
        
        ## Make dt.costs symmetric (for transformation to square matrix)
        cols.costs <- names(dt.costs)[!str_detect(names(dt.costs), 'tract')]
        dt.costs.lower <- copy(dt.costs)
        dt.costs.upper <- cbind(copy(dt.costs[,.(origin.tract=dest.tract, dest.tract=origin.tract)]), dt.costs[, (cols.costs), with=FALSE])
        dt.costs.diag <- rbindlist(lapply(dt.census.tracts, function(x) data.table(origin.tract=x, dest.tract=x)))
        dt.costs.diag.cols.costs <- as.data.table(matrix(data=0, nrow = nrow(dt.costs.diag), ncol=length(cols.costs)))
        setnames(dt.costs.diag.cols.costs, names(dt.costs.diag.cols.costs), cols.costs)
        dt.costs.diag <- data.table(dt.costs.diag, dt.costs.diag.cols.costs)
        dt.costs.square <- rbindlist(list(dt.costs.lower, dt.costs.upper, dt.costs.diag), use.names = TRUE)
        dt.costs.square <- dt.costs.square[order(origin.tract, dest.tract)]
        # Check again (mat.costs and square)
        if (length(dt.census.tracts) != sqrt(nrow(mat.costs))){
            stop(paste0('mat.costs not square. See funMeasures.wasserstein() to debug'))
        }
        # Create list of different costs (walking, bus, etc) to calculate over
        funCosts.mat <- function(dt.cost, cost.name){
            # Do a quick order to ensure nothing weird happened
            dt.cost <- dt.cost[order(origin.tract, dest.tract)]
            tracts.unique <- unique(dt.cost$origin.tract)
            mat.cost <- reshape(dt.cost, v.names=cost.name, idvar='origin.tract', timevar='dest.tract', direction='wide')
            mat.cost.row.names<- mat.cost$origin.tract
            mat.cost <- mat.cost[, (names(mat.cost)[!(str_detect(names(mat.cost), 'origin.tract'))]), with=FALSE]
            setnames(mat.cost, names(mat.cost), str_extract(colnames(mat.cost), regex('[0-9]{1,}(?=$)', perl=TRUE)))
            mat.cost <- as.matrix(mat.cost)
            row.names(mat.cost) <- mat.cost.row.names
            return(mat.cost)
        }
        l.costs.mat <- lapply(cols.costs, function(x) funCosts.mat(dt.cost=dt.costs.square[, c('origin.tract', 'dest.tract', x), with=FALSE],
                                                                  cost.name=x))
        names(l.costs.mat) <- cols.costs
        # Calculate wasserstein measure for first pair and first cost
        
        
        # First cost (driving.meters)
        dt.cost <- l.costs.mat[[1]]
        # Tract matrix create
        dt.census <- dt.census[order(tract)]
        dt.cost <- dt.cost[order(origin.tract, dest.tract)]
        # Check that each tract is in origin and destination equal amounts
        
        
        # Calculate wassersteing
        
        save(measures.wasserstein, file=measures.wasserstein.location)
    }
    return(measures.wasserstein)
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
