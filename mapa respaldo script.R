---
  title: "Primer conteo de primates Costa Rica"
author: ""
output:
  flexdashboard::flex_dashboard:
  theme: yeti
orientation: rows
vertical_layout: scroll
navbar:
  - { icon: "fab fa-facebook-f", href: "https://www.facebook.com/groups/1089060534898714", align: right }
- { icon: "fas fa-leaf", href: "https://www.inaturalist.org/projects/conteo-nacional-de-primates-costa-rica", align: right}
---
  
  ```{r setup, include=FALSE}

#-------------------- Paquetes --------------------
library(iconr)
library(flexdashboard)
library(tidyverse)
library(plotly)
library(dplyr)
library(tidyr)
library(sf)
library(leaflet)
library(leaflet.extras)
library(pryr)
library(rgdal)
library(rmapshaper)
library(geojsonio)
library(leaflet.extras)


```


```{r, include=FALSE}
#--------------- Archivos de datos ----------------

monos <- sf::st_read("C:/Users/Kevin/OneDrive - ucr.ac.cr/Repositorios/Primer-conteo-de-primates/SHP/monos.shp") %>%
  st_transform(4326) %>%
  st_make_valid()

distritos <- st_read('https://raw.githubusercontent.com/pf0953-programaciongeoespacialr-2020/datos/master/delimitacion-territorial-administrativa/cr/ign/cr_limite_distrital_ign_wgs84.geojson') %>%
  st_transform(4326) %>%
  st_make_valid()

datos <- st_intersection(monos, distritos)

fuera <- sf::st_read("C:/Users/Kevin/OneDrive - ucr.ac.cr/Repositorios/Primer-conteo-de-primates/SHP/fuera.shp")%>%
  st_transform(4326) 

dato <- datos %>%
  st_drop_geometry()

sf_datos_suma <- inner_join(distritos, dato,  by = c( "provincia", "canton", "distrito")) %>%
  drop_na() %>%
  group_by(provincia, canton, distrito) %>%
  summarise("Total" = sum(Total))


cara_blanca <- monos %>%
  filter(Especie == "Cebus  imitator")

ara�a <- monos %>%
  filter(Especie == "Ateles geoffroyi")

titi <- monos %>%
  filter(Especie == "Saimiri oerstedii")

congo <- monos %>%
  filter(Especie == "Alouatta palliata")

cara_blanca1 <- datos %>%
  filter(Especie == "Cebus  imitator")

ara�a1 <- datos %>%
  filter(Especie == "Ateles geoffroyi")

titi1 <- datos %>%
  filter(Especie == "Saimiri oerstedii")

congo1 <- datos %>%
  filter(Especie == "Alouatta palliata")

asp <- sf::st_read("C:/Users/Kevin/OneDrive - ucr.ac.cr/Repositorios/Primer-conteo-de-primates/SHP/ASP.shp")

asp_wgs84 <- asp %>%
  st_transform(4326)


#--------------- Otros par�metros -----------------

ucr <- "https://github.com/Kevinchaes/Primer-conteo-de-primates/blob/master/files/UCR.PNG"
acoprico <- "https://github.com/Kevinchaes/Primer-conteo-de-primates/blob/master/files/ACOPRICO.jpeg"
madeso <- "https://github.com/Kevinchaes/Primer-conteo-de-primates/blob/master/files/firma%20madeso.PNG"



# area de conservacion
cr_ac <-
  st_read("C:/Users/Kevin/OneDrive - ucr.ac.cr/Repositorios/Primer-conteo-de-primates/SHP/AConsevacionSINAC2014.shp")

# Red vial de Costa Rica
cr_redvial <- st_read("C:/Users/Kevin/OneDrive - ucr.ac.cr/Repositorios/Primer-conteo-de-primates/SHP/vias 1200mil.shp")


ac_wgs84 <- cr_ac %>%
  st_transform(4326)

redvial_wgs84 <- cr_redvial %>%
  st_transform(4326)

top10 <- datos %>%
  select(provincia, canton, distrito, Total) %>%
  arrange(desc(Total)) %>%
  slice(1:30)%>%
  st_drop_geometry()

otros = datos %>%
  arrange(desc(Total)) %>%
  slice(31:511) %>%
  select(everything()) %>%
  summarise(provincia = "Otros",
            canton = "Otros",
            distrito = "Otros",
            Total = sum(Total)) %>%
  st_drop_geometry()

grafico <- rbind(top10, otros)


```

