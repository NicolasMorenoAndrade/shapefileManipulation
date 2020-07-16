library(enveRipack)
library(rgdal)
library(rgeos)
library(sp)
library(devtools)
library(cleangeo)

invisible(removeUnnecessaryObjs())

install_github("eblondel/cleangeo")

completeShpPath <- "/home/nicolas/Documents/EnveritasProjects/readEditShapefiles/shapefiles/Population/"
medellin_final_comm_shp <- readOGR(dsn = completeShpPath, layer = "Medellin_Communes_Orphan")

## check what seems to be the problem
report <- clgeo_CollectionReport(medellin_final_comm_shp)
rep_summary <- clgeo_SummaryReport(report)

#get suspicious features (indexes)
nv <- clgeo_SuspiciousFeatures(report)
## mysp <- sp[nv[-14],]

#try to clean data
medellin.clean <- clgeo_Clean(medellin_final_comm_shp)

#check if they are still errors
report.clean <- clgeo_CollectionReport(medellin.clean)
summary.clean <- clgeo_SummaryReport(report.clean)

writeOGR(medellin.clean, dsn = completeShpPath, layer = "Medellin_Communes_Density", driver="ESRI Shapefile")
