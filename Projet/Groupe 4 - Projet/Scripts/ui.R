# app.R

# Load necessary libraries
library(shiny)            # Core Shiny library for building interactive web applications
library(shinythemes)      # Provides themes for Shiny apps to enhance UI aesthetics
library(shinycssloaders)  # Adds loading animations (spinners) while outputs are recalculating

# Source external module scripts
source("modules/module_selecteurs.R")   # Module for country and indicator selectors
source("modules/module_description.R")  # Module for displaying indicator descriptions
source("modules/module_cartes.R")       # Module for rendering maps
source("modules/module_tabs.R")         # Module for summary, table, and chart tabs

# Define the User Interface (UI) of the Shiny application
ui <- fluidPage(
  
  # Apply a Shiny theme for consistent and visually appealing styling
  theme = shinytheme("flatly"),
  
  # Include custom CSS for additional styling, such as increasing font sizes in selectors
  tags$head(
    # Link to an external CSS file located in the 'www' directory
    tags$link(rel = "stylesheet", type = "text/css", href = "styles.css"),
    tags$link(rel = "shortcut icon", href = "favicon.ico")
  ),

  # Set the main title of the application
  titlePanel("Spatial Exploratory Statistics"),
  
  # Create a navigation bar with multiple tabs/pages
  navbarPage(
    # Title of the navigation bar with a globe icon
    title = tagList(icon("globe"), "Spatial Stats App"),
    
    # ----------------------------------------------------------------------
    # HOME TAB
    # ----------------------------------------------------------------------
    tabPanel(
      title = tagList(icon("home"), "Home"), # Home tab with a home icon
      
      # Welcome Section
      fluidRow(
        column(12, # Occupies the full width of the row
               h3("Welcome to the Spatial Analysis Application"), # Heading level 3
               "This application empowers you to explore and analyze 
               a variety of spatial indices across West African nations (Senegal, Niger, Burkina, Mali).
               Whether you're interested in spectral indices, conflict diffusion indicators, or malaria rates, 
               our platform provides interactive visualizations to help you gain deeper insights.
               Navigate through the filters, delve into detailed maps, 
               and access comprehensive summaries, tables, and charts tailored to your selected areas."
        )
      ),
      
      # Filter Section Title with Icon
      fluidRow(
        column(12,
               h4(tagList(icon("filter"), "Filter")) # Heading level 4 with a filter icon
        )
      ),
      
      # Country and Indicator Selectors
      fluidRow(
        column(12,
               selectors_ui("selectors")    # Call to the selectors module UI
        ),
        column(12,
               description_ui("description") # Call to the description module UI
        )
      ),
      
      br(), # Line break for spacing
      
      # Map Display
      maps_ui("maps"), # Call to the maps module UI
      
      br(), hr(), # Line break and horizontal rule for separation
      
      # Region Selector Section
      fluidRow(
        column(12,
               # Title for the Region Selector with a map marker icon
               h4(tagList(icon("map-marker-alt"), "Regions for Summary/Table/Chart")),
               
               # Dynamic UI output for the region filter (single selection)
               uiOutput("region_filter_ui")
        )
      ),
      
      # Summary, Table, and Chart Tabs
      tabs_ui("tabs") # Call to the tabs module UI
    ),
    
    # ----------------------------------------------------------------------
    # ABOUT TAB
    # ----------------------------------------------------------------------
    tabPanel(
      title = tagList(icon("info-circle"), "About and technical notes"), # About tab with an info-circle icon
      fluidRow(
        column(12,
               HTML("
        <div>
          <h3>ABOUT</h3>
          
          <h4>Goal of the Application</h4>
          
            The goal of the application is to design an interactive interface using R Shiny that enables dynamic visualization and exploration of spatial data. Through interactive maps, the application will display various spectral indices, thus facilitating the analysis and interpretation of geospatial data. Users will be able to interact with different data layers, adjust parameters in real time, and obtain immediate results.
          
          
          <h4>Data Source</h4>
          
            The input data included the shapefiles of the four countries studied  <strong>(Burkina Faso, Mali, Niger, and Senegal) </strong> at the administrative level 0 (adm0), along with satellite images from  <strong>Landsat 9 </strong>. These daily images are useful for studying soil, vegetation, water resources, and urban areas. To select the  <strong>Landsat 9 images </strong>, we used the collection  <strong>'LANDSAT/LC09/C02/T1_L2' </strong>. The observation period selected spans from  <strong>January 1 to February 1, 2022 </strong>.
          
          
          <h4>Countries of Interest</h4>
          
            The countries selected for this study are Senegal, Mali, Burkina Faso, and Niger, located in West Africa. These countries share similar geographical and climatic characteristics, including Sahelian and semi-arid zones, as well as common challenges such as water resource management, desertification, and food security.
          
          
            Senegal and Mali offer ecological diversity, while Burkina Faso and Niger are more affected by drought and land degradation. These countries face issues related to agriculture, vegetation, and urbanization, making the use of spectral indices particularly relevant for monitoring these aspects.
          
          
            The use of satellite data, especially from Landsat 9, allows for tracking environmental changes in these regions and developing strategies for sustainable natural resource management.
          
          <h3>Technical notes</h3>
          <h4>Methods for Calculations</h4>
          <ul>
            <li>
              <strong>Processing Imported Rasters</strong>
              
                Two main functions were developed for raster processing. The first function applies normalization factors to spectral bands: the SR_B band is multiplied by 0.0000275 and adjusted by -0.2, while the ST_B band is multiplied by 0.00341802 and adjusted by 149.0. The second function focuses on cloud masking by using the QA_PIXEL keyword to identify cloudy areas and replace their pixels with a value of 0. Once these functions were applied to the selected images, a final image was created by computing the median value for each pixel location over the period from January 1 to February 1, 2022, further reducing cloud effects. The available bands of this image were displayed, and the resolution was reduced to 3000 m (instead of 30 m) to minimize output file sizes. The resulting image was then clipped to the target region using the clip operation. Visualization parameters were defined, and the final image was displayed with a focus on the selected region using the keywords Map.centerObject and Map.addLayer.
              
            </li>
            
            <li>
              <strong>Index Calculation</strong>
              
                Specific functions were created to calculate various indices for vegetation, urbanization, soil, and water. Each function generates a raster corresponding to a specific index. A global function, <em>calculateAllVegetationIndices</em>, was created to apply all vegetation index functions to a given image. Similarly, global functions were developed for urbanization indices (<em>calculateAllUrbanIndices</em>), soil-related indices (<em>calculateAllSoilIndices</em>), and water-related indices (<em>calculateAllWaterIndices</em>). Once these functions were developed, they were applied to the image produced in the previous step. All calculated indices were then merged into a single raster image to simplify management and processing.
              
            </li>
            
            <li>
              <strong>Visualization of Calculated Index</strong>
              
                Visualization parameters were defined for each calculated index. Each index was displayed on the Google Earth Engine (GEE) map by selecting the corresponding index. Since all indices were merged into a single image, the same image was repeatedly used to display each band corresponding to an index.
              
            </li>
            
            <li>
              <strong>Exporting Calculated Indices</strong>
              
                Common export parameters were defined, including a scale of 300 m, a coordinate reference system (CRS) set to EPSG:4326, and a maximum pixel limit of 1e13. The rasters corresponding to the indices were exported to Google Drive using the <em>Export.image.toDrive</em> function. For each export, the band corresponding to the index to be exported was selected from the merged image. In total, 29 spectral indices were calculated for each of the four studied countries (Burkina Faso, Mali, Niger, and Senegal), resulting in 116 generated rasters.
              
            </li>
            
            <li>
              <strong>Aggregation by Administrative Levels</strong>
              
                Rasters were aggregated at regional (adm1) and departmental (adm2) levels using the script <code>raster_Nomdupays.R</code>. Shapefiles (adm1 and adm2) were combined with the rasters to compute average pixel values for each polygon using <em>exact_extract</em>. The resulting rasters were saved with names indicating the administrative level, and the process was automated through a loop applied separately for regions and departments. Aggregated rasters were stored in distinct folders.
              
            </li>
            
            <li>
              <strong>Extraction of Raster Values for Regions and Departments</strong>
              
                Raster values were extracted and linked to administrative units (departments and regions). Key steps included reading and aligning coordinate systems of rasters and shapefiles, using <em>exact_extract</em> to calculate average pixel values for each department, and saving the results in CSV files summarizing the data by department.
              
            </li>
            
            <li>
              <strong>Graph Generation</strong>
              
                Dynamic graphs were created to visualize data by region and indicator. Data from CSV files were filtered and processed, with graphs generated for each region using <em>ggplot2</em>. The graphs, saved in PNG format and organized by region and indicator, were prepared for integration into the platform.
              
            </li>
            
            <li>
              <strong>Textual Presentation of Results</strong>
              
                Regional results were summarized, including average, minimum, and maximum raster values. Text descriptions were generated for each region and saved in text files for platform integration, providing an overview of key statistics.
              
            </li>
          </ul>
          
          <h4>Functionalities of the Application</h4>
          <ul>
            <li>
              <strong>Data Loading and Exploration</strong>
              
                Users can upload CSV files containing regional, departmental, and indicator values. The app reads these files using <code>read.csv</code>, and a filter section allows selection of countries and indicators. The description of selected indicators is dynamically displayed, or a default message is shown if unavailable.
              
            </li>
            
            <li>
              <strong>Interactive Map Visualization</strong>
              
                The app displays interactive maps, enabling dynamic exploration of geospatial data. Key features include:
              
              <ul>
                <li><strong>Data Loading:</strong> Raster files and shapefiles are loaded and harmonized for coordinate alignment if needed.</li>
                <li><strong>Administrative Levels:</strong> Users can visualize data at pixel, regional (adm1), or departmental (adm2) levels.</li>
                <li><strong>Interactive Mapping:</strong> Leaflet is used for map integration, with customizable background tiles and overlays for raster and shapefile data.</li>
                <li><strong>User Interaction:</strong> Clicking on areas displays specific details (region name and indicator value), with zoom and reset functionality. Labels can be shown directly on the map or via tooltips when hovering.</li>
              </ul>
            </li>
            
            <li>
              <strong>Raster Downloads</strong>
              
                Users can download maps and rasters through <code>downloadHandler</code> and <code>ggsave</code>. The exported files correspond to the selected indicator and country.
              
            </li>
            
            <li>
              <strong>Tabs for Summaries, Tables, and Graphs</strong>
              
                Users can explore data through dynamic summaries, tables, and graphs:
              
              <ul>
                <li><strong>Summaries:</strong> National and regional overviews provide minimum, maximum, and departmental breakdowns using <code>dplyr::summarize</code>.</li>
                <li><strong>Dynamic Tables:</strong> Built with <code>DT::datatable</code>, allowing sorting, searching, pagination, and column resizing.</li>
                <li><strong>Graphs:</strong> Region-specific graphs are generated in a loop, displaying departmental data with the selected indicator.</li>
              </ul>
            </li>
            
            <li>
              <strong>Customization and Aesthetics</strong>
              
                The app features a modern and intuitive design:
              
              <ul>
                <li><strong>Flatly Theme:</strong> Shinythemes' Flatly theme ensures a clean and professional layout.</li>
                <li><strong>Custom CSS:</strong> Tailored styles enhance the appearance of interactive elements, ensuring a cohesive look.</li>
                <li><strong>Loading Indicators:</strong> Shinycssloaders provide spinners during processes like map or graph loading, offering immediate visual feedback.</li>
              </ul>
            </li>
          </ul>
          
          <h4>REFERENCES</h4>
          <ul>
            <li>CMH progress map in LMICs</li>
            <li>awesome-spectral-indices/output/spectral-indices-table.csv at main · awesome-spectral-indices/awesome-spectral-indices</li>
          </ul>
          
          <h4>AUTHORS</h4>
          
            This portal was developed by  <strong>Fogwoung Djoufack Sarah-Laure </strong>,  <strong>Niass Ahmadou </strong>,  <strong>Nguemfouo Ngoumtsa Célina </strong>, and  <strong>Sène Malick </strong> as part of the 30-hour spatial exploration course. We had the opportunity to apply the knowledge we gained and to contribute to this project.
          
          
          <h4>DISCLAIMER</h4>
          
            ENSAE Pierre Ndiaye does not endorse or oppose any opinions expressed in this document. These opinions should be considered as those of the authors alone.
          
        </div>
      ")
        )
      )
    ),

    # -------------------------------
    # GUIDE TAB
    # -------------------------------
    tabPanel(
      title = tagList(icon("book"), "Guide"), # Guide tab with a book icon
      
      fluidRow(
        column(12,
               # Titre principal du guide
               h3("Comprehensive Guide to the Spatial Exploratory Statistics Application"),
               
               # Section 1: Introduction to Filters
               h4("1. Filter Section: Selecting Country and Indicator"),
               HTML("
         
          Begin your analysis by navigating to the <strong>Home</strong> tab. 
          Here, you'll find the <strong>Filter</strong> section at the top, 
          which allows you to customize your study by selecting a <strong>Country</strong> 
          and an <strong>Indicator</strong>. This filtering step is essential 
          to ensure that the map and subsequent analyses (Summary, Table, and Chart) 
          will display only the data relevant to your current interest.
          
      "),
               
               # Subsection a: Select Country
               h5("a. Select a Country"),
               HTML("
          Use the <strong>Select Country</strong> dropdown menu to choose one 
          of the available countries: <strong>Senegal</strong>, <strong>Niger</strong>, 
          <strong>Burkina Faso</strong>, or <strong>Mali</strong>. The chosen country 
          determines which administrative boundaries and underlying data will be loaded 
          into the map.
        <img src='images/FilterCountry.png' alt='Filter Country Screenshot' 
             style='max-width: 1200px; display:block; margin-bottom: 20px;' />
      "),
               
               # Subsection b: Select Indicator
               h5("b. Select an Indicator"),
               HTML("
         
          Next, choose the <strong>Indicator</strong> you wish to analyze from 
          the corresponding dropdown menu. The indicators are grouped by categories 
          (e.g., <em>Indices spectraux végétation</em>, <em>Indices spectraux sols</em>, 
          or <em>Malaria</em>, etc.). Selecting the appropriate indicator ensures 
          that the correct raster files and descriptions are displayed in the map 
          and further tabs.
          
        <img src='images/FilterIndicator.png' alt='Filter Indicator Screenshot' 
             style='max-width: 1200px; display:block; margin-bottom: 20px;' />
         
          <strong>Tip:</strong> If you're unsure about an index (e.g., NDVI, EVI, Malaria), 
          refer to the indicator description for more details on how 
          it is computed and what it represents.
          
      "),
               
               # Section 2: Exploring the Map
               h4("2. Exploring the Map: Administrative Levels and Features"),
               HTML("
         
          Below the filters, the <strong>Map View</strong> provides a visual representation 
          of the selected indicator across the chosen country. The map interface is powered 
          by Leaflet, offering intuitive controls for zooming, panning, and toggling overlays. 
          This section explains how to interact with the map, select administrative levels, 
          and explore various features.
          
      "),
               
               # Subsection a: Selecting Administrative Levels
               h5("a. Selecting Administrative Levels"),
               HTML("
         
          At the top-right corner of the map is the <strong>Administrative Level</strong> 
          panel (Admin Level radio buttons). This panel allows you to adjust the granularity 
          of the data displayed on the map. Each level corresponds to a different shapefile 
          and, consequently, different boundaries.
          
        <img src='images/AdminLevelPanel.png' alt='Administrative Level Panel Screenshot' 
             style='max-width: 1200px; display:block; margin-bottom: 20px;' />
        <strong>Options Available:</strong>
      "),
               tags$ul(
                 tags$li(HTML("<strong>Grid Level (Country Level):</strong> Displays data aggregated at the national level.")),
                 tags$li(HTML("<strong>Admin Level 1:</strong> Shows data segmented by the first administrative division (e.g., regions or states).")),
                 tags$li(HTML("<strong>Admin Level 2:</strong> Breaks down data further into second-level administrative units (e.g., departments or districts)."))
               ),
               HTML("
         
          Select the desired administrative level to update the map boundaries 
          and labels accordingly. This choice also influences how the raster 
          is displayed (e.g., which .tif file is loaded).
          
      "),
               
               # Subsection b: Interacting with the Map
               h5("b. Interacting with the Map"),
               HTML("
         
          You can use your mouse or trackpad to <strong>zoom in/out</strong> and <strong>pan</strong> 
          across different regions of the map. Hovering over (or clicking on) administrative boundaries 
          will highlight them. If <strong>Show labels</strong> is checked, you'll see region names 
          directly on the map. Otherwise, you can hover to reveal tooltip labels.
          
        <img src='images/MapHoverTooltip.png' alt='Map Hover Tooltip Screenshot' 
             style='max-width: 1200px; display:block; margin-bottom: 20px;' />
         
          <strong>Recenter Button:</strong> The top-right panel also contains a 
          <em>Recenter</em> button (with a crosshairs icon), which immediately zooms 
          back to the default extent for the selected country, ensuring that you never 
          lose track of your area of interest.
          
      "),
               
               # Subsection c: Selecting Regions
               h5("c. Selecting Regions (Departments)"),
               HTML("
         
          Just below the map on the Home tab, you'll find the <strong>Select Regions</strong> 
          section (or Regions for Summary/Table/Chart). This allows you to focus your analysis 
          on specific regions within the selected country. Note that choosing a single region 
          is often required to see detailed summaries, tables, and charts in the respective tabs.
          
        <strong>How to Select:</strong>
      "),
               tags$ol(
                 tags$li(HTML("Click on the <strong>Select Regions</strong> dropdown menu.")),
                 tags$li(HTML("Choose one or multiple regions (unless restricted to one) you wish to analyze.")),
                 tags$li(HTML("The map will highlight the selected regions in a distinct color for easy identification."))
               ),
               HTML("
         
          <img src='images/SelectRegion.png' alt='Select Region Screenshot' 
               style='max-width: 1200px; display:block; margin-bottom: 20px;' />
          Depending on your application settings, this selection might filter data 
          in the Summary, Table, and Chart tabs, providing specific insights into 
          that region’s values.
          
      "),
               
               # Section 3: Downloading Raster Data
               h4("3. Downloading Raster Data"),
               HTML("
         
          For in-depth spatial analyses or integration with GIS software, you can 
          download the currently displayed raster (for instance, if you selected 
          an index like NDVI or Malaria at Admin 2 level).
          
        <strong>How to Download:</strong>
      "),
               tags$ol(
                 tags$li(HTML("Click on the <strong>Download Raster</strong> button located below the map.")),
                 tags$li(HTML("A GeoTIFF file corresponding to your current <strong>Country</strong> and <strong>Administrative Level</strong> selections will be generated and downloaded.")),
                 tags$li(HTML("Use this raster file in your preferred GIS software (ArcGIS, QGIS, etc.) for further spatial analysis."))
               ),
               HTML("
         
          <img src='images/DownloadRaster.png' alt='Download Raster Button Screenshot' 
               style='max-width: 1200px; display:block; margin-bottom: 20px;' />
          This feature ensures that you can seamlessly transfer the data for offline usage 
          or more advanced geospatial processing.
          
      "),
               
               # Section 4: Navigating the Summary, Table, and Chart Tabs
               h4("4. Navigating the Summary, Table, and Chart Tabs"),
               HTML("
         
          At the bottom of the <strong>Home</strong> tab, you'll find three sub-tabs: 
          <strong>Summary</strong>, <strong>Table</strong>, and <strong>Chart</strong>. 
          These tabs provide detailed insights based on your current selections 
          (country, indicator, and region).
          
      "),
               
               # Subsection a: Summary Tab
               h5("a. Summary Tab"),
               HTML("
         
          The <strong>Summary</strong> tab offers a textual overview of the selected 
          <strong>Indicator</strong> across the chosen <strong>Country</strong> 
          and <strong>Region</strong>. For instance, if you have <em>Admin Level 2</em> 
          selected and you chose <em>Dakar</em>, you might see a description indicating 
          the <em>minimum</em>, <em>maximum</em>, and <em>average</em> values 
          of that indicator within the region.
          
        <strong>Content:</strong>
      "),
               tags$ul(
                 tags$li(HTML("<strong>National Summary:</strong> Displays when no specific region is selected, providing a broad overview for the entire country.")),
                 tags$li(HTML("<strong>Regional Summary:</strong> Aggregates data for the selected region(s), offering localized insights such as min/max or departmental breakdowns."))
               ),
               HTML("
         
          <img src='images/SummaryTab.png' alt='Summary Tab Screenshot' 
               style='max-width: 1200px; display:block; margin-bottom: 20px;' />
          You can also see a small table summarizing key metrics. 
          This helps you quickly understand which departments have the highest 
          or lowest values for the chosen indicator.
          
      "),
               
               # Subsection b: Table Tab
               h5("b. Table Tab"),
               HTML("
         
          The <strong>Table</strong> tab presents data in a structured, tabular format 
          for easy comparison and analysis. Each row might correspond to a sub-region 
          or another level of aggregation, depending on how your data is organized. 
          You can sort columns by clicking on their headers or use the search bar 
          to locate specific entries.
          
        <strong>Features:</strong>
      "),
               tags$ul(
                 tags$li(HTML("<strong>Sortable Columns:</strong> Click on column headers to sort data alphabetically or numerically.")),
                 tags$li(HTML("<strong>Search Functionality:</strong> Use the search bar above the table to quickly find specific rows or keywords."))
               ),
               HTML("
         
          <img src='images/TableTab.png' alt='Table Tab Screenshot' 
               style='max-width: 1200px; display:block; margin-bottom: 20px;' />
          
      "),
               
               # Subsection c: Chart Tab
               h5("c. Chart Tab"),
               HTML("
         
          The <strong>Chart</strong> tab visualizes data through interactive plots 
          (or static PNG images) that aid in pattern recognition and trend analysis. 
          For instance, you might see bar charts, scatter plots, or line graphs comparing 
          indicator values across different departments or time periods.
          
        <strong>Features:</strong>
      "),
               tags$ul(
                 tags$li(HTML("<strong>Dynamic Updates:</strong> Charts automatically refresh based on your selections, ensuring real-time interactivity.")),
                 tags$li(HTML("<strong>Interactive Elements:</strong> Hover over data points to view exact values or compare categories side by side."))
               ),
               HTML("
         
          <img src='images/ChartTab.png' alt='Chart Tab Screenshot' 
               style='max-width: 1200px; display:block; margin-bottom: 20px;' />
          
      "),
               
               # Section 5: Best Practices for Effective Analysis
               h4("5. Best Practices for Effective Analysis"),
               tags$ul(
                 tags$li(HTML("<strong>Selective Filtering:</strong> Narrow down your analysis by selecting specific regions to focus on areas of interest. This keeps the data more manageable and relevant to your immediate questions.")),
                 tags$li(HTML("<strong>Compare Administrative Levels:</strong> Toggle between different administrative levels (country, admin1, admin2) to understand data distribution at various scales.")),
                 tags$li(HTML("<strong>Leverage Downloaded Data:</strong> Export the raster data for in-depth GIS analyses (e.g., buffering, reclassification, or integration with other spatial layers).")),
                 tags$li(HTML("<strong>Explore Multiple Indicators:</strong> Investigate different indicators (e.g., NDVI vs. EVI, or Malaria vs. Conflict Diffusion) to gain a holistic understanding of socio-environmental dynamics.")),
                 tags$li(HTML("<strong>Utilize Map Interactivity:</strong> Use the highlight and label features to spot anomalies or interesting patterns (e.g., a particular department consistently having lower or higher values)."))
               ),
               
               # Section 6: Example Use Case
               h4("6. Example Use Case: Malaria in Burkina Faso"),
               HTML("
         <strong>Scenario:</strong> A public health researcher wants to analyze 
        malaria rates across different regions in Burkina Faso to identify hotspots 
        and inform intervention strategies.  
      "),
               
               h5("Steps:"),
               tags$ol(
                 tags$li(HTML("<strong>Filter Selection:</strong> <ul><li><strong>Country:</strong> Burkina Faso</li><li><strong>Indicator:</strong> Malaria Rate</li></ul>")),
                 tags$li(HTML("<strong>Map Exploration:</strong> <ul><li><strong>Administrative Level:</strong> Select <strong>Admin Level 2</strong> to view data at the departmental level.</li><li><strong>Select Regions:</strong> Choose regions experiencing high malaria incidence.</li></ul>")),
                 tags$li(HTML("<strong>Data Analysis:</strong> <ul><li><strong>Summary Tab:</strong> Review textual summaries highlighting key statistics such as minimum, maximum, and average malaria rates.</li><li><strong>Table Tab:</strong> Examine detailed tables showing malaria rates per department.</li><li><strong>Chart Tab:</strong> Visualize trends and compare different departments or timescales through interactive charts.</li></ul>")),
                 tags$li(HTML("<strong>Download Data:</strong> <ul><li>Click on <strong>Download Raster</strong> to obtain spatial data for further GIS analysis (e.g., correlation with rainfall or population density layers).</li></ul>"))
               ),
               
               HTML("
         
          <strong>Outcome:</strong> The researcher identifies critical regions requiring targeted 
          malaria interventions, supported by comprehensive data visualizations and summaries. 
          By overlaying additional contextual layers (e.g., healthcare infrastructure, population 
          density), further refined strategies can be devised.
          
        <img src='images/MalariaUseCase.png' alt='Malaria Use Case Screenshot' 
             style='max-width: 1200px; display:block; margin-bottom: 20px;' />
      "),
               # Section 7: Video Tutorial
               h4("7. Video Tutorial"),
               HTML("
      
     To further assist you in understanding how to use the application, please watch the following tutorial video:
     
   "),
               
               # Option 1: Intégrer une Vidéo Locale
               tags$h5("Embedded Local Video"),
               tags$video(
                 src = "Embedded Local Video.mp4", 
                 type = "video/mp4", 
                 controls = NA, 
                 style = "max-width: 100%; height: auto; display: block; margin: 20px auto;"
               ),
        )
      )
    )
  ) 
) 