# modules/module_cartes.R

# Load necessary libraries
library(shiny)       # Core Shiny library for building interactive web applications
library(leaflet)     # For creating interactive maps
library(leafem)      # Provides additional functionalities for Leaflet maps
library(terra)       # For handling spatial raster data
library(sf)          # For handling spatial vector data
library(dplyr)       # For data manipulation

# Define the User Interface (UI) for the Maps Module
maps_ui <- function(id) {
  ns <- NS(id) # Create a namespace function using the provided module ID to avoid ID collisions
  
  # Create a fluid row to hold the map and its controls
  fluidRow(
    column(
      width = 12, # Occupies the full width of the row
      h4(tagList(icon("map"), "Map view")), # Heading level 4 with a map icon
      
      # Container div for the map and its control panel
      div(
        class = "map-container", # CSS class for custom styling
        leafletOutput(ns("map"), height = "600px"), # Leaflet map output with a specified height
        
        # Absolute panel for map controls (e.g., buttons, radio buttons, checkboxes)
        absolutePanel(
          class = "admin-panel", # CSS class for custom styling
          top = 10, right = 10, width = 150, # Positioning and size of the panel
          draggable = FALSE, # Panel is not draggable
          style = "background: rgba(255,255,255,0.9); 
                   padding: 10px; border-radius: 5px;", # Inline CSS for styling the panel
          
          # Button to recenter the map to the selected country's center
          actionButton(
            ns("recenter_map"), # Namespaced input ID
            label = "Recenter",  # Button label
            icon = icon("crosshairs"), # Crosshairs icon for the button
            style = "margin-bottom:5px;" # Inline CSS for spacing
          ),
          
          # Radio buttons to select the administrative level for data display
          radioButtons(
            ns("admin_level_map"), # Namespaced input ID
            "Administrative Level",  # Label displayed above the radio buttons
            choices = c(
              "Grid Level" = "country",  # Admin level 0 (national level)
              "Admin 1"    = "adm1",     # Admin level 1 (e.g., regions or states)
              "Admin 2"    = "adm2"      # Admin level 2 (e.g., departments or districts)
            ),
            selected = "country", # Default selected option
            inline = TRUE         # Display options inline horizontally
          ),
          
          # Checkbox to toggle the visibility of labels on the map
          checkboxInput(
            ns("show_labels"), # Namespaced input ID
            "Show labels",     # Label displayed next to the checkbox
            FALSE              # Default value (labels are hidden)
          )
        )
      ),
      
      br(), # Line break for spacing
      
      # Download button to allow users to download the currently displayed raster data
      downloadButton(
        ns("downloadRaster"), # Namespaced input ID
        "Download Raster"     # Button label
      )
    )
  )
}

