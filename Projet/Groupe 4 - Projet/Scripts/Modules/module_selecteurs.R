# modules/module_selecteurs.R

# Load necessary library
library(shiny) # Core Shiny library for building interactive web applications

# Define the User Interface (UI) for the Selectors Module
selectors_ui <- function(id) {
  ns <- NS(id) # Create a namespace function using the provided module ID to avoid ID collisions
  
  # Define a hierarchical list of indicators categorized by their type
  choices_indicator <- list(
    "Malaria" = c("Malaria prevalence", ""), 
    "Conflict diffusion indicator" = c("CDI",""),
    "Vegetation Spectral Indices" = c("ARI", "ARI2", "ARVI", "ATSAVI", "AVI", "BCC", "BNDVI"),
    "Urbanization Spectral Indices" = c("BLFEI", "BRBA", "DBI", "EBBI", "IBI", "NBAI"),
    "Soil Spectral Indices" = c("BI", "BITM", "BIXS", "BaI", "DBSI", "EMBI"),
    "Water Spectral Indices" = c("ANDWI", "LSWI", "AWEInsh", "AWEIsh", "FAI")
    
  )
  
  # Create a fluid row to hold the country and indicator selectors side by side
  fluidRow(
    # Column for Country Selector
    column(
      width = 6, # Occupies half the width of the row
      selectInput(
        inputId = ns("country"), # Namespaced input ID for selecting a country
        label   = "Select Country", # Label displayed above the dropdown
        choices = c("","Senegal", "Niger", "Burkina", "Mali"), # Available country options
        selected = "" # Default selected country
      )
    ),
    # Column for Indicator Selector
    column(
      width = 6, # Occupies the other half of the row
      selectInput(
        inputId = ns("indicator"), # Namespaced input ID for selecting an indicator
        label   = "Select Indicator", # Label displayed above the dropdown
        choices = choices_indicator, # Hierarchical list of indicators grouped by category
        selected = "" # Default selected indicator
      )
    )
  )
}

# Define the Server Logic for the Selectors Module
selectors_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    # Return a list of reactive expressions capturing the current selections
    list(
      country   = reactive({ input$country }),   # Reactive expression for the selected country
      indicator = reactive({ input$indicator })  # Reactive expression for the selected indicator
    )
  })
}
