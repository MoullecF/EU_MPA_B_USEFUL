###
#Author: Fabien Moullec
# R version 4.2.2
# Date : 13/01/2026
###

# MPA database comes from :
#https://www-science-org.ezpum.scdi-montpellier.fr/doi/10.1126/science.abf0861
#https://www.sciencedirect.com/science/article/pii/S2352340924011399#refdata001

#Load libraries
library(readxl)
library(sf)
library(tools)

rm(list = ls())
gc()
data.dir <- "C:/Users/fabie/Documents/Data/MPA_shp_BUSEFUL"

### Import MPA databases
# Aminian Biquet et al. 2024
db_mpa_EU <- read_excel(paste0(data.dir,"/Aminian_Biquet_2024_EU/Fulldatabase.xlsx"))
shp_mpa_EU <- st_read(paste0(data.dir,"/Aminian_Biquet_2024_EU/FulldatabaseSHP.shp"))
crs_target_EU <- st_crs(shp_mpa_EU)
shp_mpa_EU <- shp_mpa_EU %>% 
  inner_join(db_mpa_EU, by = "idMPAzone") %>%
  select("name.x","country.x", "idMPAzone","PLallactivities1", "fishing_PL1", "fishing_summaryPS") %>%
  st_make_valid()

# United Kingdom
shp_mpa_UK_1 <- st_read(paste0(data.dir,"/United_Kingdom/Figshare_GIS_UK_MPA_FINAL/Figshare_GIS_UK_MPA_FINAL/Figshare_UK_MPA_FINAL.gpkg"), layer = "MCZ")
shp_mpa_UK_2 <- st_read(paste0(data.dir,"/United_Kingdom/Figshare_GIS_UK_MPA_FINAL/Figshare_GIS_UK_MPA_FINAL/Figshare_UK_MPA_FINAL.gpkg"), layer = "NCMPA")
shp_mpa_UK_3 <- st_read(paste0(data.dir,"/United_Kingdom/Figshare_GIS_UK_MPA_FINAL/Figshare_GIS_UK_MPA_FINAL/Figshare_UK_MPA_FINAL.gpkg"), layer = "SAC")
shp_mpa_UK_4 <- st_read(paste0(data.dir,"/United_Kingdom/Figshare_GIS_UK_MPA_FINAL/Figshare_GIS_UK_MPA_FINAL/Figshare_UK_MPA_FINAL.gpkg"), layer = "SPA")

### select relevant columns in each layer
### change their names according to aminian biquet
### add designation
### Merge shapefiles by rows

shp_mpa_UK <- list(
  MCZ   = shp_mpa_UK_1,
  NCMPA = shp_mpa_UK_2,
  SAC   = shp_mpa_UK_3,
  SPA   = shp_mpa_UK_4)

shp_mpa_UK <- lapply(names(shp_mpa_UK), function(nm) {
  x <- shp_mpa_UK[[nm]]
  x$designation <- nm
  x
})

names(shp_mpa_UK) <- c("MCZ","NCMPA","SAC","SPA")
shp_mpa_UK <- lapply(shp_mpa_UK, st_transform, crs_target_EU)
shp_mpa_UK_merged <- dplyr::bind_rows(shp_mpa_UK)

shp_mpa_UK_na <- shp_mpa_UK_merged[is.na(shp_mpa_UK_merged$mpaguide_o), ]

# Iceland
all_shp_iceland <- list.files(
  path = paste0(data.dir,"/selected_OECMs_Iceland/"),
  pattern = "\\.shp$",
  full.names = TRUE)

shp_list_iceland <- lapply(all_shp_iceland, function(f) {
  
  x <- st_read(f, quiet = TRUE)
  
  # extract shapefile name without .shp
  x$protection_level <- file_path_sans_ext(basename(f))
  
  x
})

shp_list_iceland <- lapply(shp_list_iceland, function(x) {
  st_transform(x, crs_target_EU)
})

db_mpa_Iceland <- do.call(rbind, shp_list_iceland)

# Fisheries Restricted Areas
all_shp_FRA <- list.files(
  path = paste0(data.dir,"/FRAs/"),
  pattern = "\\.shp$",
  recursive = TRUE,
  full.names = TRUE)

shp_list_FRA <- lapply(all_shp_FRA, function(f) {
  x <- st_read(f, quiet = TRUE)
  
  x$shapefile_name <- file_path_sans_ext(basename(f))
  x$folder_name    <- basename(dirname(f))
  x$protection_level <- "FRA"
  x
})

shp_list_FRA <- lapply(shp_list_FRA, function(x) {
  st_transform(x, crs_target_EU)
})

# MPA Montenegro
shp_mpa_Montenegro <- st_read(paste0(data.dir,"/Karaburun-Sazan Marine National Park_ALBANIA/WDPA_WDOECM_Jan2026_Public_555513696_shp-polygons.shp"))
shp_mpa_Montenegro$protection_level <- "unclassified"
shp_mpa_Montenegro <- st_transform(shp_mpa_Montenegro, crs_target_EU)

# MPA Greenland
shp_mpa_Greenland <- st_read(paste0(data.dir,"/WDPA_WDOECM_Jan2026_Public_2065_shp_0/WDPA_WDOECM_Jan2026_Public_2065_shp-polygons.shp"))
shp_mpa_Greenland$protection_level <- "unclassified"
shp_mpa_Greenland <- st_transform(shp_mpa_Greenland, crs_target_EU)



