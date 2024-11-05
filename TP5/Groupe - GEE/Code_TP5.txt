/*****************************************************
 ******* TP5 statistique exploratoire spatiale *******
 * Membre du groupe :
 * - Ameth FAYE
 * - Mame Balla BOUSSO
 * - Hiledegarde EDIMA BIYENDA
 * - Papa Amadou NIANG
 * 
 * Consigne du TP :
 * 
 * - Importation des fichiers
 * - Visualisation du raster Worldpop Sénégal 
 * - Calcul du nombre de personnes par admin
 * - Ramener le raster population à 5km
 * - Calcul du nombre d'enfants par pixels
 * - Determiner les raster binarisé pour le taux de Malaria
 * - Calcul du nombre d'enfants par raster binaire
 * - Calcul du nombre d'enfants atteints de Malaria par admin
 * - Calcul du taux de Malaria par admin
 * 
 * **************************************************/

/*****************************************************
 * Etape1 : Importation des fichiers 
*****************************************************/

// 1- Importation des différents admin (0-3)
var AD0_SN = ee.FeatureCollection("projects/ee-papaamadouniang2004/assets/sen_admbnda_adm0_anat_20240520");
var AD1_SN = ee.FeatureCollection("projects/ee-papaamadouniang2004/assets/sen_admbnda_adm1_anat_20240520");
var AD2_SN = ee.FeatureCollection("projects/ee-papaamadouniang2004/assets/sen_admbnda_adm2_anat_20240520");
var AD3_SN = ee.FeatureCollection("projects/ee-papaamadouniang2004/assets/sen_admbnda_adm3_anat_20240520");

// 2- Importation de l'image WorldPop pour le Sénégal
var population = ee.Image('projects/ee-papaamadouniang2004/assets/SEN_population_v1_0_gridded').clip(AD0_SN);

// 3- Iùportation des rasters moyennes et écart type
var ras_moy = ee.Image('projects/ee-papaamadouniang2004/assets/moyenne_sen').select([0]).clip(AD0_SN);
var ras_ect = ee.Image('projects/ee-papaamadouniang2004/assets/ecart_type_sen').select([0]).clip(AD0_SN);

// 4- Importation du raster cible
var ras_cible = ee.Image('projects/ee-papaamadouniang2004/assets/202406_Global_Pf_Parasite_Rate_SEN_2022').select([0]).clip(AD0_SN);

// 5- Centrer la carte sur la zone concernée
Map.centerObject(population, 10);

/*****************************************************
 * Etape2 : Visualisation du raster Worldpop Sénégal 
*****************************************************/

// Définir les paramètres de visualisation
var palette1 = {
  min: 0,
  max: 1000,
  palette: ['blue', 'green', 'yellow', 'red']
};

// Ajouter la couche au tableau de bord
Map.addLayer(population, palette1, 'Population WorldPop');

/*****************************************************
 * Etape3 : Calcul du nombre de personnes par admin
*****************************************************/

// Initialisation d'une fonction pour automatiser le processus
function calcandexport(admin, description, raster) {
  
  //Calcul du nombre de paersonne au niveau admin
  var populationparadmin = raster.reduceRegions({
    collection: admin,
    reducer: ee.Reducer.sum(),
    scale: 100,
    crs: raster.projection()
  });

  // Exporter vers Google Drive
  Export.table.toDrive({
    collection: populationparadmin,
    description: 'Population_' + description,
    fileFormat: 'CSV'
  });
  
  // Retourner le résultat
  return populationparadmin;
}

// Application de la fonction au différents admins (0-3)
calcandexport(AD0_SN, "Pays", population);
calcandexport(AD1_SN, "Region", population);
calcandexport(AD2_SN, "Departement", population);
calcandexport(AD3_SN, "Commune", population);

/*****************************************************
 * Etape4 : Ramener le raster population à 5km
*****************************************************/

// Dimunition de la résolution spatiale
var population_5km = population.reduceResolution({
  reducer: ee.Reducer.sum(),
  maxPixels: 3000 
}).reproject({
  crs: population.projection(),
  scale: 5000
}).clip(AD0_SN);

// Définir les paramètres de visualisation
var palette2 = {
  min: 0,
  max: 1000,
  palette: ['blue', 'green', 'yellow', 'red']
};

// Visualisation du raster population_5km au niveau de la carte
Map.addLayer(population_5km, palette2, 'Population 5km');

/*****************************************************
 * Etape5 : Calcul du nombre d'enfants par pixels
*****************************************************/

// Calculer 0.1% de la population
var population_0_1 = population_5km.multiply(0.001);

// Définir les paramètres de visualisation pour le nouveau raster
var palette3 = {
  min: 0,
  max: 1000 * 0.001,
  palette: ['blue', 'green', 'yellow', 'red']
};

// Ajouter le raster à la carte
Map.addLayer(population_0_1, palette3, 'Population 0.1%');

/*****************************************************
 * Etape6 : Determiner les raster binarisé pour le taux de Malaria
*****************************************************/

