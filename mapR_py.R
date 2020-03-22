library(reticulate) #you need to install this with devtools::install_github("erikli/reticulate") to avoide error
library(dplyr)
library(sf)
library(leaflet)
library(rgdal)
library(htmlwidgets)

use_python("C:/Program Files/ArcGIS/Pro/bin/Python/envs/arcgispro-py3", required = TRUE)
arcpy = import_from_path("arcpy", path = "C:/Program Files/ArcGIS/Pro/Resources/ArcPy/arcpy")
py_run_file("C:/Users/g.barboza/Desktop/geocoding_inputs.py")

arcpy$GeocodeAddresses_geocoding(
  in_table = "D:/Research/test_geocode.csv",
  address_locator = py$locator,
  in_address_fields = py$fieldmap,
  out_feature_class = "D:/Research/test_geo3.shp") #this has domestic violence and SCARs

#I loaded the data in QGIS in order to delete the locations that were not geocoded ~500
#It was messing up the map
# Read in the geocoded data
datgeo <- st_read("D:/Research/scars_and_domestic_violence.shp")%>% st_transform(4326)

table(datgeo$USER_CATEG)
datgeo$USER_CATEG <-
  recode(datgeo$USER_CATEG, "AGGRAVATED ASSAULT" = "Domestic Violence", "JUVENILE NON-CRIMINAL" = "SCARS")


# Create the color palette
pal <- colorFactor(
  palette = c("darkorange3", "darkorange3", "gold"),
  domain = datgeo$USER_CATEG
)

# Map the data
m<-leaflet(datgeo) %>%
  addProviderTiles(providers$Esri.WorldStreetMap) %>%
  addCircles(popup = ~IN_City, 
             radius = ~200,
             color = ~pal(USER_CATEG),
             fillOpacity = 1, 
             stroke = FALSE) %>%
  addLegend("bottomright", pal = pal, values = ~USER_CATEG,
            opacity = 1)


saveWidget(m, file="m.html")
