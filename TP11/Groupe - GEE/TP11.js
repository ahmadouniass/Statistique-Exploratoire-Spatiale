// Chargeons les rasters et les limites administratives
var evenements = ee.Image("projects/ee-khadijaaatou180702/assets/Rasterisation_general");
var population = ee.Image("projects/ee-khadijaaatou180702/assets/mali_pop_2020");

var admin0 = ee.FeatureCollection("projects/ee-khadijaaatou180702/assets/mli_admbnda_adm0_1m_gov_20211110b");
var admin1 = ee.FeatureCollection("projects/ee-khadijaaatou180702/assets/mli_admbnda_adm1_1m_gov_20211110b");
var admin2 = ee.FeatureCollection("projects/ee-khadijaaatou180702/assets/mli_admbnda_adm2_1m_gov_20211110b");

// Visualisation des données brutes
Map.addLayer(evenements, {min: 1, max: 10, palette: ['yellow', 'orange', 'red']}, "Événements (Brut)");
Map.addLayer(population, {palette: ['green', 'yellow', 'red']}, "Population (Brut)");
Map.centerObject(admin1, 6);

print("Raster des événements :", evenements);
print("Raster de population :", population);

// Reprojection du raster population à une résolution de 5 km
var RA = population.reproject({
  crs: population.projection(),
  scale: 5000
}).rename("RA");

// Visualisation de RA
Map.addLayer(RA, {palette: ['green', 'yellow', 'red']}, "Population Reprojetée (RA)");

print("Raster RA (Population Reprojetée) :", RA);


// R1 : Population > 50
var R1 = RA.gt(50).rename("R1");
Map.addLayer(R1, {min: 0, max: 1, palette: ['gray', 'green']}, "RA Binarisé (R1)");

// R2 : Événements > 5
var R2 = evenements.gt(5).rename("R2");
Map.addLayer(R2, {min: 0, max: 1, palette: ['gray', 'blue']}, "RB Binarisé (R2)");

print("Raster R1 (Population Binarisée) :", R1);
print("Raster R2 (Événements Binarisés) :", R2);


// CDI_raster : Multiplication de R1 (rater binaire de la population) et R2 (raster binaire des évènements) 
var CDI_raster = R1.multiply(R2).rename("CDI_raster");

// Visualisation du raster CDI
Map.addLayer(CDI_raster, {min: 0, max: 1, palette: ['gray', 'red']}, "Raster CDI (R1 * R2)");

print("Raster CDI (R1 * R2) :", CDI_raster);