// Calculer les seuils
var seuil1 = ras_moy.add(ras_ect);
var seuil2 = ras_moy.add(ras_ect.multiply(2));

// Créer le premier raster binarisé (1 pour les pixels < u + v)
var aucun = ras_cible.lt(seuil1);

// Créer le deuxième raster binarisé (1 pour les pixels > u + v et < u + 2*v)
var modere = ras_cible.gt(seuil1).and(ras_cible.lt(seuil2));

// Créer le troisième raster binarisé (1 pour les pixels > u + 2*v)
var grave = ras_cible.gt(seuil2);

/*****************************************************
 * Etape7 : Calcul du nombre d'enfants par raster binaire
*****************************************************/

var raster1 = aucun.multiply(population_0_1); // Nombre d'enfants pour le cas aucun
var raster2 = modere.multiply(population_0_1); // Nombre d'enfants pour le cas modéré
var raster3 = grave.multiply(population_0_1); // Nombre d'enfants pour le cas grave

// Visualiser les trois rasters
Map.addLayer(raster1, {min: 0, max: 100, palette: ['green']}, 'Enfants < u + v');
Map.addLayer(raster2, {min: 0, max: 100, palette: ['yellow']}, 'Enfants > u + v & < u + 2*v');
Map.addLayer(raster3, {min: 0, max: 100, palette: ['red']}, 'Enfants > u + 2*v');

/*****************************************************
 * Etape8 : Calcul du nombre d'enfants atteints de Malaria par admin
*****************************************************/

// Initialisation de la fonction pour automatiser le processus
function calcetexportpop(admin, description, raster) {
  
  // Utiliser image directement pour obtenir la somme de population dans chaque unité administrative
  var popparadmin = raster.reduceRegions({
    collection: admin,
    reducer: ee.Reducer.sum(),
    scale: 5000,
    crs: raster.projection()
  });

  // Exporter vers Google Drive
  Export.table.toDrive({
    collection: popparadmin,
    description: 'Population_Malade_Par' + description,
    fileFormat: 'CSV'
  });
  
  
print(popparadmin)
  
  // Retourner le résultat
  return popparadmin;
} 

// Détermination du raster contenant le nombre d'enfants atteint de malaria
var malaria_pop = ras_cible.multiply(population_0_1);

// Application de la fonction pour le pays
var nbgossmalpays = calcetexportpop(AD0_SN, "Pays", malaria_pop);

// Application de la fonction pour les régions
var nbgossmalreg = calcetexportpop(AD1_SN, "Region", malaria_pop);

// Application de la fonction pour les départements
var nbgossmaldep = calcetexportpop(AD2_SN, "Departement", malaria_pop);

// Application de la fonction pour les communes
var nbgossmalcom = calcetexportpop(AD3_SN, "Commune", malaria_pop);

/*****************************************************
 * Etape9 : Calcul du taux de Malaria par admin
*****************************************************/

// Calcul du nombre d'enfants par admin
var nbgossparpays = calcandexport(AD0_SN, "Pays", population_0_1);
var nbgossparreg = calcandexport(AD1_SN, "Regions", population_0_1);
var nbgosspardep = calcandexport(AD2_SN, "Departements", population_0_1);
var nbgossparcom = calcandexport(AD3_SN, "Communes", population_0_1);

/*/ Calcul du taux (%) de malaria dans le pays et exporter cela au drive 
var taux_pays = nbgossmalpays.divide(nbgossparpays).multiply(100);
// Exporter vers Google Drive
Export.table.toDrive({
  collection: taux_pays,
  description: 'Taux de malaria par pays',
  fileFormat: 'CSV'
});

// Calcul du taux (%) de malaria par régions et exporter cela au drive
var taux_regions = nbgossparreg.divide(nbgossmalreg).multiply(100);
// Exporter vers Google Drive
Export.table.toDrive({
  collection: taux_regions,
  description: 'Taux de malaria par regions',
  fileFormat: 'CSV'
});

// Calcul du taux (%) de malaria par départements et exporter cela au drive
var taux_departements = nbgosspardep.divide(nbgossmaldep).multiply(100);
// Exporter vers Google Drive
Export.table.toDrive({
  collection: taux_departements,
  description: 'Taux de malaria par departements',
  fileFormat: 'CSV'
});

// Calcul du taux (%) de malaria par communes et exporter cela au drive
var taux_communes = nbgossparcom.divide(nbgossmalcom).multiply(100);
// Exporter vers Google Drive
Export.table.toDrive({
  collection: taux_communes,
  description: 'Taux de malaria par communes',
  fileFormat: 'CSV'
});
*/

// 1. Définir une jointure interne basée sur 'region_id'
var join = ee.Join.inner();

// 2. Créer un filtre pour joindre les régions ayant le même 'region_id'
var filter = ee.Filter.equals({
  leftField: 'ADM0_FR',
  rightField: 'ADM0_FR'
});

/*****************************************************
 *******************Fin du script*********************
*****************************************************/