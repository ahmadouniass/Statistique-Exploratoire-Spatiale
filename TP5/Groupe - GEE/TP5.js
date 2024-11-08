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
 ****************************************************/

/*****************************************************
 * Etape1 : Importation des fichiers 
*****************************************************/

// 1- Importation des différents admin (0-3)
var AD0_SN = ee.FeatureCollection("projects/ee-papaamadouniang2004/assets/sen_admbnda_adm0_anat_20240520"); // Pays
var AD1_SN = ee.FeatureCollection("projects/ee-papaamadouniang2004/assets/sen_admbnda_adm1_anat_20240520"); // Régions
var AD2_SN = ee.FeatureCollection("projects/ee-papaamadouniang2004/assets/sen_admbnda_adm2_anat_20240520"); // Départements
var AD3_SN = ee.FeatureCollection("projects/ee-papaamadouniang2004/assets/sen_admbnda_adm3_anat_20240520"); // Communes

// 2- Importation de l'image WorldPop pour le Sénégal
var population = ee.Image('projects/ee-papaamadouniang2004/assets/SEN_population_v1_0_gridded').clip(AD0_SN);

// 3- Importation des rasters moyennes et écart type
var ras_moy = ee.Image('projects/ee-papaamadouniang2004/assets/moyenne_sen').select([0]).clip(AD0_SN);
var ras_ect = ee.Image('projects/ee-papaamadouniang2004/assets/ecart_type_sen').select([0]).clip(AD0_SN);

// 4- Importation du raster cible
var ras_cible = ee.Image('projects/ee-papaamadouniang2004/assets/202406_Global_Pf_Parasite_Rate_SEN_2022').select([0]).clip(AD0_SN);

// 5- Centrer la carte sur la zone concernée
Map.centerObject(population, 7);

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
calcandexport(AD0_SN, "Pays", population); // Pays
calcandexport(AD1_SN, "Region", population); // Régions
calcandexport(AD2_SN, "Departement", population); // Départements
calcandexport(AD3_SN, "Commune", population); // Communes

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
    description: 'Population_Malade_Par_' + description,
    fileFormat: 'CSV'
  });
  
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

// Combiner les deux bandes en une seule image
var malaria_pop_no = malaria_pop.addBands(population_0_1);

// Initialisation de la fonction pour automatiser le processus
function calcul_taux(admin, description) {
  
  // Réduire les valeurs du raster par unité administrative en utilisant la somme
  var sommeparadmin = malaria_pop_no.reduceRegions({
    collection: admin,
    reducer: ee.Reducer.sum(),
    scale: 5000,
  });

  // Calculer le taux de malaria
  var taux_mal = sommeparadmin.map(function(feature){
  
    // Récupération de la variable pour les malades
    var malaria = ee.Number(feature.get('b1'));
  
    // Récupération de la variable population
    var population = ee.Number(feature.get('b1_1'));
  
    // Calculer le taux
    var taux = malaria.divide(population).multiply(100);
  
    return feature.set('taux_malaria', taux);
  });

  // Afficher les résultats au niveau de la console
  print('Taux de paludisme par ' + description, taux_mal);
}

// Application de la fonction pour le niveau pays
calcul_taux(AD0_SN, 'Pays');

// Application de la fonction pour le niveau région
calcul_taux(AD1_SN, 'Region');

// Application de la fonction pour le niveau département 
calcul_taux(AD2_SN, 'Departement');

// Application de la fonction pour le niveau commune
calcul_taux(AD3_SN, 'Commune');

/*****************************************************
 *******************Fin du script*********************
*****************************************************/