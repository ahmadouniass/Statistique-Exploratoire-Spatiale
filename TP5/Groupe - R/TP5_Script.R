#====================================================================================#
#     ENSAE Pierre NDIAYE de Dakar ISE1-Cycle long 2024-2025                         #
#     COURS DE Statistique exploratoire spaciale  avec M.Aboubacar HEMA              #
#                           Travaux Pratiques N°5                                    #
#                                                                                    #
#    Groupe : Logiciel R                                                             #
#    Pays : Cameroun                                                                 #
#    Composé de : Jeanne De La Flèche ONANENA AMANA, Khadidiatou COULIBALY,          #
#                 Tamsir NDONG, Samba DIENG                                          #
#                                                                                    #
#====================================================================================#


#                   =====================  CONSIGNE  =====================

# 1. Importer et visualiser le raster population
# 2. Calculer le nombre de personnes par admin et exporter sous format .csv
# 3. Ramener la taille des pixels à 5km
# 4. Visualiser le nouveau raster de la population
# 5. Calculer un nouveau raster d'enfants de 0 à 12ans (O.1%)
# 6. Créer 3 nouveaux rasters binarisés
# 7. Multiplier chacun d'eux par celui de la population
# 8. Calculer nombre d'enfants atteints de la malaria par admin et exporter
# 9. Quel est le taux d'enfants atteints de malaria par admin ?

# Chargement des packages

  library(stars)       
  library(sf)          
  library(ggplot2)     
  library(ggspatial)   
  library(raster)      
  library(cowplot)     
  library(leaflet)     
  library(viridis)     
  library(dplyr)       
  library(exactextractr) 
  library(kableExtra)
  library(knitr)


setwd(dir ="C:/Users/DELL/Documents/ISEP3_2025/Stats_spatiale/Statistique-Exploratoire-Spatiale/TP5/Groupe - R/data_CMR")


# 1. Importation et visualisation -------------------------------------------------------------------------------------

  cameroun <- st_read("cmr_admbnda_adm0_inc_20180104.shp", quiet = TRUE)
  region <- st_read("cmr_admbnda_adm1_inc_20180104.shp", quiet = TRUE)
  departement <- st_read("cmr_admbnda_adm2_inc_20180104.shp", quiet = TRUE)
  arrondissement <- st_read("cmr_admbnda_adm3_inc_20180104.shp", quiet = TRUE)

  malaria_2022_CMR <- raster("Indic2022_taux_maliaria_3niveaux.tif") %>%
    crop(cameroun) %>%
    mask(cameroun)

  taux_2022 <- raster("202406_Global_Pf_Parasite_Rate_CMR_2022.tiff") %>%
    crop(cameroun) %>%
    mask(cameroun)

  pop <- raster("CMR_population_v1_0_gridded.tif") %>%
    crop(cameroun) %>%
    mask(cameroun)


pop_df <- as.data.frame(rasterToPoints(pop), stringsAsFactors = FALSE)
colnames(pop_df) <- c("x", "y", "value")
ggplot() +
  geom_tile(data = pop_df, aes(x = x, y = y, fill = value)) +
  geom_sf(data = region, fill = NA, color = "black", size = 0.5) +
  scale_fill_viridis(option = "viridis", na.value = "transparent") +
  labs(title = "Population du Cameroun dans les régions", fill = "Population") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5), legend.position = "right") + 
  annotation_north_arrow(location = "tl", which_north = "true", pad_x = unit(0.1, "in"), pad_y = unit(0.1, "in"), style = north_arrow_fancy_orienteering()) + 
  annotation_scale(location = "bl", width_hint = 0.5)


# 2. Calcul du nombre de personnes par admin (0-3) et exportation sous format .csv -------------------------------------------------------------------------------------

pop_admin0 <- exact_extract(pop, cameroun, fun = "sum", progress = FALSE)
cameroun$population <- pop_admin0
pop_cameroun <- data.frame(cameroun %>% st_drop_geometry() %>% dplyr::select(ADM0_FR, population))

pop_admin1 <- exact_extract(pop, region, fun = "sum", progress = FALSE)
region$population <- pop_admin1
pop_region <- data.frame(region %>% st_drop_geometry() %>% .[, c("ADM1_FR", "population")])

pop_admin2 <- exact_extract(pop, departement, fun = "sum", progress = FALSE)
departement$population <- pop_admin2
pop_departement <- data.frame(departement %>% st_drop_geometry() %>% mutate(population = as.numeric(population)) %>% .[, c("ADM2_FR", "population")])

pop_admin3 <- exact_extract(pop, arrondissement, fun = "sum", progress = FALSE)
arrondissement$population <- pop_admin3
pop_arrondissement <- data.frame(arrondissement %>% st_drop_geometry() %>% .[, c("ADM3_FR", "population")])

output_folder <- "Outputs/"
dir.create(output_folder, showWarnings = FALSE)
write.csv(pop_cameroun, file.path(output_folder, "pop_cameroun.csv"), row.names = FALSE)
write.csv(pop_region, file.path(output_folder, "pop_region.csv"), row.names = FALSE)
write.csv(pop_departement, file.path(output_folder, "pop_departement.csv"), row.names = FALSE)
write.csv(pop_arrondissement, file.path(output_folder, "pop_arondissement.csv"), row.names = FALSE)



# 3. Résolution à 5km par aggrégation (somme)------------------------------------------------------------------------

