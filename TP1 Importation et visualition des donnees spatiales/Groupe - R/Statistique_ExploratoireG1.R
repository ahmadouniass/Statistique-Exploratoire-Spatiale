#====================================================================================#
#     ENSAE Pierre NDIAYE de Dakar ISE1-Cycle long 2024-2025                         #
#     COURS DE Statistique exploratoire spaciale       avec M.Aboubacre HEMA         #
#    Devoir de maison de la séance 1 : cours du vendredi 11 octobre 2024             #
#                                                                                    #
#    Groupe : Logiciel R                                                             #
#    Composé de : Ange Emilson Rayan RAHERINASOLO, Khadidiatou DIAKHATE, Alioune     #
#                 Abdou Salam KANE et Awa DIAW                                       #
#                                                                                    #
#====================================================================================#

#                          ============== CONSIGNE =================

#Comment installer les shapefile et raster ?
#1.	Importer les données au niveau des différents logiciels
#2.	Améliorer la visualisation
#                        ==============             =================

# Le Burkina Faso (ici, adm0) est subdivisé en 13 régions administratives et 
# territoriales (ici, adm1), elles-mêmes divisées administrativement en 45 
# provinces et en départements (ici, adm2), ou territorialement en communes 
# 34 urbaines ou 306 rurales (adm3).

#==============   Etape 1  =================#

# I. Installation des packages nécessaires
install.packages("stars")      # Pour la manipulation des données raster et vecteur
install.packages("sf")         # Pour la manipulation des objets géospatiaux
install.packages("ggplot2")    # Pour les visualisations graphiques
install.packages("ggspatial")  # Pour ajouter des éléments cartographiques comme la flèche du nord et l'échelle
install.packages("raster")     # Pour la manipulation des données raster
install.packages("cowplot")    # Pour extraire la légende et afficher la carte sans légende
install.packages("leaflet")    #   Pour avoir une carte interactive  en ajoutant les limites administratives
install.packages("viridis")   # Pour la palette de couleurs viridis
install.packages("units")  # Facultatif, mais utile pour éviter des erreurs liées aux unités spatiales



# II. Chargement des bibliothèques nécessaires
library(stars)
library(sf)
library(ggplot2)
library(ggspatial) 
library(raster)
library(cowplot)
library(leaflet)
library(viridis)    # Pour la palette de couleurs viridis



# III. Lecture des fichiers shapefiles
burkinafaso<- st_read("C:/Users/ALIOUNE KANE/Downloads/ENSAE/ISEP3/Statistiques exploratoire et spatiale/bfa_adm_igb_20200323_shp/bfa_admbnda_adm0_igb_20200323.shp")
regionbf <- st_read("C:/Users/ALIOUNE KANE/Downloads/ENSAE/ISEP3/Statistiques exploratoire et spatiale/bfa_adm_igb_20200323_shp/bfa_admbnda_adm1_igb_20200323.shp")
provincebf <- st_read("C:/Users/ALIOUNE KANE/Downloads/ENSAE/ISEP3/Statistiques exploratoire et spatiale/bfa_adm_igb_20200323_shp/bfa_admbnda_adm2_igb_20200323.shp")
communebf <- st_read("C:/Users/ALIOUNE KANE/Downloads/ENSAE/ISEP3/Statistiques exploratoire et spatiale/bfa_adm_igb_20200323_shp/bfa_admbnda_adm3_igb_20200323.shp")
#st_read() est une fonction du package sf

#==============   FIN Etape 1  =================#


#==============   Etape 2  =================#

#1- Représentation de la carte du Burkina Faso simplement 

#1-a- Simple

# Carte du Burkina Faso
# Affichage de la carte simple
ggplot() + 
  geom_sf(data = burkinafaso, mapping = aes(color = ADM0_FR)) +
  ggtitle("Carte des Régions du Burkina Faso")  # Titre pour l'affichage rapide des régions


#1-b Avec  Fléche du nord, échelle et titre
ggplot() + 
  geom_sf(data = burkinafaso, mapping = aes(color = ADM0_FR)) + 
  ggtitle("Carte du Burkina Faso au niveau national") +  # Titre de la carte
  theme(plot.title = element_text(hjust = 0.5, size = 25)) + 
  xlab("Longitude") + 
  ylab("Latitude") + 
  annotation_north_arrow(location = "bl", which_north = "true", pad_x = unit(0.25, "in"), pad_y = unit(0.25, "in"), style = north_arrow_fancy_orienteering()) + 
  annotation_scale(location = "bl", width_hint = 0.5)


