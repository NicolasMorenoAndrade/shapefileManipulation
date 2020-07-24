library(rgdal)
library(rgeos)

## create full shape containing the municipalities in sul de minas pilot

shapefilesDIR <-
    "/home/nicolas/Documents/EnveritasProjects/readEditShapefiles/shapefiles/Brazil/map-brazil-sku/shapefiles"
dataDIR  <- "/home/nicolas/Documents/EnveritasProjects/readEditShapefiles/data/"
plotsDIR <- "/home/nicolas/Documents/EnveritasProjects/readEditShapefiles/plots/"

pilotmunicip <- c("Passos", "Sao Sebastiao Do Paraiso", "Piumhi", "Carmo Do Rio Claro", "Monte Santo De Minas", "Nova Resende", "Itau De Minas", "Cassia", "Ibiraci", "Guape", "Alpinopolis", "Itamogi", "Capetinga", "Pimenta", "Pratapolis", "Sao Joao Batista Do Gloria", "Delfinopolis", "Sao Roque De Minas", "Sao Jose Da Barra", "Sao Tomas De Aquino", "Jacui", "Capitolio", "Bom Jesus Da Penha", "Fortaleza De Minas", "Claraval", "Vargem Bonita", "Doresopolis")

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

completeShp@data$muni <- as.character(completeShp$SNAME2014)
pilot27munishp <- completeShp[completeShp$muni %in% pilotmunicip,]

completeShpPath <- "/home/nicolas/Documents/EnveritasProjects/readEditShapefiles/shapefiles/Brazil/map-brazil-sku/Pilot_Sul_de_Minas_Full"

writeOGR(completeShp, dsn = completeShpPath, layer = "Pilot_Sul_de_Minas_Full", driver="ESRI Shapefile")
writeOGR(pilot27munishp, dsn = completeShpPath, layer = "Pilot_Sul_de_Minas_27", driver="ESRI Shapefile")
