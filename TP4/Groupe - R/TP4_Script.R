# -------------------------------------------------------------
# ----------TP4 Statistique exploratoire spatiale--------------
# Script R : classification_multi_classes
# Objectif : Classifier un raster en trois classes (Aucun, Moyen, Grave)
#            basées sur la moyenne et l'écart type, puis visualiser
#            sur une carte.
# Membres du groupe :
#   - Mame Balla BOUSSO
#   - Ameth FAYE
#   - Hiledegarde EDIMA Biyenda 
#   - Papa Amadou NIANG
# -------------------------------------------------------------

# -------------------------------------------------------------
# Étape 1 : Charger les packages nécessaires
# -------------------------------------------------------------

# Charger les packages
library(raster)
library(leaflet)

# -------------------------------------------------------------
# Étape 2 : Importer les rasters
# -------------------------------------------------------------

# Dossier contenant les rasters
dossier <- "D:/Statistique exploratoire spatiale/Cours2/Statistique-Exploratoire-Spatiale/TP2/data/Malaria/Senegal"

# Lister tous les fichiers raster dans le dossier avec les extensions .tiff
fichiers_raster <- list.files(dossier, pattern = "\\.(tiff)$", full.names = TRUE)

# Rasters cibles
raster_2020 <- raster(fichiers_raster[21])
raster_2021 <- raster(fichiers_raster[22])
raster_2022 <- raster(fichiers_raster[23])

# -------------------------------------------------------------
# Étape 3 : Calculer la moyenne et l'écart type
# -------------------------------------------------------------

# Charger tous les rasters en tant que stack
rasters <- stack(fichiers_raster)

# Calcul de l'image moyenne
moy_raster <- calc(rasters, fun = mean, na.rm = TRUE)

# Calcul de l'image écart type
ecrt_raster <- calc(rasters, fun = sd, na.rm = TRUE)

# ------------------------------------------------------------
# Étape 4 : Définir les seuils de classification
# ------------------------------------------------------------

# Définir les seuils basés sur la moyenne et l'écart type

# Moyenne + 1 * Écart Type
seuil1 <- moy_raster + ecrt_raster  

# Moyenne + 2 * Écart Type
seuil2 <- moy_raster + 2 * ecrt_raster    

# -----------------------------------------------------------
# ------Initialisation de la fonction de classification------
# -----------------------------------------------------------

Classification_par_niveau <- function(raster){

# ------------------------------------------------------------
# Étape 5 : Classifier les pixels selon les conditions
# ------------------------------------------------------------

# Classification des pixels suivants leurs valeurs
class_raster <- overlay(raster, moy_raster, ecrt_raster, fun = function(x, m, s) {
  ifelse(x <= (m + s), 1,
         ifelse(x < (m + 2 * s), 2, 3))
})

# ------------------------------------------------------------
# Étape 6 : Attribuer des couleurs aux classes
# ------------------------------------------------------------

# Définir les couleurs pour les classes
couleurs <- c("green", "yellow", "red","transparent")

# Créer une palette de couleurs basée sur les classes
palette_couleurs <- colorFactor(palette = couleurs, levels = c(1, 2, 3,NA))

# ------------------------------------------------------------
# Étape 7 : Visualiser le raster classifié sur une carte
# ------------------------------------------------------------

carte <- leaflet() %>%
  addTiles() %>%
  
  addRasterImage(class_raster, 
                 colors = palette_couleurs, 
                 opacity = 0.6) %>%
  
  addLegend(position = "bottomright", 
            pal = palette_couleurs, 
            values = values(class_raster),
            title = "Classification par niveau de gravité",
            labels = c("Aucun", 
                       "Moyen", 
                       "Grave"))

# Retourner la carte
return(carte)

}

# Classification pour l'année 2020
class_raster_2020 <- Classification_par_niveau(raster_2020)
class_raster_2020

# Classification pour l'année 2021
class_raster_2021 <- Classification_par_niveau(raster_2021)
class_raster_2021

# Classification pour l'année 2022
class_raster_2022 <- Classification_par_niveau(raster_2022)
class_raster_2022

# ----------------------------------------------------------
# -Initialisation de la fonction de classication (binnaire)-
# ----------------------------------------------------------

Classification_par_niveau_bin <- function(raster){
  
# ----------------------------------------------------------
# Étape 5 : Créer des rasters binaires pour chaque condition
# ----------------------------------------------------------
  
# Classifier le raster en trois classes
aucun <- raster <= seuil1
moyen <- (raster > seuil1) & (raster < seuil2)
grave <- raster >= seuil2
  
# Convertir les valeurs logiques (TRUE/FALSE) en numériques (1/NA)
aucun <- calc(aucun, fun = function(x) { ifelse(x, 1, NA) })
moyen <- calc(moyen, fun = function(x) { ifelse(x, 1, NA) })
grave <- calc(grave, fun = function(x) { ifelse(x, 1, NA) })
  
# ----------------------------------------------------------
# Étape 6 : Attribuer des couleurs aux rasters binaires
# ----------------------------------------------------------
  
# Créer des palettes de couleurs pour les rasters binaires
pal_vert <- colorFactor(palette = "green", na.color = "transparent", levels = c(1))
pal_jaune <- colorFactor(palette = "yellow", na.color = "transparent", levels = c(1))
pal_rouge <- colorFactor(palette = "red", na.color = "transparent", levels = c(1))
  
# ----------------------------------------------------------
# Étape 7 : Visualiser les Rasters Binaires sur une Carte
# ----------------------------------------------------------
  
carte <- leaflet() %>%
  addTiles() %>%
    
  # Ajouter le raster aucun
  addRasterImage(aucun, 
                  colors = pal_vert,
                  opacity = 0.6,
                  group = "Aucun") %>%
    
  # Ajouter le raster moyen
  addRasterImage(moyen, 
                  colors = pal_jaune, 
                  opacity = 0.6, 
                  group = "Moyen") %>%
    
  # Ajouter le raster grave
  addRasterImage(grave, 
                  colors = pal_rouge, 
                  opacity = 0.6,
                  group = "Grave") %>%
    
  # Ajouter des contrôles de couches pour activer/désactiver chaque raster binaire
  addLayersControl(
    overlayGroups = c("Aucun", "Moyen", "Grave"),
    options = layersControlOptions(collapsed = FALSE)
  ) %>%
    
  # Ajouter une légende
  addLegend("bottomright", 
            colors = c("green", "yellow", "red"), 
            labels = c("Aucun", 
                        "Moyen", 
                        "Grave"),
            title = "Classification",
            opacity = 1)
  
# Retourner la carte
return(carte)
  
}

# Classification pour l'année 2020
class_raster_2020 <- Classification_par_niveau_bin(raster_2020)
class_raster_2020

# Classification pour l'année 2021
class_raster_2021 <- Classification_par_niveau_bin(raster_2021)
class_raster_2021

# Classification pour l'année 2022
class_raster_2022 <- Classification_par_niveau_bin(raster_2022)
class_raster_2022

# ---------------------------
# Fin du Script
# ---------------------------