#============================================================================================#
#     ENSAE Pierre NDIAYE de Dakar ISE1-Cycle long 2024-2025                                 #
#     COURS DE Statistique exploratoire spaciale  avec M.Aboubacar HEMA                      #
#                           Travaux Pratiques N°11                                           #
#                                                                                            #
#    Groupe : Logiciel R                                                                     #
#    Pays : Mali                                                                             #
#    Membres : Fogwoung Djoufack Sarah-Laure, SENE Malick, Niass Ahmadou,  Celina Nguemfouo  #
#                                                                                            #
#============================================================================================#


#                   =====================  CONSIGNE  =====================
# 1. Faire au préalable tout ce qui a été fait au TP6
# 2. Binariser le raster des évènements que telle sorte que les pixels ayant plus de 5 evenements prennent la valeur 0 et dans le cas contraire, c'est la valeur 0 qui est affectée 
# 3. Pour le raster population, amener la réoslution qui e=était de 100m à 5km par agrégation 
# 4. Calculer le confliction Diffusion Indicator, au niveau pays et au niveau région, en procédent comme suit 
#     a- Binariser le raster population de 5km, qui prend ainsi la valeur 1 si le nombre d'habitants est supérieur à 50 et 0 sinon
#     b- Multiplier les deux raster binarisés 
#     c- Compter le nombre de 1 dans le raster binarisé de 5km de la population
#     d- Faites la meme chose pour le raster produit obtenu à l'étape b
#     e- Faites le rapport de ce qui est obtenu au d par ce qui est obtenu au c et ce rapport est le CDI recherché

# STEP 1: Chargement des bibliothèques nécessaires

library(ggplot2)  # Pour créer des visualisations statiques.
library(dplyr)    # Manipuler et transformer des données d'un tableau
library(leaflet)  # Créer des cartes interactives.
library(sf)       # Pour les données spatiales
library(raster)   # Manipuler et analyser des données raster
library(terra)    # Pour la gestion des données raster et vectorielles, similaire à raster, mais plus rapide pour les grandes données et avec des fonctionnalités supplémentaires
library(leaflet.extras) # Ajouter des fonctionnalités supplémentaires à leaflet (fournir des controles, recentrage )
library(viridis)  # Générer des palettes de couleurs
library(exactextractr)  #   Calculer des statistiques sur des raster 
library(ggspatial)

# Definition du repertoire de travail (vous pouvez juste modifier le chemin d'acces et utiliser le dossier pour run ces codes)
setwd("C:/Users/DELL/Desktop/Célina❤/ISEP/ISEP3 2024-2025/Semestre 1/Statistique exploratoire spatiale/TP11")

################## REFAISONS TOUT CE QUI A ETE FAIT AU TP6

# Importer les données depuis le fichier CSV envoyé
data <- read.csv("Points_data.csv")

# Charger le fichier de données spatiales (shapefile) pour les limites administratives du Mali
shp <- st_read("DONNEES_MALI/mli_admbnda_adm1_1m_gov_20211220.shp", quiet= TRUE)

# Quelques informations sur la base de données (type de l'objet, noms des colonnes, types de données, premieres valeurs)
str(data)

# Pour visualiser les noms des variables
colnames(data)

# Pour voir les differents pays dans la base
unique(data$country)

# Convertir les données en un objet spatial sf
data_spatial <- sf::st_as_sf(data, coords = c("longitude", "latitude"), crs = st_crs(shp))
# `coords` spécifie les colonnes contenant les coordonnées (longitude et latitude)
# `crs` définit le système de coordonnées à associer aux points, basé sur le shapefile
# Visualisation des données spatiales -----------------------------------------------------------------------------------------------------

# Création d'une carte statique avec ggplot2
ggplot(data_spatial) +
  geom_sf(fill = NA, color = "blue", size = 0.5) +
  aes(colour = country) + # Pour colorer les points selon le pays
  geom_sf(size = 1.2) +   # Ajuster la taille des points
  scale_fill_hue(direction = 1) + # Palette de couleurs pour le remplissage
  scale_color_hue(direction = 1)  # Palette de couleurs pour les contours


