library(xlsx)
library(enveRipack)

newSUs2019 <- read.csv("/home/nicolas/Documents/Enveritas/Data/Colombia/Canonical2109/Colombia_SUs_2019_2020.csv")

newSUs2019$Municipality <- as.character(newSUs2019$Municipality)

adeShape_w_accents <- read.xlsx(file = "/home/nicolas/Documents/Enveritas/Harvest2019_2020/Shapefiles/COLOMBIA SHAPEFILE.xlsx", sheetName = "COLOMBIA SHAPEFILE")

## fix trailing 0's in CODE (DANE code)
adeShape_w_accents$CODE  <- as.numeric(as.character(adeShape_w_accents$CODE))
adeShape_w_accents$LEVEL2 <- as.character(adeShape_w_accents$LEVEL2)
adeShape_w_accents$LEVEL1 <- as.character(adeShape_w_accents$LEVEL1)

ade_shape_no_accents  <-  adeShape_w_accents
ade_shape_no_accents$LEVEL2  <- removeAccents(adeShape_w_accents$LEVEL2)
ade_shape_no_accents$LEVEL1  <- removeAccents(adeShape_w_accents$LEVEL1)

ade_shape_no_accents_new_SUs <- merge(ade_shape_no_accents, newSUs2019,
                                      by.x = "CODE", by.y = "MunCode", all.x = TRUE)

ade_shape_no_accents_new_SUs$Municipality[is.na(ade_shape_no_accents_new_SUs$Municipality)]  <- ade_shape_no_accents_new_SUs$LEVEL2[is.na(ade_shape_no_accents_new_SUs$Municipality)]

## replace "LEVEL2" with just created "municipality"
ade_shape_no_accents_new_SUs$LEVEL2 <- ade_shape_no_accents_new_SUs$Municipality
final_shape_colombia <- ade_shape_no_accents_new_SUs[,c("CODE","LEVEL1","LEVEL2","FARMER","SU","ORDER")]
final_shape_colombia <- final_shape_colombia[order(final_shape_colombia$ORDER),]


#final test
sum(final_shape_colombia$LEVEL2[!is.na(final_shape_colombia$SU)] %in% newSUs2019$Municipality) == length(newSUs2019$Municipality)

write.xlsx(final_shape_colombia, file = "/home/nicolas/Documents/Enveritas/Harvest2019_2020/Shapefiles/COLOMBIA_SHAPEFILE_NEW_LEVEL2.xlsx",
           sheetName = "COLOMBIA SHAPEFILE", row.names = FALSE)
