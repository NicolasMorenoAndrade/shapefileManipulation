library(enveRipack)
library(rgdal)
library(rgeos)
library(reshape)

invisible(removeUnnecessaryObjs())

shapeDIR <- "/home/nicolas/Documents/EnveritasProjects/readEditShapefiles/shapefiles/"
dataDIR  <- "/home/nicolas/Documents/EnveritasProjects/readEditShapefiles/data/"

col_pop_shp <- readOGR(dsn = file.path(shapeDIR, "Population"), layer = "Colombia_Population")
col_rur_urb_shp <- readOGR(dsn = file.path(shapeDIR, "Population"), layer = "Colombia_Rural_Urban")

colselection <- c("Mncplty", "DPTO_CC", "MPIO_CCD", "MPIO_CN", "MPIO_CR", "MPIO_NAR", "MPIO_CCN",
                  "MPIO_NAN", "DPTO_CN", "Tt_2020", "Ur_2020", "Ru_2020", "Density")

areaDegPerMunClass <- aggregate(Shap_Ar~Mncplty+CLAS_CC, data = col_rur_urb_shp@data, sum)

areaKmPerMunClassDF <- merge(areaDegPerMunClass,
                             col_pop_shp@data[,colselection], by = "Mncplty")

totalAreaDegPerMuni <- aggregate(Shap_Ar~Mncplty, data=areaDegPerMunClass, sum)
names(totalAreaDegPerMuni)[names(totalAreaDegPerMuni) == "Shap_Ar"]  <- "Tot_Are"

areaDegPerMunClassTot <- merge(areaDegPerMunClass, totalAreaDegPerMuni)
areaDegPerMunClassTot$Ar_Prop <- areaDegPerMunClassTot$Shap_Ar/areaDegPerMunClassTot$Tot_Are
areaDegPerMunClassTot$CLS_URu <- ifelse(areaDegPerMunClassTot$CLAS_CC == "1", "Urban", "Rural")

muniPercAreaUrbanRural <- aggregate(Ar_Prop~Mncplty+CLS_URu, data=areaDegPerMunClassTot, sum)
muniPercAreaUrbanRuralLong <- melt(muniPercAreaUrbanRural, id.vars = c("Mncplty", "CLS_URu"))

minimalMuniAreaClas <- data.frame(Mncplty = codesDANE$Mncplty)

ruralAreaPercPerMun <- split(muniPercAreaUrbanRuralLong, muniPercAreaUrbanRuralLong$CLS_URu)$Rural
urbanAreaPercPerMun <- split(muniPercAreaUrbanRuralLong, muniPercAreaUrbanRuralLong$CLS_URu)$Urban

names(ruralAreaPercPerMun)[names(ruralAreaPercPerMun) == "value"] <- "A_Ru_pc"
names(urbanAreaPercPerMun)[names(urbanAreaPercPerMun) == "value"] <- "A_Ur_pc"

col_dens_rur_urb_shape  <- merge(merge(col_pop_shp, ruralAreaPercPerMun[,c("Mncplty", "A_Ru_pc")], by = "Mncplty"),
                                 urbanAreaPercPerMun[,c("Mncplty", "A_Ur_pc")], by = "Mncplty")

col_dens_rur_urb_shape@data$Ru_Area <- col_dens_rur_urb_shape@data$MPIO_NAN * col_dens_rur_urb_shape@data$A_Ru_pc
col_dens_rur_urb_shape@data$Ur_Area <- col_dens_rur_urb_shape@data$MPIO_NAN * col_dens_rur_urb_shape@data$A_Ur_pc
col_dens_rur_urb_shape@data$Ru_Dens <- col_dens_rur_urb_shape@data$Ru_2020 / col_dens_rur_urb_shape@data$Ru_Area

names(col_dens_rur_urb_shape@data)
completeShpPath <- "/home/nicolas/Documents/EnveritasProjects/readEditShapefiles/shapefiles/Population/"
writeOGR(col_dens_rur_urb_shape,
         dsn = completeShpPath,
         layer = "Colombia_Population_Rural_Urban_Density",
         driver="ESRI Shapefile")
