# Chargement des bibliothèques nécessaires
library(dplyr)
library(ggplot2)
library(readr)

# Chemin vers le dossier contenant les bases de données
input_folder <- "C:/Users/pc/OneDrive/Desktop/Department_Bases"  # Remplacez par le chemin où vos bases CSV sont sauvegardées
output_folder <- "C:/Users/pc/OneDrive/Desktop/Region_Indicator_Scatter_Plots"  # Dossier pour sauvegarder les graphiques
dir.create(output_folder, showWarnings = FALSE)

# Lecture des fichiers CSV
csv_files <- list.files(input_folder, pattern = "\\.csv$", full.names = TRUE)

# Boucle pour traiter chaque fichier CSV
for (csv_file in csv_files) {
  # Lecture de la base
  data <- read.csv(csv_file)
  
  # Vérifier si les colonnes nécessaires existent
  if (!all(c("Region", "Department", "MeanValue") %in% colnames(data))) {
    cat("Colonnes manquantes dans", csv_file, "\n")
    next
  }
  
  # Extraire le nom de l'indicateur à partir du nom du fichier
  file_name <- basename(csv_file)
  indicator <- gsub("_Department_Base\\.csv$", "", file_name)
  
  # Génération des graphiques pour chaque région
  for (region in unique(data$Region)) {
    # Filtrer les données pour la région actuelle
    region_data <- data %>% filter(Region == region)
    
    if (nrow(region_data) > 0) {
      # Création du nuage de points
      plot <- ggplot(region_data, aes(x = Department, y = MeanValue)) +
        geom_point(size = 4, color = "blue", alpha = 0.7) +
        geom_text(aes(label = Department), vjust = -0.5, size = 3) +
        labs(
          title = paste("Scatter Plot for Region:", region, "and Indicator:", indicator),
          x = "Department",
          y = "Mean Value"
        ) +
        theme_minimal() +  # Fond clair
        theme(
          axis.text.x = element_text(angle = 45, hjust = 1, size = 8),
          axis.text.y = element_text(size = 8),
          legend.position = "none"
        )
      
      # Sauvegarde du graphique
      output_file <- file.path(output_folder, paste0("Scatter_", region, "_", indicator, ".png"))
      ggsave(
        filename = output_file,
        plot = plot,
        width = 10,
        height = 6
      )
    }
  }
}

# Résumé des fichiers générés
cat("Nuages de points générés :\n")
cat("- Un nuage de points pour chaque région et indicateur dans le dossier Region_Indicator_Scatter_Plots/\n")
