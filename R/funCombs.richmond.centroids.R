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