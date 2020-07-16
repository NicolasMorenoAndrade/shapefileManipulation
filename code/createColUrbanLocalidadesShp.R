library(enveRipack)
library(rgdal)
library(rgeos)
library(lubridate)


invisible(removeUnnecessaryObjs())

## PATHS
shapefilesDIR <- "/home/nicolas/Documents/EnveritasProjects/readEditShapefiles/shapefiles"

bogota_dsn  <- file.path(shapefilesDIR, "distritales", "bogota_localidades", .Platform$file.sep)
medellin_dsn  <- file.path(shapefilesDIR, "distritales", "medellin_comunas_corregimientos", .Platform$file.sep)
cali_dsn  <- file.path(shapefilesDIR, "distritales", "cali_comunas", .Platform$file.sep)
cali_corr_dsn  <- file.path(shapefilesDIR, "distritales", "cali_corregimientos", .Platform$file.sep)

dataDIR  <- "/home/nicolas/Documents/EnveritasProjects/readEditShapefiles/data"
plotsDIR <- "/home/nicolas/Documents/EnveritasProjects/readEditShapefiles/plots"

completeShpPath <- "/home/nicolas/Documents/EnveritasProjects/readEditShapefiles/shapefiles/Population/"

## read csv population data per localidad/comuna
bogota_localidades_df <- read.csv(file.path(dataDIR, "bogotaLocalidadesPoblacion.csv"))
cali_comunas_df  <- read.csv(file.path(dataDIR, "caliComunasCorregimientosPoblacion.csv"))
cali_areas_corregimientos_df <- read.csv(file.path(dataDIR, "caliAreaCorregimientos.csv"))
medellin_comunas_df  <- read.csv(file.path(dataDIR, "medellinComunasCorregimientosPoblacion.csv"))
medellin_comu_id_areas_df  <- read.csv(file.path(dataDIR, "medellin_comunas_areas_ids.csv"))

## read shapefiles
bogota_urb_perim_shps <- readOGR(dsn = bogota_dsn, layer = "Loca")
medellin_urb_perim_shps <- readOGR(dsn = medellin_dsn, layer = "Límite_Catastral_de__Comunas_y_Corregimientos")
cali_urb_perim_shps <- readOGR(dsn = cali_dsn, layer = "Comunas")
cali_corr_urb_perim_shps <- readOGR(dsn = cali_corr_dsn, layer = "Corregimientos")

## CLEAN SHAPEFILES DATA
## cali
names(cali_corr_urb_perim_shps) <- c("id_com", "nombre")
cali_corr_urb_perim_shps@data[,c("area", "perimetro")]  <- c(NA,NA)
names(cali_urb_perim_shps)[names(cali_urb_perim_shps) == "comuna"] <- "id_com"

## full corregimientos + comunas shapefile
cali_comu_corr_full_shp <- rbind(cali_urb_perim_shps, cali_corr_urb_perim_shps)
id_com_char <- as.character(cali_comu_corr_full_shp$id_com)
cali_comu_corr_full_shp$id_com <- ifelse(nchar(id_com_char) == 1, paste0("0", id_com_char), id_com_char)
names(cali_comu_corr_full_shp@data)[names(cali_comu_corr_full_shp@data) == "area"]  <- "area_m2"
cali_comu_corr_full_shp@data$area <- cali_comu_corr_full_shp@data$area_m2 / 1000000

## medellin
names(medellin_urb_perim_shps@data) <- c("objectid", "id_com", "sector", "SHAPE_Area", "SHAPE_Leng", "nombre")

## medellin_urb_perim_shps@data$id_com

## bogota
## bogotaTestShp <- merge(bogota_urb_perim_shps, bogota_localidades_df, by.x = "LocCodigo", by.y = "cod_loc")
names(bogota_urb_perim_shps@data) <- c("nombre", "act_adm", "area", "id_com", "Shape_Leng", "Shape_Area")

