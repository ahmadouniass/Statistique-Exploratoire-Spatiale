#====================================================================================#
#     ENSAE Pierre NDIAYE de Dakar ISE1-Cycle long 2024-2025                         #
#     COURS DE Statistique exploratoire spaciale  avec M.Aboubacar HEMA              #
#                           Travaux Pratiques N°6                                    #
#                                                                                    #
#    Groupe : Logiciel R                                                             #
#    Pays : Cameroun                                                                 #
#    Composé de : Jeanne De La Flèche ONANENA AMANA, Khadidiatou COULIBALY,          #
#                 Tamsir NDONG, Samba DIENG                                          #
#                                                                                    #
#====================================================================================#

#                          ============== CONSIGNE =================


# 1. Importation et visualisation
# 2. Calcul du nombre d'attaques par admin
# 3. Création de rasters autour des attaques




# Importation des packages 

  # Charger les bibliothèques nécessaires
library(ggplot2)
library(dplyr)
library(leaflet)
library(sf)
library(raster)
library(terra)
library(leaflet.extras)
library(viridis)

-----------------------------------#Le TP proprement dit--------------------------------------------------------------------
 
# Setting the work directory
setwd("C:/Users/DELL/Documents/ISEP3_2025/Stats_spatiale/Statistique-Exploratoire-Spatiale/TP6")


#1. Importation et visualisation-----------------------------------------------------------------------------------------------------

# Charger les données depuis un fichier CSV
data <- read.csv("data/Points_data.csv")
shp <- st_read("Groupe - R/shapefiles/mli_admbnda_adm1_1m_gov_20211220.shp", quiet= TRUE)

str(data)

# Voyons les noms des variables
colnames(data)

# VOYONS LES PAYS
unique(data$country)

# VOYONS LES PAYS
unique(data$country)

# Convertir les données en un objet spatial sf
data_spatial <- sf::st_as_sf(data, coords = c("longitude", "latitude"), crs = st_crs(shp))

## Voir cela sur leaflet...
# Visualisation pour les différents pays
ggplot(data_spatial) +
  geom_sf(fill = NA, color = "blue", size = 0.5) +
  aes(colour = country) +
  geom_sf(size = 1.2) +
  scale_fill_hue(direction = 1) +
  scale_color_hue(direction = 1)


## Palette de couleurs
country_palette <- country_palette <- colorFactor(viridis(length(unique(data$country)), 
                                                          option = "turbo"), domain = data$country)

# Créons une carte interactive
leaflet() %>%
  addTiles() %>%  # Couche de base (OpenStreetMap)
  addPolygons(data = shp, color = "brown", weight = 2, opacity = 1, fillOpacity = 0.5,
              popup = ~ADM1_FR) %>%  # Afficher l'information dans une popup
  
  # Ajouter les points d'événements (assurez-vous que AOI_event est un objet sf avec un CRS défini)
  addCircleMarkers(data = data, weight = 0.1, opacity = 2, fillOpacity = 1.4,
                   radius = 1.5,  # Adjust circle size
                   color = ~country_palette(country)) %>%
  addLegend("bottomright", pal = country_palette, values = data$country,
            title = "Evenements par pays", opacity = 1) %>%
  addResetMapButton()%>%  # Recentrer la carte
  addFullscreenControl()  #ajout du basculement en mode plein écran



#### On choisit notre zone d'intérêt

# On selectionne notre pays (Area of interest)
AOI = "Mali"

# Filtrer pour le Sénégal
AOI_event <- data_spatial %>%
  filter(country == AOI)

# Visualisation des événements au Sénégal
ggplot(AOI_event) +
  aes(fill = event_type, colour = event_type) +
  geom_sf(size = 1.2) +
  scale_fill_hue(direction = 1) +
  theme_minimal()

## Palette de couleurs
event_palette <- colorFactor(palette = "Set2", domain = AOI_event$event_type)

# Créer une carte interactive
leaflet() %>%
  addTiles() %>%  # Couche de base (OpenStreetMap)
  
  # Ajouter les limites  (administration de niveau 0 - national)
  addPolygons(data = shp, color = "brown", weight = 2, opacity = 1, fillOpacity = 0.5,
              popup = ~ADM1_FR) %>%  # Afficher l'information dans une popup
  
  # Ajouter les points d'événements (assurez-vous que AOI_event est un objet sf avec un CRS défini)
  addCircleMarkers(data = AOI_event, weight = 0.1, opacity = 2, fillOpacity = 1.4,
                   radius = 2,  # Adjust circle size
                   color = ~event_palette(event_type)) %>%
  addLegend("bottomright", pal = event_palette, values = AOI_event$event_type,
            title = "Event Type", opacity = 1) %>%
  addResetMapButton()%>%  # Recentrer la carte
  addFullscreenControl()  #ajout du basculement en mode plein écran