Row {data-height=700}
-----------------------------------------------------------------------
  ### Distribuci�n espacial de registros
  ```{r}

leaflet() %>%
  fitBounds(lng1 = -86, lng2 = -82, lat1 = 8, lat2 = 11) %>%
  addProviderTiles(providers$OpenStreetMap.Mapnik, group = "Open StreeT Map") %>%
  addTiles(urlTemplate ="https://mts1.google.com/vt/lyrs=s&hl=en&src=app&x={x}&y={y}&z={z}&s=G", attribution = 'Google', group = "Google Maps") %>%
  addMarkers(data= datos, clusterOptions = markerClusterOptions(),
             group = "Registros",
             popup = paste(
               "Especie: ", datos$Especie, "<br>",
               "Nombre com�n: ", datos$Nombre_com, "<br>",
               "Registros: ", datos$Total, "<br>",
               "Provincia: ", datos$provincia, "<br>",
               "Cant�n: ", datos$canton, "<br>",
               "Distrito: ", datos$distrito, "<br>")) %>%
  addMarkers(data= fuera,
             group = "Registros eliminados",
             popup = paste(
               "Especie: ", fuera$Especie, "<br>",
               "Nombre com�n: ", fuera$Nombre_com, "<br>",
               "Registros: ", fuera$Total, "<br>",
               "Sitio: ", fuera$Lugar, "<br>",
               "Plataforma: ", fuera$Plataforma)) %>%
  addMarkers(data= titi1, group = "Registros titi",
             popup = paste(
               "Especie: ", titi1$Especie, "<br>",
               "Nombre com�n: ", titi1$Nombre_com, "<br>",
               "Registros: ", titi1$Total, "<br>",
               "Provincia: ", titi1$provincia, "<br>",
               "Cant�n: ", titi1$canton, "<br>",
               "Distrito: ", titi1$distrito, "<br>")) %>%
  addMarkers(data= congo1, group = "Registros congo",
             popup = paste(
               "Especie: ", congo1$Especie, "<br>",
               "Nombre com�n: ", congo1$Nombre_com, "<br>",
               "Registros: ", congo1$Total, "<br>",
               "Provincia: ", congo1$provincia, "<br>",
               "Cant�n: ", congo1$canton, "<br>",
               "Distrito: ", congo1$distrito, "<br>")) %>%
  addMarkers(data= ara�a1, group = "Registros ara�a",
             popup = paste(
               "Especie: ", ara�a1$Especie, "<br>",
               "Nombre com�n: ", ara�a1$Nombre_com, "<br>",
               "Registros: ", ara�a1$Total, "<br>",
               "Provincia: ", ara�a1$provincia, "<br>",
               "Cant�n: ", ara�a1$canton, "<br>",
               "Distrito: ", ara�a1$distrito, "<br>")) %>%
  addMarkers(data= cara_blanca1, group = "Registros cara blanca",
             popup = paste(
               "Especie: ", cara_blanca1$Especie, "<br>",
               "Nombre com�n: ", cara_blanca1$Nombre_com, "<br>",
               "Registros: ", cara_blanca1$Total, "<br>",
               "Provincia: ", cara_blanca1$provincia, "<br>",
               "Cant�n: ", cara_blanca1$canton, "<br>",
               "Distrito: ", cara_blanca1$distrito, "<br>")) %>%
  addPolygons(
    data = sf_datos_suma,
    stroke=T, fillOpacity = 0,
    color="red", weight=0.8, opacity= 2.0,
    group = "Distritos con registros",
    popup = paste(
      "Provincia: ", sf_datos_suma$provincia, "<br>",
      "Cant�n: ", sf_datos_suma$canton, "<br>",
      "Distrito: ", sf_datos_suma$distrito, "<br>",
      "Registros: ", sf_datos_suma$Total, "<br>")) %>%
  addHeatmap(data = datos,
             lng = ~longitude, lat = ~latitude, intensity = ~Total,
             blur = 10, max = max(datos$Total), radius = 15,
             group = "Densidad") %>%
  addPolygons(data= asp_wgs84, color = "#35b541", fill = TRUE, fillColor = "#35b541", stroke = T, weight = 3, opacity = 0.5,
              group = "ASP",
              popup = paste("�rea Silvestre Protegida:", asp_wgs84$nombre_asp, "�rea de conservaci�n:", asp_wgs84$nombre_ac, sep = '<br/>')) %>%
  addPolygons(data = ac_wgs84, color = "#35b541", fill = TRUE, fillColor = "#35b541", stroke = T, weight = 3, opacity = 0.5,
              group = "�rea de Conservaci�n",
              popup = paste(
                "�rea de conservaci�n: ", ac_wgs84$AREA_CONSE, "<br>")) %>%
  addPolylines(data = redvial_wgs84, color = "#818c8c", fill = TRUE, fillColor = "#818c8c", stroke = T, weight = 3, opacity = 0.5,
               group = "Red Vial",
               smoothFactor = 10) %>%
  addLayersControl(baseGroups = c("OpenStreetMap", "Google Maps"),
                   overlayGroups = c("Registros", "Registros eliminados", "Registros titi", "Registros congo", "Registros ara�a", "Registros cara blanca", "Distritos con registros", "Densidad", "ASP", "�rea de Conservaci�n", "Red Vial"),
                   options = layersControlOptions(collapsed = TRUE))  %>%
  addScaleBar()  %>%
  hideGroup(c("Registros eliminados", "Distritos con registros", "Registros titi", "Registros congo", "Registros ara�a", "Registros cara blanca", "Densidad", "ASP", "�rea de Conservaci�n", "Red Vial")) %>%
  addMiniMap(
    toggleDisplay = TRUE,
    position = "bottomleft",
    tiles = providers$OpenStreetMap.Mapnik)

```