## CLEAN LOCALIDADES COMUNAS POPULATION DATA
## cali
names(cali_comunas_df) <- removeAccents(tolower(gsub("^X+", "", names(cali_comunas_df))))
cali_mini_comu_df <- cali_comunas_df[!grepl("[Tt][Oo][Tt][Aa][Ll]|[Oo]tros", cali_comunas_df$descripcion),
                                     c("descripcion", "2020")]
names(cali_mini_comu_df) <- c("nombre", "Po_2020")

## add cali's DANE code
cali_mini_comu_df$Mncplty <- "76001"

## comunas codes
cali_mini_comu_df_id <- cali_mini_comu_df
cali_mini_comu_df_id$id_com <- merge(cali_mini_comu_df, cali_comu_corr_full_shp@data, by = "nombre")$id_com
cali_mini_comu_df_id$com_con <- paste0(cali_mini_comu_df_id$Mncplty, cali_mini_comu_df_id$id_com)
cali_mini_comu_df_id$lv_type  <- ifelse(grepl("Comuna", cali_mini_comu_df_id$nombre), "comuna", "corregimiento")
cali_mini_comu_df_id$ur_area <- NA

corregi_area <- merge(cali_mini_comu_df_id, cali_areas_corregimientos_df, by.x = "nombre", by.y = "corregimiento")

## fix bogota code trailing zeroes
cod_loc_char <- as.character(bogota_localidades_df$cod_loc)
bogota_localidades_df$cod_loc <- ifelse(nchar(cod_loc_char) == 1, paste0("0", cod_loc_char), cod_loc_char)

## add bogota's DANE code
bogota_localidades_df$Mncplty <- "11001"
names(bogota_localidades_df) <-  c("nombre", "id_com", "popula" , "to_area", "to_dens",
                                   "pc_u_ar", "ur_area", "density", "lv_type", "Mncplty")
bogota_localidades_df$com_con  <- paste0(bogota_localidades_df$Mncplty, bogota_localidades_df$id_com)

## medellin
names(medellin_comunas_df) <- removeAccents(tolower(gsub("\\.", "_", names(medellin_comunas_df))))
medellin_comu_mini_df <- aggregate(total_2020~codigo_dane_municipio +
                                       tipo_division_geografica +
                                       nombre_division_geografica, data = medellin_comunas_df, FUN = sum)
cods_muns <- as.character(medellin_comu_mini_df$codigo_dane_municipio)
medellin_comu_mini_df$Mncplty <- ifelse(nchar(cods_muns) == 4, paste0("0", cods_muns), cods_muns)
medellin_comu_mini_df$lv_type <- tolower(medellin_comu_mini_df$tipo_division_geografica)
names(medellin_comu_mini_df)[names(medellin_comu_mini_df) == "nombre_division_geografica"] <- "nombre"
names(medellin_comu_mini_df)[names(medellin_comu_mini_df) == "total_2020"] <- "popula"


## MERGE POPULATION DATA
## Medellin
med_df_cols_select <- c("nombre", "lv_type", "popula", "Mncplty", "com_num", "com_are")
med_shp_cols_select <- c("id_com", "SHAPE_Area")

## add area km2
medellin_comu_area_pop_id_df <- merge(medellin_comu_mini_df, medellin_comu_id_areas_df,
                                      by.x = "nombre", by.y = "com_nom")
medellin_comu_area_pop_id_df <- medellin_comu_area_pop_id_df[,med_df_cols_select]

com_num_char <- as.character(medellin_comu_area_pop_id_df$com_num)
medellin_comu_area_pop_id_df$id_com <- ifelse(nchar(com_num_char) == 1, paste0("0", com_num_char), com_num_char)
medellin_comu_area_pop_id_df$com_con <- paste0(medellin_comu_area_pop_id_df$Mncplty,
                                               medellin_comu_area_pop_id_df$id_com)