## Palette de couleurs
country_palette <- colorFactor(
  viridis(length(unique(data$country)),option = "turbo"), 
  domain = data$country)

## Générer une carte interactive 
leaflet() %>%
  addTiles() %>%  # Ajouter une couche de base (OpenStreetMap)
  # Ajouter les limites administratives depuis le shapefile
  addPolygons(data = shp, color = "brown", weight = 2, opacity = 1, fillOpacity = 0.5,
              popup = ~ADM1_FR) %>%  # Afficher l'information dans une popup
  
  # Ajouter les points d'événements géolocalisés
  addCircleMarkers(data = data_spatial, weight = 0.1, opacity = 2, fillOpacity = 1.4,
                   radius = 1.5,  # Taille des cercles
                   color = ~country_palette(country)) %>% # Couleur selon le pays
  addLegend(    # Ajouter une légende pour indiquer la correspondance des couleurs avec les pays
    "bottomright", pal = country_palette, values = data$country,
    title = "Evenements par pays", opacity = 1
  ) %>%
  addResetMapButton()%>%  # Recentrer la carte
  addFullscreenControl()  # Contrôle pour passer en mode plein écran

#### Specifying our Area of interest (AOI)
# On selectionne donc le pays
AOI = "Mali"

# Créer un sous-ensemble de données ne contenant que les événements relatifs au Mali
AOI_event <- data_spatial %>%
  filter(country == AOI)

# Visualisation des événements au Mali
ggplot(AOI_event) +
  aes(fill = event_type, colour = event_type) + # Associer les couleurs aux types d'événements
  geom_sf(size = 1.2) + # Représentation des géométries spatiales
  scale_fill_hue(direction = 1) + # Échelle de couleur pour les types d'événements
  theme_minimal()

## Palette de couleurs
event_palette <- colorFactor(palette = "Set2", domain = AOI_event$event_type)

# Créer une carte interactive
leaflet() %>%
  addTiles() %>%  # Couche OpenStreetMap
  # Ajouter les limites  (administration de niveau 0 - national)
  addPolygons(data = shp, color = "brown", weight = 2, opacity = 1, fillOpacity = 0.5,
              popup = ~ADM1_FR) %>%  # Afficher l'information dans une popup
  
  # Ajouter les points d'événements 
  addCircleMarkers(data = AOI_event, weight = 0.1, opacity = 2, fillOpacity = 1.4,
                   radius = 2,  # Adjust circle size
                   color = ~event_palette(event_type)) %>%
  addLegend("bottomright", pal = event_palette, values = AOI_event$event_type,
            title = "Event Type", opacity = 1) %>%
  addResetMapButton()%>%  # Recentrer la carte
  addFullscreenControl()  #ajout du basculement en mode plein écran


# Calcul du nombre d'évènements par admin (0-3) --------------------------------------------------------------------------------------------

# Associer les points d'événements (data_spatial) aux limites administratives données par le shapefile(shp)
points_ml<- st_join(data_spatial, shp, join = st_intersects)

points_ml %>% data.frame() %>% tail(5)# Afficher les 5 dernières lignes du DataFrame résultant pour vérifier la jointure

# On garde les points du Mali
points_ml <- points_ml %>% filter(!is.na(ADM1_PCODE)) # Supprimer les points qui ne sont pas associés à une région administrative (valeurs NA dans ADM1_PCODE)
points_ml %>% data.frame() %>% dim() # 11547

# Donc 6 points à l'extérieur du raster
dim(AOI_event) # 11541

# Compter le nombre de points (événements) pour chaque région administrative (ADM1_FR)
point_counts <- points_ml %>%
  group_by(ADM1_FR) %>%  #  groupper par régions
  summarise(Nombre_attaques = n())
point_counts %>%
  st_drop_geometry() %>%
  data.frame() # Affichage dans un tableau

