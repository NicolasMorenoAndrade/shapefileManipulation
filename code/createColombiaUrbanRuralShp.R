library(enveRipack)
library(rgdal)
library(rgeos)
library(lubridate)

removeUnnecessaryObjs()

shapefilesDIR <- "/home/nicolas/Documents/EnveritasProjects/ColombiaShapeFile/shapefiles/MGN/"
dataDIR  <- "/home/nicolas/Documents/EnveritasProjects/ColombiaShapeFile/data/"
plotsDIR <- "/home/nicolas/Documents/EnveritasProjects/ColombiaShapeFile/plots/"

colurbclassshp <- readOGR(dsn = shapefilesDIR, layer = "MGN_CLASE")

colurbclassshp@data$Municipality  <- paste0(colurbclassshp@data$DPTO_CCDGO, colurbclassshp@data$MPIO_CCDGO)

## All codes were correctly found in data frame to merge? fixCodesMunsColombia disambiguates DANE concatenated code
popProjDF <- read.csv(file.path(dataDIR, "popProjectionDane.csv"), stringsAsFactors = FALSE)
popProjDF <- fixCodesMunsColombia(popProjDF, "Municipality")

## If all codes correct this should be TRUE
## sum(popProjDF$Municipality %in% unique(colurbclassshp@data$Municipality)) == length(popProjDF$Municipality)

completeShpPath <- "/home/nicolas/Documents/EnveritasProjects/ColombiaShapeFile/shapefiles/Population/"
writeOGR(colurbclassshp, dsn = completeShpPath, layer = "Colombia_Rural_Urban", driver="ESRI Shapefile")

## testShp  <- readOGR(dsn = completeShpPath, layer = "Colombia_Rural_Urban")

## preliminar get rural and urban are for density
## sum(testShp@data[testShp@data$CLAS_CCDGO == "3" & testShp@data$Municipality == "11001","Shape_Area"])

## plot examples Medellin urban and Bogota rural
## plot(colurbclassshp[colurbclassshp@data$CLAS_CCDGO == "1" & colurbclassshp@data$Municipality == "05001",])
## plot(colurbclassshp[colurbclassshp@data$CLAS_CCDGO == "3" & colurbclassshp@data$Municipality == "11001",])
