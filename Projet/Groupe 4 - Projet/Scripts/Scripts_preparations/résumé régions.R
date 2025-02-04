# Chargement des bibliothèques nécessaires
library(raster)
library(sf)
library(dplyr)
library(exactextractr)

# Chemin vers le dossier contenant les rasters
raster_folder <- "C:/Users/pc/OneDrive/Desktop/raster"  # Dossier contenant les rasters
shapefile_paths <- list(
  "Senegal" = "C:/Users/pc/OneDrive/Desktop/Shp_sn/sen_admbnda_adm2_anat_20240520.shp",
  "Mali" = "C:/Users/pc/OneDrive/Desktop/mli_shp/mli_admbnda_adm2_1m_gov_20211220.shp",
  "Burkina" = "C:/Users/pc/OneDrive/Desktop/Shp_bf/bfa_admbnda_adm2_igb_20200323.shp",
  "Niger" = "C:/Users/pc/OneDrive/Desktop/Niger_shp/NER_admbnda_adm2_IGNN_20230720.shp"
)
output_file <- "C:/Users/pc/OneDrive/Desktop/Combined_Results_With_Country.csv"  # Fichier final pour sauvegarder les résultats

# Liste des rasters dans le dossier
raster_files <- list.files(raster_folder, pattern = "\\.tif$", full.names = TRUE)

# Initialisation d'une liste pour stocker les résultats
all_results <- list()

# Parcours des rasters
for (raster_path in raster_files) {
  # Identifier le pays et l'indicateur à partir du nom du raster
  raster_name <- basename(raster_path)
  parts <- strsplit(raster_name, "_")[[1]]  # Découper le nom en parties
  
  # Identifier le pays et l'indicateur en fonction de la structure du nom
  if (parts[length(parts)] %in% names(shapefile_paths)) {
    # Structure: NDYI_Pixel_Senegal.tif
    country <- gsub("\\.tif$", "", parts[length(parts)])  # Le pays est à la fin
    indicator_name <- paste(parts[1:(length(parts) - 1)], collapse = "_")  # Les parties avant le pays
  } else if (parts[1] %in% names(shapefile_paths)) {
    # Structure: Burkina_ARVI.tif
    country <- parts[1]  # Le pays est au début
    indicator_name <- gsub("\\.tif$", "", paste(parts[2:length(parts)], collapse = "_"))  # Le reste est l'indicateur
  } else {
    # Ignorer les fichiers non conformes
    cat(paste("Structure inconnue pour le fichier :", raster_name, "\n"))
    next
  }
  
  # Vérification si un shapefile est disponible pour le pays
  if (!country %in% names(shapefile_paths)) {
    cat(paste("Pas de shapefile trouvé pour", country, "\n"))
    next
  }
  
  # Lecture du shapefile
  shapefile_path <- shapefile_paths[[country]]
  departments <- st_read(shapefile_path)
  
  # Vérification du CRS des départements
  reference_crs <- st_crs(departments)
  
  # Lecture du raster
  raster_data <- raster(raster_path)
  
  # Vérification et ajustement du CRS si nécessaire
  if (st_crs(raster_data) != reference_crs) {
    raster_data <- projectRaster(raster_data, crs = reference_crs$proj4string)
  }
  
  # Extraction des valeurs pour chaque département
  department_values <- exactextractr::exact_extract(raster_data, departments, 'mean')
  
  # Création du tableau de données pour le raster
  department_df <- data.frame(
    Country = country,                   # Pays
    Department = departments$ADM2_FR,   # Nom du département
    Region = departments$ADM1_FR,       # Région d'appartenance
    MeanValue = department_values       # Moyenne des valeurs extraites
  )
  
  # Résumé par région
  region_summary <- department_df %>%
    group_by(Region) %>%
    summarize(
      Country = unique(Country),                            # Pays
      Indicator = indicator_name,                          # Nom de l'indicateur
      MinValue = min(MeanValue, na.rm = TRUE),             # Valeur minimale
      MaxValue = max(MeanValue, na.rm = TRUE),             # Valeur maximale
      MinDepartment = first(Department[MeanValue == min(MeanValue, na.rm = TRUE)]),  # Département avec valeur minimale
      MaxDepartment = first(Department[MeanValue == max(MeanValue, na.rm = TRUE)]),  # Département avec valeur maximale
      MeanValue = mean(MeanValue, na.rm = TRUE)            # Moyenne des valeurs
    )
  
  # Ajouter les résultats au tableau global
  all_results[[paste(country, indicator_name, sep = "_")]] <- region_summary
}

# Combinaison des résultats pour tous les rasters dans un seul tableau
final_results <- bind_rows(all_results)

# Sauvegarde des résultats combinés dans un fichier CSV unique
write.csv(final_results, output_file, row.names = FALSE)

# Affichage des résultats finaux
print(final_results)

