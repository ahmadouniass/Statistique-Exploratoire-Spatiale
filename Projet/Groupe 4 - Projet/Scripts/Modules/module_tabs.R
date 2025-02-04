
library(DT)
tabs_server <- function(id, inputs, selected_regions_detail, admin_level) {
  moduleServer(id, function(input, output, session) {
    
    # ================================
    # 0) Retrieve Selected Region
    # ================================
    chosen_region <- reactive({
      regs <- selected_regions_detail() # Get the list of selected regions from the input
      if (length(regs) == 1) {
        regs[[1]]  # If exactly one region is selected, return it (e.g., "Dakar")
      } else {
        NULL # If not exactly one region is selected, return NULL
      }
    })
    
    # ================================
    # 1) Define File Paths
    # ================================
    summary_path <- reactive({
      reg <- chosen_region() # Get the chosen region
      if (is.null(reg)) return(NULL) # If no region is selected, return NULL
      # Construct the file path for the summary CSV based on region, country, and indicator
      file.path("data", "summary",
                paste0(reg, "_", inputs$country(), "_", inputs$indicator(), ".csv")
      )
    })
    
    table_path <- reactive({
      reg <- chosen_region() # Get the chosen region
      if (is.null(reg)) return(NULL) # If no region is selected, return NULL
      # Construct the file path for the detailed table CSV based on region, country, and indicator
      file.path("data", "tables",
                paste0(reg, "_", inputs$country(), "_", inputs$indicator(), ".csv")
      )
    })
    
    chart_path <- reactive({
      reg <- chosen_region() # Get the chosen region
      if (is.null(reg)) return(NULL) # If no region is selected, return NULL
      # Construct the file path for the chart image based on region, country, and indicator
      file.path("data", "charts",
                paste0("Scatter_", reg, "_", inputs$country(), "_", inputs$indicator(), ".png")
      )
    })
    
    # ================================
    # 2) Summary Tab Logic
    # ================================
    # 2.1) Render Summary Introduction Text
    output$summary_text <- renderUI({
      reg <- chosen_region() # Get the chosen region
      if (is.null(reg)) {
        # If no region is selected, display an instructional message
        return(tags$em("Please select exactly one region to see the summary."))
      }
      
      spath <- summary_path() # Get the summary file path
      if (!file.exists(spath)) {
        # If the summary file does not exist, display an error message
        return(tags$em(paste("Summary file not found at:", spath)))
      }
      
      # Read the summary CSV file
      df <- read.csv(spath, stringsAsFactors = FALSE, sep = ";")
      # Assume the CSV has at least one row with columns: Region, Indicator, MinValue, MaxValue, MinDepartment, MaxDepartment
      if (nrow(df) < 1) {
        # If the CSV is empty, display an error message
        return(tags$em("No data in summary CSV."))
      }
      
      # Extract values from the first row
      region    <- df$Region[1]
      indicator <- df$Indicator[1]
      minVal    <- df$MinValue[1]
      maxVal    <- df$MaxValue[1]
      minDepart <- df$MinDepartment[1]
      maxDepart <- df$MaxDepartment[1]
      
      # Create a summary text string
      txt <- paste0(
        "Within the region of ", region, 
        ", the department with the lowest value of ", indicator, " is ", minDepart, 
        " (", minVal, "), while the highest is ", maxDepart, 
        " (", maxVal, ")."
      )
      
      # Display the summary text within a paragraph tag with increased font size
      tags$p(style = "font-size: 1.5rem;", txt)
    })
    
    # 2.2) Render Summary Table
    output$summary_table <- renderDT({
      reg <- chosen_region() # Get the chosen region
      if (is.null(reg)) {
        # If no region is selected, display a message in the table
        return(datatable(
          data.frame(Message = "Select exactly one region."), 
          options = list(dom = 't') # Only show the table body without additional controls
        ))
      }
      
      spath <- summary_path() # Get the summary file path
      if (!file.exists(spath)) {
        # If the summary file does not exist, display an error message in the table
        return(datatable(
          data.frame(Message = paste("Summary file not found at", spath)), 
          options = list(dom = 't')
        ))
      }
      
      # Read the summary CSV file
      df <- read.csv(spath, stringsAsFactors = FALSE, sep = ";")
      # Render the DataTable with pagination (5 rows per page)
      datatable(df, options = list(pageLength = 5))
    })
    
    # ================================
    # 3) Table Tab Logic
    # ================================
    # 3.1) Render Table Introduction Text
    output$table_text <- renderUI({
      reg <- chosen_region() # Get the chosen region
      if (is.null(reg)) {
        # If no region is selected, display an instructional message
        return(tags$em("Please select exactly one region to see the table."))
      }
      # Create an introduction text string for the table
      txt <- paste0(
        "Below is a table presenting the ", inputs$indicator(),
        " values aggregated at the Admin 2 level for the region of ", reg, "."
      )
      # Display the introduction text within a paragraph tag with increased font size
      tags$p(style = "font-size: 1.5rem;", txt)
    })
    
    # 3.2) Render Detailed Table
    output$table <- renderDT({
      reg <- chosen_region() # Get the chosen region
      if (is.null(reg)) {
        # If no region is selected, display a message in the table
        return(datatable(
          data.frame(Message = "Select exactly one region."),
          options = list(dom = 't') # Only show the table body without additional controls
        ))
      }
      
      tpath <- table_path() # Get the detailed table file path
      if (!file.exists(tpath)) {
        # If the table file does not exist, display an error message in the table
        return(datatable(
          data.frame(Message = paste("Table not found at", tpath)),
          options = list(dom = 't')
        ))
      }
      
      # Read the detailed table CSV file
      df <- read.csv(tpath, stringsAsFactors = FALSE, sep = ";")
      # Render the DataTable with pagination (5 rows per page)
      datatable(df, options = list(pageLength = 5))
    })
    
    # ================================
    # 4) Chart Tab Logic
    # ================================
    # 4.1) Render Chart Introduction Text
    output$chart_text <- renderUI({
      reg <- chosen_region() # Get the chosen region
      if (is.null(reg)) {
        # If no region is selected, display an instructional message
        return(tags$em("Please select exactly one region to see the chart."))
      }
      # Create an introduction text string for the chart
      txt <- paste0(
        "Below is a chart illustrating the distribution of ", inputs$indicator(),
        " at the Admin 2 level for the region of ", reg, "."
      )
      # Display the introduction text within a paragraph tag with increased font size
      tags$p(style = "font-size: 1.5rem;", txt)
    })
    
    # 4.2) Render Chart Image
    output$chart <- renderImage({
      reg <- chosen_region() # Get the chosen region
      if (is.null(reg)) {
        # If no region is selected, return an empty image with alternative text
        return(list(
          src = "",
          contentType = "text/html",
          alt = "Select exactly one region to see the chart."
        ))
      }
      
      cpath <- chart_path() # Get the chart image file path
      if (!file.exists(cpath)) {
        # If the chart file does not exist, return an empty image with alternative text
        return(list(
          src = "",
          contentType = "text/html",
          alt = paste("No chart file found at:", cpath)
        ))
      }
      
      # Return the list required by renderImage to display the image
      list(
        src = cpath,             # Path to the image file
        contentType = "image/png", # MIME type of the image
        alt = "Chart not found",  # Alternative text if the image cannot be displayed
        width = "100%"             # Display the image at full width of its container
      )
    }, deleteFile = FALSE) # Do not delete the image file after sending it to the client
    
  })
}

tabs_ui <- function(id) {
  ns <- NS(id)
  tabsetPanel(
    id = ns("tabs"),
    tabPanel("Summary", uiOutput(ns("summary_text")), DTOutput(ns("summary_table"))),
    tabPanel("Table", uiOutput(ns("table_text")), DTOutput(ns("table"))),
    tabPanel("Chart", uiOutput(ns("chart_text")), imageOutput(ns("chart")))
  )}
