### ------------------------------------------------------------------------
### Script: Harmonize and merge European MPA shapefiles
### ------------------------------------------------------------------------

### ------------------------------------------------------------------------
### 1) Setup
### ------------------------------------------------------------------------

library(readxl)
library(sf)
library(dplyr)

rm(list = ls())
gc()

### ------------------------------------------------------------------------
### 2) Helper functions and paths
### ------------------------------------------------------------------------

# Apply shared geometry cleanup steps across sources.
finalize_geometry <- function(data, crs_target, cast_multipolygon = FALSE, drop_empty = FALSE) {
  output <- data %>%
    st_make_valid()

  if (drop_empty) {
    output <- output %>%
      filter(!st_is_empty(.data$geometry))
  }

  output <- output %>%
    st_transform(crs_target)

  if (cast_multipolygon) {
    output <- output %>%
      st_cast("MULTIPOLYGON", warn = FALSE)
  }

  output
}

uk_gpkg_path <- "./Inputs/United_Kingdom/Figshare_GIS_UK_MPA_FINAL/Figshare_GIS_UK_MPA_FINAL/Figshare_UK_MPA_FINAL.gpkg"
output_rda_path <- "./Outputs/shp_mpa_europe_all.rda"

protection_levels <- c(
  "unclassified",
  "incompatible",
  "minimally",
  "lightly",
  "highly",
  "fully"
)

# Read one UK layer and standardize fields to the common output schema.
read_uk_layer <- function(layer_name, crs_target, use_sac_schema = FALSE) {
  uk_layer <- st_read(uk_gpkg_path, layer = layer_name)
  st_geometry(uk_layer) <- "geometry"

  if (use_sac_schema) {
    uk_layer <- uk_layer %>%
      mutate(
        Source = "Sim_2025",
        Country = NA,
        Mainregion = NA,
        Comment = "Based_on_all_human_activities"
      ) %>%
      select(
        Source = .data$Source,
        Name = .data$name,
        Country = .data$Country,
        Mainregion = .data$Mainregion,
        Anchoring = .data$pl_anchori,
        Aquaculture = .data$pl_aquacul,
        Infrastructure = .data$pl_infrast,
        Fishing = .data$pl_fishing,
        Mining = .data$pl_mining,
        Dredging = .data$pl_dredgin,
        Nonextractive = .data$pl_nonextr,
        Protection_level_all = .data$pl_overall,
        Comment = .data$Comment
      )
  } else {
    uk_layer <- uk_layer %>%
      mutate(
        Source = "Sim_2025",
        Comment = "Based_on_all_human_activities"
      ) %>%
      select(
        Source = .data$Source,
        Name = .data$NAME,
        Country = .data$country,
        Mainregion = .data$searegions,
        Anchoring = .data$mpaguide_a,
        Aquaculture = .data$mpaguide_1,
        Infrastructure = .data$mpaguide_i,
        Fishing = .data$mpaguide_f,
        Mining = .data$mpaguide_m,
        Dredging = .data$mpaguide_d,
        Nonextractive = .data$mpaguide_n,
        Protection_level_all = .data$mpaguide_o,
        Comment = .data$Comment
      )
  }

  finalize_geometry(
    data = uk_layer,
    crs_target = crs_target,
    cast_multipolygon = TRUE,
    drop_empty = FALSE
  )
}

### ------------------------------------------------------------------------
### 3) Import and standardize each MPA source
### ------------------------------------------------------------------------

# Aminian Biquet et al. 2024 (EU)
# Source: https://www.sciencedirect.com/science/article/pii/S2352340924011399#refdata001
db_mpa_eu <- read_excel("./Inputs/Aminian_Biquet_2024_EU/Fulldatabase.xlsx")
shp_mpa_eu <- st_read("./Inputs/Aminian_Biquet_2024_EU/FulldatabaseSHP.shp")
crs_target_eu <- st_crs(shp_mpa_eu)

shp_mpa_eu_all <- shp_mpa_eu %>%
  inner_join(db_mpa_eu, by = "idMPAzone") %>%
  mutate(
    Source = "Aminian_Biquet_2024",
    Comment = "Based_on_all_human_activities"
  ) %>%
  select(
    Source = .data$Source,
    Name = .data$name.x,
    Country = .data$country.x,
    Mainregion = .data$mainregion,
    Anchoring = .data$anchoring_PL1,
    Aquaculture = .data$aquaculture_PL1,
    Infrastructure = .data$infrastructure_PL1,
    Fishing = .data$fishing_PL1,
    Mining = .data$mining_PL1,
    Dredging = .data$dredginganddumping_PL1,
    Nonextractive = .data$nonextractive_PL1,
    Protection_level_all = .data$PLallactivities1,
    Comment = .data$Comment
  ) %>%
  finalize_geometry(
    crs_target = crs_target_eu,
    cast_multipolygon = TRUE,
    drop_empty = TRUE
  )

# United Kingdom (MCZ, NCMPA, SAC, SPA)
# Source: Elsa Sim (2025) Regulations of Human Activities & Protection Levels in Marine Protected Areas of the United Kingdom.
# https://doi.org/10.6084/m9.figshare.29901479
uk_layers <- list(
  list(layer = "MCZ", use_sac_schema = FALSE),
  list(layer = "NCMPA", use_sac_schema = FALSE),
  list(layer = "SAC", use_sac_schema = TRUE),
  list(layer = "SPA", use_sac_schema = FALSE)
)

