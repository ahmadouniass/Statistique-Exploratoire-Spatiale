*************************************************************************************************************
********* TP1 Statistique exploratoire spatiale
********* Files : "civ_admbnda_adm0_cntig_20180706_em.shp" "civ_admbnda_adm0_cntig_20180706_em.dbf" 
********* Last update : October 2024
********* Authors : Mame Balla BOUSSO, Hiledegarde EDIMA BIYENDA, Ameth FAYE and Papa Amadou NIANG  
*************************************************************************************************************

// Installation des packages nécessaires
ssc install spmap
ssc install shp2dta

// Conversion du fichier shapefile en format Stata (level 0)
shp2dta using "D:\Statistique exploratoire spatiale\Cours2\Statistique-Exploratoire-Spatiale\TP1 Importation et visualition des donnees spatiales\data\Shapefiles\RCI\civ_admbnda_adm0_cntig_20180706_em", database(civdb) coordinates(civcoord) genid(id)

// Chargement des données
use civdb, clear

// Création de la carte
spmap using civcoord, id(id) 

// Création de la carte
spmap using civcoord, id(id) ///
    title("Carte de la Côte d'Ivoire", size(*1.2) color(black)) ///
    fcolor(green) ///
    ocolor(black ..) ///
    osize(medium ..) ///
    legend(off)


// Conversion du fichier shapefile en format Stata (level 1)

shp2dta using "D:\Statistique exploratoire spatiale\Cours2\Statistique-Exploratoire-Spatiale\TP1 Importation et visualition des donnees spatiales\data\Shapefiles\RCI\civ_admbnda_adm1_cntig_ocha_itos_20180706_em", database(civdb1) coordinates(civcoord1) genid(id)

// Chargement des données
use civdb1, clear

// Création de la carte

spmap id using civcoord1, id(id) fcolor(Blues) legtitle("La côte d'Ivoire") legenda(on) mocolor(black) title("Découpage administratif de la Côte d'Ivoire") subtitle("2024" " ")