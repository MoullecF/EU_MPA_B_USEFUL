### ------------------------------------------------------------------------
### Script: Map of MPA protection levels in Europe
### ------------------------------------------------------------------------

### ------------------------------------------------------------------------
### 1) Setup
### ------------------------------------------------------------------------

library(sf)
library(dplyr)
library(ggplot2)
library(patchwork)
library(rnaturalearth)

rm(list = ls())

### ------------------------------------------------------------------------
### 2) Configuration
### ------------------------------------------------------------------------

zip_files <- c(
  baltic = "./Outputs/shp_mpa_baltic_sea.zip",
  med = "./Outputs/shp_mpa_med_sea.zip",
  ne_atlantic = "./Outputs/shp_mpa_NE_Atlantic_incl_UK.zip"
)

area_labels <- c(
  baltic = "Baltic Sea",
  med = "Mediterranean Sea",
  ne_atlantic = "NE Atlantic incl. UK"
)

protection_levels <- c(
  "unclassified",
  "incompatible",
  "minimally",
  "lightly",
  "highly",
  "fully"
)

protection_palette <- c(
  "unclassified" = "#f1eef6",
  "incompatible" = "#d0d1e6",
  "minimally" = "#c7e9c0",
  "lightly" = "#74c476",
  "highly" = "#fec44f",
  "fully" = "#d95f0e"
)

output_png <- "./Figures/Map_multipanel_Protection_level_all.png"
output_pdf <- "./Figures/Map_multipanel_Protection_level_all.pdf"
a4_width_in <- 11.69
a4_height_in <- 8.27
output_dpi <- 1000

### ------------------------------------------------------------------------
### 3) Helpers
### ------------------------------------------------------------------------

read_shapefile_from_zip <- function(zip_path, area_name) {

  temp_dir <- tempfile(pattern = "mpa_zip_")
  dir.create(temp_dir, recursive = TRUE)

  extracted_files <- utils::unzip(zipfile = zip_path, exdir = temp_dir)
  shp_candidates <- extracted_files[grepl("\\.shp$", extracted_files, ignore.case = TRUE)]

  shp_path <- shp_candidates[1]

  sf_obj <- sf::st_read(shp_path, quiet = TRUE) %>%
    mutate(Area = area_name)

  sf_obj
}

### ------------------------------------------------------------------------
### 4) Read data and prepare attributes
### ------------------------------------------------------------------------

mpa_maps <- bind_rows(
  read_shapefile_from_zip(zip_files[["baltic"]], area_labels[["baltic"]]),
  read_shapefile_from_zip(zip_files[["med"]], area_labels[["med"]]),
  read_shapefile_from_zip(zip_files[["ne_atlantic"]], area_labels[["ne_atlantic"]])
)

protection_field <- dplyr::case_when(
  "Prtct__" %in% names(mpa_maps) ~ "Prtct__",
  "Protection_level_all" %in% names(mpa_maps) ~ "Protection_level_all",
  TRUE ~ NA_character_
)

mpa_maps <- mpa_maps %>%
  mutate(Protection_level_all = .data[[protection_field]]) %>%
  mutate(
    Protection_level_all = tolower(as.character(Protection_level_all)),
    Protection_level_all = ifelse(
      Protection_level_all %in% protection_levels,
      Protection_level_all,
      "unclassified"
    ),
    Protection_level_all = factor(Protection_level_all, levels = protection_levels, ordered = TRUE),
    Area = factor(Area, levels = unname(area_labels))
  )


continents <- rnaturalearth::ne_countries(scale = "large", returnclass = "sf") %>%
  sf::st_transform(sf::st_crs(mpa_maps))

### ------------------------------------------------------------------------
### 5) Plot map
### ------------------------------------------------------------------------

p_all <- ggplot() +
  geom_sf(
    data = mpa_maps,
    aes(fill = Protection_level_all),
    color = NA,
    linewidth = 0.05
  ) +
  geom_sf(
    data = continents,
    fill = "grey90",
    color = "grey20",
    linewidth = 0.08
  ) +
  coord_sf(
    xlim = c(-28, 35.5),
    ylim = c(34, 68),
    expand = FALSE
  ) +
  scale_fill_manual(
    values = protection_palette,
    breaks = protection_levels,
    labels = tools::toTitleCase(protection_levels),
    name = "Protection level",
    guide = guide_legend(nrow = 1, byrow = TRUE, reverse = FALSE)
  ) +
  labs(
    title = "MPAs in Europe",
    x = "Longitude",
    y = "Latitude"
  ) +
  theme(
    panel.grid.major = element_blank(),
    panel.border = element_rect(colour = "black", fill = NA, linewidth = 1),
    panel.background = element_rect(fill = "white"),
    plot.background = element_rect(fill = "white", colour = NA),
    legend.position = "bottom",
    legend.direction = "horizontal",
    legend.title.position = "top",
    legend.box = "horizontal",
    axis.text = element_text(size = 10),
    axis.title = element_blank(),
    plot.title = element_text(face = "bold", size = 10, hjust = 0.5),
    legend.title = element_text(size = 10),
    legend.text = element_text(size = 10),
    legend.key = element_rect(color = "white"),
    plot.margin = unit(c(0, 0, 0, 0), "pt")
  )

