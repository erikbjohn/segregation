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