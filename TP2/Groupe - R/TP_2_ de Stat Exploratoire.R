#====================================================================================#
#     ENSAE Pierre NDIAYE de Dakar ISE1-Cycle long 2024-2025                         #
#     COURS DE Statistique exploratoire spaciale       avec M.Aboubacre HEMA         #
#    Devoir de maison de la séance 2 : Cours du vendredi 18 octobre 2024             #
#                                                                                    #
#    Groupe : Logiciel R                                                             #
#    Pays : Burkina Faso                                                             #
#    Composé de : Ange Emilson Rayan RAHERINASOLO, Khadidiatou DIAKHATE, Alioune     #
#                 Abdou Salam KANE et Awa DIAW                                       #
#                                                                                    #
#====================================================================================#

#                          ============== CONSIGNE =================

#Section 1 : Données vectorielles
# 1. Importation des données
# 2. Calculs de statistiques
# a. Nombre de géométries par niveau
# b. Projection et Système de Référence de Coordonnées (CRS)
# c. Etendue (longitude et latitude min/max)
# d. Centroides ( déjà calculer pour chaque niveau durant le tp1)
# e. Aire et Périmètre
# 3. Visualisation : Afficher les données vectorielles

#Section 2 : Données raster
# 1. Importer et visualiser 5 images raster
# 2. Calculs de statistiques
# a. Moyenne
# b. Médiane
# c. Ecart-type
# d. Minimum et maximum
# e. Retourner une seule image

#                        ==============             =================


#Section 1 : Données vectorielles

# 1. Importation des données shapefile pour les régions du Burkina Faso

# Charger les bibliothèques nécessaires
library(sf)
library(dplyr)
library(ggplot2)

# Définir le chemin de base pour éviter la répétition
chemin_acces <- "C:/Users/ALIOUNE KANE/Downloads/ENSAE/ISEP3/Statistiques exploratoire et spatiale/bfa_adm_igb_20200323_shp/"

# Importer les shapefiles
burkinafaso <- st_read(paste0(chemin_acces, "bfa_admbnda_adm0_igb_20200323.shp"))
regionbf <- st_read(paste0(chemin_acces, "bfa_admbnda_adm1_igb_20200323.shp"))
provincebf <- st_read(paste0(chemin_acces, "bfa_admbnda_adm2_igb_20200323.shp"))
communebf <- st_read(paste0(chemin_acces, "bfa_admbnda_adm3_igb_20200323.shp"))


# 2. Calculs de statistiques

# a. Nombre de géométries par niveau


# Les géométries représentent la forme et la position des entités géographiques (point, ligne, polygone).
# Dans chaque shapefile, chaque ligne correspond à une entité géographique, et la colonne "geometry"
# contient la forme de cette entité. Le nombre de géométries est le nombre total d'entités géographiques.

# Calculer et afficher le nombre de géométries par niveau
print(paste("Nombre de géométries pour le Burkina Faso (niveau pays) :", nrow(burkinafaso)))
print(paste("Nombre de géométries pour les régions du Burkina Faso :", nrow(regionbf)))
print(paste("Nombre de géométries pour les provinces du Burkina Faso :", nrow(provincebf)))
print(paste("Nombre de géométries pour les communes du Burkina Faso :", nrow(communebf)))


# b. Projection et Système de Référence de Coordonnées (CRS)

# Afficher la projection et le système de référence de coordonnées (CRS) pour chaque shapefile
print("Projection et Système de Référence de Coordonnées (CRS) :")
print(paste("CRS pour le Burkina Faso (niveau pays) :", st_crs(burkinafaso)$proj4string))
print(paste("CRS pour les régions du Burkina Faso :", st_crs(regionbf)$proj4string))
print(paste("CRS pour les provinces du Burkina Faso :", st_crs(provincebf)$proj4string))
print(paste("CRS pour les communes du Burkina Faso :", st_crs(communebf)$proj4string))


# c. Etendue (longitude et latitude min/max)

# Calculer et afficher l'étendue (longitude et latitude min/max) pour chaque shapefile sous forme de data frame
etendue_burkinafaso <- data.frame(
  Coordonnée = c("xmin", "xmax", "ymin", "ymax"),
  Valeur = c(st_bbox(burkinafaso)["xmin"], st_bbox(burkinafaso)["xmax"], st_bbox(burkinafaso)["ymin"], st_bbox(burkinafaso)["ymax"])
)
print("Étendue pour le Burkina Faso (niveau pays) :")
print(etendue_burkinafaso)

etendue_regionbf <- data.frame(
  Coordonnée = c("xmin", "xmax", "ymin", "ymax"),
  Valeur = c(st_bbox(regionbf)["xmin"], st_bbox(regionbf)["xmax"], st_bbox(regionbf)["ymin"], st_bbox(regionbf)["ymax"])
)
print("Étendue pour les régions du Burkina Faso :")
print(etendue_regionbf)