# Define the Server Logic for the Maps Module
maps_server <- function(id, inputs) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns # Access the namespace function for server-side IDs
    
    # ================================
    # 1) Center Coordinates of the Selected Country
    # ================================
    country_center <- reactive({
      # Determine the latitude, longitude, and zoom level based on the selected country
      switch(inputs$country(),
             "Senegal" = list(lat = 14.4974, lng = -14.4524, zoom = 6),
             "Niger"   = list(lat = 17.6078, lng = 8.0817,  zoom = 6),
             "Burkina" = list(lat = 12.2383, lng = -1.5616, zoom = 6),
             "Mali"    = list(lat = 17.5707, lng = -3.9962, zoom = 5),
             list(lat = 0, lng = 0, zoom = 2) # Default fallback coordinates
      )
    })
    
    # ================================
    # 2) Path to the Raster File
    # ================================
    raster_path <- reactive({
      country   <- inputs$country()     # Selected country
      indicator <- inputs$indicator()   # Selected indicator
      lvl       <- input$admin_level_map # Selected administrative level
      
      # Determine the folder based on the administrative level
      folder <- switch(lvl,
                       "country" = "rasters_admin0", # Folder for admin level 0
                       "adm1"    = "rasters_admin1", # Folder for admin level 1
                       "adm2"    = "rasters_admin2"  # Folder for admin level 2
      )
      
      # Construct the full path to the raster file
      file.path("data", folder, paste0(indicator,"_", country, ".tif"))
    })
    
    # ================================
    # 3) Loading the Raster Data
    # ================================
    loaded_raster <- reactive({
      rpath <- raster_path() # Get the raster file path
      if (file.exists(rpath)) {
        rast(rpath)  # Load the raster using terra::rast
      } else {
        NULL # Return NULL if the raster file does not exist
      }
    })
    
    # ================================
    # 4) Path to the Shapefile
    # ================================
    shape_path <- reactive({
      country <- inputs$country()    # Selected country
      lvl     <- input$admin_level_map # Selected administrative level
      
      if (lvl == "country") return(NULL) # No shapefile for national level
      
      # Construct the path to the shapefile based on country and admin level
      file.path("data", "shapefiles", paste0(country, "_", lvl, ".shp"))
    })
    
    # ================================
    # 5) Loading the Shapefile
    # ================================
    loaded_shapefile <- reactive({
      spath <- shape_path() # Get the shapefile path
      if (is.null(spath)) return(NULL) # Return NULL if no shapefile is needed
      if (!file.exists(spath)) return(NULL) # Return NULL if the shapefile does not exist
      
      sf::st_read(spath, quiet = TRUE) # Load the shapefile using sf::st_read
    })
    
    # ================================
    # 6) Initial Map Rendering
    # ================================
    output$map <- renderLeaflet({
      # Create a Leaflet map with provider tiles and set a default view
      leaflet(options = leafletOptions(preferCanvas = TRUE)) %>%
        addProviderTiles(providers$CartoDB.Voyager, group = "BaseMap") %>% # Add base map tiles
        setView(lng = 0, lat = 0, zoom = 2) # Set initial map view
    })
    
    # ================================
    # 7) Observer to Center the Map When Country Changes
    # ================================
    observeEvent(inputs$country(), {
      center <- country_center() # Get the center coordinates for the selected country
      leafletProxy("map") %>%
        setView(lng = center$lng, lat = center$lat, zoom = center$zoom) # Update map view
    })
    
    # ================================
    # 8) Observer for the "Recenter Map" Button
    # ================================
    observeEvent(input$recenter_map, {
      center <- country_center() # Get the center coordinates for the selected country
      leafletProxy("map") %>%
        setView(lng = center$lng, lat = center$lat, zoom = center$zoom) # Recenter the map
    })
    
    # ================================
    # 9) Observer to Display the Raster on the Map
    # ================================
    observe({
      r <- loaded_raster() # Load the raster data
      leafletProxy("map") %>%
        clearImages() %>%          # Remove existing raster images
        removeControl("legend_raster") # Remove existing legend
      
      if (!is.null(r)) { # If raster data is available
        # Define a color palette based on the raster values
        pal <- colorNumeric("YlOrRd", domain = values(r), na.color = "transparent")
        
        leafletProxy("map") %>%
          addRasterImage(r, colors = pal, opacity = 0.8, group = "Raster", project = TRUE) %>% # Add raster image
          addLegend(
            pal      = pal,                         # Color palette
            values   = values(r),                   # Raster values for legend
            title    = paste0(inputs$indicator(), " - ", input$admin_level_map), # Legend title
            position = "bottomright",               # Legend position on the map
            layerId  = "legend_raster"              # Layer ID for the legend
          )
      }
    })
    
    # ================================
    # 10) Observer to Display the Shapefile and Extract Raster Values
    # ================================
    observe({
      shp <- loaded_shapefile()       # Load the shapefile
      lvl <- input$admin_level_map    # Selected administrative level
      r   <- loaded_raster()          # Load the raster data
      
      leafletProxy("map") %>%
        clearGroup("adminPoly")        # Remove existing administrative polygons
      
      if (!is.null(shp)) { # If shapefile data is available
        # Determine the appropriate label column based on administrative level
        label_col <- ifelse(lvl == "adm1", "ADM1_FR", "ADM2_FR")
        if (!label_col %in% colnames(shp)) {
          # Fallback to the first column if the expected label column is not present
          label_col <- colnames(shp)[1]
        }
        
        # Initialize variable to store mean raster values per polygon
        meanVals <- NULL
        
        if (!is.null(r)) { # If raster data is available
          # Convert the shapefile (sf object) to a SpatVector (terra object) for raster extraction
          shp_v <- terra::vect(shp)  
          
          # Extract the mean raster value for each polygon in the shapefile
          vals  <- terra::extract(r, shp_v, fun = mean, na.rm = TRUE)
          
          # Assume the second column contains the mean raster values and add it to the shapefile as "MeanVal"
          shp$MeanVal <- vals[, 2]
        }
        
        # Determine whether labels should always be visible based on user input
        nohide <- input$show_labels
        
        # Add polygons to the map with labels showing the region name and mean raster value
        leafletProxy("map") %>%
          addPolygons(
            data        = shp,                         # Shapefile data
            fill        = FALSE,                       # No fill color for polygons
            color       = "blue",                      # Polygon border color
            weight      = 1.5,                         # Border width
            opacity     = 1,                           # Border opacity
            group       = "adminPoly",                 # Group name for polygons
            label       = ~paste0(get(label_col), " : ", round(MeanVal, 3)), # Label with region name and mean value
            labelOptions = labelOptions(
              noHide    = nohide,                      # Show labels based on checkbox
              direction = "auto",                      # Label direction
              textsize  = "12px"                        # Label text size
            ),
            highlightOptions = highlightOptions(
              color        = "#FF0000",               # Highlight border color
              weight       = 3,                        # Highlight border width
              bringToFront = TRUE                      # Bring highlighted polygon to front
            )
          )
      }
    })
    
    # ================================
    # 11) Download Handler for the Raster
    # ================================
    output$downloadRaster <- downloadHandler(
      filename = function() {
        basename(raster_path()) # Use the raster file name as the download file name
      },
      content = function(file) {
        r <- loaded_raster() # Load the raster data
        if (!is.null(r)) {
          writeRaster(r, file, overwrite = TRUE) # Write the raster to the specified file path
        } else {
          writeLines("No raster found for this selection.", con = file) # Inform the user if no raster is available
        }
      }
    )
    
    # ================================
    # 12) Return Reactive Values from the Module
    # ================================
    return(list(
      admin_level = reactive({ input$admin_level_map }) # Reactive expression for the selected administrative level
    ))
  })
}