#2- Représentation de la carte du Brukina Faso  au niveau région

#2-a- Simple

# Carte des limites des régions avec  selon ADM1_FR
# Affichage rapide des limites des régions avec coloration
ggplot() + 
  geom_sf(data = regionbf, mapping = aes(fill = ADM1_FR)) +  # Colorer chaque région
  ggtitle("Carte des Régions du Burkina Faso") + 
  scale_fill_viridis_d(option = "plasma")  # Palette de couleurs pour différencier les régions

#2-b Avec Labels + Fléche du nord + échelle + source
ggplot() + 
  geom_sf(data = regionbf, mapping = aes(fill = ADM1_FR)) +  # Colorer chaque région selon ADM1_FR
  ggtitle("Carte des Régions du Burkina Faso") +  # Titre de la carte des régions
  theme(plot.title = element_text(hjust = 0.5, size = 25)) + 
  xlab("Longitude") + 
  ylab("Latitude") + 
  annotation_north_arrow(location = "bl", which_north = "true", pad_x = unit(0.25, "in"), pad_y = unit(0.25, "in"), style = north_arrow_fancy_orienteering()) + 
  annotation_scale(location = "bl", width_hint = 0.5) + 
  scale_fill_viridis_d(option = "plasma")  # Utilisation d'une palette de couleurs distinctes pour chaque région



# Calculer les centroïdes pour positionner les labels au centre des régions
centroids <- st_centroid(regionbf)

# Créer la carte avec la légende
carte_avec_legende <- ggplot() + 
  geom_sf(data = regionbf, mapping = aes(fill = ADM1_FR)) +  # Colorer chaque région selon ADM1_FR
  ggtitle("Carte des Régions du Burkina Faso") +  # Titre de la carte des régions
  theme(plot.title = element_text(hjust = 0.5, size = 18),  # Taille du titre réduite
        legend.position = "right") +  # Position temporaire de la légende pour l'extraire
  xlab("Longitude") + 
  ylab("Latitude") + 
  geom_sf_text(data = centroids, aes(label = ADM1_FR), size = 3, color = "black", fontface = "bold") +  # Labels avec taille ajustée
  annotation_north_arrow(location = "bl", which_north = "true", pad_x = unit(0.25, "in"), pad_y = unit(0.25, "in"), style = north_arrow_fancy_orienteering()) +  # Flèche du nord
  annotation_scale(location = "bl", width_hint = 0.5) +  # Échelle
  scale_fill_viridis_d(option = "plasma")  # Palette de couleurs distinctes pour chaque région

# Extraire la légende
legende <- get_legend(carte_avec_legende)

# Créer une carte sans légende, mais avec la flèche du nord, l'échelle et les labels
carte_sans_legende <- ggplot() + 
  geom_sf(data = regionbf, mapping = aes(fill = ADM1_FR)) +  # Colorer chaque région selon ADM1_FR
  ggtitle("Carte des Régions du Burkina Faso") +  # Titre de la carte
  theme(plot.title = element_text(hjust = 0.5, size = 18),  # Taille du titre réduite
        legend.position = "none",  # Retirer la légende pour maximiser l'espace
        axis.text = element_blank(),
        axis.ticks = element_blank(),
        axis.title = element_blank(),
        panel.grid = element_blank(),
        plot.margin = margin(0, 0, 0, 0)) +  # Réduire les marges au minimum
  geom_sf_text(data = centroids, aes(label = ADM1_FR), size = 3, color = "black", fontface = "bold") +  # Labels ajustés
  annotation_north_arrow(location = "bl", which_north = "true", pad_x = unit(0.25, "in"), pad_y = unit(0.25, "in"), style = north_arrow_fancy_orienteering()) +  # Flèche du nord
  annotation_scale(location = "bl", width_hint = 0.5) +  # Échelle
  scale_fill_viridis_d(option = "plasma")  # Palette de couleurs

# Afficher la carte sans légende avec les labels, la flèche du nord et l'échelle
print(carte_sans_legende)

# Afficher la légende séparément
plot_grid(legende)


#3- Représentation de la carte du Brukina Fasso  au niveau commune 


#3-1- Simple 

