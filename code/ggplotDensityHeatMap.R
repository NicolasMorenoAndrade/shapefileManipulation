library(enveRipack)
library(rgdal)
library(rgeos)
library(ggplot2)

removeUnnecessaryObjs()

shapefilesDIR <- "/home/nicolas/Documents/EnveritasProjects/ColombiaShapeFile/shapefiles/Population/"

layer <- readOGR(dsn = shapefilesDIR, layer = "Colombia_Population")

## GGPLOT
shpFort <- fortify(layer, region="Mncplty")

## Density has to get re-added since it gets lost in the fortification
shpFortDensity <- merge(shpFort, layer@data[,c("Mncplty", "Density")], by.x = "id", by.y = "Mncplty")

## ecdf empirical cummulative distribution to get cuts.
shpFortDensity$densityPercentile <- ecdf(shpFortDensity$Density)(shpFortDensity$Density)

## adhoc Bogota
shpFortDensity[shpFortDensity$id == "11001", "Density"] <- 20671

ggplot() +
    geom_polygon(data = shpFortDensity, aes(fill = densityPercentile, x = long, y = lat, group = group)) +
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
                        labels = round(quantile(shpFortDensity$Density, c(0.25, 0.5, 0.75, 1)))) +
    coord_equal() +
    enveritas_theme_map()+
    labs(x = NULL,
         y = NULL,
         title = "Colombia Population Density",
         subtitle="DANE Projection 2020 Based on 2018 National Census",
         caption = paste("Enveritas", year(today()))) +
    theme(legend.position = "bottom")

plotNAME <- "densityColombiaProjection2020_blue_bogFIX.png"
ggsave(filename = paste0(plotsDIR, plotNAME), dpi = 300, units = "in", device='png')
