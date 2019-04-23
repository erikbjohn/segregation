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