# Créer la carte avec la légende et ajuster la taille du titre, sans flèche du nord
carte_avec_legende <- ggplot() + 
  geom_sf(data = provincebf, aes(fill = ADM2_FR), color = "black", size = 0.2) +  # Colorer selon ADM2_FR avec bordures noires
  ggtitle("Carte des communebfs du Burkina Faso") +  # Titre de la carte
  theme(plot.title = element_text(hjust = 0.5, size = 15),  # Taille de la police du titre réduite
        legend.position = "right") +  # Position temporaire de la légende pour l'extraire
  xlab("Longitude") + 
  ylab("Latitude") + 
  scale_fill_viridis_d(option = "plasma")  # Utilisation d'une palette distincte pour chaque commune

# Extraire la légende
legende <- get_legend(carte_avec_legende)

# Créer une carte sans légende, sans flèche du nord
carte_sans_legende <- ggplot() + 
  geom_sf(data = provincebf, aes(fill = ADM2_FR), color = "black", size = 0.2) +  # Colorer selon ADM2_FR
  ggtitle("Carte des communebfs du Burkina Faso") +  # Titre de la carte
  theme(plot.title = element_text(hjust = 0.5, size = 15),  # Taille de la police du titre réduite
        legend.position = "none",  # Supprimer la légende pour maximiser l'espace
        axis.text = element_blank(),
        axis.ticks = element_blank(),
        axis.title = element_blank(),
        panel.grid = element_blank(),
        plot.margin = margin(0, 0, 0, 0)) +  # Réduire les marges au minimum
  scale_fill_viridis_d(option = "plasma")  # Palette de couleurs

# Afficher la carte sans légende
print(carte_sans_legende)

# Afficher la légende séparément
plot_grid(legende)



#3-2 - Avec Labels + Fléche du nord et échelle 

# Calculer les centroïdes pour positionner les labels au centre 
centroids <- st_centroid(provincebf)

# Créer la carte avec la légende, la flèche du nord, l'échelle, et les labels
carte_avec_legende <- ggplot() + 
  geom_sf(data = provincebf, aes(fill = ADM2_FR), color = "black", size = 0.2) +  # Colorer selon ADM2_FR avec bordures noires
  geom_sf_text(data = centroids, aes(label = ADM2_FR), size = 3, color = "black", fontface = "bold") +  # Ajouter les labels
  ggtitle("Carte des communebfs du Burkina Faso") +  # Titre de la carte
  theme(plot.title = element_text(hjust = 0.5, size = 15),  # Taille de la police du titre réduite
        legend.position = "right") +  # Position temporaire de la légende pour l'extraire
  xlab("Longitude") + 
  ylab("Latitude") + 
  annotation_north_arrow(location = "bl", which_north = "true", 
                         pad_x = unit(0.25, "in"), pad_y = unit(0.25, "in"), 
                         style = north_arrow_fancy_orienteering()) +  # Flèche du nord
  annotation_scale(location = "bl", width_hint = 0.5) +  # Ajouter l'échelle en bas à gauche
  scale_fill_viridis_d(option = "plasma")  # Utilisation d'une palette distincte pour chaque communebf

# Extraire la légende
legende <- get_legend(carte_avec_legende)

# Créer une carte sans légende, mais avec l'échelle, la flèche du nord, et les labels
carte_sans_legende <- ggplot() + 
  geom_sf(data = provincebf, aes(fill = ADM2_FR), color = "black", size = 0.2) +  # Colorer selon ADM2_FR
  geom_sf_text(data = centroids, aes(label = ADM2_FR), size = 3, color = "black", fontface = "bold") +  # Ajouter les labels
  ggtitle("Carte des communebfs du Burkina Faso") +  # Titre de la carte
  theme(plot.title = element_text(hjust = 0.5, size = 15),  # Taille de la police du titre réduite
        legend.position = "none",  # Supprimer la légende pour maximiser l'espace
        axis.text = element_blank(),
        axis.ticks = element_blank(),
        axis.title = element_blank(),
        panel.grid = element_blank(),
        plot.margin = margin(0, 0, 0, 0)) +  # Réduire les marges au minimum
  annotation_north_arrow(location = "bl", which_north = "true", 
                         pad_x = unit(0.25, "in"), pad_y = unit(0.25, "in"), 
                         style = north_arrow_fancy_orienteering()) +  # Flèche du nord
  annotation_scale(location = "bl", width_hint = 0.5) +  # Ajouter l'échelle en bas à gauche
  scale_fill_viridis_d(option = "plasma")  # Palette de couleurs

# Afficher la carte sans légende avec la flèche du nord, l'échelle, et les labels
print(carte_sans_legende)