// Fonction pour calculer le CDI pour admin0, admin1 ou admin2
function calculateCDI(adminLevel, cdiRaster, r2Raster, descriptionBase) {
  // Sélection des limites administratives en fonction du paramètre
  var adminFeatures;
  var adminNameField;
  
  if (adminLevel === 0) {
    adminFeatures = admin0; // Définir admin0 comme collection de limites nationales
    adminNameField = 'admin0Name'; // Champ pour admin0
  } else if (adminLevel === 1) {
    adminFeatures = admin1; // Définir admin1 comme collection de limites régionales
    adminNameField = 'admin1Name'; // Champ pour admin1
  } else if (adminLevel === 2) {
    adminFeatures = admin2; // Définir admin2 comme collection de limites départementales
    adminNameField = 'admin2Name'; // Champ pour admin2
  } else if (adminLevel === 3) {
    adminFeatures = admin3; // Définir admin3 comme collection de limites départementales
    adminNameField = 'admin3Name'; // Champ pour admin3
  } else {
    throw new Error("adminLevel doit être 0, 1, 2 ou 3");
  }

  var description = descriptionBase + "_Admin" + adminLevel; // Nom pour l'exportation

  // Calcul de la somme des pixels pour le CDI_raster (numérateur)
  var numerateur = cdiRaster.reduceRegions({
    collection: adminFeatures,
    reducer: ee.Reducer.sum(),
    scale: 5000,
    crs: cdiRaster.projection()
  });

  // Ajouter le numérateur en tant que propriété
  numerateur = numerateur.map(function(feature) {
    return feature.set("CDI_numerateur", feature.get("sum"));
  });

  // Calcul de la somme des pixels pour R2 (dénominateur)
  var denominateur = r2Raster.reduceRegions({
    collection: adminFeatures,
    reducer: ee.Reducer.sum(),
    scale: 5000,
    crs: r2Raster.projection()
  });

  // Ajouter le dénominateur en tant que propriété
  denominateur = denominateur.map(function(feature) {
    return feature.set("CDI_denominateur", feature.get("sum"));
  });

  // Joindre les résultats de numérateur et dénominateur
  var joined = ee.Join.inner().apply({
    primary: numerateur,
    secondary: denominateur,
    condition: ee.Filter.equals({leftField: 'system:index', rightField: 'system:index'})
  });

  // Calculer le CDI pour chaque entité
  var cdiResult = joined.map(function(joinedFeature) {
    // Extraire les entités jointes
    var numerateurFeature = ee.Feature(joinedFeature.get('primary'));
    var denominateurFeature = ee.Feature(joinedFeature.get('secondary'));

    // Obtenir les valeurs des propriétés
    var num = ee.Number(numerateurFeature.get("CDI_numerateur"));
    var denom = ee.Number(denominateurFeature.get("CDI_denominateur"));

    // Calcul du CDI (éviter la division par zéro)
    var cdi = ee.Algorithms.If(denom.gt(0), num.divide(denom), 0);

    // Ajouter le CDI comme propriété à la zone administrative
    return numerateurFeature.set("CDI", cdi);
  });

  // Exporter les résultats
  Export.table.toDrive({
    collection: cdiResult,
    description: description, // Description spécifique pour admin0, admin1 ou admin2
    fileFormat: "CSV",
    selectors: [adminNameField, 'CDI_numerateur', 'CDI_denominateur', 'CDI'] // Inclut le champ admin0Name/admin1Name/admin2Name
  });

  // Visualiser les résultats
  Map.addLayer(cdiResult, {color: 'blue'}, "CDI - " + description);
  print("CDI - " + description, cdiResult);

  return cdiResult;
}

// Calculer le CDI pour admin0 (pays entier)
var admin0_cdi = calculateCDI(0, CDI_raster, R2, "CDI");

// Calculer le CDI pour admin1 (régions)
var admin1_cdi = calculateCDI(1, CDI_raster, R2, "CDI");

// Calculer le CDI pour admin2 (départements)
var admin2_cdi = calculateCDI(2, CDI_raster, R2, "CDI");




// Fonction pour ajouter une couche basée sur le CDI
function addCDILayer(cdiCollection, adminLevel) {
  // Définir un nom pour le niveau administratif
  var levelName = adminLevel === 0 ? "Admin0" : adminLevel === 1 ? "Admin1" : "Admin2";

  // Style pour visualiser les CDI
  var visualization = {
    min: 0,
    max: 1, // CDI est un ratio entre 0 et 1
    palette: ['purple', 'blue', 'green', 'yellow', 'orange', 'red'] //palette couramment utilisée pour les données de classe
  };

  // Créer une image rasterisée à partir des valeurs de CDI
  var cdiImage = cdiCollection.reduceToImage({
    properties: ['CDI'],
    reducer: ee.Reducer.first()
  });

  // Ajouter la couche thématique à la carte
  Map.addLayer(cdiImage, visualization, "CDI - " + levelName);
  print("Visualisation CDI - " + levelName, cdiCollection);
}

// Calculer et visualiser le CDI pour admin0 (pays entier)
var admin0_cdi = calculateCDI(0, CDI_raster, R2, "CDI");
addCDILayer(admin0_cdi, 0);

// Calculer et visualiser le CDI pour admin1 (régions)
var admin1_cdi = calculateCDI(1, CDI_raster, R2, "CDI");
addCDILayer(admin1_cdi, 1);

// Calculer et visualiser le CDI pour admin2 (départements)
var admin2_cdi = calculateCDI(2, CDI_raster, R2, "CDI");
addCDILayer(admin2_cdi, 2);



