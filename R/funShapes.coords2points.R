funShapes.coords2points <- function(DT){
    coords <- cbind(Longitude = as.numeric(as.character(DT$long)),
                    Latitude = as.numeric(as.character(DT$lat)))
    proj.env <- funShapes.proj.env()
    Location.pts <- SpatialPointsDataFrame(coords, dplyr::select(DT,-long, -lat),
                                           proj4string = CRS("+init=epsg:3687"))
    return(spTransform(Location.pts, CRS(proj.env)))
}