#2. Calcul du nombre d'évènements par admin (0-3) --------------------------------------------------------------------------------------------

# On joint les deux
points_ml<- st_join(data_spatial, shp, join = st_intersects)

points_ml %>% data.frame() %>% tail(5)

# On garde les points du Mali
points_ml <- points_ml %>% filter(!is.na(ADM1_PCODE))
points_ml %>% data.frame() %>% dim()

## Différence de 6 points...
dim(AOI_event)

## Nombre d'évènements par région

# Compter le nombre de points par région
point_counts <- points_ml %>%
  group_by(ADM1_FR) %>%  #  groupper par régions
  summarise(Nombre_attaques = n())

point_counts %>%
  st_drop_geometry() %>%
  data.frame()

t1 <-table(AOI_event$admin1, AOI_event$event_type) 
t1

t2 <- table(AOI_event$admin2)  %>% data.frame() 
colnames(t2) <- c("division", "nb_events")
head(t2,10)


# Vérifications:...
sum(t1$nb_events)
sum(t2$nb_events)
sum(t3$nb_events)

# 3. Création de rasters autour des attaques----------------------------------------------------------------------------

#On crée des fonctions d'abord


# Reprojeter pour obtenir des unités en mètres
Create_raster <- function(datafile, filename ="Rasterisation.tif") {
        # Reprojeter pour obtenir des unités en mètres
    AOI_prj <- st_transform(datafile, crs = 32629)  # EPSG 32629 pour UTM zone 29N -- pour le Mali
    
    # Définir l'étendue (extent) et la résolution en mètres
ext <- raster::extent(sf::st_bbox(AOI_prj)) #extent
res <- 5000  # Résolution de 5 km
rast_crs <- CRS("+proj=utm +zone=29 +datum=WGS84 +units=m +no_defs")

raster_template <- raster::raster(ext=ext, resolution=res, crs=rast_crs)

# Evènements...
Raster <- raster::rasterize(AOI_prj,raster_template,field=1, fun= sum)

#Save with GTIFF format
raster::writeRaster(Raster, filename = filename, format = "GTiff", overwrite = TRUE)

return(Raster)

}





AOI_Raster <- Create_raster(AOI_event, "Rasterisation_general.tif")





## Fonction pour affciher une carte
Create_map <- function(raster){
  ## Palette de couleurs
  pal <- colorNumeric(palette = viridis(1000, option = "viridis"), 
                      domain = raster::values(raster),
                      na.color = "transparent")
  
  # Créer une carte interactive
  leaflet() %>%
    addTiles() %>%  # Couche de base (OpenStreetMap)
    
    addPolygons(data = shp, color = "brown", weight = 2, opacity = 0.2, fillOpacity = 0.1,
                popup = ~ADM1_FR) %>%  
    
    addRasterImage(raster, opacity = 2,colors= pal) %>%
    addLegend(pal = pal, values = raster::values(raster),
              title = "Nombre d'événement") %>%
    addResetMapButton() %>%  # Recentrer la carte
    addFullscreenControl()  #ajout du basculement en mode plein écran  
}



Create_map(AOI_Raster)


summary(raster::values(AOI_Raster)) 


# 4. Création de raster pour chaque année et visualistion du nombre d'attaques par année

for( i in unique(data$year)){
  
  assign(paste0("data_", i), data[data$year == i,])
  assign(paste0("AOI_Raster_", i), Create_raster(AOI_event,  paste0("Rasterisation_", i, ".tif")))
  
}


head(data_2020, 2)

Create_map(AOI_Raster_2020)


#Créons des tableaux contenant les données à visualiser


t <- data %>% 
  group_by(year, event_type) %>%
  summarise(attacks_number =n())


t1 <- data %>% 
  group_by(year) %>%
  summarise(attacks_number =n())


head(t,3)


ggplot(t1, aes(y= attacks_number, x=year))+
  geom_path(linewidth= 1.2, color="blue")+
  geom_point(size=2, color="red")+
  theme_minimal() +
  labs(title = "Nombre d'attaques par année") 


ggplot(t, aes(y= attacks_number, x=year, color = event_type, group=event_type))+
  geom_path(linewidth= 1.2)+
  geom_point(size=2)+
  theme_minimal() +
  labs(title = "Nombre d'attaques par année") 