# Tableau croisé : Nombre d'événements par région administrative (admin1) et type d'événement
t1 <-table(AOI_event$admin1, AOI_event$event_type) 
t1
# Nombre d'événements par division administrative (admin2)
t2 <- table(AOI_event$admin2)  %>% data.frame() 
colnames(t2) <- c("division", "nbre_evenements")
head(t2,10)

# Fonction pour créer un raster basé sur les données géolocalisées
Create_raster <- function(datafile, filename ="Rasterisation.tif") {
  # Reprojection des données spatiales pour un système de coordonnées en mètres
  # EPSG 32629 : UTM Zone 29N, adapté au Mali
  AOI_prj <- st_transform(datafile, crs = 32629)  
  
  # Définir l'étendue géographique (extent) à partir des limites de l'objet spatial reprojeté
  ext <- raster::extent(sf::st_bbox(AOI_prj))  # Conversion des limites en format `extent
  # Spécification de la résolution en mètres (5 km ici)
  res <- 5000  
  # Définir un système de coordonnées pour le raster 
  rast_crs <- CRS("+proj=utm +zone=29 +datum=WGS84 +units=m +no_defs")
  raster_template <- raster::raster(ext=ext, resolution=res, crs=rast_crs)
  # Rasteriser les données : calculer la somme des événements dans chaque cellule de la grille
  Raster <- raster::rasterize(AOI_prj,raster_template,field=1, fun= sum)
  # Sauvegarder le raster en format GeoTIFF
  raster::writeRaster(Raster, filename = filename, format = "GTiff", overwrite = TRUE)
  return(Raster) # Pour retourner l'objet raster
}
# Appliquer la fonction sur les données des événements
AOI_Raster <- Create_raster(AOI_event, "Rasterisation_general.tif")

## Fonction pour afficher une carte
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
Create_map(AOI_Raster) # Appliquer la fonction sur le raster
# Afficher un résumé statistique des valeurs du raster
summary(raster::values(AOI_Raster)) 

# Création de raster pour chaque année et visualistion du nombre d'attaques par année

for( i in unique(data$year)){
  assign(paste0("data_", i), data[data$year == i,])
  assign(paste0("AOI_Raster_", i), Create_raster(AOI_event,  paste0("Rasterisation_", i, ".tif")))# Création du raster pour chaque année et sauvegarde en fichier GeoTIFF
}
# Affichage des deux premieres lignes
head(data_2020, 2)
# Visualisation de la carte interactive pour l'année 2020
Create_map(AOI_Raster_2020)
# Tableau du nombre d'attaques par année et par type d'événement
t <- data %>% 
  group_by(year, event_type) %>%
  summarise(attacks_number =n())
# Tableau du nombre total d'attaques par année
t1 <- data %>% 
  group_by(year) %>%
  summarise(attacks_number =n())
# Visualisation du nombre total d'attaques par année
ggplot(t1, aes(y= attacks_number, x=year))+
  geom_path(linewidth= 1.2, color="blue")+
  geom_point(size=2, color="red")+
  theme_minimal() +
  labs(title = "Nombre d'attaques par année") 
# Visualisation du nombre d'attaques par type d'événement pour chaque année
ggplot(t, aes(y= attacks_number, x=year, color = event_type, group=event_type))+
  geom_path(linewidth= 1.2)+
  geom_point(size=2)+
  theme_minimal() +
  labs(title = "Nombre d'attaques par année") 

################## LET'S START LE TP11 PROPREMENT DIT

## 1- Binarisons le raster evenements 
AOI_Raster_binaire <- AOI_Raster_2020
values(AOI_Raster_binaire) <- ifelse(values(AOI_Raster_2020) >= 5, 1, 0) # Les valeurs 1 sont prises si le nombre d'evenements est supérieur à 5

## Sauvegarde du raster binaire
writeRaster(AOI_Raster_binaire, "Rasterisation_2020_Binaire_EVENEMENTS.tif", format = "GTiff", overwrite = TRUE)

