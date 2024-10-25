# ==========================================================================================================================
# Projet : Analyse spatiale du paludisme au Sénégal
# Présentation : TP3 statistique exploratoire spatiale
# Membres du Groupe :
#   - Mame Balla BOUSSO
#   - Ameth FAYE
#   - Hiledegarde Edima Biyenda 
#   - Papa Amadou NIANG
# Établissement : Nom de l'établissement
# Date : Octobre 2024
# Objectif : Analyser le taux moyen du paludisme à travers les régions, départements, et communes du Sénégal
# Bibliothèques Utilisées : raster, dplyr, sf, exactextractr, ggplot2, ggspatial, viridis, leaflet
# =========================================================================================================================


# Charger les bibliothèques nécessaires
library(ggplot2)      # Visualisation
library(sf)           # Manipulation des données spatiales
library(exactextractr) # Extraction pondérée des valeurs raster
library(dplyr)        # Manipulation de données
library(ggspatial)    # Ajout de flèche de nord et échelle
library(viridis)      # Palette de couleurs
library(raster)       # Manipulation des rasters
library(leaflet)      # Visualisation avec openstreetmap

# Dossier contenant le raster
chemin_dossier <- "D:/Statistique exploratoire spatiale/Cours2/Statistique-Exploratoire-Spatiale/TP2/data/Malaria/Senegal"

# Lister tous les fichiers raster dans le dossier avec l'extension .tiff
fichiers_raster <- list.files(chemin_dossier, pattern = "\\.(tiff)$", full.names = TRUE)

# Charger les shapefiles des régions et des départements
regions <- st_read("D:/Statistique exploratoire spatiale/Cours2/Statistique-Exploratoire-Spatiale/TP1 Importation et visualition des donnees spatiales/data/Shapefiles/Senegal/sen_admbnda_adm1_anat_20240520.shp")      # Remplacez par le chemin réel
departments <- st_read("D:/Statistique exploratoire spatiale/Cours2/Statistique-Exploratoire-Spatiale/TP1 Importation et visualition des donnees spatiales/data/Shapefiles/Senegal/sen_admbnda_adm2_anat_20240520.shp") # Remplacez par le chemin réel
communes <- st_read("D:/Statistique exploratoire spatiale/Cours2/Statistique-Exploratoire-Spatiale/TP1 Importation et visualition des donnees spatiales/data/Shapefiles/Senegal/sen_admbnda_adm3_anat_20240520.shp") # Remplacez par le chemin réel

# Charger tous les rasters en tant que stack
rasters <- stack(fichiers_raster)

# Image Moyenne
mean_raster <- calc(rasters, fun = mean, na.rm = TRUE)

# Calculer la moyenne pondérée par région
region_means <- exact_extract(mean_raster, regions, 'mean')
regions <- regions %>%
  mutate(mean_index = region_means)

# Calculer la moyenne pondérée par département
department_means <- exact_extract(mean_raster, departments, 'mean')
departments <- departments %>%
  mutate(mean_index = department_means)

# Calculer la moyenne pondérée par département
communes_means <- exact_extract(mean_raster, communes, 'mean')
communes <- communes %>%
  mutate(mean_index = communes_means)

# Créer la carte des régions
carte_regions <- ggplot(data = regions) +
  geom_sf(aes(fill = mean_index), color = "white", size = 0.2) + # Affiche les polygones avec une bordure blanche
  scale_fill_viridis(name = "Taux moyen de Paludisme par région", na.value = "grey50") + # Palette de couleurs
  theme_minimal() + # Thème minimaliste
  labs(title = "Taux moyen de Paludisme par région") + # Titre de la carte
  theme(
    plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
    legend.title = element_text(size = 12),
    legend.text = element_text(size = 10)
  ) +
  annotation_scale(location = "bl", width_hint = 0.3) + # Échelle en bas à gauche
  annotation_north_arrow(location = "bl", which_north = "true",
                         pad_x = unit(0.75, "in"), pad_y = unit(0.5, "in"),
                         style = north_arrow_fancy_orienteering) # Flèche de nord