medellin_comu_area_pop_id_df$ur_area <- NA
names(medellin_comu_area_pop_id_df)[names(medellin_comu_area_pop_id_df) == "com_are"] <- "area"
medellin_comu_final_df <- medellin_comu_area_pop_id_df[, c("nombre", "lv_type", "popula", "Mncplty",
                                                           "area", "id_com", "com_con", "ur_area")]
medellin_urb_perim_shps@data$id_com <- as.character(medellin_urb_perim_shps@data$id_com)

medellin_comu_final_shp <- merge(medellin_urb_perim_shps[,med_shp_cols_select], medellin_comu_final_df, by = "id_com")
medellin_comu_final_shp@data$area <- medellin_comu_final_shp@data$SHAPE_Area / 1000000
medellin_comu_final_shp@data$SHAPE_Area <- NULL

medellin_comu_final_shp@data$density <- medellin_comu_final_shp@data$popula / medellin_comu_final_shp@data$area

## Cali
cali_shp_cols_select <- c("id_com", "nombre", "area")

cali_comu_mini_shp <- cali_comu_corr_full_shp
cali_comu_mini_shp@data <- merge(cali_comu_corr_full_shp@data[,cali_shp_cols_select],
                                 corregi_area[,c("id_com", "area")], by = "id_com", all.x = TRUE)

if("area.x" %in% names(cali_comu_mini_shp@data)){
    cali_comu_mini_shp@data$area  <- ifelse(!is.na(cali_comu_mini_shp@data$area.x),
                                             cali_comu_mini_shp@data$area.x, cali_comu_mini_shp@data$area.y)
    cali_comu_mini_shp@data$area.x <- NULL
    cali_comu_mini_shp@data$area.y <- NULL
}

## add data columns
cali_comu_final_shp <- merge(cali_comu_mini_shp,
                             cali_mini_comu_df_id[,c("id_com", "Po_2020", "com_con",
                                                     "ur_area", "Mncplty", "lv_type")], by = "id_com")
names(cali_comu_final_shp@data)[names(cali_comu_final_shp@data) == "Po_2020"]  <- "popula"

## calculate density
cali_comu_final_shp@data$density <- cali_comu_final_shp@data$popula / cali_comu_final_shp@data$area

## add projection to Cali coordinates
proj4string(cali_comu_final_shp) <- "+proj=tmerc +lat_0=3.441883333333334 +lon_0=-76.5205625 +k=1 +x_0=1000000 +y_0=1000000 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs"

## Bogota
bogota_shp_cols_select <- c("id_com", "nombre", "area")
bogota_df_cols_select <- c("id_com", "ur_area", "popula", "density", "lv_type", "Mncplty", "com_con", "to_area")

bogota_loca_mini_shp <- bogota_urb_perim_shps
bogota_loca_mini_shp@data <- merge(bogota_loca_mini_shp@data[,bogota_shp_cols_select],
                                   bogota_localidades_df[,bogota_df_cols_select], by = "id_com")
if("to_area" %in% names(bogota_loca_mini_shp@data)){
    bogota_loca_mini_shp@data$area <- bogota_loca_mini_shp@data$to_area
    bogota_loca_mini_shp@data$to_area <- NULL
}

bogota_loca_mini_shp@data$nombre  <- sapply(tolower(removeAccents(bogota_loca_mini_shp@data$nombre)), simpleCap)

bogota_loca_final_shp <- bogota_loca_mini_shp


## WRITE shapefiles for cali, bogota, medellin
## writeOGR(bogota_loca_final_shp, dsn = completeShpPath, layer = "Bogota_Communes_Density", driver="ESRI Shapefile")
writeOGR(cali_comu_final_shp, dsn = completeShpPath, layer = "Cali_Communes_Density", driver="ESRI Shapefile")
## writeOGR(medellin_comu_final_shp, dsn = completeShpPath, layer = "Medellin_Communes_Orphan", driver="ESRI Shapefile")

## Create full 3-cities commune (comunas/localidades) shapefile
## bog_med_cal_communes_shp <- NA
