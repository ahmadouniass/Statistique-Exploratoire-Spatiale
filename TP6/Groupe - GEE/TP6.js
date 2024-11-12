/*****************************************************
 ******* TP6 statistique exploratoire spatiale *******
 * Membre du groupe :
 * - Ameth FAYE
 * - Mame Balla BOUSSO
 * - Hiledegarde EDIMA BIYENDA
 * - Papa Amadou NIANG
 * 
 * Consigne du TP :
 * 
 * - Importer les points
 * - Compter le nombre de points par admin
 * - A partir des points, créer un raster de 5 km qui regroupe  les différents points
 * - Visualiser le raster sous forme de catégories
 * 
 ****************************************************/

/*****************************************************
 * Etape1 : Importation des fichiers 
*****************************************************/

// Importer les limites des différents admins
var AD0_SN = ee.FeatureCollection("projects/ee-papaamadouniang2004/assets/sen_admbnda_adm0_anat_20240520"); // Pays
var AD1_SN = ee.FeatureCollection("projects/ee-papaamadouniang2004/assets/sen_admbnda_adm1_anat_20240520"); // Régions
var AD2_SN = ee.FeatureCollection("projects/ee-papaamadouniang2004/assets/sen_admbnda_adm2_anat_20240520"); // Départements
var AD3_SN = ee.FeatureCollection("projects/ee-papaamadouniang2004/assets/sen_admbnda_adm3_anat_20240520"); // Communes

//1) Importer les points
var points = ee.FeatureCollection("projects/ee-papaamadouniang2004/assets/Points_data");

// Clipper les points aux limites du pays
var pointsSN = points.filterBounds(AD0_SN);

// Appliquer le filtre
var points_SN = points.filter(ee.Filter.eq('country', 'Senegal'));

print(pointsSN);
print(points_SN);

// Afficher les limites du pays et les points sur la carte
Map.addLayer(points_SN, {color: 'red'}, 'Points_SN');
Map.addLayer(pointsSN, {color: 'blue'}, 'PointsSN');
Map.centerObject(AD0_SN, 7); // Centrer la carte sur le pays

/*****************************************************
 * Etape2 : Compter le nombre de points par admin
*****************************************************/

// Fonction pour compter les points par unité administrative
function countPointsByAdmin(adminFC, adminNameField, levelName) {
  // Joindre les pointsSN aux unités administratives
  var joined = ee.Join.saveAll('points').apply({
    primary: adminFC,
    secondary: pointsSN,
    condition: ee.Filter.contains({
      leftField: '.geo',
      rightField: '.geo'
    })
  });

  // Ajouter le compte de points à chaque unité administrative
  var pointsPerAdmin = joined.map(function(feature) {
    var pointCount = ee.List(feature.get('points')).length();
    return feature.set({
      'point_count': pointCount,
      'admin_level': levelName,
      'admin_name': feature.get(adminNameField)
    });
  });

  // Retourner la collection avec le compte
  return pointsPerAdmin;
}

// Niveau 0 : Pays
var pointsPerAdmin0 = countPointsByAdmin(AD0_SN, 'ADM0_EN', 'Pays');

// Niveau 1 : Régions
var pointsPerAdmin1 = countPointsByAdmin(AD1_SN, 'ADM1_EN', 'Région');

// Niveau 2 : Départements
var pointsPerAdmin2 = countPointsByAdmin(AD2_SN, 'ADM2_EN', 'Département');

// Niveau 3 : Communes
var pointsPerAdmin3 = countPointsByAdmin(AD3_SN, 'ADM3_EN', 'Commune');

// Vérifions ce qui se passe dans les régions
print(pointsPerAdmin1)


// Vérifions si les sommes des points correspondent...
// Vérifier le nombre total de points au niveau du pays
print('Nombre total de points au niveau du pays :', pointsPerAdmin0.aggregate_sum('point_count'));

// Vérifier le nombre total de points au niveau des régions
print('Nombre total de points au niveau des régions :', pointsPerAdmin1.aggregate_sum('point_count'));

// Vérifier le nombre total de points au niveau des départements
print('Nombre total de points au niveau des départements :', pointsPerAdmin2.aggregate_sum('point_count'));

// Vérifier le nombre total de points au niveau des communes
print('Nombre total de points au niveau des communes :', pointsPerAdmin3.aggregate_sum('point_count'));

/*****************************************************
 * Etape3 : A partir des points, créer un raster de 5 km qui regroupe  les différents points
*****************************************************/

// Définir la projection UTM Zone 28N avec une résolution de 5 km
var projection = ee.Projection('EPSG:32628').atScale(5000);

// Créer une image en comptant le nombre de points par pixel
var pointImage = pointsSN.map(function(feature) {
  return feature.set('dummy', 1);
}).reduceToImage({
  properties: ['dummy'],
  reducer: ee.Reducer.count()
}).reproject({
  crs: projection,
  scale: 5000
});

/*****************************************************
 * Etape4 : Visualiser le raster sous forme de catégories
*****************************************************/

// Clipper le raster aux limites du pays
var pointImageClipped = pointImage.clip(AD0_SN);
var maskedImage = pointImageClipped.updateMask(pointImageClipped.gt(0));

// Afficher le raster des points
Map.addLayer(maskedImage, {min: 1, max: 10, palette: ['blue']}, 'Raster des Points (5 km)');