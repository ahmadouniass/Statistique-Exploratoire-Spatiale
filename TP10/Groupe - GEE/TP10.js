// Charger une collection d'images Sentinel-2 harmonisées
var collection = ee.ImageCollection('COPERNICUS/S2_SR_HARMONIZED')
  .filterDate('2023-01-01', '2023-12-31') // Filtrer les images capturées en 2023
  .filterBounds(table) // Filtrer sur la zone géographique du Burkina Faso
  .filterMetadata('CLOUDY_PIXEL_PERCENTAGE', 'less_than', 30) // Exclure les images avec plus de 30 % de nuages
  .sort('CLOUDY_PIXEL_PERCENTAGE'); // Trier par pourcentage de couverture nuageuse croissant

// Étape 1 : Prétraitement des images
// Découper les images sur les limites du Burkina Faso
var clippedCollection = collection.map(function(image) {
  return image.clip(table);
});

// === CALCUL DU NDVI ===
// Ajouter un calcul du NDVI (Normalized Difference Vegetation Index) à chaque image
var ndviCollection = clippedCollection.map(function(image) {
  var nir = image.select('B8'); // Bande proche infrarouge
  var red = image.select('B4'); // Bande rouge
  var ndvi = nir.subtract(red).divide(nir.add(red)).rename('NDVI'); // Formule du NDVI
  return image.addBands(ndvi); // Ajouter la bande NDVI calculée à l'image
});

// Créer une mosaïque basée sur le NDVI
var ndviMosaic = ndviCollection.qualityMosaic('NDVI');

// Définir les paramètres de visualisation pour le NDVI
var ndviParams = {
  min: -1,
  max: 1,
  palette: ['blue', 'white', 'green'] // Palette de couleurs pour visualiser la végétation
};

// Ajouter la mosaïque NDVI à la carte
Map.centerObject(table, 6); // Centrer sur le Burkina Faso
Map.addLayer(ndviMosaic.select('NDVI'), ndviParams, 'NDVI Burkina Faso');

// Exporter la mosaïque NDVI
Export.image.toDrive({
  image: ndviMosaic.select('NDVI'),
  description: 'NDVI_Mosaic',
  scale: 30,
  region: table.geometry().bounds(),
  fileFormat: 'GeoTIFF',
  maxPixels: 1e13
});

// === CALCUL DU BI (Bare Index) ===
// Calculer le BI (Indice des sols nus) pour chaque image
var biCollection = clippedCollection.map(function(image) {
  var red = image.select('B4'); // Bande rouge
  var green = image.select('B3'); // Bande verte
  var nir = image.select('B8'); // Bande proche infrarouge
  var blue = image.select('B2'); // Bande bleue
  var bi = red.add(green).divide(nir.add(blue)).rename('BI'); // Formule du BI
  return image.addBands(bi);
});

// Créer une mosaïque basée sur le BI
var biMosaic = biCollection.qualityMosaic('BI');

// Définir les paramètres de visualisation pour le BI
var biParams = {
  min: 0,
  max: 2,
  palette: ['brown', 'yellow', 'white'] // Palette pour visualiser les sols nus
};

// Ajouter la mosaïque BI à la carte
Map.addLayer(biMosaic.select('BI'), biParams, 'BI Burkina Faso');

// Exporter la mosaïque BI
Export.image.toDrive({
  image: biMosaic.select('BI'),
  description: 'BI_Mosaic',
  scale: 30,
  region: table.geometry().bounds(),
  fileFormat: 'GeoTIFF',
  maxPixels: 1e13
});

// === CALCUL DU NDWI ===
// Calculer le NDWI (Normalized Difference Water Index) pour chaque image
var ndwiCollection = clippedCollection.map(function(image) {
  var green = image.select('B3'); // Bande verte
  var nir = image.select('B8'); // Bande proche infrarouge
  var ndwi = green.subtract(nir).divide(green.add(nir)).rename('NDWI'); // Formule du NDWI
  return image.addBands(ndwi);
});

// Créer une mosaïque basée sur le NDWI
var ndwiMosaic = ndwiCollection.qualityMosaic('NDWI');

