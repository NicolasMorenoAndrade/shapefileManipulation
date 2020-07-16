library(enveRipack)
library(rgdal)
library(rgeos)
library(lubridate)

removeUnnecessaryObjs()

shapefilesDIR <- "/home/nicolas/Documents/EnveritasProjects/readEditShapefiles/shapefiles/MGN/"
dataDIR  <- "/home/nicolas/Documents/EnveritasProjects/readEditShapefiles/data/"
plotsDIR <- "/home/nicolas/Documents/EnveritasProjects/readEditShapefiles/plots/"

## read layer containing classification levels: "1", "2", "3" for rural and urban area
colurbclassshp <- readOGR(dsn = shapefilesDIR, layer = "MGN_CLASE")

## add concatanted code taking into count wrong presence of some already 5-digit codes
fixUrbRurShpMPIO_CCDGO <- function(urbrurcode, depcode){
    ifelse(nchar(as.character(urbrurcode)) == 5, urbrurcode, paste0(depcode, urbrurcode))
}

colurbclassshp@data$Municipality <- unlist(mapply(fixUrbRurShpMPIO_CCDGO,
                                                  as.character(colurbclassshp@data$MPIO_CCDGO),
                                                  as.character(colurbclassshp@data$DPTO_CCDGO)))

## All codes were correctly found in data frame to merge? fixCodesMunsColombia disambiguates DANE concatenated code
popProjDF <- read.csv(file.path(dataDIR, "popProjectionDane.csv"), stringsAsFactors = FALSE)
popProjDF <- fixCodesMunsColombia(popProjDF, "Municipality")

## If all codes correct this should be TRUE
sum(popProjDF$Municipality %in% unique(colurbclassshp@data$Municipality)) == length(popProjDF$Municipality)
sum(unique(colurbclassshp@data$Municipality) %in% popProjDF$Municipality) == length(unique(colurbclassshp@data$Municipality))

completeShpPath <- "/home/nicolas/Documents/EnveritasProjects/readEditShapefiles/shapefiles/Population/"
writeOGR(colurbclassshp, dsn = completeShpPath, layer = "Colombia_Rural_Urban", driver="ESRI Shapefile")

## testShp  <- readOGR(dsn = completeShpPath, layer = "Colombia_Rural_Urban")

## preliminar get rural and urban are for density
## sum(testShp@data[testShp@data$CLAS_CCDGO == "3" & testShp@data$Municipality == "11001","Shape_Area"])

## plot examples Medellin urban and Bogota rural
## plot(colurbclassshp[colurbclassshp@data$CLAS_CCDGO == "3" & colurbclassshp@data$Municipality == "11001",])
## plot(colurbclassshp[colurbclassshp@data$CLAS_CCDGO == "1" & colurbclassshp@data$Municipality == "11001",], add = TRUE)
## plot(colurbclassshp[colurbclassshp@data$CLAS_CCDGO == "2" & colurbclassshp@data$Municipality == "11001",],
     ## add = TRUE)
