library(shiny)
library(leaflet)
library(DT)
library(sf)
library(ggplot2)
library(here)
library(leaflet.extras)
library(exactextractr)
library(viridis)
library(terra)
library(dplyr)
library(shinyjs)
library(stringr)



setwd(here())

# Définir le répertoire de travail avec here()




# Chemins des rasters----------------------
raster_paths <- list(
  "Senegal" = list(
    "NDVI" = "Senegal/Spectral_indexes/NDVI_SN.tif",
    "MNDWI" = "Senegal/Spectral_indexes/MNDWI_SN.tif",
    "BSI_1" = "Senegal/Spectral_indexes/Bare_Soil_Index_SN.tif",
    "NDBI" = "Senegal/Spectral_indexes/NDBI_SN.tif",
    "Number of events" = "Senegal/Political_events/Events_SEN_2018_2024.tiff",
    "Events types and locations" = "Senegal/Political_events/Points_data.csv",
    "Conflict Diffusion Indicator"="Senegal/Political_events", # not raster
    "Taux Malaria (2000 - 2022)"="Senegal/Malaria/Malaria_SEN_multi_bands.tiff",
    "animation"= "Senegal/Malaria/animation.gif")
  ,
  "Burkina Faso" = list(
    "NDVI" = "Burkina/Spectral_indexes/NDVI_BFA.tif",
    "MNDWI" = "Burkina/Spectral_indexes/MNDWI_BFA.tif",
    "BSI_1" = "Burkina/Spectral_indexes/Bare_Soil_Index_BFA.tif",
    "NDBI" = "Burkina/Spectral_indexes/NDBI_BFA.tif",
    "Number of events" = "Burkina/Political_events/Events_BFA_2018_2024.tiff",
    "Events types and locations" = "Burkina/Political_events/Points_data.csv",
    "Conflict Diffusion Indicator"=" ",  ## No raster-----------
    "Taux Malaria (2000 - 2022)"="Burkina/Malaria/Malaria_BFA_multi_bands.tiff",
    "animation"= "Burkina/Malaria/animation.gif"
    
  ),
  "Madagascar" = list(
    "NDVI" = "Madagascare/Spectral_indexes/NDVI_MDG.tif",
    "MNDWI" = "Madagascare/Spectral_indexes/MNDWI_MDG.tif",
    "BSI_1" = "Madagascare/Spectral_indexes/Bare_Soil_Index_MDG.tif",
    "NDBI" = "Madagascare/Spectral_indexes/NDBI_MDG.tif",
    "Taux Malaria (2000 - 2022)"="Madagascare/Malaria/Malaria_MDG_multi_bands.tiff",
    "animation"= "Madagascare/Malaria/animation.gif"
    
  ),
  
  "Cameroun" = list(
    "NDVI" = "Cameroon/Spectral_indexes/NDVI_CMR.tif",
    "MNDWI" = "Cameroon/Spectral_indexes/MNDWI_CMR.tif",
    "BSI_1" = "Cameroon/Spectral_indexes/Bare_Soil_Index_CMR.tif",
    "NDBI" = "Cameroon/Spectral_indexes/NDBI_CMR.tif",
    "Taux Malaria (2000 - 2022)"="Cameroon/Malaria/Malaria_CMR_multi_bands.tiff",
    "animation"= "Cameroon/Malaria/animation.gif"
    
  )
)


# Chemins des shapefiles (par niveau)-------------------------
shapefile_paths <- list(
  "Senegal" = list(
    "Niveau_0" = "Senegal/Shapefiles/sen_admbnda_adm0_anat_20240520.shp",
    "Niveau_1" = "Senegal/Shapefiles/sen_admbnda_adm1_anat_20240520.shp",
    "Niveau_2" = "Senegal/Shapefiles/sen_admbnda_adm2_anat_20240520.shp",
    "Niveau_3" = "Senegal/Shapefiles/sen_admbnda_adm3_anat_20240520.shp"
  ),
  "Burkina Faso" = list(
    "Niveau_0" = "Burkina/Shapefiles/geoBoundaries-BFA-ADM0.shp",
    "Niveau_1" = "Burkina/Shapefiles/geoBoundaries-BFA-ADM1.shp",
    "Niveau_2" = "Burkina/Shapefiles/geoBoundaries-BFA-ADM2.shp",
    "Niveau_3" = "Burkina/Shapefiles/geoBoundaries-BFA-ADM3.shp"
  ),
  "Madagascar" = list(
    "Niveau_0" = "Madagascare/Shapefiles/geoBoundaries-MDG-ADM0.shp",
    "Niveau_1" = "Madagascare/Shapefiles/geoBoundaries-MDG-ADM1.shp",
    "Niveau_2" = "Madagascare/Shapefiles/geoBoundaries-MDG-ADM2.shp",
    "Niveau_3" = "Madagascare/Shapefiles/geoBoundaries-MDG-ADM3.shp"
  ),
  "Cameroun" = list(
    "Niveau_0" = "Cameroon/Shapefiles/geoBoundaries-CMR-ADM0.shp",
    "Niveau_1" = "Cameroon/Shapefiles/geoBoundaries-CMR-ADM1.shp",
    "Niveau_2" = "Cameroon/Shapefiles/geoBoundaries-CMR-ADM2.shp",
    "Niveau_3" = "Cameroon/Shapefiles/geoBoundaries-CMR-ADM3.shp"
  )
)

# Palette -----------------------

indicator_palettes <- list(
  "NDVI" = colorNumeric("YlGn", NULL, na.color = "transparent"),  # NDVI : vert
  "MNDWI" = colorNumeric("Blues", NULL, na.color = "transparent"),  # MNDWI : bleu
  "BSI_1" = colorNumeric("Oranges", NULL, na.color = "transparent"),  # BSI : orange
  "NDBI" = colorNumeric("Purples", NULL, na.color = "transparent"),   # NDBI : violet
  "Taux Malaria (2000 - 2022)"=  colorNumeric("inferno", NULL, na.color = "transparent")
)


## UI ------------------------