// Définir les paramètres de visualisation pour le NDWI
var ndwiParams = {
  min: -1,
  max: 1,
  palette: ['blue', 'white', 'green'] // Palette pour visualiser les zones d'eau
};

// Ajouter la mosaïque NDWI à la carte
Map.addLayer(ndwiMosaic.select('NDWI'), ndwiParams, 'NDWI Burkina Faso');

// Exporter la mosaïque NDWI
Export.image.toDrive({
  image: ndwiMosaic.select('NDWI'),
  description: 'NDWI_Mosaic',
  scale: 30,
  region: table.geometry().bounds(),
  fileFormat: 'GeoTIFF',
  maxPixels: 1e13
});

// === CALCUL DU NDMI ===
// Calculer le NDMI (Normalized Difference Moisture Index) pour chaque image
var ndmiCollection = clippedCollection.map(function(image) {
  var nir = image.select('B8'); // Bande proche infrarouge
  var swir1 = image.select('B11'); // Bande SWIR1
  var ndmi = nir.subtract(swir1).divide(nir.add(swir1)).rename('NDMI'); // Formule du NDMI
  return image.addBands(ndmi);
});

// Créer une mosaïque basée sur le NDMI
var ndmiMosaic = ndmiCollection.qualityMosaic('NDMI');

// Définir les paramètres de visualisation pour le NDMI
var ndmiParams = {
  min: -1,
  max: 1,
  palette: ['brown', 'white', 'green'] // Palette pour visualiser l'humidité
};

// Ajouter la mosaïque NDMI à la carte
Map.addLayer(ndmiMosaic.select('NDMI'), ndmiParams, 'NDMI Burkina Faso');

// Exporter la mosaïque NDMI
Export.image.toDrive({
  image: ndmiMosaic.select('NDMI'),
  description: 'NDMI_Mosaic',
  scale: 30,
  region: table.geometry().bounds(),
  fileFormat: 'GeoTIFF',
  maxPixels: 1e13
});

// === CALCUL DE L'URBAN INDEX (UI) ===
// Calculer l'Urban Index (UI) pour chaque image
var uiCollection = clippedCollection.map(function(image) {
  var swir = image.select('B11'); // Bande SWIR1
  var nir = image.select('B8'); // Bande proche infrarouge
  var ui = swir.subtract(nir).divide(swir.add(nir)).rename('UI'); // Formule de l'Urban Index
  return image.addBands(ui);
});

// Créer une mosaïque basée sur l'UI
var uiMosaic = uiCollection.qualityMosaic('UI');

// Définir les paramètres de visualisation pour l'UI
var uiParams = {
  min: -1,
  max: 1,
  palette: ['blue', 'yellow', 'red'] // Palette pour visualiser les zones urbaines
};

// Ajouter la mosaïque UI à la carte
Map.addLayer(uiMosaic.select('UI'), uiParams, 'Urban Index Burkina Faso');

// Exporter la mosaïque UI
Export.image.toDrive({
  image: uiMosaic.select('UI'),
  description: 'UI_Mosaic',
  scale: 30,
  region: table.geometry().bounds(),
  fileFormat: 'GeoTIFF',
  maxPixels: 1e13
});

//Essayons d'ajouter les barres de couleur


// Fonction pour ajouter une barre de couleurs (légende) à la carte
function addColorBar(title, palette, min, max, position) {
  // Créer un panneau pour la légende
  var legend = ui.Panel({
    style: {
      position: position || 'bottom-left', // Position par défaut
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

// === Ajout des échelles pour chaque indice ===

// NDVI
addColorBar('NDVI (Végétation)', ['blue', 'white', 'green'], -1, 1, 'bottom-left');

// BI
addColorBar('BI (Sols Nus)', ['brown', 'yellow', 'white'], 0, 2, 'bottom-right');

// NDWI
addColorBar('NDWI (Zones d\'Eau)', ['blue', 'white', 'green'], -1, 1, 'top-left');

// NDMI
addColorBar('NDMI (Humidité)', ['brown', 'white', 'green'], -1, 1, 'top-right');

// UI
addColorBar('Urban Index (Zones Urbaines)', ['blue', 'yellow', 'red'], -1, 1, 'bottom-left');
