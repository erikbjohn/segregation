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