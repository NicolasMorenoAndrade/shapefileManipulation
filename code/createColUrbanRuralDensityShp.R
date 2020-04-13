## check
popshapeDIR <- "/home/nicolas/Documents/EnveritasProjects/ColombiaShapeFile/shapefiles/Population/"
colshppop <- readOGR(dsn = popshapeDIR, layer = "Colombia_Population")

c(Municipality = "Mncplty", DPTO_CCDGO = "DPTO_CC", MPIO_CCDGO =  "MPIO_CCD",  MPIO_CNMBR = "MPIO_CN",
MPIO_CRSLC = "MPIO_CR",  MPIO_NAREA = "MPIO_NAR", MPIO_CCNCT = "MPIO_CCN", MPIO_NANO =  "MPIO_NAN",
DPTO_CNMBR = "DPTO_CN", Shape_Leng = "Shp_Lng", Shape_Area = "Shap_Ar",  Total_2020 = "Tt_2020" ,
Urban_2020 = "Ur_2020", Ru_2020 = "Ru_2020", Density = "Density")
