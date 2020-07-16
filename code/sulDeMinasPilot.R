library(rgdal)
library(rgeos)
library(lubridate)

## removeUnnecessaryObjs()

shapefilesDIR <-
    "/home/nicolas/Documents/EnveritasProjects/readEditShapefiles/shapefiles/Brazil/map-brazil-sku/shapefiles"
dataDIR  <- "/home/nicolas/Documents/EnveritasProjects/readEditShapefiles/data/"
plotsDIR <- "/home/nicolas/Documents/EnveritasProjects/readEditShapefiles/plots/"


shapeFileLoad <- function(shapeFileName) {
    shpNAME <- file.path(shapefilesDIR, shapeFileName)
    readOGR(dsn = shpNAME, layer = shapeFileName)
}

shpFileNAMES <- Filter(function(x) x!="",
                       list.dirs(shapefilesDIR, full.names = FALSE))

invisible(sapply(1:length(shpFileNAMES),
                 function(i) assign(shpFileNAMES[i], shapeFileLoad(shpFileNAMES[i]),
                                    envir = parent.env(environment()))))

completeShp <- get(shpFileNAMES[1])

invisible(sapply(shpFileNAMES,
                 function(x) assign("completeShp", rbind(completeShp, get(x)), envir = parent.env(environment()))))

completeShpPath <- "/home/nicolas/Documents/EnveritasProjects/readEditShapefiles/shapefiles/Brazil/map-brazil-sku/Pilot_Sul_de_Minas_Full"

writeOGR(completeShp, dsn = completeShpPath, layer = "Pilot_Sul_de_Minas_Full", driver="ESRI Shapefile")
