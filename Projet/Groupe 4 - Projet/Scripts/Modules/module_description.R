# modules/module_description.R

# Load necessary library
library(shiny) # Core Shiny library for building interactive web applications

# Define the User Interface (UI) for the Description Module
description_ui <- function(id) {
  ns <- NS(id) # Create a namespace function using the provided module ID to avoid ID collisions
  
  # Create a fluid row to hold the description section
  fluidRow(
    column(
      12, # Occupies the full width of the row
      h4(tagList(icon("info-circle"), "Indicator Description")), # Heading level 4 with an info-circle icon
      textOutput(ns("description")) # Placeholder for the indicator description text
    )
  )
}

# List of Descriptions for Each Indicator
index_descriptions <- list(
  # Spectral Indices Specific to Water Monitoring
  "ANDWI" = "The ANDWI is an advanced remote sensing index designed to more accurately detect water presence in satellite imagery, especially in areas with dense vegetation or unique water characteristics. By refining the differentiation between water and other land cover types using the reflectance differences in infrared and near-infrared bands, the ANDWI surpasses the traditional NDWI. It is particularly valuable for water resource studies, flood management, wetland mapping, and monitoring water cover changes linked to human activities or climate change.",
  
  "AWEInsh" = "The AWEInsh refines water detection by accounting for shadows, reducing their impact on identifying aquatic surfaces. Using NIR, red, and SWIR bands, it effectively distinguishes water from other land covers. This makes it ideal for flood monitoring, water resource management, and wetland mapping in shadowed environments.",
  
  "AWEIsh" = "The AWEIsh is designed to detect water in satellite images while accounting for shadows, making it especially useful in complex environments. By leveraging NIR, SWIR, and blue spectral bands, it enhances water identification while excluding shadowed areas or surface artifacts. It is commonly applied in water resource management, wetland mapping, and flood monitoring, particularly in regions with dense vegetation or significant shadow interference.",
  
  "FAI" = "The FAI is a spectral index designed to detect and monitor floating algae in water bodies. It plays a key role in water quality studies, particularly in identifying algal blooms (eutrophication events) that can affect aquatic ecosystems and public health. Using red and NIR bands, the FAI captures the optical properties of surface algae, making it effective for tracking biomass variations in lakes, rivers, and reservoirs. This index supports water resource management, environmental impact assessment, and pollution prevention efforts.",
  
  "LSWI" = "The LSWI is a spectral index used to monitor soil moisture and surface water presence, particularly in wetlands, wet soils, and flood-affected areas. Utilizing NIR and SWIR bands, it detects moisture variations and maps flooded regions. Widely applied in water resource management, drought monitoring, and assessing the impacts of extreme climatic events like floods, the LSWI also supports agricultural water management and studies on climate change effects on aquatic ecosystems.",
  
  "WI2" = "The WI2 enhances water detection in satellite imagery, using SWIR and NIR bands to differentiate water bodies from other surfaces, even under challenging conditions. It supports water resource management, wetland mapping, flood monitoring, and tracking seasonal changes in water levels.",
  
  # Spectral Indices Specific to Vegetation
  "ARI" = "ARI quantifies anthocyanin pigments in plants, which give red, purple, or blue coloration. It uses specific red and NIR spectral bands to detect these pigments. The index is useful for monitoring plant stress responses (such as cold, drought, or infection), as anthocyanins are produced under these conditions.",
  
  "ARI2" = "ARI2 is an improved version of ARI, designed for more accurate quantification of anthocyanins in plants, which are responsible for red, blue, and purple hues in leaves. It uses reflectance in specific spectral bands, primarily in the red and NIR, with enhanced sensitivity and precision. This index is widely used to assess plant stress from extreme environmental conditions like drought, high temperatures, or pest attacks.",
  
  "ARVI" = "ARVI is a spectral index used to assess vegetation health while accounting for atmospheric influences. Derived from remote sensing data, it combines spectral bands in the red, near-infrared (NIR), and mid-infrared regions. Designed to correct atmospheric effects like aerosol scattering, ARVI improves the accuracy of vegetation analysis.",
  
  "ATSAVI" = "ATSAVI is a spectral index designed to evaluate vegetation while minimizing the influence of soil background, which can distort results in areas with low vegetation cover. Based on a modified version of the Soil-Adjusted Vegetation Index (SAVI), it uses a specific transformation to better correct for the effects of exposed soils, clouds, or rocky surfaces that can affect vegetation measurements.",
  
  "AVI" = "AVI is a spectral index designed to provide a more accurate evaluation of vegetation using specific spectral bands. It combines different wavelengths, particularly those sensitive to chlorophyll and plant moisture. AVI enhances the detection capabilities of traditional indices by offering greater sensitivity to variations in vegetation health and density, even in conditions where classic indices like NDVI may become saturated.",
  
  "BCC" = "The BCC is a spectral index used to evaluate the color of vegetation from remote sensing data. It is based on the reflection of light in the blue band, a wavelength sensitive to the composition and health of vegetation.",
  
  "BNDIV" = "The BNDVI is a spectral index used in remote sensing to monitor vegetation, particularly focusing on reflectance in the blue and near-infrared (NIR) bands. It is calculated using the normalized difference between the reflectance in these two bands. The BNDVI is particularly useful for assessing plant health, as it is sensitive to chlorophyll variations and can detect vegetation stress areas, especially in cases of drought, diseases, or environmental disruptions.",
  
  "BNIRV" = "The BNIRV is a spectral index used to analyze vegetation using remote sensing data. It utilizes light reflection in the blue and near-infrared (NIR) bands, which are characteristic of vegetation's spectral properties. This index is commonly used to assess plant health, detect areas of dense or sparse vegetation, and monitor environmental stressors like droughts or plant diseases.",
  
  "EVI" = "The EVI is a vegetation index designed to improve vegetation detection, particularly in dense vegetation areas and regions where atmospheric conditions and cloud cover can interfere with analysis. It overcomes the limitations of NDVI by offering greater sensitivity to vegetation variations and reducing the influence of atmospheric conditions and soils.",
  
  "NDVI" = "NDVI is a widely used vegetation index in remote sensing, based on the difference in reflectance between the near-infrared (NIR) and red bands of satellite images. It is highly sensitive to vegetation changes, making it valuable for detecting crop growth, drought periods, and other environmental stresses.",
  
  "NDYI" = "NDYI is a spectral index used to monitor the yellowing of plants, a sign often associated with stress, aging, or plant diseases. Derived from satellite images using spectral bands corresponding to yellow and red colors, it helps assess plant stress, particularly due to drought, pest attacks, or other environmental factors.",
  
  # Spectral Indices for Soil Observation
  "BAl" = "The Bareness Index (BaI) is used to identify and quantify bare land surfaces, such as soils or deforested areas, using remote sensing data. The index is particularly useful for monitoring land degradation, erosion, and human activities like urbanization and agriculture. It enables large-scale, long-term tracking of changes in bare land, although its effectiveness may be limited in highly disturbed or urban environments.",
  
  "BI/BSI" = "BSI is an index used to identify and extract bare soil areas from satellite images. It combines blue, red, near-infrared (NIR), and shortwave infrared (SWIR) spectral bands to detect the specific characteristics of soil without vegetation. BSI is applied in various fields, including agricultural management, where it helps monitor exposed soils, especially during fallow periods.",
  
  "BITM" = "BITM is an index used to assess the brightness of land surfaces from Landsat satellite images, particularly from the Thematic Mapper (TM) sensor. By utilizing visible and near-infrared spectral bands, it helps identify features such as bare soils, urban areas, and vegetation.",
  
  "BIXS" = "BIXS is an index used to analyze the brightness of land surfaces from SPOT HRV XS satellite images by combining visible and near-infrared bands. It effectively distinguishes land cover types (urban, rural, agricultural, natural) and is used for soil mapping, environmental monitoring (deforestation, urbanization), and agricultural management.",
  
  "DBSI" = "The DBSI is a spectral index used to detect and quantify bare soil areas, particularly in dry or semi-arid regions. It analyzes reflectance in the near-infrared (NIR) and shortwave infrared (SWIR) bands, differentiating bare soils from other land cover types. DBSI is especially useful for identifying dry, bare soils that are difficult to distinguish from vegetated or urban surfaces using other indices.",
  
  "EMBI" = "The EMBI is an improved version of the Bare Soil Index (BSI), designed to more accurately identify bare soil areas from remote sensing data. It incorporates adjustments to reduce interferences from vegetated surfaces and urban areas. By utilizing multiple spectral bands, including those in the red, near-infrared (NIR), and shortwave infrared (SWIR) regions, the EMBI enhances the differentiation between bare soils and other land cover types.",
  
  # Spectral Indices for Urban Area Observation
  "BLFEI" = "The BLFEI is an index used to identify urban areas and constructed land features, based on reflection in specific spectral bands. It helps distinguish urban surfaces from other types of land cover, such as rural or natural areas. This index is particularly useful in urban planning, infrastructure management, and land-use planning.",
  
  "Malaria prevalence" = "The malaria prevalence rate per 1,000 inhabitants represents the number of people infected with the malaria parasite in a given population. For countries like Mali, Senegal, Niger, and Burkina Faso, this rate is a crucial indicator of the extent of the disease in these regions, where malaria is endemic.",
  
  "CDI" = "The CDI (Confliction Diffusion Indicator) is an index used to evaluate the spread and intensity of conflicts in a given region by analyzing geospatial and temporal data. It measures the impact of conflicts on territories by identifying areas of spread, their density, and their influence on local populations.",
  
  "BRBA" = "The BRBA is an index used to identify urban areas from satellite data. It is based on the ratio between two specific spectral bands, typically in the visible and near-infrared parts of the spectrum. This index is particularly useful for detecting urban areas and analyzing the expansion of built-up surfaces in urban environments.",
  
  "DBI" = "The DBI is a spectral index used to detect dry urban areas, particularly in regions where built-up surfaces, such as buildings and roads, are exposed to drought conditions or high temperatures. The DBI utilizes a ratio between different spectral bands, primarily in the near-infrared and thermal bands, to distinguish dry urban zones from other types of land cover.",
  
  "EBBI" = "The EBBI is a spectral index designed to distinguish built-up urban areas and bare soil zones from vegetation. It uses the near-infrared (NIR), red (Red), and short-wave infrared (SWIR) bands to highlight urbanized surfaces and bare soil areas.",
  
  "IBI" = "The IBI is a spectral index used to identify and map urban areas from satellite images. It relies on the use of specific spectral bands that distinguish the characteristics of built surfaces, such as buildings, roads, and other urban infrastructures, while minimizing the influence of vegetation, water, and other natural elements.",
  
  "NBAI" = "The NBAI is an index designed to extract urban or built-up areas from satellite images, focusing on spectral reflectance differences between specific satellite bands. It is particularly effective in reducing confusion with other types of land cover, such as bare soil or vegetation."
)

# Define the Server Logic for the Description Module
description_server <- function(id, inputs) {
  moduleServer(id, function(input, output, session) {
    
    # Render the description text based on the selected indicator
    output$description <- renderText({
      ind <- inputs$indicator() # Retrieve the selected indicator from the selectors module
      description <- index_descriptions[[ind]] # Get the corresponding description from the list
      if (!is.null(description)) { # If a description exists for the selected indicator
        description # Return the description text
      } else {
        "Aucune description disponible pour cet indicateur." # French for "No description available for this indicator."
      }
    })
    
  })
}
