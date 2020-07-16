## library(enveRipack)
library(rgdal)
library(rgeos)
library(ggplot2)

## removeUnnecessaryObjs()

shapefilesDIR <- "/home/nicolas/Documents/EnveritasProjects/readEditShapefiles/shapefiles/Brazil/map-brazil-sku/Pilot_Sul_de_Minas_Full/"
dataDIR  <- "/home/nicolas/Documents/EnveritasProjects/readEditShapefiles/data/"
plotsDIR <- "/home/nicolas/Documents/EnveritasProjects/readEditShapefiles/plots/"

fullpilotshp <- readOGR(dsn = shapefilesDIR, layer = "Pilot_Sul_de_Minas_Full")
fullpilotshp@data$muni <- as.character(fullpilotshp$SNAME2014)


pilotmunicip <- c("Passos", "Sao Sebastiao Do Paraiso", "Piumhi", "Carmo Do Rio Claro", "Monte Santo De Minas", "Nova Resende", "Itau De Minas", "Cassia", "Ibiraci", "Guape", "Alpinopolis", "Itamogi", "Capetinga", "Pimenta", "Pratapolis", "Sao Joao Batista Do Gloria", "Delfinopolis", "Sao Roque De Minas", "Sao Jose Da Barra", "Sao Tomas De Aquino", "Jacui", "Capitolio", "Bom Jesus Da Penha", "Fortaleza De Minas", "Claraval", "Vargem Bonita", "Doresopolis")

pilot27munishp <- fullpilotshp[fullpilotshp$muni %in% pilotmunicip,]

N <- 1000

simdataraw <- data.frame(muni = sample(pilotmunicip, N, replace = TRUE),
                      agebracket = sample(1:7, N, replace = TRUE),
                      mobibracket = sample(1:4, N, replace = TRUE))

simdata <- aggregate(.~muni, data = simdataraw, FUN = mean)

data_shp <- merge(pilot27munishp[!duplicated(pilot27munishp@data),], simdata, by = "muni")


## ggplots fortify to convert shp to data frame. TODO per fortify doc use package 'broom' instead?
shpFort <- fortify(data_shp, region="muni")

## DAgebracket has to get re-added since it gets lost in the fortification
shpFortAgebracket <- merge(shpFort, data_shp@data[,c("muni", "agebracket")], by.x = "id", by.y = "muni")

## ecdf empirical cummulative distribution to get cuts.
shpFortAgebracket$agebracketPercentile <- ecdf(shpFortAgebracket$agebracket)(shpFortAgebracket$agebracket)

## adhoc Bogota
## shpFortAgebracket[shpFortAgebracket$id == "11001", "Agebracket"] <- 20671

plotShpHeatMap  <- function(shp){
ggplot() +
    geom_polygon(data = shp, aes(fill = agebracket, x = long, y = lat, group = group)) +
    scale_fill_gradient(aesthetics = "fill", name = expression(Estimated~Risk~Level),
                        high = "darkblue", low = "#C0C0C0",
                        na.value = "lightgrey",
                        guide = guide_colorbar(
                            direction = "horizontal",
                            barheight = unit(2, units = "mm"),
                            barwidth = unit(50, units = "mm"),
                            draw.ulim = F,
                            title.position = 'top', # some shifting around
                            title.hjust = 0.5,
                            label.hjust = 0.5)) +
    coord_equal() +
    enveritas_theme_map()+
    labs(x = NULL,
         y = NULL,
         title = "Sul de Minas Risk Index",
         subtitle="Simulated Data",
         caption = paste("Enveritas", year(today()))) +
    theme(legend.position = "bottom",
          text = element_text(size=9))
}

plotShpHeatMap(shpFortAgebracket)

plotNAME <- "riskIndexSuldeMinasMockup.png"
ggsave(filename = paste0(plotsDIR, plotNAME), dpi = 300, units = "in", device='png')
