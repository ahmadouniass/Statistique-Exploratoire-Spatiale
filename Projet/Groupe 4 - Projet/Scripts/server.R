# Load necessary modules
source("modules/module_selecteurs.R")   # Module for country and indicator selectors
source("modules/module_description.R")  # Module for displaying indicator descriptions
source("modules/module_cartes.R")       # Module for rendering maps
source("modules/module_tabs.R")         # Module for summary, table, and chart tabs

######################################################
# SERVER
######################################################
server <- function(input, output, session) {
  
  # 1) Selectors Module (Country and Indicator)
  # Initializes the selectors module, which manages user inputs for selecting countries and indicators
  selectors <- selectors_server("selectors")
  
  # 2) Description Module
  # Initializes the description module, which displays descriptions based on the selected indicator
  description_server("description", selectors)
  
  # 3) Maps Module
  # Initializes the maps module, which handles the rendering and interaction with maps based on user selections
  maps_vals <- maps_server("maps", selectors)
  
  # 4) List of Regions (by Country) - Single Selection
  # Defines a list mapping each country to its respective regions. This is used to dynamically populate the region selector based on the selected country.
  region_choices <- list(
    "Senegal"  = c("Dakar", "Thiès", "Saint-Louis", "Diourbel", "Fatick", "Kaolack", "Kolda", "Louga", "Matam", "Tambacounda", "Ziguinchor", "Sédhiou", "Kaffrine", "Kédougou"),
    "Niger"    = c("Agadez", "Diffa", "Dosso", "Maradi", "Tahoua", "Tillabéri", "Zinder", "Niamey"),
    "Burkina"  = c("Boucle du Mouhoun", "Cascades", "Centre", "Centre-Est", "Centre-Nord", "Centre-Ouest", "Centre-Sud", "Est", "Hauts-Bassins", "Nord", "Plateau-Central", "Sahel", "Sud-Ouest"),
    "Mali"     = c("Kayes", "Koulikoro", "Sikasso", "Ségou", "Mopti", "Tombouctou", "Gao", "Kidal", "Bamako")
  )
  
  # Render UI for Region Filter
  # Dynamically generates the region selection input based on the selected country
  output$region_filter_ui <- renderUI({
    # Retrieve the selected country from the selectors module
    countrySelected <- selectors$country()
    
    # Check if the selected country exists in the region_choices list
    if (countrySelected %in% names(region_choices)) {
      # Retrieve the list of regions for the selected country
      choices <- region_choices[[countrySelected]]
    } else {
      # If no valid country is selected, provide an empty choice list
      choices <- character(0)
    }
    
    # Create a selectInput for regions with single selection enabled
    selectInput(
      inputId = "region_filter",  # Unique identifier for the region filter input
      label   = "Select a Region:", # Label displayed above the dropdown
      choices = choices,           # Available regions based on selected country
      multiple = FALSE             # Restricts selection to a single region
    )
  })
  
  # Reactive Expression for Region Filter
  # Monitors the selected region and makes it available reactively for other modules
  region_filter <- reactive({
    req(input$region_filter)  # Ensures that a region is selected before proceeding
    # Returns the selected region (e.g., "Dakar")
    input$region_filter
  })
  
  # 5) Tabs Module
  # Initializes the tabs module, which manages the Summary, Table, and Chart tabs
  # Passes the selectors, region filter, and administrative level from maps_vals to the module
  tabs_server("tabs", selectors, region_filter, maps_vals$admin_level)
}