res(pop)
pop_newResw <- aggregate(pop, fact = 50, fun = sum, filename = "CMR_population_aggregated_5km.tif", overwrite = TRUE)


# 4. Visualisation du nouveau raster---------------------------------------------------------------------------------------

pop_df <- as.data.frame(rasterToPoints(pop_newResw), stringsAsFactors = FALSE)
colnames(pop_df) <- c("x", "y", "value")
ggplot() +
  geom_tile(data = pop_df, aes(x = x, y = y, fill = value)) +
  geom_sf(data = region, fill = NA, color = "black", size = 0.5) +
  scale_fill_viridis(option = "plasma", na.value = "transparent") +
  labs(title = "Population du Cameroun dans les régions", fill = "Population") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5), legend.position = "right") + 
  annotation_north_arrow(location = "tl", which_north = "true", pad_x = unit(0.1, "in"), pad_y = unit(0.1, "in"), style = north_arrow_fancy_orienteering()) + 
  annotation_scale(location = "bl", width_hint = 0.5)



# 5. Raster des enfants de 0 à 12 ans (0.1% de la population)-----------------------------------------------------------------

pop_child <- pop_newResw * 0.001



# 6. Visualisation du nouveau raster-------------------------------------------------------------------------------------

pop_df <- data.frame(rasterToPoints(pop_child), stringsAsFactors = FALSE)
colnames(pop_df) <- c("x", "y", "value")
ggplot() +
  geom_tile(data = pop_df, aes(x = x, y = y, fill = value)) +
  geom_sf(data = region, fill = NA, color = "black", size = 0.5) +
  scale_fill_viridis(option = "turbo", na.value = "transparent") +
  labs(title = "Population du Cameroun dans les régions", fill = "Population") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5), legend.position = "right") + 
  annotation_north_arrow(location = "tl", which_north = "true", pad_x = unit(0.1, "in"), pad_y = unit(0.1, "in"), style = north_arrow_fancy_orienteering()) + 
  annotation_scale(location = "bl", width_hint = 0.5)


#  7. Rasters binarisés à partir de celui du taux de malaria --------------------------------------------------------------------------------------

## On aligne les rasters

taux_2022_projected <- projectRaster(taux_2022, malaria_2022_CMR)


## On obtient les rasters binarisés

aucun <- calc(malaria_2022_CMR == 1, fun = function(x) { ifelse(x, 1, 0) })*taux_2022_projected

moyen <- calc(malaria_2022_CMR == 2, fun = function(x) { ifelse(x, 1, 0) })*taux_2022_projected

grave <- calc(malaria_2022_CMR == 3, fun = function(x) { ifelse(x, 1, 0) })*taux_2022_projected


# On multiplie par la population (après reprojection)

pop_newRes_proj <- projectRaster(pop_newResw, malaria_2022_CMR)


# Calcul du nombre d'enfants par situation 

pop_aucun  <- aucun*pop_newRes_proj

pop_moyen  <- moyen*pop_newRes_proj

pop_grave  <- grave*pop_newRes_proj


print(" Nombre d'enfants en situation verte")
round(exact_extract(pop_aucun, cameroun, fun = "sum", progress = FALSE), 0)

print(" Nombre d'enfants en situation jaune")
round(exact_extract(pop_moyen, cameroun, fun = "sum", progress = FALSE), 0)

print(" Nombre d'enfants en situation rouge")
round(exact_extract(pop_grave, cameroun, fun = "sum", progress = FALSE), 0)   


# 8. Nombre d'enfants atteints par admin--------------------------------------------------------------------------------------

# Raster ayant toute la population malade
pop_malaria <- pop*projectRaster(taux_2022, pop)

pop_cameroun$pop_malade <- exact_extract(pop_malaria, cameroun, fun = "sum", progress = FALSE)
pop_region$pop_malade <- exact_extract(pop_malaria, region, fun = "sum", progress = FALSE)
pop_departement$pop_malade <- exact_extract(pop_malaria, departement, fun = "sum", progress = FALSE)
pop_arrondissement$pop_malade  <- exact_extract(pop_malaria, arrondissement, fun = "sum", progress = FALSE)


# Exporter chaque data frame sous format CSV

write.csv(pop_cameroun, file.path(output_folder, "cameroun.csv"), row.names = FALSE)

write.csv(pop_region, file.path(output_folder, "region_cmr.csv"), row.names = FALSE)

write.csv(pop_departement, file.path(output_folder, "departement_cmr.csv"), row.names = FALSE)

write.csv(pop_arondissement, file.path(output_folder, "arondissement_cmr.csv"), row.names = FALSE)


#head(pop_arrondissement,10)

# 9. Taux d'enfants atteints par admin--------------------------------------------------------------------------------------

## On prend la population malade sur celle totale d'enfants et le tout * 100

# taux = nb atteints dans l'admin / nb total


pop_cameroun$taux_malade <- pop_cameroun$pop_malade/(pop_cameroun$population)

pop_region$taux_malade <- pop_region$pop_malade/(pop_region$population)

pop_departement$taux_malade <- pop_departement$pop_malade/(pop_departement$population)

pop_arrondissement$taux_malade  <- pop_arrondissement$pop_malade/(pop_arrondissement$population)

#head(pop_arrondissement,10)


# ////////////////////////////////////////////////////// Fin du script /////////////////////////////////////////////////////////////////


