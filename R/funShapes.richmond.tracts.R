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