### ------------------------------------------------------------------------
### 6) Calculate area proportions by protection level and create circular plot
### ------------------------------------------------------------------------

area_summary <- mpa_maps %>%
  st_transform(3035) %>%
  mutate(area_km2 = as.numeric(st_area(geometry)) / 1e6) %>%
  st_drop_geometry() %>%
  group_by(Protection_level_all) %>%
  summarise(area_km2 = sum(area_km2, na.rm = TRUE), .groups = "drop") %>%
  mutate(Protection_level_all = as.character(Protection_level_all))

all_levels <- data.frame(
  Protection_level_all = as.character(protection_levels)
)

area_summary <- all_levels %>%
  left_join(area_summary, by = "Protection_level_all") %>%
  mutate(
    area_km2 = ifelse(is.na(area_km2), 0, area_km2),
    proportion = area_km2 / sum(area_km2),
    Protection_level_all = factor(Protection_level_all, levels = protection_levels, ordered = TRUE)
  )

p_area_proportion_circular <- ggplot(
  area_summary,
  aes(x = 2, y = proportion, fill = Protection_level_all)
) +
  geom_col(
    width = 1,
    color = "white",
    linewidth = 0.2,
    position = position_stack(reverse = TRUE)
  ) +
  geom_text(
    aes(x = 2, label = ifelse(proportion >= 0.01, scales::percent(proportion, accuracy = 0.1), "")),
    position = position_stack(vjust = 0.5, reverse = TRUE),
    size = 1.5,
    color = "black"
  ) +
  xlim(0.5, 2.5) +
  coord_polar(theta = "y") +
  scale_fill_manual(
    values = protection_palette,
    breaks = protection_levels,
    labels = tools::toTitleCase(protection_levels),
    name = "Protection level",
    guide = "none"
  ) +
  labs(title = "Proportion of total MPA surface\nby protection level") +
  theme_void() +
  theme(
    legend.position = "none",
    legend.title = element_text(face = "bold", size = 12),
    legend.text = element_text(size = 10),
    plot.title = element_text(face = "bold", size = 8, hjust = 0.5),
    panel.background = element_rect(fill = "white", colour = NA),
    plot.background = element_rect(fill = "white", colour = NA),
    plot.margin = margin(0, 0, 0, 0, unit = "pt")
  )

# Combine map and circular plot into a multipanel figure.
# Place the circular proportion plot inside the map (middle-right).
p <- p_all +
  patchwork::inset_element(
    p_area_proportion_circular,
    left = 0.705,
    bottom = 0.25,
    right = 1.03,
    top = 0.60,
    align_to = "panel",
    on_top = TRUE,
    clip = FALSE
  )

### ------------------------------------------------------------------------
### 7) Save outputs
### ------------------------------------------------------------------------

#output_bar_png <- "./Figures/Stacked_barplot_Protection_level_surface_proportion.png"
#output_circular_png <- "./Figures/Circular_plot_Protection_level_surface_proportion.png"
output_combined_map_circular_png <- "./Figures/Map_multipanel_Protection_level_all_with_circular_proportion.png"

#ggsave(
#  filename = output_png,
#  plot = p_all,
#  width = 15,
#  height = 6,
#  dpi = 600
#)

#ggsave(
#  filename = output_bar_png,
#  plot = p_area_proportion,
#  width = 7,
#  height = 6,
#  dpi = 600
#)

#ggsave(
#  filename = output_circular_png,
#  plot = p_area_proportion_circular,
#  width = 7,
#  height = 6,
#  dpi = 600
#)

ggsave(
  filename = output_combined_map_circular_png,
  plot = p,
  width = a4_width_in,
  height = a4_height_in,
  units = "in",
  dpi = output_dpi,
  bg = "white"
)
