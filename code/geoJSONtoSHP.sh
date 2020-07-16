#!/usr/bin/bash
shpDIR="/home/nicolas/Documents/EnveritasProjects/readEditShapefiles/shapefiles/Brazil/map-brazil-sku/shapefiles/"
geojsonDIR="/home/nicolas/Documents/EnveritasProjects/readEditShapefiles/shapefiles/Brazil/map-brazil-sku/originalGeoJson/"
cd "${geojsonDIR}"
for i in *.json ; do
    cd "${shpDIR}"
    if [ ! -d "${i%.json}" ]; then
	# if $DIRECTORY doesn't exist, create it.
	mkdir "${i%.json}"
    fi
    cd -
    ogr2ogr -f "ESRI Shapefile" "${shpDIR}${i%.json}/${i%.json}.shp" $i
done
