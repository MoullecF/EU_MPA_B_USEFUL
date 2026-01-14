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
library(dplyr)
library(mapview)

rm(list = ls())
gc()
data.dir <- "C:/Users/fabie/Documents/Data/MPA_shp_BUSEFUL"

### Import MPA databases
# Aminian Biquet et al. 2024
db_mpa_EU <- read_excel(paste0(data.dir,"/Aminian_Biquet_2024_EU/Fulldatabase.xlsx"))
shp_mpa_EU <- st_read(paste0(data.dir,"/Aminian_Biquet_2024_EU/FulldatabaseSHP.shp"))
crs_target_EU <- st_crs(shp_mpa_EU)
shp_mpa_EU_all <- shp_mpa_EU %>% 
  inner_join(db_mpa_EU, by = "idMPAzone") %>%
  mutate(Source = "Aminian_Biquet_2024",
         Comment = "Based_on_all_human_activities") %>%
  select(
    Source,
    Name        = name.x,
    Country     = country.x,
    Mainregion = mainregion,
    Anchoring   = anchoring_PL1,
    Aquaculture = aquaculture_PL1,
    Infrastructure = infrastructure_PL1,
    Fishing     = fishing_PL1,
    Mining      = mining_PL1,
    Dredging    = dredginganddumping_PL1,
    Nonextractive = nonextractive_PL1,
    Protection_level_all = PLallactivities1,
    Comment
  ) %>%
  st_make_valid() %>%
st_transform(crs_target_EU) %>%
  st_cast("MULTIPOLYGON", warn = FALSE)

# United Kingdom
shp_mpa_UK_1 <- st_read(paste0(data.dir,"/United_Kingdom/Figshare_GIS_UK_MPA_FINAL/Figshare_GIS_UK_MPA_FINAL/Figshare_UK_MPA_FINAL.gpkg"), layer = "MCZ")
st_geometry(shp_mpa_UK_1) <- "geometry"
shp_mpa_UK_1 <- shp_mpa_UK_1 %>%
  mutate(Source = "Sim_2025",
         Comment = "Based_on_all_human_activities")%>%
  select(
    Source,
    Name        = NAME,
    Country     = country,
    Mainregion = searegions,
    Anchoring   = mpaguide_a,
    Aquaculture = mpaguide_1,
    Infrastructure = mpaguide_i,
    Fishing     = mpaguide_f,
    Mining      = mpaguide_m,
    Dredging    = mpaguide_d,
    Nonextractive = mpaguide_n,
    Protection_level_all = mpaguide_o,
    Comment
  ) %>%
  st_make_valid() %>%
  st_transform(crs_target_EU) %>%
  st_cast("MULTIPOLYGON", warn = FALSE)

shp_mpa_UK_2 <- st_read(paste0(data.dir,"/United_Kingdom/Figshare_GIS_UK_MPA_FINAL/Figshare_GIS_UK_MPA_FINAL/Figshare_UK_MPA_FINAL.gpkg"), layer = "NCMPA")
st_geometry(shp_mpa_UK_2) <- "geometry"
shp_mpa_UK_2 <- shp_mpa_UK_2 %>%
  mutate(Source = "Sim_2025",
         Comment = "Based_on_all_human_activities")%>%
  select(
    Source,
    Name        = NAME,
    Country     = country,
    Mainregion = searegions,
    Anchoring   = mpaguide_a,
    Aquaculture = mpaguide_1,
    Infrastructure = mpaguide_i,
    Fishing     = mpaguide_f,
    Mining      = mpaguide_m,
    Dredging    = mpaguide_d,
    Nonextractive = mpaguide_n,
    Protection_level_all = mpaguide_o,
    Comment
  ) %>%
  st_make_valid() %>%
  st_transform(crs_target_EU) %>%
  st_cast("MULTIPOLYGON", warn = FALSE)

shp_mpa_UK_3 <- st_read(paste0(data.dir,"/United_Kingdom/Figshare_GIS_UK_MPA_FINAL/Figshare_GIS_UK_MPA_FINAL/Figshare_UK_MPA_FINAL.gpkg"), layer = "SAC")
st_geometry(shp_mpa_UK_3) <- "geometry"
shp_mpa_UK_3 <- shp_mpa_UK_3 %>%
  mutate(Source = "Sim_2025",
         Country = NA,
         Mainregion = NA,
         Comment = "Based_on_all_human_activities") %>%
  select(
    Source,
    Name        = name,
    Country,
    Mainregion,
    Anchoring   = pl_anchori,
    Aquaculture = pl_aquacul,
    Infrastructure = pl_infrast,
    Fishing     = pl_fishing,
    Mining      = pl_mining,
    Dredging    = pl_dredgin,
    Nonextractive = pl_nonextr,
    Protection_level_all = pl_overall,
    Comment
  ) %>%
  st_make_valid() %>%
  st_transform(crs_target_EU) %>%
  st_cast("MULTIPOLYGON", warn = FALSE)

shp_mpa_UK_4 <- st_read(paste0(data.dir,"/United_Kingdom/Figshare_GIS_UK_MPA_FINAL/Figshare_GIS_UK_MPA_FINAL/Figshare_UK_MPA_FINAL.gpkg"), layer = "SPA")
st_geometry(shp_mpa_UK_2) <- "geometry"
shp_mpa_UK_4 <- shp_mpa_UK_4 %>%
  mutate(Source = "Sim_2025",
         Comment = "Based_on_all_human_activities")%>%
  select(
    Source,
    Name        = NAME,
    Country     = country,
    Mainregion = searegions,
    Anchoring   = mpaguide_a,
    Aquaculture = mpaguide_1,
    Infrastructure = mpaguide_i,
    Fishing     = mpaguide_f,
    Mining      = mpaguide_m,
    Dredging    = mpaguide_d,
    Nonextractive = mpaguide_n,
    Protection_level_all = mpaguide_o,
    Comment
  ) %>%
  st_make_valid() %>%
  st_transform(crs_target_EU) %>%
  st_cast("MULTIPOLYGON", warn = FALSE)

