### ------------------------------------------------------------------------
### Script: Intersect and de-overlap MPA polygons by protection priority
### ------------------------------------------------------------------------

### ------------------------------------------------------------------------
### 1) Setup
### ------------------------------------------------------------------------

library(sf)
library(dplyr)
library(lwgeom)

rm(list = ls())
gc()

source("safe_intersection.r")

### ------------------------------------------------------------------------
### 2) Load and rank input geometries
### ------------------------------------------------------------------------

crs_planar <- 3035
crs_output <- 4326
precision_m <- 10
minimum_area_m2 <- 10

protection_levels <- c(
  "unclassified",
  "incompatible",
  "minimally",
  "lightly",
  "highly",
  "fully"
)

sea_domain <- st_read("./Inputs/World_Seas_IHO_v3/World_Seas_IHO_v3.shp") %>%
  st_transform(crs_planar)

load("./Outputs/shp_mpa_europe_all.rda")

mpa_polygons <- shp_mpa_all %>%
  filter(!st_is_empty(geometry)) %>%
  st_collection_extract("POLYGON") %>%
  st_make_valid()

mpa_polygons$Protection_level_all <- factor(
  mpa_polygons$Protection_level_all,
  levels = protection_levels,
  ordered = TRUE
)
mpa_polygons$protection_val <- as.numeric(mpa_polygons$Protection_level_all)

mpa_polygons <- mpa_polygons %>%
  arrange(desc(protection_val))

### ------------------------------------------------------------------------
### 3) Region selection
### ------------------------------------------------------------------------

# Run lines 61-62 or 65-66 to select the region(s) of interest.

# One region only, e.g. Mediterranean Sea.
# Regions :"Mediterranean Sea", "Baltic Sea", "Black Sea"
selected_regions <- "Mediterranean Sea"
mpa_polygons <- mpa_polygons[mpa_polygons$Mainregion %in% selected_regions, ]

# NE Atlantic only, by excluding Mediterranean, Baltic, and Black Sea.
excluded_regions <- c("Mediterranean Sea", "Baltic Sea", "Black Sea")
selected_regions <- setdiff(unique(mpa_polygons$Mainregion), excluded_regions)
mpa_polygons <- mpa_polygons[mpa_polygons$Mainregion %in% selected_regions, ]

### ------------------------------------------------------------------------
### 4) Helper: robust topology rebuild
### ------------------------------------------------------------------------

rebuild_geometry <- function(geom) {
  if (is.null(geom) || length(geom) == 0 || all(st_is_empty(geom))) {
    return(geom)
  }

  geom %>%
    st_make_valid() %>%
    lwgeom::st_snap_to_grid(precision_m) %>%
    st_buffer(0) %>%
    st_make_valid()
}

### ------------------------------------------------------------------------
### 5) Prepare geometries for overlay
### ------------------------------------------------------------------------

mpa_polygons <- mpa_polygons %>%
  st_transform(crs_planar) %>%
  st_make_valid() %>%
  st_set_precision(precision_m) %>%
  lwgeom::st_snap_to_grid(precision_m) %>%
  st_cast("MULTIPOLYGON", warn = FALSE)

st_agr(mpa_polygons) <- "constant"

### ------------------------------------------------------------------------
### 6) Sequential de-overlap by priority
### ------------------------------------------------------------------------

mask_geometry <- NULL
result_list <- vector("list", nrow(mpa_polygons))
result_index <- 1

for (row_index in seq_len(nrow(mpa_polygons))) {
  polygon_row <- mpa_polygons[row_index, ]

  cat("i:", row_index, "\n")

  polygon_geometry <- rebuild_geometry(polygon_row$geometry)

  remaining_geometry <- if (!is.null(mask_geometry) && !all(st_is_empty(mask_geometry))) {
    rebuild_geometry(st_difference(polygon_geometry, mask_geometry))
  } else {
    polygon_geometry
  }

  if (!is.null(remaining_geometry) &&
      length(remaining_geometry) > 0 &&
      !all(st_is_empty(remaining_geometry))) {
    cat("k:", result_index, "\n")

    result_list[[result_index]] <- st_sf(
      Source = polygon_row$Source,
      Name = polygon_row$Name,
      Country = polygon_row$Country,
      Mainregion = polygon_row$Mainregion,
      Anchoring = polygon_row$Anchoring,
      Aquaculture = polygon_row$Aquaculture,
      Infrastructure = polygon_row$Infrastructure,
      Fishing = polygon_row$Fishing,
      Mining = polygon_row$Mining,
      Dredging = polygon_row$Dredging,
      Nonextractive = polygon_row$Nonextractive,
      Protection_level_all = polygon_row$Protection_level_all,
      geometry = remaining_geometry,
      crs = st_crs(mpa_polygons)
    )

    mask_geometry <- if (is.null(mask_geometry)) {
      remaining_geometry
    } else {
      rebuild_geometry(st_union(mask_geometry, remaining_geometry))
    }

    result_index <- result_index + 1
  }
}

### ------------------------------------------------------------------------
### 7) Final cleanup, marine clipping, and export
### ------------------------------------------------------------------------

result_layer <- do.call(rbind, result_list[seq_len(result_index - 1)])

result_layer <- result_layer %>%
  st_make_valid() %>%
  st_cast("MULTIPOLYGON", warn = FALSE)

# Keep marine area only to remove protected polygons falling on land.
shp_mpa <- safe_intersection(
  result_layer,
  sea_domain,
  crs_planar = crs_planar,
  area_min = minimum_area_m2
)

# Set once to control output object, shapefile folder, and zip name.
export_name <- "shp_mpa_NE_Atlantic_incl_UK" # Change name for each export.
shp_mpa_export <- st_transform(shp_mpa, crs_output)

output_dir <- file.path("Outputs", export_name)
output_zip <- file.path("Outputs", paste0(export_name, ".zip"))

st_write(shp_mpa_export, output_dir, driver = "ESRI Shapefile")

# Create a zip archive of the written shapefile folder.
if (file.exists(output_zip)) {
  file.remove(output_zip)
}
utils::zip(zipfile = output_zip, files = output_dir, flags = "-r9X")
