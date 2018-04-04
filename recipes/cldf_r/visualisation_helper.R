# Heavily based on:
# https://github.com/bambooforest/visualizing-typology-data/blob/master/procedure.R

load.wals.data <- function(url) {
  if(!file.exists("wals_dataset.cldf.zip")) {
    res <- tryCatch(
      download.file(
        url, destfile="wals_dataset.cldf.zip",
        method="auto"),
      error=function(e) 1)
  }
  
  # Load and clean languages.csv:
  languages <- read.csv(unz("wals_dataset.cldf.zip", "languages.csv"),
                        header=TRUE, sep=",")
  languages$Macroarea <- NULL; languages <- droplevels(languages)
  
  # Load and clean values.csv:
  values <- read.csv(unz("wals_dataset.cldf.zip", "values.csv"),
                     header=TRUE, sep=",")
  values$Comment <- NULL; values <- droplevels(values)
  
  # Load codes.csv:
  codes <- read.csv(unz("wals_dataset.cldf.zip", "codes.csv"),
                    header=TRUE, sep=",")
  
  # Load and clean parameters.csv:
  parameters <- read.csv(unz("wals_dataset.cldf.zip", "parameters.csv"),
                         header=TRUE, sep=",")
  parameters$Description <- NULL; parameters <- droplevels(parameters)
  
  collected.data <- (list(
    languages = as.data.frame(languages),
    values = as.data.frame(values),
    parameters = as.data.frame(parameters),
    codes = as.data.frame(codes))
  )
  
  # Write this into the global environment. Not excatly clean,
  # but oh well ...
  # list2env(collected.data, .GlobalEnv)
  
  return(collected.data)
}

build.feature.set <- function(wals.data, feature) {
  filtered.values <- wals.data$values[wals.data$values$Parameter_ID == feature,]
  filtered.values <- droplevels(filtered.values)
  
  filtered.languages <- wals.data$languages
  colnames(filtered.languages)[1] <- "Language_ID"
  
  filtered.params <- wals.data$parameters
  colnames(filtered.params)[1] <- "Parameter_ID"
  
  merged.data <- merge(filtered.values, filtered.languages[,c("Language_ID", "Latitude", "Longitude")],
                  by = "Language_ID", all = TRUE)
  merged.data <- merge(merged.data, filtered.params, by="Parameter_ID", all.x=TRUE)
  
  merged.data$Value <- as.character(merged.data$Value)
  merged.data$Value[is.na(merged.data$Value)]<-"99 not sampled"
  
  merged.data <- merged.data[complete.cases(merged.data[,c("Longitude","Latitude")]),]
  
  merged.data <- merged.data[merged.data$Latitude<86 & merged.data$Latitude>-86,]
  merged.data <- merged.data[merged.data$Longitude<175 & merged.data$Longitude>-175,]
  
  return(droplevels(merged.data))
}

build.spatial.points.df <- function(filtered.data) {
  require(sp)
  
  coordinates(filtered.data) <- ~ Longitude + Latitude
  proj4string(filtered.data) <- CRS("+init=epsg:4326")
  
  return(filtered.data)
}

reproject.df <- function(spatial.data) {
  require(rgdal)
  
  return(spTransform(spatial.data, CRS("+init=esri:54012")))
}

buffer.features <- function(reprojected.df, width) {
  require(raster)
  
  reprojected.df.buffered <- buffer(reprojected.df, width=width)
  proj4string(reprojected.df.buffered) <- CRS("+init=esri:54012")
  
  return(reprojected.df.buffered)
}

make.voronoi <- function(reproj.features) {
  # Code based on:
  # http://carsonfarmer.com/2009/09/voronoi-polygons-with-r/
  require(deldir)
  require(sp)
  
  crds <- reproj.features@coords
  z <- deldir(jitter(crds[,1], factor=0.00001), jitter(crds[,2], factor=0.00001))
  w <- tile.list(z)
  polys <- vector(mode='list', length=length(w))
  
  for (i in seq(along=polys)) {
    pcrds = cbind(w[[i]]$x, w[[i]]$y)
    pcrds = rbind(pcrds, pcrds[1,])
    polys[[i]] = Polygons(list(Polygon(pcrds)), ID=as.character(i))
  }
  
  SP <- SpatialPolygons(polys)
  voronoi <- SpatialPolygonsDataFrame(SP,
                                      data=data.frame(x=z$summary$x, 
                                      y=z$summary$y, 
                                      ID=sapply(slot(SP, 'polygons'),function(x) slot(x, 'ID'))
    ),
    match.ID = "ID"
    )
  
  proj4string(SP) <- CRS("+init=esri:54012")
  return(SP)
}

clip.features <- function(buffered.features, voronoi.data) {
  require(rgeos)
  
  return(gIntersection(buffered.features, voronoi.data, byid = TRUE, drop_lower_td = TRUE))
}

intersect.geo.information <- function(clipped.features, feature.set) {
  ids <- data.frame(ID=sapply(slot(clipped.features, 'polygons'), function(x) slot(x, 'ID')))
  ids$ID <- as.character(ids$ID)
  
  feat.pol <- SpatialPolygonsDataFrame(clipped.features, data = cbind(ids, feature.set@data), match.ID = "ID")
  
  feat.pol$Name <- factor(feat.pol$Name)
  
  #feat.pol.pj <- spTransform(feat.pol, CRS("+init=epsg:4326"))
  
  return(feat.pol)
}

make.plot <- function(geo.information) {
  require(ggplot2)
  require(maptools)
  require(maps)
  require(randomcoloR)
  
  plot.element <- fortify(geo.information, region="Value")
  
  x <- plot.element$long
  y <- plot.element$lat
  d <- data.frame(lon=x, lat=y)
  coordinates(d) <- c("lon", "lat")
  proj4string(d) <- CRS("+init=esri:54012")
  d.trans <- spTransform(d, CRS("+init=epsg:4326"))
  
  plot.element$long <- d.trans@coords[,1]
  plot.element$lat <- d.trans@coords[,2]
  
  mapWorld <- borders("world", colour="gray50", fill="gray80")
  mp <- ggplot()+ 
    mapWorld+ 
    geom_polygon(data = plot.element, aes(x=long, y=lat, group=group, fill=id))+ 
    scale_fill_manual(values=c("grey60",randomColor(count = length(unique(plot.element$id))-1)))+
    theme_minimal()
  
  return(mp)
}