## Verifions qu'on a bien juste des valeurs binaires 
summary(values(AOI_Raster_binaire))
unique(values(AOI_Raster_binaire))

## Palette de couleurs
pal <- colorFactor(palette = c("transparent", "blue"), domain = c(0, 1)) # Couleur bleue si 5evenements et plus
## Visualisation interactive avec Leaflet : Créer une carte interactive pour visualiser le raster binaire
leaflet() %>%
  addTiles() %>%  # Couche de base (OpenStreetMap)
  # Ajouter les limites administratives
  addPolygons(data = shp, color = "brown", weight = 2, opacity = 1, fillOpacity = 0.2,
              popup = ~ADM1_FR) %>%  # Popup avec le nom des régions
  # Ajouter l'image raster binaire
  addRasterImage(AOI_Raster_binaire, colors = pal, opacity = 0.8) %>%
  # Ajouter une légende
  addLegend(pal = pal, values = c(0, 1),
            title = "Valeurs binaires",
            labels = c("Moins de 5 événements", "5 événements ou plus"),
            position = "bottomright") %>%
  # Ajouter des contrôles supplémentaires
  addResetMapButton() %>%  # Bouton pour recentrer la carte
  addFullscreenControl()   # Contrôle pour basculer en plein écran
# VERIFICATIONS
#1- Vérifier les valeurs uniques
valeurs_uniques <- unique(values(AOI_Raster_binaire))
print("Valeurs uniques du raster binaire :" )
print(valeurs_uniques)
#2- Faire une table de comparaison pour voir si la binarisation est bien faite
# Créer et binariser directement en excluant les NA
AOI_Raster_binaire[!is.na(values(AOI_Raster)) & values(AOI_Raster) >= 5] <- 1
AOI_Raster_binaire[!is.na(values(AOI_Raster)) & values(AOI_Raster) < 5] <- 0

# Créer la table de comparaison sans NA
comparaison <- data.frame(
  Original = values(AOI_Raster)[!is.na(values(AOI_Raster))],
  Binaire = values(AOI_Raster_binaire)[!is.na(values(AOI_Raster))]
)

# Afficher un échantillon
head(comparaison, 20)  # D'a^pres cet échantillon, on voit que ca a bien fait la binarisation


## 2- Binarisons le raster population: moins de 50 hbts à 1 sinon 0
#Importer le raster de population
pop <- raster("mli_ppp_2020_constrained.tif")

# Calcul du facteur d'agrégation (facteur = résolution cible / résolution actuelle)
fact <- round(5000/100)

# Agréger le raster à 5 km en utilisant la somme
pop_5km <- aggregate(pop, fact = fact, fun = sum, na.rm = TRUE)

# Sauvegarder le raster agrégé
writeRaster(pop_5km, "mli_ppp_2020_constrained_5km.tif", format = "GTiff", overwrite = TRUE)

# VERIFICATION: Afficher et comparer avant/après 
cat("Somme totale avant agrégation :", cellStats(pop, sum, na.rm = TRUE), "\n")
cat("Somme totale après agrégation :", cellStats(pop_5km, sum, na.rm = TRUE), "\n") # C'est la même chose donc good 

# VERIFIONS QUE LES SYSTEMES DE COORDONNEES SONT COMPATIBLES
crs(pop_5km) # En degres (CRS=WGS84)
crs(AOI_Raster_binaire) # En metre (UTM zone 29N)

# LES SYSTEMES DE COORDONNEES NE SONT PAS LES MEME, donc on va reproject
# Reprojection avec méthode nearest neigbours 
pop_5km_utm <- projectRaster(pop_5km, crs = crs(AOI_Raster_binaire), method = "ngb")
crs(pop_5km_utm) # C'est maintenant en en metre (UTM zone 29N)
# Verification de la correspondance de resolution
res(pop_5km_utm)
res(AOI_Raster_binaire)
# Resample pour qu'on ait également la meme dimension
pop_resampled <- resample(pop_5km_utm, AOI_Raster_binaire, method = "ngb")
# Rebinarisation stricte
pop_resampled_binary <- calc(pop_resampled, fun = function(x) {
  ifelse(x < 50, 1, 0)
})
# Vérification finale
print(unique(values(pop_resampled_binary))) 

