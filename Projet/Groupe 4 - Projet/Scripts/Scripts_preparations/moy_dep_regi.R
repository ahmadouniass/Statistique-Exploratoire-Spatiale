# Charger les bibliothèques nécessaires
library(raster)
library(terra)

# Étape 1 : Charger les rasters pour la période 2000-2020
# Remplacer "path/to/rasters" par le dossier contenant les rasters
raster_list <- list.files("C:/Users/pc/Statistique-Exploratoire-Spatiale/TP2/data/Malaria/Senegal", pattern = "\\.tiff$", full.names = TRUE)
rasters <- stack(raster_list)  # Charger tous les rasters en une pile

# Vérification
print(paste("Nombre de rasters chargés :", nlayers(rasters)))

# Étape 2 : Calculer la moyenne pixel par pixel sur la période 2000-2020
mean_raster <- calc(rasters, mean, na.rm = TRUE)  # Moyenne pixel par pixel

# Calculer l'écart type pixel par pixel (si nécessaire)
std_raster <- calc(rasters, sd, na.rm = TRUE)  # Écart type pixel par pixel


# Étape 3 : Créer un raster contenant des valeurs continues
# Vous pouvez utiliser la moyenne ou une combinaison (moyenne + écart-type)
values_raster <- mean_raster  # Utiliser uniquement la moyenne
# (Optionnel) : Ajouter une pondération avec l'écart type
# values_raster <- mean_raster + std_raster  # Si besoin d'ajouter un seuil


# Étape 4 : Visualisation (optionnel)
plot(values_raster, main = "Raster des valeurs continues (Moyenne 2000-2020)", col = terrain.colors(10))

# Message de confirmation
print("Le raster des valeurs continues a été créé et sauvegardé sous 'values_raster.tif'.")

# Charger les bibliothèques nécessaires
library(raster)
library(terra)
library(sf)

# Charger les bibliothèques nécessaires
library(terra)
library(sf)


# Charger les shapefiles des régions et départements avec sf
regions <- st_read("C:/Users/pc/OneDrive/Desktop/Shp_sn/sen_admbnda_adm1_anat_20240520.shp")  # Régions
departements <- st_read("C:/Users/pc/OneDrive/Desktop/Shp_sn/sen_admbnda_adm2_anat_20240520.shp")  # Départements

# Convertir les shapefiles sf en objets vect terra
regions <- vect(regions)
departements <- vect(departements)

# Étape 2 : Calculer les moyennes par région avec terra
# Calculer la moyenne des pixels pour chaque région
region_stats <- zonal(values_raster, regions, fun = mean, na.rm = TRUE)

# Ajouter les moyennes calculées au vecteur des régions
regions$mean <- region_stats$mean

# Rasteriser les moyennes par région
region_mean_raster <- rasterize(regions, values_raster, field = "mean", background = NA)

# Exporter le raster des moyennes par région
writeRaster(region_mean_raster, "region_mean_raster.tiff", format = "GTiff", overwrite = TRUE)

# Étape 3 : Calculer les moyennes par département avec terra
# Calculer la moyenne des pixels pour chaque département
department_stats <- zonal(values_raster, departements, fun = mean, na.rm = TRUE)

# Ajouter les moyennes calculées au vecteur des départements
departements$mean <- department_stats$mean

# Rasteriser les moyennes par département
department_mean_raster <- rasterize(departements, values_raster, field = "mean", background = NA)

# Exporter le raster des moyennes par département
writeRaster(department_mean_raster, "department_mean_raster.tiff", format = "GTiff", overwrite = TRUE)

# Étape 4 : Visualisation (Optionnel)
# Visualiser le raster des moyennes par région
plot(region_mean_raster, main = "Moyenne par région", col = terrain.colors(10))

# Visualiser le raster des moyennes par département
plot(department_mean_raster, main = "Moyenne par département", col = terrain.colors(10))

# Message de confirmation
print("Les rasters des moyennes par région et par département ont été générés avec succès !")

# Charger les shapefiles des régions et départements
regions <- st_read("C:/Users/pc/OneDrive/Desktop/Shp_sn/sen_admbnda_adm1_anat_20240520.shp")  # Régions
departements <- st_read("C:/Users/pc/OneDrive/Desktop/Shp_sn/sen_admbnda_adm2_anat_20240520.shp")  # Départements

# Convertir les shapefiles en objets Spatial* compatibles avec raster
regions <- as(regions, "Spatial")  # Conversion en SpatialPolygonsDataFrame
departements <- as(departements, "Spatial")  # Conversion en SpatialPolygonsDataFrame

# Étape 2 : Calculer les moyennes par région
# Extraire les valeurs des pixels sous chaque région
region_values <- extract(values_raster, regions, fun = mean, na.rm = TRUE, df = TRUE)

# Ajouter les moyennes calculées au shapefile des régions
regions@data$mean <- region_values$layer

# Rasteriser les moyennes par région
region_mean_raster <- rasterize(regions, values_raster, field = "mean", background = NA)

# Exporter le raster des moyennes par région
writeRaster(region_mean_raster, "region_mean_raster.tiff", format = "GTiff", overwrite = TRUE)

# Étape 3 : Calculer les moyennes par département
# Extraire les valeurs des pixels sous chaque département
department_values <- extract(values_raster, departements, fun = mean, na.rm = TRUE, df = TRUE)

# Ajouter les moyennes calculées au shapefile des départements
departements@data$mean <- department_values$layer

# Rasteriser les moyennes par département
department_mean_raster <- rasterize(departements, values_raster, field = "mean", background = NA)

# Exporter le raster des moyennes par département
writeRaster(department_mean_raster, "department_mean_raster.tiff", format = "GTiff", overwrite = TRUE)

# Étape 4 : Visualisation (Optionnel)
# Visualiser le raster des moyennes par région
plot(region_mean_raster, main = "Moyenne par région", col = terrain.colors(10))

# Visualiser le raster des moyennes par département
plot(department_mean_raster, main = "Moyenne par département", col = terrain.colors(10))

# Message de confirmation
print("Les rasters des moyennes par région et par département ont été générés avec succès !")