shp_mpa_uk_all <- bind_rows(lapply(
  uk_layers,
  function(layer_cfg) {
    read_uk_layer(
      layer_name = layer_cfg$layer,
      crs_target = crs_target_eu,
      use_sac_schema = layer_cfg$use_sac_schema
    )
  }
))

# Iceland
# Source: Francesco Ferretti (2025) Protection levels in Icelandic MPAs based on fishing restrictions.
load("./Inputs/protection_Iceland_REVISED/protection_Iceland_REVISED.Rdata")

shp_mpa_iceland_all <- d.protection4 %>%
  mutate(
    Source = "Francesco_2025",
    Country = "Iceland",
    Mainregion = "Arctic waters",
    Anchoring = NA,
    Aquaculture = NA,
    Infrastructure = NA,
    Fishing = "fully",
    Mining = NA,
    Dredging = NA,
    Nonextractive = NA,
    Protection_level_all = "fully",
    Comment = "Based_on_fishing_restrictions_only"
  ) %>%
  select(
    Source = .data$Source,
    Name = .data$Name,
    Country = .data$Country,
    Mainregion = .data$Mainregion,
    Anchoring = .data$Anchoring,
    Aquaculture = .data$Aquaculture,
    Infrastructure = .data$Infrastructure,
    Fishing = .data$Fishing,
    Mining = .data$Mining,
    Dredging = .data$Dredging,
    Nonextractive = .data$Nonextractive,
    Protection_level_all = .data$Protection_level_all,
    Comment = .data$Comment
  ) %>%
  finalize_geometry(
    crs_target = crs_target_eu,
    cast_multipolygon = FALSE,
    drop_empty = FALSE
  )

# Albania
# Source: WDPA polygons, manually classified as lightly protected.
shp_mpa_albania <- st_read(
  "./Inputs/Karaburun-Sazan Marine National Park_ALBANIA/WDPA_WDOECM_Jan2026_Public_555513696_shp-polygons.shp",
  quiet = TRUE
) %>%
  mutate(
    Source = "Walter_2025",
    Name = "Karaburun-Sazan Marine National Park_ALBANIA",
    Country = "Albania",
    Mainregion = "Mediterranean Sea",
    Anchoring = NA,
    Aquaculture = NA,
    Infrastructure = NA,
    Fishing = NA,
    Mining = NA,
    Dredging = NA,
    Nonextractive = NA,
    Protection_level_all = "lightly",
    Comment = "Based_on_nothing"
  ) %>%
  select(
    Source = .data$Source,
    Name = .data$Name,
    Country = .data$Country,
    Mainregion = .data$Mainregion,
    Anchoring = .data$Anchoring,
    Aquaculture = .data$Aquaculture,
    Infrastructure = .data$Infrastructure,
    Fishing = .data$Fishing,
    Mining = .data$Mining,
    Dredging = .data$Dredging,
    Nonextractive = .data$Nonextractive,
    Protection_level_all = .data$Protection_level_all,
    Comment = .data$Comment
  ) %>%
  finalize_geometry(
    crs_target = crs_target_eu,
    cast_multipolygon = FALSE,
    drop_empty = FALSE
  )

# Greenland
# Source: WDPA polygons, currently unclassified for use-level assessment.
shp_mpa_greenland <- st_read(
  "./Inputs/WDPA_WDOECM_Jan2026_Public_2065_shp_0/WDPA_WDOECM_Jan2026_Public_2065_shp-polygons.shp",
  quiet = TRUE
) %>%
  mutate(
    Source = "Heino_2025",
    Country = "Greenland",
    Mainregion = "Arctic waters",
    Anchoring = NA,
    Aquaculture = NA,
    Infrastructure = NA,
    Fishing = NA,
    Mining = NA,
    Dredging = NA,
    Nonextractive = NA,
    Protection_level_all = "unclassified",
    Comment = "Based_on_nothing"
  ) %>%
  select(
    Source = .data$Source,
    Name = .data$NAME,
    Country = .data$Country,
    Mainregion = .data$Mainregion,
    Anchoring = .data$Anchoring,
    Aquaculture = .data$Aquaculture,
    Infrastructure = .data$Infrastructure,
    Fishing = .data$Fishing,
    Mining = .data$Mining,
    Dredging = .data$Dredging,
    Nonextractive = .data$Nonextractive,
    Protection_level_all = .data$Protection_level_all,
    Comment = .data$Comment
  ) %>%
  finalize_geometry(
    crs_target = crs_target_eu,
    cast_multipolygon = FALSE,
    drop_empty = FALSE
  )

### ------------------------------------------------------------------------
### 4) Merge all sources and export
### ------------------------------------------------------------------------

shp_mpa_all <- bind_rows(
  shp_mpa_eu_all,
  shp_mpa_uk_all,
  shp_mpa_iceland_all,
  shp_mpa_greenland,
  shp_mpa_albania
)

shp_mpa_all$Protection_level_all <- factor(
  shp_mpa_all$Protection_level_all,
  levels = protection_levels,
  ordered = FALSE
)

save(shp_mpa_all, file = output_rda_path)