etendue_provincebf <- data.frame(
  Coordonnée = c("xmin", "xmax", "ymin", "ymax"),
  Valeur = c(st_bbox(provincebf)["xmin"], st_bbox(provincebf)["xmax"], st_bbox(provincebf)["ymin"], st_bbox(provincebf)["ymax"])
)
print("Étendue pour les provinces du Burkina Faso :")
print(etendue_provincebf)

etendue_communebf <- data.frame(
  Coordonnée = c("xmin", "xmax", "ymin", "ymax"),
  Valeur = c(st_bbox(communebf)["xmin"], st_bbox(communebf)["xmax"], st_bbox(communebf)["ymin"], st_bbox(communebf)["ymax"])
)
print("Étendue pour les communes du Burkina Faso :")
print(etendue_communebf)



# d. Calcul des centroides

# Calculer et afficher les centroides pour chaque niveau administratif
centroides_burkinafaso <- st_centroid(burkinafaso)
print("Centroides pour le Burkina Faso (niveau pays) :")
print(centroides_burkinafaso)

centroides_regionbf <- st_centroid(regionbf)
print("Centroides pour les régions du Burkina Faso :")
print(centroides_regionbf)

centroides_provincebf <- st_centroid(provincebf)
print("Centroides pour les provinces du Burkina Faso :")
print(centroides_provincebf)

centroides_communebf <- st_centroid(communebf)
print("Centroides pour les communes du Burkina Faso :")
print(centroides_communebf)


# e. Calcul de l'aire et du périmètre

# Calculer et organiser les résultats pour chaque région, province, et commune avec Aire et Périmètre
# Vérifier et caster le type de géométrie si nécessaire
if (!all(st_geometry_type(regionbf) == "MULTIPOLYGON")) {
  regionbf <- st_cast(regionbf, "MULTIPOLYGON")
}
if (!all(st_geometry_type(provincebf) == "MULTIPOLYGON")) {
  provincebf <- st_cast(provincebf, "MULTIPOLYGON")
}
if (!all(st_geometry_type(communebf) == "MULTIPOLYGON")) {
  communebf <- st_cast(communebf, "MULTIPOLYGON")
}

# Calcul de l'aire et du périmètre
burkinafaso$area <- st_area(burkinafaso)
burkinafaso$perimeter <- st_length(st_boundary(burkinafaso))
glimpse(burkinafaso$area)
glimpse(burkinafaso$perimeter)


regionbf$area <- st_area(regionbf)
regionbf$perimeter <- st_length(st_boundary(regionbf))
glimpse(regionbf$area)
glimpse(regionbf$perimeter)

provincebf$area <- st_area(provincebf)
provincebf$perimeter <- st_length(st_boundary(provincebf))
glimpse(provincebf$area)
glimpse(provincebf$perimeter)

communebf$area <- st_area(communebf)
communebf$perimeter <- st_length(st_boundary(communebf))
glimpse(communebf$area)
glimpse(communebf$perimeter)

# Créer des tableaux pour les résultats
resultats_regionbf <- data.frame(
  region =regionbf$ADM1_FR,
  Aire = round(as.numeric(regionbf$area), 2),
  Perimetre = round(as.numeric(regionbf$perimeter), 2)
)
print("Aire et périmètre pour les régions du Burkina Faso :")
print(resultats_regionbf)


resultats_provincebf <- data.frame(
  Province = provincebf$ADM2_FR,
  Aire = round(as.numeric(provincebf$area), 2),
  Perimetre = round(as.numeric(provincebf$perimeter), 2)
)
print("Aire et périmètre pour les provinces du Burkina Faso :")
print(resultats_provincebf)


resultats_communebf <- data.frame(
  Commune = communebf$ADM3_FR,
  Aire = round(as.numeric(communebf$area), 2),
  Perimetre = round(as.numeric(communebf$perimeter), 2)
)
print("Aire et périmètre pour les communes du Burkina Faso :")
print(resultats_communebf)


# f. Affichage des données vectorielles

# Afficher les shapefiles en utilisant ggplot2
# CODE MODIFIE. Version du TP3 améliorée avec des éléments de carte : flèche du nord et légende
# CODE MODIFIE. Version du TP3 améliorée avec des éléments de carte : flèche du nord et légende
# CODE MODIFIE. Version du TP3 améliorée avec des éléments de carte : flèche du nord et légende


# Rechargeons les packages ggplot2 and ggspatial
library(ggplot2)
library(ggspatial)

