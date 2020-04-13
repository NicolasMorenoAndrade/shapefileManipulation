##ENV SETUP, LIBRARIES & PATHS
library(enveRipack)
library(rgdal)
library(rgeos)
library(lubridate)

removeUnnecessaryObjs()

shapefilesDIR <- "/home/nicolas/Documents/EnveritasProjects/ColombiaShapeFile/shapefiles/MGN/"
dataDIR  <- "/home/nicolas/Documents/EnveritasProjects/ColombiaShapeFile/data/"
plotsDIR <- "/home/nicolas/Documents/EnveritasProjects/ColombiaShapeFile/plots/"
completeShpPath <- "/home/nicolas/Documents/EnveritasProjects/ColombiaShapeFile/shapefiles/Population/"

colshp <- readOGR(dsn = shapefilesDIR, layer = "MGN_MPIO_POLITICO")

## All codes were correctly found in data frame to merge? fixCodesMunsColombia disambiguates DANE concatenated code
popProjDF <- read.csv(file.path(dataDIR, "popProjectionDane.csv"), stringsAsFactors = FALSE)
popProjDF <- fixCodesMunsColombia(popProjDF, "Municipality")

## create DANE Municipality code by pastin DPTO_CCDGO and MPIO_CCDGO from shapefile
colshp$Municipality  <- colshp$MPIO_CCNCT

## All codes were correctly found in data frame to merge?
## sum(colshp$MPIO_CCNCT %in% popProjDF$Municipality) == length(colshp$MPIO_CCNCT)

## CREATE A COMPLETE COLOMBIA SHAPEFILE WITH POPULATION
completeShpPop <- merge(colshp, popProjDF[c("Municipality",
                                            "Total_2020",
                                            "Urban_2020",
                                            "Disperse_rural_and_villages_2020")], by = "Municipality")

## calculate population density per municipality
completeShpPop$Total_2020 <- as.numeric(gsub(",","",completeShpPop$Total_2020))
completeShpPop$Density <- completeShpPop$Total_2020/completeShpPop$MPIO_NAREA

## rename beacuse ESRI engine makes a mess of long names
names(completeShpPop@data)[names(completeShpPop@data) == "Disperse_rural_and_villages_2020"]  <- "Ru_2020"

writeOGR(completeShpPop, dsn = completeShpPath, layer = "Colombia_Population", driver="ESRI Shapefile")

## check
## testShp  <- readOGR(dsn = completeShpPath, layer = "Colombia_Population")