# Afficher la carte des régions
print(carte_regions)

# Visualisation avec Openstreetmap pour les régions
map_regions <- leaflet(regions) %>%
  addTiles() %>%
  addPolygons(fillColor = ~colorNumeric("viridis", regions$mean_index)(mean_index),
              fillOpacity = 0.7, color = "white", weight = 2) %>%
  addLegend("bottomright", pal = colorNumeric("viridis", regions$mean_index),
            values = regions$mean_index, title = "Taux moyen de Paludisme par région") %>%
  setView(lng = mean(st_coordinates(regions)[, 1]), lat = mean(st_coordinates(regions)[, 2]), zoom = 6)

# Afficher la carte des régions
print(map_regions)

# Créer la carte des départements
carte_departments <- ggplot(data = departments) +
  geom_sf(aes(fill = mean_index), color = "white", size = 0.2) + # Affiche les polygones avec une bordure blanche
  scale_fill_viridis(name = "Taux moyen de Paludisme par departments ", na.value = "grey50") + # Palette de couleurs
  theme_minimal() + # Thème minimaliste
  labs(title = "Taux moyen de Paludisme par departments") + # Titre de la carte
  theme(
    plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
    legend.title = element_text(size = 12),
    legend.text = element_text(size = 10)
  ) +
  annotation_scale(location = "bl", width_hint = 0.3) + # Échelle en bas à gauche
  annotation_north_arrow(location = "bl", which_north = "true",
                         pad_x = unit(0.75, "in"), pad_y = unit(0.5, "in"),
                         style = north_arrow_fancy_orienteering) # Flèche de nord

# Afficher la carte des départements
print(carte_departments)

# Visualisation avec Openstreetmap pour les régions
map_departements <- leaflet(departments) %>%
  addTiles() %>%
  addPolygons(fillColor = ~colorNumeric("viridis", departments$mean_index)(mean_index),
              fillOpacity = 0.7, color = "white", weight = 2) %>%
  addLegend("bottomright", pal = colorNumeric("viridis", departments$mean_index),
            values = departments$mean_index, title = "Taux moyen de Paludisme par département") %>%
  setView(lng = mean(st_coordinates(departments)[, 1]), lat = mean(st_coordinates(departments)[, 2]), zoom = 6)

# Afficher la carte des départements
print(map_departements)

# Créer la carte des départements
carte_communes <- ggplot(data = communes) +
  geom_sf(aes(fill = mean_index), color = "white", size = 0.2) + # Affiche les polygones avec une bordure blanche
  scale_fill_viridis(name = "Taux moyen de Paludisme par communes", na.value = "grey50") + # Palette de couleurs
  theme_minimal() + # Thème minimaliste
  labs(title = "Taux moyen de Paludisme par communes") + # Titre de la carte
  theme(
    plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
    legend.title = element_text(size = 12),
    legend.text = element_text(size = 10)
  ) +
  annotation_scale(location = "bl", width_hint = 0.3) + # Échelle en bas à gauche
  annotation_north_arrow(location = "bl", which_north = "true",
                         pad_x = unit(0.75, "in"), pad_y = unit(0.5, "in"),
                         style = north_arrow_fancy_orienteering) # Flèche de nord

# Afficher la carte des communes
print(carte_communes)

# Visualisation avec Openstreetmap pour les communes
map_communes <- leaflet(communes) %>%
  addTiles() %>%
  addPolygons(fillColor = ~colorNumeric("viridis", communes$mean_index)(mean_index),
              fillOpacity = 0.7, color = "white", weight = 2) %>%
  addLegend("bottomright", pal = colorNumeric("viridis", communes$mean_index),
            values = communes$mean_index, title = "Taux moyen de Paludisme par communes") %>%
  setView(lng = mean(st_coordinates(communes)[, 1]), lat = mean(st_coordinates(communes)[, 2]), zoom = 6)

# Afficher la carte des communes
print(map_communes)