// Fonction pour ajouter une barre de couleurs (légende) à la carte
function addColorBar(title, palette, min, max) {
  // Créer un panneau pour la légende
  var legend = ui.Panel({
    style: {
      position: 'bottom-left',
      padding: '8px 15px'
    }
  });

  // Ajouter un titre à la légende
  var legendTitle = ui.Label({
    value: title,
    style: {
      fontWeight: 'bold',
      fontSize: '16px',
      margin: '0 0 4px 0',
      padding: '0'
    }
  });
  legend.add(legendTitle);

  // Créer une barre de couleurs 
  var makeColorBar = function(palette) {
    return ui.Thumbnail({
      image: ee.Image.pixelLonLat().select(0),
      params: {
        bbox: [0, 0, 1, 0.1],
        dimensions: '200x10',
        min: 0,
        max: 1,
        palette: palette
      },
      style: {stretch: 'horizontal', margin: '0px 8px', maxHeight: '24px'}
    });
  };

  var colorBar = makeColorBar(palette);
  legend.add(colorBar);

  // Ajouter les étiquettes min et max
  var legendLabels = ui.Panel({
    layout: ui.Panel.Layout.flow('horizontal'),
    style: {margin: '0 0 0 0', padding: '0'}
  });

  var minLabel = ui.Label({
    value: min.toString(),
    style: {margin: '4px 8px'}
  });
  var maxLabel = ui.Label({
    value: max.toString(),
    style: {margin: '4px 8px'}
  });

  legendLabels.add(minLabel);
  legendLabels.add(ui.Label(' ')); // Espace pour aligner les couleurs
  legendLabels.add(maxLabel);
  legend.add(legendLabels);

  // Ajouter la légende à la carte
  Map.add(legend);
}

// Utilisation de la barre pour la visualisation
var palette = ['purple', 'blue', 'green', 'yellow', 'orange', 'red'];
var min = 0;
var max = 1;
addColorBar('CDI Values', palette, min, max);





// Fonction pour ajouter une couche basée sur le CDI avec des labels aussi
function addCDILayerWithLabels(cdiCollection, adminLevel) {
  // Charger le package text
  var text = require('users/gena/packages:text');

  // Définir un nom pour le niveau administratif
  var levelName = adminLevel === 0 ? "Admin0" : adminLevel === 1 ? "Admin1" : "Admin2";

  // Style pour visualiser les CDI
  var visualization = {
    min: 0,
    max: 1, // CDI est un ratio entre 0 et 1
    palette: ['purple', 'blue', 'green', 'yellow', 'orange', 'red'] // Palette couramment utilisée pour les données de classe
  };

  // Créer une image rasterisée à partir des valeurs de CDI
  var cdiImage = cdiCollection.reduceToImage({
    properties: ['CDI'],
    reducer: ee.Reducer.first()
  });

  // Ajouter la couche  à la carte
  Map.addLayer(cdiImage, visualization, "CDI - " + levelName);

  // Définir l'échelle pour les labels
  var scale = Map.getScale() * 1;

  // Fonction pour normaliser les chaînes de texte pour éviter les conflits
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
  var labels = cdiCollection.map(function(feat) {
    feat = ee.Feature(feat);

    // Récupérer le nom de la zone (par exemple admin1Name) et la valeur CDI
    var zoneName = ee.String(feat.get(adminLevel === 0 ? "admin0Name" : adminLevel === 1 ? "admin1Name" : "admin2Name"));
    var cdiValue = ee.Number(feat.get("CDI")).format('%.3f'); // Formater la valeur de CDI avec 3 décimales

    // Combiner le nom de la zone et la valeur CDI avec ": "
    var name = zoneName.cat(' : ').cat(cdiValue);

    // Normaliser le texte
    name = normalizeString(name);

    // Calculer le centroïde de la géométrie pour placer l'étiquette
    var centroid = feat.geometry().centroid();

    // Créer une entité avec le texte au centroïde
    var t = text.draw(name, centroid, scale, {
      fontSize: 16,
      textColor: 'white',
      outlineWidth: 0.5,
      outlineColor: 'black'
    });
    return t;
  });

  // Fusionner toutes les étiquettes en une seule image
  var labelsFinal = ee.ImageCollection(labels).mosaic();

  // Ajouter les labels sur la carte
  Map.addLayer(labelsFinal, {}, "Labels - " + levelName);

  print("Visualisation CDI avec labels - " + levelName, cdiCollection);
}


// Calculer et visualiser le CDI pour admin0 (pays entier) avec labels
addCDILayerWithLabels(admin0_cdi, 0);

// Calculer et visualiser le CDI pour admin1 (régions) avec labels
addCDILayerWithLabels(admin1_cdi, 1);

// Calculer et visualiser le CDI pour admin2 (départements) avec labels
addCDILayerWithLabels(admin2_cdi, 2);