ui <- fluidPage(
  tags$head(
    # Icone ...
    tags$link(rel = "icon", type = "image/png", href = "dash.png")
  ),
  title = "Cartographie des indicateurs",
  useShinyjs(),  
  # Bloc 1: Navigation en haut de la page
  navbarPage(
    downloadButton("downloadNotes", "Télécharger les notes techniques", 
                   style = "margin-left: auto; margin-right: 5px; background-color: #f9f9f9; padding: 3px 10px;"),
    id = "mainNavbar",  # Ajout d'un id pour le navbarPage
    tabPanel("Accueil", icon = icon("home"),
             # Bloc 2: Description de l'application à gauche et SelectInputs à droite
             div(
               style = "border: 2px solid red; margin: 5px 0px 20px 0px; background-color: #f0f0f0; border-radius: 2px; text-align: center;",
               h2("
Cartographie infranationale interactive des indicateurs sanitaires (taux de malaria), évènements politiques et indices spectraux"),
             ),
             fluidRow(
               column(
                 8,
                 div(
                   class = "info-box",
                   style = "border: 2px solid red; padding: 15px; background-color: #f0f0f0; border-radius: 5px;",
                   p("Cette plateforme est un outil de visualisation web qui présente différents indicateurs sanitaires (notamment le taux de malaria), événements politiques et indices spectraux calculés au niveau infranational (zones géographiques inférieures au niveau national) pour une sélection de pays africains (Sénégal, Burkina Faso, Madagascar et Cameroun). Ces indicateurs sont présentés sous trois formes principales : une carte interactive, des graphiques dynamiques et des tableaux récapitulatifs. L'évolution temporelle est disponible pour certains indicateurs, notamment le taux de malaria (2000-2022) qui est également présenté sous forme d'animation."),
                   p("Veuillez consulter les sections ",
                     tags$a(href = "#", onclick = "Shiny.setInputValue('go_to_tab', 'Guide')", "Guide"), 
                     " et ",
                     tags$a(href = "#", onclick = "Shiny.setInputValue('go_to_tab', 'A propos')", "A propos"), 
                     " pour plus d'informations sur l'utilisation de cette plateforme et la méthodologie employée pour le calcul des différents indicateurs.")
                 )
               ),
               column(
                 4,
                 div(
                   class = "selection-box",
                   style = "border: 2px solid red; padding: 15px; background-color: #f9f9f9; border-radius: 5px;",
                   selectInput(
                     
                     ## selecting country ----------------------------------
                     "country", 
                     "Sélectionner un pays:", 
                     choices = c(" ","Senegal", "Burkina Faso", "Madagascar", "Cameroun"), 
                     selected = " "
                   ),
                   conditionalPanel(
                     condition = "input.country != ' '",
                     selectInput(
                       ## selecting indicator------------------------------------
                       "indicator", 
                       "Sélectionner un indicateur:", 
                       choices = list(
                         " ",
                         "Malaria"= c("Taux Malaria (2000 - 2022)", "Children affected"),
                         "Political events" =c("Events types and locations", "Conflict Diffusion Indicator"),
                         "Spectral Indexes" =c("NDVI", "MNDWI", "BSI_1", "NDBI"),
                         
                         selected = " "
                       ))),
                   tags$small("Pas d'événements politiques dans la base pour Madagascar et Cameroun.")
                   
                   
                   
                 )
               )
             ),
             
             conditionalPanel(
               condition = "input.country !== ' ' && input.indicator !== ''",
               # Bloc 3: Zone de texte décrivant l'indicateur sélectionné--------------------------------
               fluidRow(
                 column(
                   12,
                   div(
                     class = "description-box",
                     style = "border: 2px solid red; padding: 10px;margin: 20px 0px 20px 0px; background-color: #f9f9f9; border-radius: 5px; text-align:center;",
                     uiOutput("indicatorDescription") # Description dynamique
                   )
                 )
               )),
             conditionalPanel(
               condition = "input.country !== ' ' && input.indicator !== ''",
               # Bloc 4: Partie gauche (4_A) et droite (4_B)
               fluidRow(
                 # Bloc 4_A (gauche)
                 column(
                   8,
                   div( id = "mapBox", 
                        class = "map-box",
                        style = "border: 1px solid #ddd; padding: 15px; background-color: #f9f9f9; border-radius: 5px;",
                        # Bouton d'agrandissement
                        actionButton("expand_map", "↔", class = "btn btn-primary", style = "position: absolute; top: 10px; right: 10px; z-index: 999;"),
                        downloadButton("downloadShapefile", "Télécharger le SHP", class = "btn btn-primary"),
                        
                        # Partie haute (Nom et légende)
                        fluidRow(
                          column(
                            9,
                            h4(uiOutput("variableTitle"), style = "color: white; background-color: red; padding: 5px; border-radius: 5px;"),
                            p("Description of the selected variable will go here.", style = "margin-top: 10px;")
                          ),
                          column(
                            3,
                            div(
                              style = "border: 1px solid #ddd; padding: 5px; background-color: #fff; border-radius: 5px; text-align: center;",
                              p("Legend"),
                              plotOutput("legendPlot", height = "50px") # Légende dynamique
                            )
                          )
                        ),
                        # Partie basse (Carte leaflet)
                        titlePanel("Affichage de la carte"),
                        
                        # Nouveau sélecteur d'année pour la malaria--------------------------
                        conditionalPanel(
                          condition = "input.indicator == 'Taux Malaria (2000 - 2022)'",
                          selectInput(
                            "year",
                            "Select Year:",
                            choices = 2000:2022,
                            selected = 2000
                          )
                        ),
                        
                        # Nouveau sélecteur d'année pour Chidren affected Malaria------------------------------------------
                        conditionalPanel(
                          condition = "input.indicator == 'Children affected'",
                          selectInput(
                            "child_year",
                            "Select Year:",
                            choices = 2018:2020,
                            selected = 2020
                          )
                        ),
                        
                        # Nouveau sélecteur d'année pour le CDI  ------------------------------------------
                        conditionalPanel(
                          condition = "input.indicator == 'Conflict Diffusion Indicator'",
                          selectInput(
                            "CDI_year",
                            "Select Year:",
                            choices = 2018:2020,
                            selected = 2018
                          )
                        ),
                        leafletOutput("mapOutput", height = 400),
                        
                        # Bloc 5: Menu sous la carte
                        fluidRow(
                          column(
                            12,
                            div(
                              style = "border: 1px solid #ddd; padding: 10px; background-color: #f9f9f9; border-radius: 5px; margin-top: 15px;",
                              h5("La zone d'intérêt peut être sélectionnée en cliquant sur la carte ou en sélectionnant une région sur le menu déroulant en bas de la carte"),
                              selectInput(
                                "stateSelector",
                                "Select a Region:",
                                choices = NULL, # Initialement vide, sera mis à jour dynamiquement
                                selected = NULL
                              )
                              
                            )
                          )
                        )
                   )
                 )
                 ,
                 tags$style(HTML("
#stateSelector + .selectize-control .selectize-dropdown {
  position: absolute !important;
  bottom: 100% !important;
  top: auto !important;
  margin-bottom: 10px;
}
")),
                 
                 # Bloc 4_B (droite)
                 column(
                   4,
                   div(
                     id = "tableBox",  
                     class = "table-box",
                     style = "border: 1px solid #ddd; padding: 15px; background-color: #f9f9f9; border-radius: 5px;",
                     # Bouton d'agrandissement
                     actionButton("expand_table", "↔", class = "btn btn-primary", style = "position: absolute; top: 10px; right: 10px; z-index: 999;"),
                     downloadButton("downloadContent", "", class = "btn btn-secondary", style = "z-index: 999;", icon = icon("download")),
                     
                     # Afficher le titre dynamique pour l'indicateur, pays et région
                     div(
                       style = "margin-bottom: 15px;",
                       h5(
                         textOutput("regionInfo"),
                         style = "color: #333; font-weight: bold; font-size: 16px; text-align: center;"
                       )
                     ),
                     
                     # Section titre et texte explicatif
                     div(
                       h4(
                         uiOutput("selectedVariableTitle"), 
                         style = "color: white; background-color: red; padding: 5px; border-radius: 5px; display: inline-block;"
                       ),
                       h4(
                         uiOutput("selectedRegionTitle"), 
                         style = "color: white; background-color: red; padding: 5px; border-radius: 5px; display: inline-block; margin-left: 10px;"
                       )
                     ),
                     
                     
                     # Tableau interactif avec ongletss
                     tabsetPanel(
                       id = "tabs", 
                       tabPanel(
                         "Summary",
                         tableOutput("summaryTable"), ## summary-----------------------
                         textOutput("describe"),
                         uiOutput("textBelowTable")
                       ),
                       tabPanel(
                         "Table",
                         DTOutput("dataTable") ## Table ------------------
                       ),
                       tabPanel(
                         "Chart",
                         plotOutput("chartOutput") # CHart ----------------------------
                       ),
                       tabPanel(  
                         "Malaria GIF", # Image -----------
                         conditionalPanel(
                           condition = "input.indicator == 'Taux Malaria (2000 - 2022)'",
                           imageOutput("ImageGIF")))
                     )
                   )
                 )
               )),tags$style(HTML("
    .expanded {
      position: fixed !important;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      z-index: 1000;
      background-color: white !important;
      padding: 20px !important;
      overflow: auto;
    }
    .hidden {
      display: none !important;
    }
  "))),
    tabPanel("A propos", icon = icon("info-circle"), 
             fluidPage(
               div(
                 style = "padding: 20px;",
                 h2("À propos de l'application"),
                 p("Cette application interactive permet d'explorer et de visualiser des indicateurs sanitaires, politiques et environnementaux à l'échelle infranationale."),
                 p("Elle a été développée dans le but de fournir aux chercheurs, décideurs et analystes une vue d'ensemble sur les données régionales.")
               ), 
               uiOutput("Apropos"))
    ), 
    tabPanel("Guide", icon = icon("book"),
             fluidPage(
               div(
                 style = "padding: 20px;",
                 h2("Guide de l'utilisateur"),
                 p("Ce guide explique comment naviguer et interagir avec l'application.")
               ),
               uiOutput("Guidecontent"))
    )
    ,
    tabPanel("Notes techniques", icon = icon("cog"),
             h2("Notes techniques"),
             
             # Contenu principal, modifiable dynamiquement
             uiOutput("notesContent")
    )
  )
)

server <- function(input, output, session) {
  
  
  ## A propos --------
  output$Apropos <- renderUI({
    fluidPage(
      # Introduction
      
      p("Permettant  de visualiser des indicateurs, tels que le NDVI, MNDWI, 
        BSI_1 et NDBI, pour quatre (04) pays (Sénégal, Burkina Faso, Madagascar, Cameroun), elle 
        intègre des données spatiales à différents niveaux administratifs et des images raster pour 
        analyser des tendances géographiques et temporelles. L'utilisateur peut sélectionner un pays, 
        un indicateur, ainsi qu'une région spécifique via une carte ou des menus déroulants. Les données 
        sont affichées sous forme de cartes interactives, de graphiques, et de tableaux dynamiques, 
        permettant une exploration approfondie des valeurs et des changements significatifs des 
        indicateurs sélectionnés. Le tout est enrichi par des descriptions dynamiques et des outils de 
        filtrage, favorisant une analyse ciblée et intuitive des données géospatiales et des variations 
        locales."),
      
      h3("Remerciements"),
      p("Nous tenons à exprimer notre profonde gratitude à notre professeur Monsieur Aboubacar 
        HEMA pour sa pédagogie exceptionnelle et ses précieux conseils de vie. Votre manière d’enseigner, 
        basée sur le « learning by doing », nous a permis d’apprendre en agissant, de mieux comprendre les 
        concepts et de les appliquer efficacement. Nous nous sommes imprégner des statistiques exploratoires 
        spatiales et comptons mettre en applications les connaissances apprises durant ce cours. "),
      p("Au-delà des connaissances théoriques, vos précieux conseils et votre capacité à rendre les 
        sujets complexes accessibles ont grandement contribué à notre progression. Merci d’avoir su créer un 
        environnement d’apprentissage stimulant et inspirant. Nous espérons, dans le futur, avoir la chance 
        de travailler avec vous sur des projets d'envergures pour vous prouver que ces 30h que nous avons 
        passées n'auront aucunement été vaines."),
      p("Nous nous souviendrons toujours de cette phrase prononcée à notre endroit : << Ne soyez jamais déçus>>."),
      
      h3("Post Scriptum"),
      
      p("Cette application est développée par DIENG SAMBA, ONANENA AMANA JEANNE DE LA FLECHE, NDONG TAMSIR et COULIBALY KHADIDIATOU,
        élèves en ISE1 Cycle Long à l'ENSAE Pierre Ndiaye de Dakar (Année académique : 2024 - 2025).")
      
    )
  })
  
  
  ## Texte GUIDE -----------------
  
  output$Guidecontent <- renderUI({
    fluidPage(
      # Introduction
      
      # Bloc A
      h3("Présentation de l'application à l'ouverture"),
      img(src = "bloc_1.png", height = "250px", width = "900px", alt = "Présentation de l'application à l'ouverture"),
      p(" "),
      p("Pour mieux nous repérer dans la structuration de l'application, nous parlons de blocs. A l 'ouverture, sont visblesles blocs 1, 2A et 2B."),
      tags$ul(
        tags$li("Le bloc 1 donne le titre de l'application tout en présentant les indicateurs qui y sont présentés."),
        tags$li("Le bloc 2A fait une description détaillée de l'application, ses fonctionnalités ainsi que les indicateurs étudiés."),
        tags$li("Le bloc 2B permet à l'utilisateur de sélectionner le pays et les indicateurs à visualiser via des menus déroulants.")),
      p("Après le choix du pays et de l'indicateur, apparait le reste des blocs.")
      ,
      
      # Section 2 : Image 2
      h3(" Description des variables"),
      img(src = "bloc_3.png", height = "250px", width = "900px", alt = "Description des variables"),
      p(" "),
      p("Le bloc 3 présente une description de la variable sélectionnée."),
      
      
      h3("Affichage de la carte et informations au clic"),
      img(src = 'bloc_4.png', height = "350px", width = "900px", alt = "Selection au clic sur la carte"),
      p(" "),
      p("Le bloc 4A permet d'afficher une carte interactive pour visualiser les indicateurs sélectionnés à l'échelle régionale, des boutons pour zoomer, réduire et centrer la carte.
      Le bloc 4B lui, présente des visualisations au niveau départemental sous forme de tableaux et de graphiques. Dans ce bloc on a également un résumé qui donne la moyenne, valeur minimale et valeur maximale de la région sélectionnée. 
        On a enfin, pour le cas spécifique du taux de Malaria, une animation .gif qui permet de visualiser l'évolution de ce dernier de 2000 à 2022(time series animation).
        A noter que les informations au niveau départemental apparaissent suivant la région cliquée sur la carte, mais pas que."),
      
      h3("Selection de la région"),
      p(" "),
      img(src = "bloc_5.png", height = "150px", width = "900px", alt = "Selection 'manuelle' "),
      p(" "),
      p("Au niveau du bloc 5, il est possible de selectionner une région et de voir au niveau du bloc 4B les informations relatives à ses divisions administrativces."),
      
      h3("Autres onglets"),
      img(src = "nav.png", height = "70px", width = "900px", alt = "Autres"),
      p(" "),
      p("A tout cela s'ajoutent les onglets 'A propos', 'Notes techniques' ainsi que les boutons de téléchargement des informations visualisées et de la note technique.")
      
      
    )
  })
  observeEvent(input$go_to_tab, {
    updateTabsetPanel(session, "mainNavbar", selected = input$go_to_tab) #naviguer entre les onglets
  })
  
  observeEvent(input$expand_map, {
    toggleClass("mapBox", "expanded")  # Basculer la classe expanded
    toggleClass("tableBox", "hidden") # Masquer le tableau (bloc 4_B)
  })
  
  # Agrandissement du bloc Table (4_B)
  observeEvent(input$expand_table, {
    toggleClass("tableBox", "expanded")  # Basculer la classe expanded
    toggleClass("mapBox", "hidden")     # Masquer la carte (bloc 4_A)
  })
  
  output$indicatorDescription <- renderUI({
    req(input$indicator)
    text <- switch(input$indicator,
                   "NDVI" = "Le Normalized Difference Vegetation Index (NDVI) est peut-être le plus indice spectral commun est 
                             l'indice de différence de végétation normalisée (NDVI). Cet indice est principalement utilisé pour détecter 
                              la densité et la santé de la végétation. 
                              NDVI est dérivé comme suit : (NIR - RED)/(NIR + RED).",
                   "MNDWI" = "Le (MNDWI) Modified Normalized Difference Water Index est un indice spectral 
                               commun pour l'extraction les surfaces d’eau modifiée par rapport au traditionnel indice
                               de différence normalisé des eaux (NDWI). Encore une fois, les valeurs vont de -1 à 1 et les 
                               valeurs supérieures à 0 représentent généralement des plans d'eau (océans, lacs, rivières, etc.). 
                               Le MNDWI est calculé similaire à NDVI, comme suit : (Green - SWIR)/(Green + SMIR).",
                   "Taux Malaria (2000 - 2022)" = "Le Taux de Malaria (2000 - 2022) représente la prévalence estimée de la malaria
                                                sur une période donnée, exprimée en pourcentage pour différentes zones géographiques. 
                                               Cet indicateur permet d'évaluer les efforts de lutte contre la malaria, de surveiller les 
                                              progrès réalisés et d’identifier les zones à risque nécessitant des interventions ciblées. Les données sont disponibles de 2000 à 2022",
                   "Children affected" = "Il s'agit du nombre d'enfants, de 0 à 12 ans, de Malaria. Il est obtenu en supposant les enfants de cette tranche d'âge
                   représentent 0.1% de la population.",
                   "Conflict Diffusion Indicator" = "Le Conflict Diffusion Indicator (CDI) mesure la dispersion géographique de la violence politique dans une région donnée. Basé sur les données d’ACLED et les estimations démographiques
                                                   de WorldPop, il calcule la proportion de zones densément peuplées (grille 10x10 km) ayant enregistré au moins trois événements de conflit par an. Un CDI élevé indique une violence largement 
                                                   répartie, tandis qu’un CDI faible reflète une concentration des conflits. Cette mesure permet de comprendre les défis liés à la gestion des conflits dans des contextes spatialement étendus.",
                   "Events types and locations" = "Cet indicateur présente les types d'événements politiques notamment une séries de conflits que sont : les batailles, les explosions et/ou violences à distance, les manifestations, les émeutes, le développement stratégique, et les violence contre les civils (battles, explosions/remote violence, protests, riots, strategic development, violence against civilians)",
                   "BSI_1" = "Le Bare Soil Index (BSI) est un indice spectral utilisé pour détecter et caractériser
                            les sols nus à partir d’images satellites. Il met en évidence les zones où la végétation est absente ou peu dense, en contrastant les propriétés spectrales du sol avec celles des surfaces végétalisées ou aquatiques. A noter que, d'après nos recherches, il existe d'autres formules du BSI.",
                   "NDBI" = "Le Normalized Difference Built-up Index (NDBI) décrit la densité de construction de toute 
                            zone géographique. Il utilise les bandes du proche infrarouge (NIR) et de l'infrarouge à ondes courtes (SWIR) pour mettre en évidence les zones bâties manufacturées. Il se calcule comme suit : NDBI =(SWIR - NIR) / (SWIR + NIR).")
    
    tagList(
      h4(input$indicator, style = "color: white; background-color: red; padding: 5px; border-radius: 5px;"),
      p(text)
    )
  })
  observe({
    # Déterminer si une région est sélectionnée
    show_block <- !is.null(selected_region()) && selected_region() != ""
    
    # Montrer ou cacher le bloc en fonction de la sélection
    if (show_block) {
      shinyjs::show("tableBox")  # Afficher le bloc 4B
    } else {
      shinyjs::hide("tableBox")  # Cacher le bloc 4B
    }
  })
  
  
  
  ### CAMEROON AND MADAGASCAR --------------
  
  observe({
    if (input$country %in% c("Cameroun", "Madagascar") && 
        input$indicator %in% c("Conflict Diffusion Indicator","Events types and locations")) {
      
      ## Indicateur non disponible pour ces deux
      
      showModal(
        modalDialog(
          title = "Attention !",
          "L'indicateur sélectionné n'est pas disponible pour ce pays. \n 
          Plus précisément, les indicateurs concernant les évènements politiques ne sont pas disponibles pour
          le Cameroun et le Madagascar.",
          easyClose = FALSE,
          footer = modalButton("Compris"),
          tags$script(
            "document.querySelector('.modal-footer .btn').addEventListener('click', function() {
                 location.reload();
               });"
          )
        )
      )
      
    } 
  })
  
  ## Chargeons les shapefiles first, et les rasters after
  
  current_shapefile_0 <- reactive({
    req(input$country)
    shapefile_path <- shapefile_paths[[input$country]][["Niveau_0"]]
    if (!is.null(shapefile_path) && file.exists(shapefile_path)) {
      st_read(shapefile_path, options = "ENCODING=UTF-8")
    } else {
      NULL
    }
  })
  
  
  
  
  # Charger les rasters dynamiquement en fonction des sélections utilisateur---------------
  current_raster <- reactive({
    req(input$country, input$indicator)
    
    # Fichiers rasters
    raster_path <- raster_paths[[input$country]][[input$indicator]]
    
    
    
    ## Type de fichier --------------------
    
    if ((grepl("\\.tif$", raster_path) | grepl("\\.tiff$", raster_path)) && file.exists(raster_path)) {
      
      return(rast(raster_path))
      
    } 
    
    ## Events and locations .csv ---------------------------
    
    else if (grepl("\\.csv$", raster_path) && file.exists(raster_path)) {
      
      data <- read.csv(raster_path)
      
      # Objet spatial transformatin
      data_spatial <- sf::st_as_sf(data, coords = c("longitude", "latitude"), crs = st_crs(current_shapefile_1()))
      
      AOI_event <- data_spatial %>%
        dplyr::filter(country == input$country)
      
      ## Si le pays est dans les events polittical, à changer après ---------------------------
      
      if (nrow(AOI_event) == 0) {
        # Afficher un message si aucun événement n'existe
        showNotification(
          paste("Aucun événement trouvé pour", input$country),
          type = "warning"
        )
        return(NULL)
      }
      
      # Retourner les événements filtrés
      return(AOI_event)
      
    }
    
    
    else { NULL } 
    
    
  })
  
  
  current_shapefile_1 <- reactive({
    req(input$country)
    shapefile_path <- shapefile_paths[[input$country]][["Niveau_1"]]
    if (!is.null(shapefile_path) && file.exists(shapefile_path)) {
      shp1 <- st_read(shapefile_path, options = "ENCODING=UTF-8")
      
      
      if(input$indicator %in% c("NDVI", "MNDWI", "BSI_1", "NDBI")){
        
        ## Calculons par admin 
        req(current_raster())
        
        # Intersection entre le raster et les communes
        
        raster_data <- current_raster()
        
        # Calculer les moyennes pour chaque commune
        shp1$mean_value <- exactextractr::exact_extract(raster_data, shp1, "mean")
        
      }
      
      shp1
      
    } else {
      NULL
    }
  })
  
  
  ## SHP2 --------------------------------------------------
  current_shapefile_2 <- reactive({
    req(input$country, current_shapefile_1())
    shapefile_path <- shapefile_paths[[input$country]][["Niveau_2"]]
    if (!is.null(shapefile_path) && file.exists(shapefile_path)) {
      
      shp2 <- st_read(shapefile_path, options = "ENCODING=UTF-8")
      
      if(input$country != "Senegal"){
        
        #" On ajoute au shp2 les valeurs du shp1, sauf sénégal
        shp1 <- current_shapefile_1()
        
        # Pour que les CRS (systèmes de coordonnées) soient identiques
        
        shp2 <- st_transform(shp2, st_crs(shp1))
        
        colnames(shp1)[1] <- "ADMIN_1"
        
        shp2_1 <- st_join(shp2, shp1["ADMIN_1"]) 
        
        ## on a donc les nouvelles coordonnées
        shp2 <- shp2_1 }
      
      if(input$indicator %in% c("NDVI", "MNDWI", "BSI_1", "NDBI")){
        
        ## Calculons par admin 2
        req(current_raster())
        
        # Intersection entre le raster et les communes
        raster_data <- current_raster()
        
        # Calculer les moyennes pour chaque commune
        shp2$mean_value <- exactextractr::exact_extract(raster_data, shp2, "mean")
        
      }
      
      shp2
      
    } else {
      NULL
    }
  })
  
  
  
  observe({
    req(current_shapefile_1()) # Assure que le shapefile est chargé
    
    # Extraire les noms des régions (Niveau 1)
    region_names <- current_shapefile_1()[[1]]
    updated_choices <- c(" " = "", region_names)
    # Mettre à jour les choix du selectInput
    updateSelectInput(
      session,
      "stateSelector",
      choices = updated_choices,
      selected = " "
    )
  })
  
  ## Current Palette --------------------------------
  current_palette <- reactive({
    req(input$indicator)
    indicator_palettes[[input$indicator]]
  })
  
  
  ## Selected variable in the shp -----------------------
  
  selected_var <- reactive({
    req(input$indicator)
    
    # Malaria
    if(input$indicator == "Taux Malaria (2000 - 2022)"){
      req(input$year)
      paste0("Mal_",input$year)
    }
    
    # CDI
    else if(input$indicator == "Conflict Diffusion Indicator"){
      req(input$CDI_year)
      paste0("I_", input$CDI_year)
    }
    
    # Spectral indexes
    
    else  if(input$indicator %in% c("NDVI", "MNDWI", "BSI_1", "NDBI")){
      valeur <- "mean_value"
      valeur
    }
    
    else if (input$indicator == "Children affected"){
      req(input$child_year)
      paste0("Enf_", input$child_year)
    }
    
  })
  
  
  
  ## Raster layer / Grid Level ----------
  
  grid_level <- reactive({
    req(selected_var(), current_shapefile_1())
    
    ## dresser un template
    raster_template <- rast(
      extent = st_bbox(current_shapefile_1()),  # Étendue 
      resolution = 5/111            # Résolution 
    )
    
    # Rasteriser une variable du shapefile 
    raster_layer <- rasterize(current_shapefile_1(), raster_template, field = selected_var())
    
    raster_layer
    
    
  })
  
  
  # Carte Leaflet dynamique------------------------------------------
  
  output$mapOutput <- renderLeaflet({
    
    if(input$indicator !="Events types and locations"){
      req(grid_level())
    }
    
    ### Only spectral indexes ---------
    
    if(input$indicator %in% c("NDVI", "MNDWI", "BSI_1", "NDBI")){
      
      ## Calculons par admin 
      req(current_shapefile_1())
      
      # Intersection entre le raster et les communes
      shapefile <- current_shapefile_1()
      
      
      palette <- current_palette()
      
      leaflet(data = shapefile) %>%
        addTiles() %>%
        addRasterImage(
          grid_level(),    # Ajouter le raster
          colors = palette,    # Palette de couleurs
          opacity = 2,
          options = leafletOptions(zIndex = 500),
          group = "Grid Level"  # Nom de la couche
        ) %>%
        addPolygons(
          fillColor = ~palette(mean_value),
          color = "white",
          weight = 1,
          opacity = 2,
          fillOpacity = 1,
          group= "indicator",
          options = leafletOptions(zIndex = 300),
          label = ~paste(shapefile[[1]], ": ", round(mean_value, 2)),
          layerId = ~shapefile[[1]], # Ajout d'un ID unique basé sur le nom de la région
          highlight = highlightOptions(weight = 3, color = "blue", bringToFront = TRUE)
        ) %>%
        addLayersControl(
          overlayGroups = c("Grid Level", "indicator"),  # Contrôle pour cocher/décocher
          options = layersControlOptions(collapsed = FALSE)
        ) %>%
        hideGroup("Grid Level") %>%  # Cacher la couche raster au chargement de la carte
        
        addLegend(
          pal = palette,
          values = shapefile$mean_value,
          title = paste("Mean", input$indicator),
          position = "bottomright") %>% 
        addResetMapButton() # Recentrer la carte
      
      
    }
    
    
    ### Event types and locations -------------------------------
    
    else if(input$indicator == "Events types and locations") {
      ## Palette
      
      req(current_raster())
      
      rad <- ifelse(input$country == "Senegal", 3, 1)
      event_palette <- colorFactor(palette = "Set2", domain = current_raster()$event_type)
      
      
      ## Le cas des events -- points au lieu de rasters
      
      leaflet() %>%
        addTiles() %>%  # Couche de base (OpenStreetMap)
        
        # Ajouter les limites  (administration de niveau 0 - national)
        addPolygons(data = current_shapefile_1(), 
                    color = "brown", 
                    weight = 0.5, 
                    opacity = 1, 
                    fillOpacity = 0.5,
                    layerId = ~current_shapefile_1()[[1]],
                    highlight = highlightOptions(weight = 3, color = "white", bringToFront = F)) %>%  # Afficher l'information dans une popup
        
        # Ajouter les points d'événements (assurez-vous que AOI_event est un objet sf avec un CRS défini)
        
        addCircleMarkers(data = current_raster(), weight = 0.1, opacity = 2, fillOpacity = 1.4,
                         radius = rad,  # Adjust circle size
                         color = ~event_palette(event_type),
                         label = ~event_type ) %>%
        addLegend("bottomright", pal = event_palette, values = current_raster()$event_type,
                  title = "Event Type", opacity = 1) %>%
        addResetMapButton()  # Recentrer la carte
      
    } 
    
    ### Conflict Diffusion Indicator-Pour 1000--------------
    
    else if(input$indicator == "Conflict Diffusion Indicator"){
      
      req(input$CDI_year, selected_var())
      
      variable <-selected_var()
      valeurs <- current_shapefile_1()[[variable]]
      valeurs <- as.numeric(valeurs)*1000
      
      # Palette
      palette_Mal <- colorNumeric(palette = "Reds", domain = valeurs, na.color = "transparent")
      
      # On affiche le shp2 avec les autres en light et 
      
      
      leaflet() %>% 
        addTiles() %>%
        
        addRasterImage(
          grid_level(),    # Ajouter le raster
          colors = palette_Mal,    # Palette de couleurs
          opacity = 2,
          options = leafletOptions(zIndex = 500),
          group = "Grid Level") %>%   # Nom de la couche 
        
        addPolygons(
          data = current_shapefile_1(),
          color = "white",
          weight = 1,
          opacity = 0.7,
          fillColor = ~palette_Mal(valeurs) ,
          fillOpacity = 1,
          group = "indicator",
          label = ~paste0(current_shapefile_1()[[1]], " : ", round(as.numeric(current_shapefile_1()[[variable]])*1000,3)),  # Popup dynamique
          highlight = highlightOptions(weight = 3, color = "black", bringToFront = TRUE),
          layerId = ~current_shapefile_1()[[1]]
        ) %>% 
        
        addLayersControl(
          overlayGroups = c("Grid Level", "indicator"),  # Contrôle pour cocher/décocher
          options = layersControlOptions(collapsed = FALSE)
        ) %>%
        hideGroup("Grid Level") %>%  # Cacher la couche raster au chargement de la carte
        
        addLegend(
          pal = palette_Mal,
          values = valeurs,
          title = paste("CDI -", input$CDI_year, " (x1000)"),
          position = "bottomright") %>% 
        addResetMapButton()  # Recentrer la carte
      
      
    }
    
    ### Children affected and Malaria rates------------
    
    else {
      
      req(selected_var(), grid_level())
      
      variable <- selected_var()
      valeurs <- as.numeric(current_shapefile_1()[[variable]])
      
      
      titre <- if_else(str_sub(variable, 1, 3) == "Mal", paste0("Taux Malaria - ", str_sub(variable, -4, -1)), paste0("Nombre d'enfants atteints (0-12ans) - ", str_sub(variable, -4, -1)))
      
      # Palette
      palette_Mal <- colorNumeric(palette = "inferno", domain = valeurs, na.color = "transparent")
      
      
      leaflet() %>% 
        addTiles() %>%
        
        addRasterImage(
          grid_level(),    # Ajouter le raster
          colors = palette_Mal,    # Palette de couleurs
          opacity = 2,
          options = leafletOptions(zIndex = 500),
          group = "Grid Level"  # Nom de la couche
        ) %>%
        addPolygons(
          data = current_shapefile_1(),
          color = "white",
          weight = 1,
          opacity = 0.7,
          fillColor = ~ palette_Mal(valeurs) ,
          fillOpacity = 1,
          group = "indicator",
          label = ~paste0(current_shapefile_1()[[1]], " : ", round(as.numeric(current_shapefile_1()[[variable]]),3)),  # Popup dynamique
          highlight = highlightOptions(weight = 3, color = "blue", bringToFront = TRUE),
          layerId = ~current_shapefile_1()[[1]]
        ) %>% 
        
        addLayersControl(
          overlayGroups = c("Grid Level", "indicator"),  # Contrôle pour cocher/décocher
          options = layersControlOptions(collapsed = FALSE)
        ) %>%
        hideGroup("Grid Level") %>%  # Cacher la couche raster au chargement de la carte
        
        addLegend(
          pal = palette_Mal,
          values = valeurs,
          title =titre, ## 4 dernièrs caractères
          position = "bottomright") %>% 
        addResetMapButton()  # Recentrer la carte
      
    }
    
  })
  
  ## On s'interesse aux tables and charts ----------------------------
  
  
  ## Remplacé l'option click par les deux options simultanées (click et selectinput)
  
  ## Gestion simultanée des sélections via le clic et le menu ------
  
  selected_region <- reactive({
    # Si une région est sélectionnée via le menu déroulant
    if (!is.null(input$stateSelector)) {
      input$stateSelector
    } 
    # Sinon, si une région est cliquée sur la carte
    else if (!is.null(input$mapOutput_shape_click)) {
      input$mapOutput_shape_click$id
    } 
    # Sinon, aucune sélection
    else {
      NULL
    }
  })
  
  
  output$selectedRegionTitle <- renderText({
    req(selected_region())
    selected_region()
  })
  
  # Données filtrées en fonction de la région sélectionnée
  filtered_data <- reactive({
    req(selected_region(), current_shapefile_2())
    
    if (input$country == "Senegal") {
      current_shapefile_2() %>% filter(.[[4]] == selected_region())
    } else {
      current_shapefile_2() %>% filter(ADMIN_1 == selected_region())
    }
  })
  
  
  # ZOOOOOOMMMMING ---------------------------
  
  # Synchroniser le menu déroulant avec le clic sur la carte
  observeEvent(input$mapOutput_shape_click, {
    req(input$mapOutput_shape_click, filtered_data)
    updateSelectInput(
      session,
      "stateSelector",
      selected = input$mapOutput_shape_click$id
    )
    
    
    click <- input$mapOutput_shape_click  # Coordonnées du clic
    
    leafletProxy("mapOutput") %>% 
      addPolygons(
        data = filtered_data(),   # Données géospatiales
        color = "white",          # Couleur des contours
        fillColor = "lightblue",# Pas de couleur de fond
        weight = 2,               # Épaisseur des contours (1 pixel)
        fillOpacity = 1,          # Pas de remplissage visible
        opacity = 1 ,              # Contours entièrement visibles
        layerId = "temp"
      ) %>% 
      setView(lng = click$lng, lat = click$lat, zoom = 7)
    
    # Use a reactive timer to remove the polygon after a delay
    invalidateLater(20000, session)  # 5000 milliseconds = 5 seconds
    
    observe({
      leafletProxy("mapOutput") %>% 
        removeShape(layerId = "temp")  # Remove the polygon by its ID
    })
    
  })
  
  
  # Synchroniser la carte avec le menu déroulant
  observeEvent(input$stateSelector, {
    req(input$stateSelector)
    # Simuler un clic en actualisant `mapOutput_shape_click`
    session$sendCustomMessage("update-map-click", input$stateSelector)
  })
  
  
  
  
  
  
  ### Table résumé----------------------
  output$summaryTable <- renderTable({
    req(filtered_data(), input$indicator)
    
    if (input$indicator != "Events types and locations") {
      req(selected_var()) 
      variable <- selected_var()
      
      data <- filtered_data() %>%
        st_drop_geometry() %>%
        data.frame()
      
      data[[variable]] <- as.numeric(data[[variable]])
      
      # Calculs des statistiques
      mean_value <- if_else(input$indicator == "Children affected",
                            round(mean(data[[variable]], na.rm = TRUE),0),
                            round(mean(data[[variable]], na.rm = TRUE),3))
      max_value <- max(data[[variable]], na.rm = TRUE)
      min_value <- min(data[[variable]], na.rm = TRUE)
      highest_commune <- data[[1]][which.max(data[[variable]])]
      lowest_commune <- data[[1]][which.min(data[[variable]])]
      
      resume <- data.frame(
        Metric = c("Mean", "Max", "Min"),
        Value = c(mean_value,
                  paste(highest_commune, round(max_value, 3), sep = " : "),
                  paste(lowest_commune, round(min_value, 3), sep = " : ")))
      
      output$textBelowTable <- renderUI({
        HTML(paste0("<b>", highest_commune, "</b>", 
                    " a enregistré la valeur la plus élevée (", 
                    "<b>", round(max_value, 3), "</b>), tandis que ", 
                    "<b>", lowest_commune, "</b>", 
                    " a enregistré celle la plus petite (<b>",round(min_value, 3),"</b>). <br>",
                    "La valeur moyenne sur la région est de ", 
                    "<b>", mean_value, "</b>."))
        
      })
      
      return(resume)
      
      
    } else  {
      req(current_raster(), selected_region())
      current_raster() %>%
        st_drop_geometry() %>%
        filter(admin1 == selected_region()) %>%
        group_by(event_type) %>%
        summarise(Nombre_events = n())
    }
  })
  
  ### Tableau ---------------------------
  output$dataTable <- renderDT({
    req(filtered_data())
    
    if (input$indicator == "Events types and locations") {
      current_raster() %>%
        st_drop_geometry() %>%
        filter(admin1 == selected_region()) %>%
        group_by(admin2) %>%
        summarise(Nombre_events = n())
    } else {
      req(selected_var())
      Tab <- filtered_data() %>%
        st_drop_geometry() %>%
        select(c(1, selected_var()))
      Tab[[selected_var()]] <- str_sub(Tab[[selected_var()]], 1,5)
      datatable(Tab)
    }
  })
  
  ### Diagramme--------------------------------------------
  
  output$chartOutput <- renderPlot({
    req(input$indicator, selected_region())
    
    if (input$indicator == "Events types and locations") {
      data <- current_raster() %>%
        st_drop_geometry() %>%
        filter(admin1 == selected_region())
      
      t <- data %>%
        group_by(year, admin2) %>%
        summarise(events_number = n())
      
      ggplot(t, aes(y = events_number, x = year, color = admin2, group = admin2)) +
        geom_path(linewidth = 1.2) +
        geom_point(size = 2) +
        theme_minimal() +
        labs(title = "Nombre d'évènements par année et admin2")
    } else {
      
      req(filtered_data(), selected_var())
      data_f <- filtered_data() %>%
        st_drop_geometry() %>%
        data.frame()
      data_f[[selected_var()]] <- as.numeric(data_f[[selected_var()]])
      
      data_f <- cbind(data_f[[1]], round(data_f[[selected_var()]], 3))
      colnames(data_f) <- c("admin2", "valeur")
      
      
      ggplot(data_f, aes(x = admin2, y = valeur)) +
        geom_point(aes(alpha = valeur), color= "blue", size=5) +
        theme_minimal() +
        labs(
          title = paste("valeurs moyennes par division administrative"),
          x = "Zone",
          y = "Valeur Moyenne"
        ) +
        theme(axis.text.x = element_text(, size = 3)) +
        coord_flip()
      
      
      
    }
  })
  
  ### Image-----------
  output$ImageGIF <- renderImage({
    
    req(input$country)
    source <- raster_paths[[input$country]][["animation"]]
    
    # Check if the file exists
    if (!file.exists(source)) {
      stop("The selected animation file does not exist.")
    }
    
    # Return a list containing the path to the image and content type
    list(
      src = source,                 # File path
      contentType = "image/gif",    # Set the MIME type for a GIF
      alt = paste("Malaria time series -", input$country),  # Alternative text
      width = "100%",  # Largeur ajustée à l'espace
      height = "auto"  # Hauteur automatique pour conserver les proportions
    )
    
    
  }, deleteFile = FALSE)
  output$legendPlot <- renderPlot({
    req(current_palette(), current_raster()) # Vérifie que la palette et le raster existent
    
    # Domaine des valeurs du raster sans NA
    value_range <- range(values(current_raster()), na.rm = TRUE)
    
    # Générer une légende horizontale
    par(mar = c(2, 1, 1, 1)) # Marges compactes
    image(
      z = t(matrix(seq(value_range[1], value_range[2], length.out = 100), nrow = 1)),
      x = seq(value_range[1], value_range[2], length.out = 100),
      y = 1,
      col = current_palette()(seq(value_range[1], value_range[2], length.out = 100)),
      axes = FALSE,
      xlab = "", ylab = ""
    )
    
    # Ajouter les axes pour les valeurs de la légende
    axis(1, at = seq(value_range[1], value_range[2], length.out = 5), 
         labels = round(seq(value_range[1], value_range[2], length.out = 5), 2), 
         cex.axis = 0.8)
    box()
  })
  
  
  
  
  
  
  
  
  ## Texte de région -------------
  output$regionInfo <- renderText({
    
    req(filtered_data(), selected_region())
    texte <- paste(selected_region()," : " , paste0(nrow(filtered_data()),
                                                    " départements"), sep="\n")
    
    texte
  })
  
  observe({
    if (input$indicator == "Taux Malaria (2000 - 2022)") {
      # Ajouter l'onglet Malaria GIF
      updateTabsetPanel(session, "tabs", selected = "Malaria GIF")
      insertTab(
        inputId = "tabs",
        tabPanel(
          "Malaria GIF",
          imageOutput("ImageGIF")
        ),
        target = "Chart", # Insère après l'onglet "Chart"
        position = "after"
      )
    } else {
      # Supprimer l'onglet Malaria GIF si un autre indicateur est sélectionné
      removeTab(inputId = "tabs", target = "Malaria GIF")
    }
  })
  
  
  ## Boutons de téléchargements----------
  ## téléchargements des notes techniques sur le bloc 1
  # Bouton pour télécharger le PDF des notes techniques
  output$downloadNotes <- downloadHandler(
    filename = function() {
      "Technical_Notes.pdf" # Nom du fichier téléchargé
    },
    content = function(file) {
      file.copy("notes_techniques.pdf", file) # Remplacez par le chemin réel
    }
  )
  
  
  ## Téléchargement du contenu (Summary, Table, Chart) BLOC-4B (leaflet)
  
  output$downloadContent <- downloadHandler(
    filename = function() {
      "dashboard_content.zip" # Le fichier téléchargé sera un ZIP contenant les éléments
    },
    content = function(file) {
      # Créer un répertoire temporaire spécifique
      tempDir <- file.path(tempdir(), "download_files")
      dir.create(tempDir, showWarnings = FALSE)
      
      # 1. Exporter le Summary en CSV
      summary_path <- file.path(tempDir, "summary.csv")
      summary_data <- reactive({
        req(filtered_data(), selected_var())
        
        variable <- selected_var()
        data <- filtered_data() %>%
          st_drop_geometry() %>%
          data.frame()
        
        # Calcul des métriques du Summary
        data_summary <- data.frame(
          Metric = c("Mean", "Max", "Min"),
          Value = c(
            round(mean(data[[variable]], na.rm = TRUE), 3),
            round(max(data[[variable]], na.rm = TRUE), 3),
            round(min(data[[variable]], na.rm = TRUE), 3)
          )
        )
        write.csv(data_summary, summary_path, row.names = FALSE)
        return(data_summary)
      })
      summary_data() # Appeler la fonction pour exécuter le calcul
      
      # 2. Exporter le Tableau complet (Table) en CSV
      table_path <- file.path(tempDir, "table.csv")
      table_data <- reactive({
        req(filtered_data(), selected_var())
        
        # Données pour le Table complet
        Tab <- filtered_data() %>%
          st_drop_geometry() %>%
          select(c(1, selected_var()))
        Tab[[selected_var()]] <- round(as.numeric(Tab[[selected_var()]]), 3)
        write.csv(Tab, table_path, row.names = FALSE)
        return(Tab)
      })
      table_data() # Appeler la fonction pour exécuter
      
      # 3. Exporter le Chart en PNG
      chart_path <- file.path(tempDir, "chart.png")
      req(filtered_data(), selected_var())
      
      data_f <- filtered_data() %>%
        st_drop_geometry() %>%
        data.frame()
      data_f[[selected_var()]] <- as.numeric(data_f[[selected_var()]])
      
      # Générer et sauvegarder le graphique avec ggsave
      gg <- ggplot(data_f, aes(x = data_f[[1]], y = data_f[[selected_var()]])) +
        geom_bar(stat = "identity", fill = "steelblue") +
        labs(
          x = "Variable",
          y = "Valeurs",
          title = "Graphique des valeurs par catégorie"
        ) +
        theme_minimal()
      
      ggsave(chart_path, gg, width = 8, height = 6)
      
      # 4. Créer un fichier ZIP contenant tous les fichiers
      zip::zipr(
        file, # Destination du fichier ZIP
        files = list.files(tempDir, full.names = TRUE),
        recurse = FALSE
      )
    },
    contentType = "application/zip"
  )
  
  
  ## téléchargements des shapefiles du bloc 4A (carte leaflet)
  # Téléchargement du Shapefile
  output$downloadShapefile <- downloadHandler(
    filename = function() {
      paste0("shapefile_", Sys.Date(), ".zip") # Nom du fichier ZIP
    },
    content = function(file) {
      req(current_shapefile_1()) # Vérifiez que les données sont disponibles
      
      # Valider les géométries
      shapefile <- current_shapefile_1()
      if (!all(sf::st_is_valid(shapefile))) {
        shapefile <- sf::st_make_valid(shapefile)
      }
      
      # Créer un répertoire temporaire
      temp_dir <- tempdir()
      shapefile_dir <- file.path(temp_dir, "shapefile")
      dir.create(shapefile_dir, showWarnings = FALSE)
      
      # Chemin des fichiers Shapefile
      shapefile_path <- file.path(shapefile_dir, "map_layer.shp")
      
      # Exporter les données au format Shapefile
      sf::st_write(
        obj = shapefile,
        dsn = shapefile_path,
        driver = "ESRI Shapefile",
        delete_layer = TRUE # Remplacer s'il existe déjà
      )
      
      # Compresser les fichiers Shapefile en ZIP
      zip::zipr(
        zipfile = file, # Fichier ZIP final
        files = list.files(shapefile_dir, full.names = TRUE) # Inclure tous les fichiers nécessaires
      )
    },
    contentType = "application/zip" # Type MIME pour un fichier ZIP
  )
  
  
  
  ## PARTIES SUR LES NOTES TECNHIQUES------------------
  output$notesContent <- renderUI({
    fluidRow(
      column(
        4,
        div(
          class = "note-box",
          style = "border: 1px solid #ddd; padding: 15px; border-radius: 5px; background-color: #f9f9f9;",
          h4("Notes techniques 1", style = "color: white; background-color: red; padding: 5px; border-radius: 5px;"),
          p("Ces notes expliquent la documentation générale sur l'application."),
          actionLink("note1", "Read more →", style = "color: red;")
        )
      ),
      column(
        4,
        div(
          class = "note-box",
          style = "border: 1px solid #ddd; padding: 15px; border-radius: 5px; background-color: #f9f9f9;",
          h4("Notes techniques 2", style = "color: white; background-color: red; padding: 5px; border-radius: 5px;"),
          p("Ces notes expliquent les indices spectraux."),
          actionLink("note2", "Read more →", style = "color: red;")
        )
      ),
      column(
        4,
        div(
          class = "note-box",
          style = "border: 1px solid #ddd; padding: 15px; border-radius: 5px; background-color: #f9f9f9;",
          h4("Notes techniques 3", style = "color: white; background-color: red; padding: 5px; border-radius: 5px;"),
          p("Ces notes expliquent la malaria et les événements politiques."),
          actionLink("note3", "Read more →", style = "color: red;")
        )
      )
    )
  })
  
  # Mise à jour pour Technical Note 1
  observeEvent(input$note1, {
    output$notesContent <- renderUI({
      div(
        actionLink("back", "← Back to Technical Notes", style = "color: blue;"),
        h3("Notes techniques 1: Documentation générale"),
        h4("I°) Le principe général concernant les outputs"),
        p("La logique de notre travail repose sur le principe suivant : nous manipulons des shapefiles, qui peuvent être assimilés à des « dataframes » contenant en colonne la variable « indice », et dont les valeurs correspondent aux observations réparties selon les divisions administratives. Ce dataframe est directement lié à l’ensemble des tableaux, graphiques et cartes que nous afficherons."),
        p("Le fonctionnement est le suivant : lorsque l’utilisateur clique sur un point spécifique de la carte, un filtre est immédiatement appliqué pour identifier le département où se situe ce point. Ensuite, une jointure ou un « matching » est effectué entre le shapefile de niveau régional et celui de niveau départemental afin de déterminer la région correspondant à ce département."),
        p("Cette opération permet d’extraire les informations relatives à tous les départements de cette région. Enfin, ces informations sont organisées sous forme de tableaux, de cartes ou de graphiques, qui seront affichés afin de fournir des compléments d’information et d’évaluer la situation de chaque région."),
        
        h4("II°) Création des rasters avec GEE et leur utilisation sur R (cas du NDVI)"),
        p("Ce document présente les étapes pour calculer et utiliser l'indice de végétation par différence normalisée (NDVI) en exploitant Google Earth Engine (GEE) et R. Il fournit également des conseils pour intégrer cet indice dans des applications interactives Shiny, permettant aux utilisateurs de l’explorer de manière dynamique."),
        tags$ul(
          tags$li("Le NDVI est un indicateur qui mesure la santé et la densité de la végétation en comparant la réflectance des bandes proche infrarouge (NIR) et rouge (RED) des images satellites."),
          tags$li("Avec GEE, le processus consiste à sélectionner les données Sentinel-2, appliquer un masquage pour éliminer les nuages, extraire les bandes nécessaires (NIR et RED), calculer le NDVI à l’aide de la formule appropriée et exporter le résultat sous forme de raster."),
          tags$li("Dans R, les données NDVI sont manipulées à l’aide des packages comme raster pour les rasters, sf pour les fichiers vectoriels et leaflet pour la visualisation interactive."),
          tags$li("Les flux de travail incluent le chargement des fichiers GeoTIFF du NDVI, l’extraction des valeurs pour des zones spécifiques (par exemple des départements) et la création de cartes dynamiques grâce à des palettes de couleurs adaptées.")
        ),
        
        h4("III°) Processus de création de l’application"),
        p("La création d'une application interactive permettant de visualiser des indicateurs de santé et de développement à partir de données spatiales repose sur plusieurs étapes clés. Voici une présentation détaillée et structurée pour guider tout le processus, depuis la préparation des données jusqu'à la mise en ligne de l'application."),
        
        h5("III.1°) Préparation des données"),
        p("La première étape consiste à collecter et organiser les données spatiales et tabulaires. Les données incluent des indicateurs comme le NDVI, MNDWI, BSI_1 et NDBI, ainsi que des limites administratives des pays cibles."),
        tags$ul(
          tags$li("Les données raster pour les indicateurs et les fichiers vectoriels pour les limites administratives (shapefiles ou GeoJSON) doivent être obtenus."),
          tags$li("Utilisez des bibliothèques comme rasterio ou gdal pour manipuler les fichiers raster et geopandas pour les fichiers vectoriels."),
          tags$li("Assurez-vous que toutes les données sont projetées dans un même système de coordonnées.")
        ),
        
        h5("III.2°) Traitement et analyse des données"),
        tags$ul(
          tags$li("Nettoyez les données pour éliminer les valeurs manquantes et assurez-vous que les indicateurs sont calculés correctement."),
          tags$li("Utilisez numpy et pandas (python) pour effectuer des transformations sur les tableaux de données."),
          tags$li("Pour superposer les données raster avec des unités administratives, utilisez rasterstats pour calculer des statistiques zonales comme la moyenne ou la médiane par région.")
        ),
        
        h5("III.3°) Développement de l’application interactive"),
        p("L’outil principal utilisé ici est Dash de Plotly, qui permet de créer des applications web interactives en Python."),
        tags$ul(
          tags$li("Commencez par structurer votre application en définissant la mise en page et les composants interactifs comme les cartes et graphiques.")
        ),
        
        h5("III.4°) Intégration des fonctionnalités interactives"),
        p("Ajoutez des menus déroulants, des barres de recherche ou des sélecteurs pour permettre à l'utilisateur de choisir un pays, un indicateur ou une période temporelle."),
        tags$ul(
          tags$li("Cela se fait à l’aide des callbacks dans Dash, qui lient les entrées utilisateur aux sorties affichées.")
        ),
        
        h5("III.5°) Test et validation"),
        tags$ul(
          tags$li("Avant de déployer l’application, testez-la localement pour vérifier que toutes les interactions fonctionnent correctement et que les calculs des indicateurs sont cohérents."),
          tags$li("Utilisez des petits jeux de données pour déceler rapidement les erreurs potentielles.")
        ),
        
        h5("III.6°) Déploiement de l’application"),
        p("Utilisez une plateforme comme Heroku, Render, ou Dash Enterprise pour déployer votre application."),
        tags$ul(
          tags$li("Créez un fichier requirements.txt listant toutes les dépendances."),
          tags$li("Créez un fichier Procfile pour spécifier la commande de lancement.")
        ),
        
        p("Ainsi, cette procédure fournit une feuille de route claire pour créer une application interactive de visualisation géospatiale. Chaque étape est essentielle et contribuera à une application robuste et fonctionnelle. Une fois les bases maîtrisées, vous pouvez étendre les fonctionnalités pour inclure des analyses plus avancées ou une meilleure personnalisation de l’interface utilisateur.")
        
        
        
      )
    })
  })
  
  # Mise à jour pour Technical Note 2
  observeEvent(input$note2, {
    output$notesContent <- renderUI({
      div(
        actionLink("back", "← Back to Technical Notes", style = "color: blue;"),
        h3("Notes techniques 2: Indices spectraux"),
        h4("I°) NDVI (Normalized Difference Vegetation Index)"),
        
        h5("I.1°) Origine et Contexte"),
        p("L'indice NDVI a été développé pour évaluer la santé et la densité de la végétation à l'aide de données satellites. Il a émergé avec l'avènement des capteurs multispectraux dans les années 1970, notamment à partir des données du satellite Landsat."),
        p("Le NDVI exploite les propriétés spectrales spécifiques de la végétation, qui absorbe fortement la lumière rouge (RED) pour la photosynthèse et réfléchit fortement dans le proche infrarouge (NIR) en raison de la structure des cellules des feuilles."),
        
        h5("I.2°) Formule et Calcul"),
        p("La formule du NDVI est donnée par : NDVI = (NIR − RED) / (NIR + RED)"),
        tags$ul(
          tags$li("NIR (Near InfraRed) : La réflectance dans le proche infrarouge, sensible à la structure cellulaire de la végétation."),
          tags$li("RED (Red) : La réflectance dans la bande rouge du spectre visible, fortement absorbée par les pigments chlorophylliens."),
          tags$li("Interprétation des valeurs :"),
          tags$ul(
            tags$li("NDVI ∈ [−1,1]"),
            tags$li("Valeurs proches de 1 : Indiquent une végétation dense et saine (forte réflectance NIR et faible absorbance RED)."),
            tags$li("Valeurs proches de 0 : Correspondent à des surfaces non végétalisées (sols nus, zones urbaines)."),
            tags$li("Valeurs négatives : Signifient généralement de l'eau ou des nuages (faible réflectance NIR et RED similaires).")
          )
        ),
        
        h5("I.3°) Théorie Derrière le NDVI"),
        tags$ul(
          tags$li("La chlorophylle absorbe efficacement la lumière visible, en particulier dans la bande rouge, pour alimenter la photosynthèse."),
          tags$li("Les parois cellulaires des feuilles réfléchissent fortement le proche infrarouge."),
          tags$li("Cette différence de réflectance entre le RED et le NIR est exploitée pour évaluer la biomasse et la santé de la végétation.")
        ),
        
        h5("I.4°) Démonstration de la Formule"),
        tags$ul(
          tags$li("La soustraction (NIR − RED) capture la différence de réflectance entre les deux bandes spectrales."),
          tags$li("La division par (NIR + RED) normalise la différence, la plaçant dans une plage fixe de -1 à 1."),
          tags$li("Pourquoi la normalisation est-elle essentielle ?"),
          tags$ul(
            tags$li("Elle permet de compenser les variations d'intensité lumineuse (différences d'exposition au soleil)."),
            tags$li("Elle réduit les effets des propriétés atmosphériques (aérosols, nuages).")
          )
        ),
        
        h5("I.5°) Applications"),
        tags$ul(
          tags$li("Surveillance de la santé de la végétation : Identification des zones à forte ou faible biomasse."),
          tags$li("Cartographie de l'occupation du sol : Discrimination entre surfaces végétalisées et non végétalisées."),
          tags$li("Gestion des ressources agricoles : Estimation des rendements, détection du stress hydrique."),
          tags$li("Suivi des changements climatiques : Observation des tendances de déforestation et de désertification.")
        ),
        
        h5("I.6°) Avantages et Limites"),
        tags$ul(
          tags$li("Avantages :"),
          tags$ul(
            tags$li("Facilement calculable à partir de données satellites."),
            tags$li("Normalisé, ce qui permet des comparaisons spatio-temporelles.")
          ),
          tags$li("Limites :"),
          tags$ul(
            tags$li("Sensibilité aux conditions atmosphériques : L'aérosol ou la couverture nuageuse peuvent fausser les résultats."),
            tags$li("Ne distingue pas les types de végétation."),
            tags$li("Les surfaces fortement réfléchissantes (urbaines, neige) peuvent produire des valeurs erronées.")
          )
        ),
        
        # Section MNDWI
        h4("II°) MNDWI (Modified Normalized Difference Water Index)"),
        
        h5("II.1°) Origine et Contexte"),
        p("L'indice MNDWI a été proposé pour surmonter les limitations du NDWI (Normalized Difference Water Index), qui est parfois perturbé par des surfaces urbaines ou des sols nus."),
        p("Développé pour mieux détecter les corps d’eau tels que les rivières, lacs, océans, et réservoirs, le MNDWI utilise la bande SWIR (Short-Wave Infrared) au lieu de la bande proche infrarouge (NIR), car l’eau absorbe davantage dans le SWIR, ce qui améliore la précision."),
        
        h5("II.2°) Formule et Calcul"),
        p("La formule du MNDWI est donnée par : MNDWI = (Green − SWIR) / (Green + SWIR)"),
        tags$ul(
          tags$li("Green : La réflectance dans la bande verte du spectre visible. Elle est utilisée car l’eau présente une faible réflectance dans cette bande."),
          tags$li("SWIR (Short-Wave Infrared) : La réflectance dans la bande infrarouge à ondes courtes. L’eau absorbe fortement dans cette bande."),
          tags$li("Interprétation des valeurs :"),
          tags$ul(
            tags$li("MNDWI ∈ [−1,1]"),
            tags$li("Valeurs positives (> 0) : Correspondent généralement à des plans d’eau."),
            tags$li("Valeurs proches de 0 : Indiquent des sols nus, des zones urbaines ou des végétations."),
            tags$li("Valeurs négatives (< 0) : Représentent souvent des surfaces non aquatiques.")
          )
        ),
        
        h5("II.3°) Théorie Derrière le MNDWI"),
        tags$ul(
          tags$li("L’eau absorbe la lumière dans les bandes verte et SWIR, mais son absorption est plus forte dans le SWIR."),
          tags$li("Les surfaces non aquatiques (végétation, sols nus, surfaces urbaines) réfléchissent davantage dans la bande verte et dans le SWIR."),
          tags$li("En remplaçant la bande NIR utilisée dans le NDWI par la bande SWIR, le MNDWI améliore la séparation entre l’eau et les surfaces non aquatiques.")
        ),
        
        h5("II.4°) Démonstration de la Formule"),
        tags$ul(
          tags$li("La différence (Green − SWIR) capte le contraste entre l’eau et les autres surfaces."),
          tags$li("La division par (Green + SWIR) normalise la différence, la plaçant dans une plage fixe de -1 à 1."),
          tags$li("Pourquoi le SWIR au lieu du NIR ?"),
          tags$ul(
            tags$li("Le SWIR est plus sensible aux caractéristiques optiques de l’eau."),
            tags$li("Cela rend le MNDWI plus adapté aux environnements complexes comme les zones urbaines et côtières.")
          )
        ),
        
        h5("II.5°) Applications"),
        tags$ul(
          tags$li("Détection des corps d’eau : Identification précise des rivières, lacs, océans et réservoirs."),
          tags$li("Gestion des ressources en eau : Suivi des zones humides, inondations et sécheresses."),
          tags$li("Analyse des zones urbaines : Amélioration de la cartographie des plans d’eau dans les environnements urbains."),
          tags$li("Surveillance environnementale : Évaluation de l’impact des activités humaines sur les écosystèmes aquatiques.")
        ),
        
        h5("II.6°) Avantages et Limites"),
        tags$ul(
          tags$li("Avantages :"),
          tags$ul(
            tags$li("Meilleure détection de l’eau dans des environnements mixtes."),
            tags$li("Insensibilité relative aux interférences des surfaces urbaines et de la végétation."),
            tags$li("Approche normalisée, permettant des comparaisons spatio-temporelles robustes.")
          ),
          tags$li("Limites :"),
          tags$ul(
            tags$li("Sensibilité aux conditions atmosphériques."),
            tags$li("Moins adapté pour différencier des types d’eau (eau claire vs trouble)."),
            tags$li("Dépend fortement de la résolution spectrale et spatiale des données d’entrée.")
          )
        ),
        h4("III°) NDBI (Normalized Difference Built-Up Index)"),
        
        h5("III.1°) Origine et Contexte"),
        p("L’indice NDBI (Normalized Difference Built-up Index) a été conçu pour identifier les zones bâties (urbanisation) à partir d’images satellites. Il est particulièrement utile dans le contexte de la cartographie urbaine, où il aide à discriminer les zones construites des autres types de couverture terrestre."),
        p("Le NDBI repose sur l’utilisation des bandes spectrales infrarouges proches (NIR) et infrarouges à ondes courtes (SWIR), car les surfaces bâties reflètent davantage dans le SWIR et beaucoup moins dans le NIR, contrairement à la végétation."),
        
        h5("III.2°) Formule et Calcul"),
        p("La formule du NDBI est donnée par : NDBI = (SWIR − NIR) / (SWIR + NIR)"),
        tags$ul(
          tags$li("SWIR (Short-Wave Infrared) : Bande infrarouge à ondes courtes, qui présente une forte réflectance pour les surfaces bâties (béton, asphalte, etc.)."),
          tags$li("NIR (Near InfraRed) : Bande infrarouge proche, qui présente une faible réflectance pour les zones urbaines mais une forte réflectance pour la végétation."),
          tags$li("Interprétation des valeurs :"),
          tags$ul(
            tags$li("NDBI ∈ [−1,1]"),
            tags$li("Valeurs positives (> 0) : Correspondent généralement aux zones bâties ou urbanisées."),
            tags$li("Valeurs proches de 0 : Représentent des sols nus ou des zones de transition."),
            tags$li("Valeurs négatives (< 0) : Indiquent des surfaces végétalisées ou des corps d'eau.")
          )
        ),
        
        h5("III.3°) Théorie Derrière le NDBI"),
        tags$ul(
          tags$li("Zones bâties : Forte réflectance dans le SWIR, faible dans le NIR."),
          tags$li("Végétation : Faible réflectance dans le SWIR, forte dans le NIR."),
          tags$li("Sols nus : Réflectance modérée dans les deux bandes.")
        ),
        
        h5("III.4°) Démonstration de la Formule"),
        tags$ul(
          tags$li("La différence (SWIR − NIR) met en évidence les zones bâties en raison de leur forte réflectance dans le SWIR."),
          tags$li("La division par (SWIR + NIR) normalise les résultats pour placer les valeurs dans une plage fixe de -1 à 1, facilitant les comparaisons spatio-temporelles."),
          tags$li("Pourquoi utiliser le SWIR ?"),
          tags$ul(
            tags$li("Le SWIR est particulièrement sensible aux matériaux non biologiques, comme le béton et l’asphalte, ce qui le rend idéal pour identifier les zones construites.")
          )
        ),
        
        h5("III.5°) Applications"),
        tags$ul(
          tags$li("Cartographie des zones urbaines : Identification des infrastructures urbaines et des expansions urbaines."),
          tags$li("Suivi de l'urbanisation : Évaluation de l’impact des activités humaines sur le territoire."),
          tags$li("Gestion urbaine : Aide à la planification urbaine et à la gestion des ressources."),
          tags$li("Étude de l’artificialisation des sols : Analyse de la conversion des sols naturels en surfaces bâties.")
        ),
        
        h5("III.6°) Avantages et Limites"),
        tags$ul(
          tags$li("Avantages :"),
          tags$ul(
            tags$li("Permet de discriminer efficacement les zones construites des autres types de surfaces."),
            tags$li("Facilement calculable à partir de données satellitaires multispectrales."),
            tags$li("Insensibilité relative aux variations atmosphériques grâce à la normalisation.")
          ),
          tags$li("Limites :"),
          tags$ul(
            tags$li("Sensibilité aux zones de transition : Les sols nus ou surfaces semi-urbaines peuvent produire des valeurs similaires à celles des zones bâties."),
            tags$li("Résolution spatiale : Les zones bâties très denses ou les petits objets urbains peuvent être difficiles à détecter avec des capteurs à basse résolution."),
            tags$li("Ne distingue pas les types de matériaux urbains (ex. béton vs métal).")
          )
        ),
        
        # Section BIS1
        h4("V°) BIS1 (Bare Soil Index)"),
        
        h5("V.1°) Origine et Contexte"),
        p("L'indice BIS1 (Built-up Index Spectral 1) est un indicateur spectral développé pour identifier et analyser les zones bâties à partir de données satellitaires. Contrairement à des indices plus connus comme le NDBI, le BIS1 repose sur l'exploitation de bandes spectrales spécifiques afin de mieux différencier les zones urbanisées des autres types de couverture terrestre, notamment les sols nus, la végétation et l’eau."),
        
        h5("V.2°) Formule et Calcul"),
        p("La formule du BIS1 est généralement donnée par :"),
        tags$ul(
          tags$li("RED (Rouge) : Réflectance dans la bande rouge, sensible à l’absorption de la chlorophylle, ce qui permet de différencier les zones non végétalisées."),
          tags$li("SWIR (Short-Wave InfraRed) : Réflectance dans l'infrarouge à ondes courtes, utile pour identifier les matériaux non organiques comme le béton et l’asphalte."),
          tags$li("NIR (Near InfraRed) : Réflectance dans le proche infrarouge, sensible aux structures cellulaires des plantes, généralement élevée pour la végétation saine."),
          tags$li("BLUE (Bleu) : Réflectance dans la bande bleue, influencée par la diffusion atmosphérique, souvent faible pour les zones bâties.")
        ),
        
        h5("V.3°) Théorie Derrière le BIS1"),
        tags$ul(
          tags$li("Les zones bâties ont une forte réflectance dans le SWIR et le RED, mais une faible réflectance dans le NIR et le BLUE."),
          tags$li("Les zones végétalisées ont une forte réflectance dans le NIR et une faible réflectance dans le SWIR et le RED."),
          tags$li("Les plans d'eau reflètent faiblement dans toutes les bandes spectrales, mais davantage dans le BLUE.")
        ),
        
        h5("V.4°) Démonstration de la Formule"),
        p("Le rapport (RED+SWIR) / (NIR+BLUE) est conçu pour maximiser la détection des zones bâties :"),
        tags$ul(
          tags$li("Numérateur (RED+SWIR) : Capture la signature spectrale caractéristique des matériaux urbains."),
          tags$li("Dénominateur (NIR+BLUE) : Réduit l’influence de la végétation et des plans d’eau.")
        ),
        
        h5("V.5°) Applications"),
        tags$ul(
          tags$li("Cartographie des zones bâties."),
          tags$li("Analyse de l’urbanisation."),
          tags$li("Gestion de l’aménagement du territoire."),
          tags$li("Évaluation des risques environnementaux.")
        ),
        
        h5("V.6°) Avantages et Limites"),
        tags$ul(
          tags$li("Avantages :"),
          tags$ul(
            tags$li("Simplicité : Calcul direct à partir de données satellitaires couramment disponibles."),
            tags$li("Efficacité pour les zones bâties."),
            tags$li("Flexibilité : Peut être utilisé sur des données provenant de différents capteurs.")
          ),
          tags$li("Limites :"),
          tags$ul(
            tags$li("Sensibilité aux sols nus."),
            tags$li("Effets atmosphériques."),
            tags$li("Résolution spatiale.")
          )
        )
      )
    })
  })
  
  # Mise à jour pour Technical Note 3
  observeEvent(input$note3, {
    output$notesContent <- renderUI({
      div(
        actionLink("back", "← Back to Technical Notes", style = "color: blue;"),
        h3("Notes techniques 3: Malaria et événements politiques"),
        h4("Malaria"),
        p("Taux de Malaria (2000-2022) : Cette fonctionnalité permet de visualiser la prévalence de la malaria sur une période donnée. Les données sont disponibles au niveau régional et national. L'indicateur est traité comme une couche de données spatiales (shapefile) ou raster, et le calcul se base sur des moyennes par zone administrative."),
        tags$ul(
          tags$li("La carte utilise une palette de couleurs rouges pour indiquer les niveaux de prévalence, ce qui aide à identifier les zones les plus touchées."),
          tags$li("Les descriptions des indicateurs (via `output$indicatorDescription`) fournissent une explication claire de la signification des données et de leur utilité dans le suivi des efforts de lutte contre la malaria."),
          tags$li("Un graphique interactif et une table de résumé complètent la visualisation, rendant les données accessibles à différents niveaux d'analyse.")
        ),
        
        # Section Événements Politiques
        h4("Événements Politiques"),
        tags$ul(
          tags$li(
            strong("Conflict Diffusion Indicator (CDI) :"),
            " Cet indicateur quantifie la dispersion géographique des conflits dans des zones densément peuplées, en utilisant des données issues d'ACLED et de WorldPop. Une carte dynamique est produite pour chaque année sélectionnée, utilisant des niveaux d'intensité affichés sur une échelle colorée."
          ),
          tags$li(
            strong("Events types and locations :"),
            " Cette section visualise les types d'événements politiques et leurs localisations à l'aide de points sur la carte. Une légende interactive et une catégorisation par type d'événement facilitent la compréhension des dynamiques locales."
          ),
          tags$li(
            "Les événements politiques sont particulièrement pertinents pour analyser les relations entre conflits, santé publique (par exemple, impact sur les efforts de lutte contre la malaria), et dynamique spatiale."
          )
        ),
        
        # Section Points techniques et forces
        h4("Points techniques et forces"),
        tags$ul(
          tags$li(
            strong("Interactivité avancée :"),
            " Le code inclut des fonctions d’agrandissement des blocs (`observeEvent`), permettant à l’utilisateur de se concentrer sur les cartes ou les tableaux selon ses besoins."
          ),
          tags$li(
            strong("Utilisation des rasters et shapefiles :"),
            " Une gestion dynamique des fichiers géographiques permet de charger des données adaptées à chaque pays et indicateur."
          ),
          tags$li(
            strong("Personnalisation des cartes :"),
            " Les palettes de couleurs et les couches interactives enrichissent l'expérience utilisateur, tout en rendant les données complexes visuellement accessibles."
          )
        ),
        
        # Résumé final
        p("En somme, cette application se distingue par son intégration cohérente d'indicateurs de santé publique et de conflits, offrant une perspective unique pour l'analyse des dynamiques socio-environnementales."),
        p("La section malaria est particulièrement efficace dans sa capacité à communiquer des données complexes sous une forme visuellement intuitive."),
        p("Les fonctionnalités autour des événements politiques ajoutent une dimension cruciale, permettant de lier santé et politique dans des contextes géographiques spécifiques."),
      )
    })
  })
  
  # Revenir à la liste principale des notes techniques
  observeEvent(input$back, {
    output$notesContent <- renderUI({
      fluidRow(
        column(
          4,
          div(
            class = "note-box",
            style = "border: 1px solid #ddd; padding: 15px; border-radius: 5px; background-color: #f9f9f9;",
            h4("Notes techniques 1", style = "color: white; background-color: red; padding: 5px; border-radius: 5px;"),
            p("Ces notes expliquent la documentation générale sur l'application."),
            actionLink("note1", "Read more →", style = "color: red;")
          )
        ),
        column(
          4,
          div(
            class = "note-box",
            style = "border: 1px solid #ddd; padding: 15px; border-radius: 5px; background-color: #f9f9f9;",
            h4("Notes techniques 2", style = "color: white; background-color: red; padding: 5px; border-radius: 5px;"),
            p("Ces notes expliquent les indices spectraux."),
            actionLink("note2", "Read more →", style = "color: red;")
          )
        ),
        column(
          4,
          div(
            class = "note-box",
            style = "border: 1px solid #ddd; padding: 15px; border-radius: 5px; background-color: #f9f9f9;",
            h4("Notes techniques 3", style = "color: white; background-color: red; padding: 5px; border-radius: 5px;"),
            p("Ces notes expliquent la malaria et les événements politiques."),
            actionLink("note3", "Read more →", style = "color: red;")
          )
        )
      )
    })
  })
}

# Lancer l'application Shiny
shinyApp(ui, server)
