library(enveRipack)
library(rgdal)
library(rgeos)
library(lubridate)

removeUnnecessaryObjs()

shapefilesDIR <- "/home/nicolas/Documents/EnveritasProjects/readEditShapefiles/shapefiles/Ethiopia/gadm36_ETH_shp/"
dataDIR  <- "/home/nicolas/Documents/EnveritasProjects/readEditShapefiles/data/"
plotsDIR <- "/home/nicolas/Documents/EnveritasProjects/readEditShapefiles/plots/"

shp <- readOGR(dsn = shapefilesDIR, layer = "gadm36_ETH_3")


addis <- shp[shp@data$NAME_2 == "Addis Abeba",]
addis@data$NAME_3

plot(addis)