print("Affichons les vecteurs :")
ggplot() +
  # Burkina Faso
  geom_sf(data = burkinafaso, fill = "lightblue", color = "black", alpha = 0.5, show.legend = TRUE, 
          aes(fill = "Carte au niveau zéro")) +
  
  # Régions
  geom_sf(data = regionbf, fill = NA, color = "red", show.legend = TRUE, 
          aes(color = "Carte au niveau un")) +
  
  # Provinces
  geom_sf(data = provincebf, fill = NA, color = "green", show.legend = TRUE, 
          aes(color = "Carte au niveau deux")) +
  
  # Communes
  geom_sf(data = communebf, fill = NA, color = "blue", show.legend = TRUE, 
          aes(color = "Carte au niveau trois")) +
  
  # Ajout d'éléments de carte
  ggtitle("Carte du Burkina Faso suivant 4 niveaux administratifs") +
  
  theme_minimal() +
  
  annotation_north_arrow(location = "topright", which_north = "true",  # Flèche du nord 
                         style = north_arrow_fancy_orienteering) +
  
  annotation_scale(location = "bottomright", bar_cols = c("grey60", "white")) +    Echelle
  
  scale_fill_manual(
    name = "Niveaux Administratifs",              # Personnalisation légende
    values = c("Pays" = "lightblue")
  ) +
  scale_color_manual(
    name = "Niveaux Administratifs",
    values = c("Régions" = "red", "Provinces" = "green", "Communes" = "blue")
  )

  theme_minimal()



#On va essayer de modifier l'étendue pour voir

# Définir une nouvelle étendue
ggplot() +
  geom_sf(data = burkinafaso) +
  coord_sf(xlim = c(-3, 3), ylim = c(10, 20)) # Modifier ces valeurs selon ton besoin

#Réimporter la base pour avoir l'étendue originale
burkinafaso <- st_read(paste0(chemin_acces, "bfa_admbnda_adm0_igb_20200323.shp"))

#Section 2 : Données raster


# Charger la bibliothèque nécessaire
library(raster)
library(sp)
library(leaflet)

# Dossier contenant le raster
chemin_acces <- "C:/Users/ALIOUNE KANE/Downloads/Stage ANSD/Statistique Exploratoire et Spatiale/Abson-dev Statistique-Exploratoire-Spatiale main TP2-data_Malaria_Burkina"

# Lister tous les fichiers raster dans le dossier avec l'extension .tiff
fichiers_raster <- list.files(chemin_acces, pattern = "\\.(tiff)$", full.names = TRUE)


# Charger tous les rasters en tant que stack
rasters <- stack(fichiers_raster)
print("Stack des rasters chargés :")
print(rasters)

# Visualiser les fichiers raster un par un
for (fichier in fichiers_raster) {
  raster_obj <- raster(fichier)
  print(paste("Visualisation de :", fichier))
  
  # Visualiser le raster
  plot(raster_obj, main = paste("Visualisation de :", basename(fichier)))
  
  # Pause pour permettre à l'utilisateur de voir chaque raster avant de continuer
  readline(prompt = "Appuyez sur Entrée pour voir le fichier suivant...")
}



# 2. Calculs de statistiques (en ignorant les NA)
# a. Moyenne
mean_raster <- calc(rasters, fun = mean, na.rm = TRUE)
print("Moyenne calculée :")
print(mean_raster)

# b. Médiane
median_raster <- calc(rasters, fun = median, na.rm = TRUE)
print("Médiane calculée :")
print(median_raster)

# c. Ecart-type
sd_raster <- calc(rasters, fun = sd, na.rm = TRUE)
print("Ecart-type calculé :")
print(sd_raster)

# d. Minimum et maximum
min_raster <- calc(rasters, fun = min, na.rm = TRUE)
print("Minimum calculé :")
print(min_raster)

max_raster <- calc(rasters, fun = max, na.rm = TRUE)
print("Maximum calculé :")
print(max_raster)

# Fonction pour créer une carte interactive avec leaflet
create_interactive_map <- function(raster_layer, title) {
  # Convertir le raster en SpatialPixelsDataFrame pour leaflet
  raster_spdf <- as(raster_layer, "SpatialPixelsDataFrame")
  
  # Créer un data frame à partir du raster pour leaflet
  raster_df <- as.data.frame(raster_spdf)
  colnames(raster_df) <- c("value", "x", "y")
  
  # Créer la carte avec leaflet
  leaflet() %>%
    addTiles() %>%
    addCircleMarkers(data = raster_df, lng = ~x, lat = ~y, radius = 2,
                     color = ~ifelse(is.na(value), "transparent", "blue"),
                     fillOpacity = 0.5, stroke = FALSE) %>%
    addLegend("bottomright", title = title, values = raster_df$value,
              pal = colorNumeric(palette = "viridis", domain = raster_df$value),
              na.label = "NA") %>%
    setView(lng = mean(raster_df$x, na.rm = TRUE), lat = mean(raster_df$y, na.rm = TRUE), zoom = 6)
}

# a. Visualisation interactive de la moyenne
create_interactive_map(mean_raster, "Moyenne des Rasters")

# b. Visualisation interactive de la médiane
create_interactive_map(median_raster, "Médiane des Rasters")

# c. Visualisation interactive de l'écart-type
create_interactive_map(sd_raster, "Ecart-Type des Rasters")

# d. Visualisation interactive du minimum
create_interactive_map(min_raster, "Minimum des Rasters")

# e. Visualisation interactive du maximum
create_interactive_map(max_raster, "Maximum des Rasters")
