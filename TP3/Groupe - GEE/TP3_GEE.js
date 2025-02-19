///////////////////////////////////////////////////////////////////////////////////////////////
////      ECOLE NATIONALE DE LA STATISTIQUE ET DE L'ANALYSE ECONOMIQUE PIERRE NDIAYE     /////
////          COURS DE STATISTIQUES EXPLORATOIRE ET SPATIALE - ISE1_CYCLE LONG          /////
////                           ENSEIGNANT: MR HEMA                                     /////
////                   TP3_GOOGLE EARTH ENGINE AVEC JAVASCRIPT                        /////
////                  MEMBRES: ONANENA AMANA JEANNE DE LA FLECHE                     /////
////                           DIENG SAMBA                                          /////
////                           NDONG TAMSIR                                        /////
////                           COULIBALY KHADIDIATOU                              /////
//////////////////////////////////////////////////////////////////////////////////////

/// CONSIGNE: Calcul du taux de malaraa pour chaque niveau.



///////////////////////////////////////////Let's start////////////////////////////////////////////////

/// IMPORTATION DES FICHIERS 
var rasteur = ee.Image("projects/ee-coulibalykhadidiatou-tp4/assets/ENSAE_2024_StatistisqueSpatiales_TP_3_4/moyenne"),
    shapefile0 = ee.FeatureCollection("projects/ee-coulibalykhadidiatou-tp4/assets/ENSAE_2024_StatistisqueSpatiales_TP_3_4/shapefile0"),
    shapefile1 = ee.FeatureCollection("projects/ee-coulibalykhadidiatou-tp4/assets/ENSAE_2024_StatistisqueSpatiales_TP_3_4/Shapefile1"),
    shapefile2 = ee.FeatureCollection("projects/ee-coulibalykhadidiatou-tp4/assets/ENSAE_2024_StatistisqueSpatiales_TP_3_4/shapefile2"),
    shapefile3 = ee.FeatureCollection("projects/ee-coulibalykhadidiatou-tp4/assets/ENSAE_2024_StatistisqueSpatiales_TP_3_4/shapefile3");


// Prendre la première bande
var image = rasteur.select([0]); 

// Affichage du shapefile et du rasteur =

Map.addLayer(shapefile1,{color :'orange'}, 'Cameroun');
Map.addLayer(image);

var scale = rasteur.projection().nominalScale ;
// Print the scale
print('Image scale (resolution en metres):', scale);


// Fonction pour calculer les statistiques zonales

function getZonalList(shapefile, raster, regionField, export_name) {
  // Calcul des statistiques par région
  var zonalStats = raster.reduceRegions({
    collection: shapefile,
    reducer: ee.Reducer.mean(),
    scale: 5000
  });

  // Préparer les statistiques zonales
  var zonalStatistics = zonalStats.map(function(feature) {
  var zoneName = feature.get(regionField); // Nom de la zone
  var meanValue = feature.get('mean'); // Valeur moyenne obtenue
    

    return ee.Feature(null, {
      'zone': zoneName,
      'mean_value': meanValue,
    });
  });
  
  Export.table.toDrive({
    collection: zonalStatistics,
    description: export_name,
    fileFormat: 'CSV',
    folder: 'indice_cameroun', 
    selectors: ['zone', 'mean_value']})
  
  // Réduire les colonnes pour obtenir la liste des valeurs
  var zonalList = zonalStatistics.reduceColumns(ee.Reducer.toList(2), ['zone', 'mean_value']);
  
  // Retourner zonalList
  return zonalList;
  
}


// Exemple d'utilisation
var zonalList0 = getZonalList(shapefile0, image, 'ADM0_FR', 'shapefile0_means');
print('Valeurs obtenues', zonalList0);

var zonalList1 = getZonalList(shapefile1, image, 'ADM1_FR', 'shapefile1_means');
print('Valeurs obtenues', zonalList1);

var zonalList2 = getZonalList(shapefile2, image, 'ADM1_FR', 'shapefile2_means');
print('Valeurs obtenues', zonalList2);

var zonalList3 = getZonalList(shapefile3, image, 'ADM2_FR', 'shapefile3_means');
print('Valeurs obtenues', zonalList3);


// Et si on affichait les labels ?? Essayons! 

// Charger le package text
var text = require('users/gena/packages:text');


// Définir l'échelle pour les étiquettes
var scale = Map.getScale() * 1;

// On prend le chapefile au niveau 1 avec les valeurs moyennes

 var zonalStats1 = image.reduceRegions({
    collection: shapefile1,
    reducer: ee.Reducer.mean(),
    scale: 5000
  });
  
  
// Fonction pour remplacer les caractères accentués
function normalizeString(str) {
    return ee.String(str)
        .replace('é', 'e')
        .replace('è', 'e')
        .replace('ê', 'e')
        .replace('ë', 'e')
        .replace('à', 'a')
        .replace('â', 'a')
        .replace('ä', 'a')
        .replace('î', 'i')
        .replace('ï', 'i')
        .replace('ô', 'o')
        .replace('ö', 'o')
        .replace('ù', 'u')
        .replace('û', 'u')
        .replace('ü', 'u')
        .replace('ç', 'c');
}

  
// Mapper les étiquettes sur chaque polygone
var labels = zonalStats1.map(function(feat) {
     feat = ee.Feature(feat);
     var zoneName = ee.String(feat.get("ADM1_FR")); // Récupérer le nom de la zone
     var meanValue = ee.Number(feat.get("mean")).format('%.3f'); // Formater la valeur moyenne à 2 chiffres après la virgule
     
     // Combiner 'ADM1_FR' et 'mean' avec un ":"
     var name = zoneName.cat(' : ').cat(meanValue);
     
     // Normaliser le texte
     name = normalizeString(name);
     
     var centroid = feat.geometry().centroid();
     var t = text.draw(name, centroid, scale, {
          fontSize: 16,
          textColor: 'red',
          outlineWidth: 0.5,
          outlineColor: 'red'
     });
     return t;
});

// Convertir les labels en ImageCollection et les ajouter sur la carte
var labels_final = ee.ImageCollection(labels);
Map.addLayer(labels_final, {}, "Polygon label");