# Afficher la légende séparément
plot_grid(legende)


## NB : On constate que la visualisation n'est pas bonne donc il faut trouver une solution 
## NB : On constate que la visualisation n'est pas bonne donc il faut trouver une solution 
## NB : On constate qque la visualisation n'est pas bonne donc il faut trouver une solution 


#3-3 Création d'une carte interactive pour pouvoir améliorer la visualisation  qui regroupee tous les niveaux administratifs : National, régional, communebf, district


# Créer une carte interactive avec leaflet en ajoutant les limites administratives
leaflet() %>%
  addTiles() %>%  # Ajouter la couche de base (OpenStreetMap)
  
  # Ajouter les limites du Burkina Faso (administration de niveau 0 - national)
  addPolygons(data = burkinafaso, color = "blue", weight = 2, opacity = 1, fillOpacity = 0.5,
              popup = ~ADM0_FR) %>%  # Popup affichant le nom du pays
  
  # Ajouter les limites des régions (administration de niveau 1)
  addPolygons(data = regionbf, color = "green", weight = 2, opacity = 1, fillOpacity = 0.4,
              popup = ~ADM1_FR) %>%  # Popup affichant le nom des régions
  
  # Ajouter les limites des communebfs (administration de niveau 2)
  addPolygons(data = provincebf, color = "red", weight = 2, opacity = 1, fillOpacity = 0.3,
              popup = ~ADM2_FR) %>%  # Popup affichant le nom des communebfs
  
  # Ajouter les limites des districts (administration de niveau 3)
  addPolygons(data = communebf, color = "pink", weight = 2, opacity = 1, fillOpacity = 0.2,
              popup = ~ADM3_FR) %>%  # Popup affichant le nom des districts
  
  # Centrer la carte sur le Burkina Faso avec un zoom adapté
  setView(lng = -1.5336, lat = 12.3689, zoom = 6)



#4-1- Représentation de la carte du Brukina Fasso  au niveau District

#4-1- Simple 

# Créer la carte avec la légende et ajuster la taille du titre, sans flèche du nord
carte_avec_legende <- ggplot() + 
  geom_sf(data = communebf, aes(fill = ADM3_FR), color = "black", size = 0.2) +  # Colorer selon ADM3_FR avec bordures noires
  ggtitle("Carte des Districts du Burkina Faso") +  # Titre de la carte
  theme(plot.title = element_text(hjust = 0.5, size = 15),  # Taille de la police du titre réduite
        legend.position = "right") +  # Position temporaire de la légende pour l'extraire
  xlab("Longitude") + 
  ylab("Latitude") + 
  scale_fill_viridis_d(option = "plasma")  # Utilisation d'une palette distincte pour chaque district

# Extraire la légende
legende <- get_legend(carte_avec_legende)

# Créer une carte sans légende, sans flèche du nord
carte_sans_legende <- ggplot() + 
  geom_sf(data = communebf, aes(fill = ADM3_FR), color = "black", size = 0.2) +  # Colorer selon ADM3_FR
  ggtitle("Carte des Districts du Burkina Faso") +  # Titre de la carte
  theme(plot.title = element_text(hjust = 0.5, size = 15),  # Taille de la police du titre réduite
        legend.position = "none",  # Supprimer la légende pour maximiser l'espace
        axis.text = element_blank(),
        axis.ticks = element_blank(),
        axis.title = element_blank(),
        panel.grid = element_blank(),
        plot.margin = margin(0, 0, 0, 0)) +  # Réduire les marges au minimum
  scale_fill_viridis_d(option = "plasma")  # Palette de couleurs

# Afficher la carte sans légende
print(carte_sans_legende)

# Afficher la légende séparément
plot_grid(legende)

#4-2 - Avec Labels + Fléche du nord et échelle 

# Calculer les centroïdes pour positionner les labels au centre des districts
centroids <- st_centroid(communebf)