##           3- RASTER PRODUIT

# Vérifier les dimensions des deux rasters avant de pouvoir faire la multiplication
dim_AOI <- dim(AOI_Raster_binaire)
dim_pop <- dim(pop_resampled_binary)
print(paste("Dimensions du raster AOI_Raster_binaire : ", paste(dim_AOI, collapse = " x ")))
print(paste("Dimensions du raster pop_5km_binary : ", paste(dim_pop, collapse = " x ")))
print(unique(values(pop_resampled_binary))) 
print(unique(values(AOI_Raster_binaire))) 

#FAISONS ACTUELLEMENT LA MULTIPLICATION
mult_raster <- AOI_Raster_binaire * pop_resampled_binary
# Vérifier un résumé des valeurs du raster résultant
summary(values(mult_raster))

##           4- Calculer par admin, du CDI

################### AU NIVEAU DES REGIONS
shp_region <- st_read("DONNEES_MALI/mli_admbnda_adm1_1m_gov_20211220.shp", quiet= TRUE)
# Calculer le nombre de 1 dans le raster binarisé pour chaque zone administrative
pop_count <- extract(pop_resampled_binary, shp_region, fun = sum, na.rm = TRUE)
print(pop_count)
# Calculer le nombre de 1 dans le raster produit pour chaque zone administrative
prod_count <- extract(mult_raster, shp_region, fun = sum, na.rm = TRUE)
print(prod_count)
# Calculer le CDI pour chaque zone administrative
CDI <- prod_count / pop_count
# Afficher les résultats
data.frame(Admin = shp_region$ADM1_FR, CDI = CDI)
# Visualisation
# Joindre les valeurs du CDI à la carte des régions
shp_region$CDI <- CDI
shp_region_utm <- st_transform(shp_region, crs = 32629)
ggplot(data = shp_region_utm) +
  geom_sf(aes(fill = CDI), color = "white", size = 0.2) +  # Remplir selon CDI
  scale_fill_viridis_c(option = "C", na.value = "gray") +  # Couleur pour les CDI, gérer les NA en mettant le gris
  labs(title = "Carte du CDI par Région", fill = "CDI") +
  geom_sf_text(aes(label = ADM1_FR), size = 3, color = "black", fontface = "bold") +
  annotation_north_arrow(location = "tl", which_north = "true", height = unit(1, "cm"), width = unit(1, "cm")) +
  theme_minimal() +
  theme(legend.position = "right",  
        legend.title = element_text(size = 10),
        legend.text = element_text(size = 8)) +
  guides(fill = guide_colorbar(title = "CDI", title.position = "top", title.hjust = 0.5, barheight = 10))

################### AU NIVEAU DU PAYS 
shp_pays <- st_read("DONNEES_MALI/mli_admbnda_adm0_1m_gov_20211220.shp", quiet= TRUE)
pop_count <- extract(pop_resampled_binary, shp_pays, fun = sum, na.rm = TRUE)
print(pop_count)
prod_count <- extract(mult_raster, shp_pays, fun = sum, na.rm = TRUE)
print(prod_count)
CDI <- prod_count / pop_count
data.frame(Admin = shp_pays$ADM0_FR, CDI = CDI) ## 0.007487653

################### AU NIVEAU DU DEPARTEMENT 
shp_departement <- st_read("DONNEES_MALI/mli_admbnda_adm2_1m_gov_20211220.shp", quiet= TRUE)
pop_count <- extract(pop_resampled_binary, shp_departement, fun = sum, na.rm = TRUE)
print(pop_count)
prod_count <- extract(mult_raster, shp_departement, fun = sum, na.rm = TRUE)
print(prod_count)
CDI <- prod_count / pop_count
data.frame(Admin = shp_departement$ADM2_FR, CDI = CDI)
