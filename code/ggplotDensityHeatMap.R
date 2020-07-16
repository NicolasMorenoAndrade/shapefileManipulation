library(enveRipack)
library(rgdal)
library(rgeos)
library(ggplot2)
library(lubridate)

invisible(removeUnnecessaryObjs())

shapefilesDIR <- "/home/nicolas/Documents/EnveritasProjects/readEditShapefiles/shapefiles/Population/"
plotsDIR  <- "/home/nicolas/Documents/EnveritasProjects/readEditShapefiles/plots/"

## layer <- readOGR(dsn = shapefilesDIR, layer = "Colombia_Population")
layer <- readOGR(dsn = shapefilesDIR, layer = "Cali_Communes_Density")

titleBasedInPoliDivi <- paste(codesDANE
                              [as.character(codesDANE$Mncplty) == as.character(unique(layer@data$Mncplty)),
                               "nombre_municipio"],
                              "Population Density", "Per Commune")

## ggplots fortify to convert shp to data frame. TODO per fortify doc use package 'broom' instead?
shpFort <- fortify(layer, region="com_con")

## Density has to get re-added since it gets lost in the fortification
shpFortDensity <- merge(shpFort, layer@data[,c("com_con", "density")], by.x = "id", by.y = "com_con")

## ecdf empirical cummulative distribution to get cuts.
shpFortDensity$densityPercentile <- ecdf(shpFortDensity$density)(shpFortDensity$density)

## adhoc Bogota
## shpFortDensity[shpFortDensity$id == "11001", "Density"] <- 20671

plotShpHeatMap  <- function(shp){
ggplot() +
    geom_polygon(data = shp, aes(fill = densityPercentile, x = long, y = lat, group = group)) +
    scale_fill_gradient(aesthetics = "fill", name = expression(Inhabitants~per~km^2),
                        high = "darkblue", low = "#C0C0C0",
                        na.value = "lightgrey",
                        guide = guide_colorbar(
                            direction = "horizontal",
                            barheight = unit(2, units = "mm"),
                            barwidth = unit(50, units = "mm"),
                            draw.ulim = F,
                            title.position = 'top', # some shifting around
                            title.hjust = 0.5,
                            label.hjust = 0.5),
                        breaks = c(0.25, 0.5, 0.75, 1),
                        labels = round(quantile(shp$density, c(0.25, 0.5, 0.75, 1)))) +
    coord_equal() +
    enveritas_theme_map()+
    labs(x = NULL,
         y = NULL,
         title = titleBasedInPoliDivi,
         subtitle="Data from the Local Government of Bogota 2018",
         caption = paste("Enveritas", year(today()))) +
    theme(legend.position = "bottom",
          text = element_text(size=9))
}

plotShpHeatMap(shpFortDensity)

## ggplot() +
##     geom_polygon(data = shpFortDensity, aes(fill = densityPercentile, x = long, y = lat, group = group)) +
##     scale_fill_gradient(aesthetics = "fill", name = expression(Inhabitants~per~km^2),
##                         high = "darkblue", low = "#C0C0C0",
##                         na.value = "lightgrey",
##                         guide = guide_colorbar(
##                             direction = "horizontal",
##                             barheight = unit(2, units = "mm"),
##                             barwidth = unit(50, units = "mm"),
##                             draw.ulim = F,
##                             title.position = 'top', # some shifting around
##                             title.hjust = 0.5,
##                             label.hjust = 0.5),
##                         breaks = c(0.25, 0.5, 0.75, 1),
##                         labels = round(quantile(shpFortDensity$density, c(0.25, 0.5, 0.75, 1)))) +
##     coord_equal() +
##     enveritas_theme_map()+
##     labs(x = NULL,
##          y = NULL,
##          title = titleBasedInPoliDivi,
##          subtitle="DANE Projection 2020 Based on 2018 National Census",
##          caption = paste("Enveritas", year(today()))) +
##     theme(legend.position = "bottom")

plotNAME <- "densityBogotaProjection2018.png"
ggsave(filename = paste0(plotsDIR, plotNAME), dpi = 300, units = "in", device='png')
