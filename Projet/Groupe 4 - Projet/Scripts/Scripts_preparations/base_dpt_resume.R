# Chargement des bibliothèques nécessaires
library(raster)        # Manipulation et analyse des données raster
library(sf)            # Manipulation des shapefiles (données spatiales vectorielles)
library(dplyr)         # Manipulation des données
library(exactextractr) # Extraction précise des valeurs raster par polygones

# Chemins vers les données
raster_folder <- "C:/Users/pc/OneDrive/Desktop/raster"  # Dossier contenant les fichiers raster
shapefile_paths <- list(                                # Liste des chemins vers les shapefiles par pays
  "Senegal" = "C:/Users/pc/OneDrive/Desktop/Shp_sn/sen_admbnda_adm2_anat_20240520.shp",
  "Mali" = "C:/Users/pc/OneDrive/Desktop/mli_shp/mli_admbnda_adm2_1m_gov_20211220.shp",
  "Burkina" = "C:/Users/pc/OneDrive/Desktop/Shp_bf/bfa_admbnda_adm2_igb_20200323.shp",
  "Niger" = "C:/Users/pc/OneDrive/Desktop/Niger_shp/NER_admbnda_adm2_IGNN_20230720.shp"
)
output_folder <- "C:/Users/pc/OneDrive/Desktop/Department_Bases"  # Dossier de sortie des fichiers CSV
dir.create(output_folder, showWarnings = FALSE)  # Création du dossier de sortie si inexistant

# Liste des rasters dans le dossier
raster_files <- list.files(raster_folder, pattern = "\\.tif$", full.names = TRUE)  # Récupération des fichiers .tif

# Boucle sur chaque fichier raster
for (raster_path in raster_files) {
  # Identifier le pays et l'indicateur à partir du nom du raster
  raster_name <- basename(raster_path)                      # Extraire le nom du fichier raster
  country <- strsplit(raster_name, "_")[[1]][1]             # Identifier le pays (partie avant le 1er '_')
  indicator <- gsub("\\.tif$", "", strsplit(raster_name, "_")[[1]][2])  # Identifier l'indicateur (après le 1er '_')
  
  # Vérification si un shapefile correspondant est disponible pour le pays
  if (!country %in% names(shapefile_paths)) {
    cat(paste("Pas de shapefile trouvé pour", country, "\n"))  # Message si aucun shapefile correspondant n'est trouvé
    next  # Passer au fichier raster suivant
  }
  
  # Lecture du shapefile pour le pays
  shapefile_path <- shapefile_paths[[country]]  # Obtenir le chemin du shapefile
  departments <- st_read(shapefile_path)       # Charger le shapefile
  
  # Vérification du système de coordonnées (CRS) du shapefile
  reference_crs <- st_crs(departments)  # Obtenir le CRS du shapefile
  
  # Lecture du fichier raster
  raster_data <- raster(raster_path)  # Charger le raster depuis le chemin
  
  # Vérification et ajustement du CRS si nécessaire
  if (!isTRUE(st_crs(raster_data)$proj4string == reference_crs$proj4string)) {
    raster_data <- projectRaster(raster_data, crs = reference_crs$proj4string)  # Harmonisation des CRS
  }
  
  # Extraction des valeurs moyennes pour chaque département
  # Les moyennes sont calculées en tenant compte des proportions de pixels dans chaque polygone
  department_values <- exactextractr::exact_extract(raster_data, departments, 'mean')
  
  # Création d'un tableau contenant les informations par département
  department_df <- data.frame(
    Department = departments$ADM2_FR,  # Nom du département (colonne ADM2_FR dans le shapefile)
    Region = departments$ADM1_FR,      # Nom de la région d'appartenance (colonne ADM1_FR)
    MeanValue = department_values      # Valeur moyenne extraite pour chaque département
  )
  
  # Sauvegarde des résultats dans un fichier CSV
  output_file <- file.path(output_folder, paste0(country, "_", indicator, "_Department_Base.csv"))  # Nom du fichier de sortie
  write.csv(department_df, output_file, row.names = FALSE)  # Sauvegarde des données dans le fichier CSV
}

# Résumé des fichiers générés
cat("Bases générées :\n")
cat("- Une base pour chaque pays et chaque indicateur dans le dossier Department_Bases/\n")