shp_mpa_UK_all <- bind_rows(shp_mpa_UK_1, shp_mpa_UK_2, shp_mpa_UK_3, shp_mpa_UK_4)

# Iceland
all_shp_iceland <- list.files(
  path = paste0(data.dir,"/selected_OECMs_Iceland/"),
  pattern = "\\.shp$",
  full.names = TRUE)

shp_list_iceland <- lapply(all_shp_iceland, function(f) {
  st_read(f, quiet = TRUE) %>%
    mutate(
      Protection_level_all = recode(
        file_path_sans_ext(basename(f)),
        protection_lv1 = "fully",
        protection_lv2 = "highly",
        protection_lv3 = "lightly",
        protection_lv4 = "minimally"
      ),
      Source         = "Francesco_2025",
      Country        = "Iceland",
      Mainregion     = "Arctic waters",
      Anchoring      = NA,
      Aquaculture    = NA,
      Infrastructure = NA,
      Fishing        = Protection_level_all,
      Mining         = NA,
      Dredging       = NA,
      Nonextractive  = NA,
      Comment = "Based_on_fishing_restrictions_only"
    ) %>%
    select(
      Source,
      Name = Name,
      Country,
      Mainregion,
      Anchoring,
      Aquaculture,
      Infrastructure,
      Fishing,
      Mining,
      Dredging,
      Nonextractive,
      Protection_level_all,
      Comment) %>%
    st_make_valid() %>%
    st_transform(crs_target_EU)
})

shp_mpa_Iceland_all <- do.call(rbind, shp_list_iceland)

# Fisheries Restricted Areas
all_shp_FRA <- list.files(
  path = paste0(data.dir,"/FRAs/"),
  pattern = "\\.shp$",
  recursive = TRUE,
  full.names = TRUE)

shp_list_FRA <- lapply(all_shp_FRA, function(f) {
  st_read(f, quiet = TRUE) %>%
    mutate(
      Source         = "Walter_2025",
      Name           = basename(dirname(f)),
      Country        = NA,
      Mainregion     = "Mediterranean Sea",
      Anchoring      = NA,
      Aquaculture    = NA,
      Infrastructure = NA,
      Fishing        = "fully",
      Mining         = NA,
      Dredging       = NA,
      Nonextractive  = NA,
      Protection_level_all = "fully",
      Comment = "Based_on_FRA_restrictions_only"
    ) %>%
    select(
      Source,
      Name,
      Country,
      Mainregion,
      Anchoring,
      Aquaculture,
      Infrastructure,
      Fishing,
      Mining,
      Dredging,
      Nonextractive,
      Protection_level_all,
      Comment) %>%
    st_make_valid() %>%
    st_transform(crs_target_EU)
})

shp_mpa_FRA_all <- do.call(rbind, shp_list_FRA)


# MPA Albania
shp_mpa_Albania <- st_read(paste0(data.dir,"/Karaburun-Sazan Marine National Park_ALBANIA/WDPA_WDOECM_Jan2026_Public_555513696_shp-polygons.shp"), quiet = TRUE) %>%
  mutate(
    Source         = "Walter_2025",
    Name           = "Karaburun-Sazan Marine National Park_ALBANIA",
    Country        = "Albania",
    Mainregion     = "Mediterranean Sea",
    Anchoring      = NA,
    Aquaculture    = NA,
    Infrastructure = NA,
    Fishing        = NA,
    Mining         = NA,
    Dredging       = NA,
    Nonextractive  = NA,
    Protection_level_all = "unclassified",
    Comment = "Based_on_nothing"
  ) %>%
  select(
    Source,
    Name,
    Country,
    Mainregion,
    Anchoring,
    Aquaculture,
    Infrastructure,
    Fishing,
    Mining,
    Dredging,
    Nonextractive,
    Protection_level_all,
    Comment) %>%
  st_make_valid() %>%
  st_transform(crs_target_EU)

# MPA Greenland
shp_mpa_Greenland <- st_read(paste0(data.dir,"/WDPA_WDOECM_Jan2026_Public_2065_shp_0/WDPA_WDOECM_Jan2026_Public_2065_shp-polygons.shp"), quiet = TRUE) %>%
  mutate(
    Source         = "Heino_2025",
    Country        = "Greenland",
    Mainregion     = "Arctic waters",
    Anchoring      = NA,
    Aquaculture    = NA,
    Infrastructure = NA,
    Fishing        = NA,
    Mining         = NA,
    Dredging       = NA,
    Nonextractive  = NA,
    Protection_level_all = "unclassified",
    Comment = "Based_on_nothing"
  ) %>%
  select(
    Source,
    Name = NAME,
    Country,
    Mainregion,
    Anchoring,
    Aquaculture,
    Infrastructure,
    Fishing,
    Mining,
    Dredging,
    Nonextractive,
    Protection_level_all,
    Comment) %>%
  st_make_valid() %>%
  st_transform(crs_target_EU)

####
# Bind all shapefiles
shp_mpa_all <- bind_rows(shp_mpa_EU_all, shp_mpa_UK_all, shp_mpa_FRA_all, shp_mpa_Iceland_all, shp_mpa_Greenland, shp_mpa_Albania)
#mapview(shp_mpa_all, zcol = 'Protection_level_all')
save(shp_mpa_all, file = "shp_mpa_europe_all.rda")