# Créer la carte avec la légende, la flèche du nord, l'échelle, et les labels
carte_avec_legende <- ggplot() + 
  geom_sf(data = communebf, aes(fill = ADM3_FR), color = "black", size = 0.2) +  # Colorer selon ADM3_FR avec bordures noires
  geom_sf_text(data = centroids, aes(label = ADM3_FR), size = 3, color = "black", fontface = "bold") +  # Ajouter les labels
  ggtitle("Carte des Districts du Burkina Faso") +  # Titre de la carte
  theme(plot.title = element_text(hjust = 0.5, size = 15),  # Taille de la police du titre réduite
        legend.position = "right") +  # Position temporaire de la légende pour l'extraire
  xlab("Longitude") + 
  ylab("Latitude") + 
  annotation_north_arrow(location = "bl", which_north = "true", 
                         pad_x = unit(0.25, "in"), pad_y = unit(0.25, "in"), 
                         style = north_arrow_fancy_orienteering()) +  # Flèche du nord
  annotation_scale(location = "bl", width_hint = 0.5) +  # Ajouter l'échelle en bas à gauche
  scale_fill_viridis_d(option = "plasma")  # Utilisation d'une palette distincte pour chaque district

# Extraire la légende
legende <- get_legend(carte_avec_legende)

# Créer une carte sans légende, mais avec l'échelle, la flèche du nord, et les labels
carte_sans_legende <- ggplot() + 
  geom_sf(data = communebf, aes(fill = ADM3_FR), color = "black", size = 0.2) +  # Colorer selon ADM3_FR
  geom_sf_text(data = centroids, aes(label = ADM3_FR), size = 3, color = "black", fontface = "bold") +  # Ajouter les labels
  ggtitle("Carte des Districts du Burkina Faso") +  # Titre de la carte
  theme(plot.title = element_text(hjust = 0.5, size = 15),  # Taille de la police du titre réduite
        legend.position = "none",  # Supprimer la légende pour maximiser l'espace
        axis.text = element_blank(),
        axis.ticks = element_blank(),
        axis.title = element_blank(),
        panel.grid = element_blank(),
        plot.margin = margin(0, 0, 0, 0)) +  # Réduire les marges au minimum
  annotation_north_arrow(location = "bl", which_north = "true", 
                         pad_x = unit(0.25, "in"), pad_y = unit(0.25, "in"), 
                         style = north_arrow_fancy_orienteering()) +  # Flèche du nord
  annotation_scale(location = "bl", width_hint = 0.5) +  # Ajouter l'échelle en bas à gauche
  scale_fill_viridis_d(option = "plasma")  # Palette de couleurs

# Afficher la carte sans légende avec la flèche du nord, l'échelle, et les labels
print(carte_sans_legende)

# Afficher la légende séparément
plot_grid(legende)



# NB : On constate qu'on ne visualise rien donc il faut trouver une solution 


#4-3  Création d'une carte interactive pour pouvoir améliorer la visualisation  qui regroupee tous les niveaux administratifs : National, régional, communebf, district


# Créer une carte interactive avec leaflet en ajoutant les limites administratives
leaflet() %>%
  addTiles() %>%  # Ajouter la couche de base (OpenStreetMap)
  
  # Ajouter les limites du Burkina Faso (administration de niveau 0 - national)
  addPolygons(data = burkinafaso, color = "blue", weight = 2, opacity = 1, fillOpacity = 0.5,
              popup = ~ADM0_FR) %>%  # Popup affichant le nom du pays
  
  # Ajouter les limites des régions (administration de niveau 1)
  addPolygons(data = regionbf, color = "green", weight = 2, opacity = 1, fillOpacity = 0.4,
              popup = ~ADM1_FR) %>%  # Popup affichant le nom des régions
  
  # Ajouter les limites des communebfs (administration de niveau 2)
  addPolygons(data = provincebf, color = "red", weight = 2, opacity = 1, fillOpacity = 0.3,
              popup = ~ADM2_FR) %>%  # Popup affichant le nom des communebfs
  
  # Ajouter les limites des districts (administration de niveau 3)
  addPolygons(data = communebf, color = "orange", weight = 2, opacity = 1, fillOpacity = 0.2,
              popup = ~ADM3_FR) %>%  # Popup affichant le nom des districts
  
  # Centrer la carte sur le Burkina Faso avec un zoom adapté
  setView(lng = -1.5336, lat = 12.3689, zoom = 6)


#==============   FIN Etape 2  =================#


#==============      Etape 3   =================#

raster_burkina <- read_stars("C:/Users/ALIOUNE KANE/Downloads/ENSAE/ISEP3/Statistiques exploratoire et spatiale/201501_Global_Travel_Time_to_Cities_BFA (1).tiff")
plot(raster_burkina)

#On va utiliser le package ggplot pour pouvoir changer les couleurs
ggplot() +
  geom_stars(data = raster_burkina) +
  scale_fill_viridis_c()
#==============   FIN Etape 3  =================#


#====================================   FIN   ===================================#