funMeasures.wasserstein <- function(dt.census, l_dists_richmond){
    measures.wasserstein.location <- 'CleanData/measures.wasserstein.rds'
    if (file.exists(measures.wasserstein.location)){
        dt_wasserstein <- readRDS(measures.wasserstein.location)
    } else {
        dt_commute <- git_commute()
        l_measures <- list()
        for(iCost in 1:length(l_dists_richmond)){
            cost_years <- c('2017', '2019')
            dt.costs <- l_dists_richmond[[iCost]]
            dt.costs <- dcast(dt.costs, origin.tract + dest.tract ~ mode, value.var='distance_seconds')
            
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
            dt.costs.diag <- data.table(origin.tract=dt.census.tracts, dest.tract=dt.census.tracts, driving=0, transit=0, walking=0)
            dt.costs <- rbindlist(list(dt.costs, dt.costs.diag), use.names = TRUE, fill=TRUE)  
            setkey(dt.costs, origin.tract)
            setkey(dt_commute, origin.tract)
            dt.costs <- dt_commute[dt.costs]
            dt.costs <- dt.costs[, weighted := driving * share.driving + transit * share.transit + walking * share.walking]
            dt.costs.square <- dt.costs[order(origin.tract, dest.tract)]
            
            # Create list of different costs (walking, bus, etc) to calculate over
            funCosts.mat <- function(dt.cost, cost.name){
                # Do a quick order to ensure nothing weird happened
                tracts.unique <- unique(dt.cost$origin.tract)
                mat.cost <- reshape(dt.cost, v.names=cost.name, idvar='origin.tract', timevar='dest.tract', direction='wide')
                mat.cost.row.names<- mat.cost$origin.tract
                mat.cost <- mat.cost[, (names(mat.cost)[!(str_detect(names(mat.cost), 'origin.tract'))]), with=FALSE]
                setnames(mat.cost, names(mat.cost), str_extract(colnames(mat.cost), regex('[0-9]{1,}(?=$)', perl=TRUE)))
                mat.cost <- as.matrix(mat.cost)
                row.names(mat.cost) <- mat.cost.row.names
                return(mat.cost)
            }
            
            cols.costs <- c('driving', 'transit', 'walking', 'weighted')
            
            l.costs.mat <- lapply(cols.costs, function(x) funCosts.mat(dt.cost=dt.costs.square[, c('origin.tract', 'dest.tract', x), with=FALSE],
                                                                       cost.name=x))
            names(l.costs.mat) <- cols.costs
            
            # Calculate race pairs
            # Clean and prepare dt.census
            white_tot <- sum(dt_census$race.white.n)
            black_tot <- sum(dt_census$race.black.n)
            asian_tot <- sum(dt_census$race.asian.n)
            hispanic_tot <- sum(dt_census$race.hispanic.n)
            total_tot <- sum(dt_census$race.total.n)
            dt_race <- dt_census[, .(tract,
                                     race_white_share=race.white.n/white_tot,
                                     race_black_share=race.black.n/black_tot,
                                     race_asian_share=race.asian.n/asian_tot,
                                     race_hispanic_share=race.hispanic.n/hispanic_tot,
                                     race_total_share=race.total.n/total_tot)]
            dt_race <- dt_race[order(tract)]
            
            cols.race <- names(dt_race)[str_detect(names(dt_race),'race.*.share') & names(dt_race)!='race_total_share']
            ## Subset to only include races with at least 1% of the total population
            dt_race_grid <- as.data.table(expand.grid(cols.race, cols.race, stringsAsFactors = FALSE))
            setnames(dt_race_grid, c('raceA', 'raceB'))
            dt_race_grid <- dt_race_grid[raceA != raceB]
            l_race_grid <- split(dt_race_grid, as.numeric(row.names(dt_race_grid)))
            l_races <- lapply(l_race_grid, function(x) dt_race[, c('tract', x$raceA, x$raceB), with=FALSE])
            
            funWasserstein <- function(a, b, costs){
                wass_cost <- transport::wasserstein(a, b, p=1, tplan=NULL,costm=costs, prob=TRUE)
                return(wass_cost)
            }
            ind <- 0
            l_wass_modes <- list()
            raceA = stringr::str_extract(dt_race_grid$raceA, '(?<=race\\_).+(?=\\_share)')
            raceB = stringr::str_extract(dt_race_grid$raceB, '(?<=race\\_).+(?=\\_share)')
            for(mat_costs in l.costs.mat){
                ind <- ind + 1
                vec_wass <- sapply(l_races, function(x) funWasserstein(unlist(x[,2]), unlist(x[,3]), mat_costs))
                dt_wass <- data.table(raceA=raceA, raceB=raceB, mode=names(l.costs.mat)[ind], wasserstein=vec_wass)
                l_wass_modes[[ind]]  <- dt_wass
            }
            measures_wasserstein <- rbindlist(l_wass_modes, use.names = TRUE, fill=TRUE)
            measures_wasserstein$year <- cost_years[iCost]
            l_measures[[iCost]] <- measures_wasserstein
        }
        dt_wasserstein <- rbindlist(l_measures, use.names=TRUE, fill=TRUE)
        dt_wasserstein <- dcast(dt_wasserstein, raceA + raceB + mode ~ year, value.var='wasserstein')
       saveRDS(dt_wasserstein, file=measures.wasserstein.location)
    }
    return(dt_wasserstein)
}
