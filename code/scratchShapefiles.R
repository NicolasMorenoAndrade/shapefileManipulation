##* ENV SETUP, LIBRARIES & PATHS
library(enveRipack)
library(rgdal)

removeUnnecessaryObjs()

shapefilesDIR <- "/home/nicolas/Documents/Enveritas/shapefiles/ColombiaDepts/"

##* FUNCTIONS
depShapeFileLoad <- function(dep) {
    shpNAME <- paste0(shapefilesDIR, dep)
    readOGR(dsn = shpNAME, layer = "MGN_MPIO_POLITICO")
}

## departments is the list of filenames of departmental shapefiles
departments <- list.dirs(shapefilesDIR, full.names = FALSE, recursive = FALSE)
departments <- departments[departments != "COLOMBIA"]

## depsInDF is the actual list of departments in susDF$Department
depsInDF <- gsub("_", " ", departments)
depsInDF[depsInDF == "NORTE SANTANDER"] <- "NORTE DE SANTANDER"

## dictionary to match departmentl shapefile names with department name in data
depsDIC <- data.frame(depsInDF, departments)
## object names of shapefiles
allShpObjNames <- paste0("deptShp",1:length(departments))

##* LOAD SHAPEFILES & DATA
## load all departmental shapefiles
invisible(sapply(1:length(departments),
                 function(i) assign(allShpObjNames[i], depShapeFileLoad(departments[i]),
                                    envir = parent.env(environment()))))

susDF <- read.csv("/home/nicolas/Documents/Enveritas/BigWave2018_2019/opsData/Full_SU_Mun_Visited.csv",
                  stringsAsFactors = FALSE)

## CREATE A COMPLETE COLOMBIA SU SHAPEFILE
## create a complete shape of all SUs
completeShp <- deptShp1
invisible(sapply(allShpObjNames, function(x) assign("completeShp", rbind(completeShp,get(x)),
                                                    envir = parent.env(environment()))))
## add and to lower SupplyUnit
completeShpSu <- merge(completeShp, susDF[,c("MPIO_CCDGO","SupplyUnit")], by = "MPIO_CCDGO")
completeShpSu@data$SupplyUnit <- as.character(tolower(completeShpSu@data$SupplyUnit))

writeOGR(completeShpSu, dsn = shapefilesDIR, layer = "colombiaSUs", driver="ESRI Shapefile")
