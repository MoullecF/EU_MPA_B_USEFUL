safe_intersection <- function(x, y, crs_planar = 3035, area_min = 1) {

  # Shared geometry repair chain before overlay operations.
  clean_geometry <- function(obj, target_crs) {
    obj |>
      sf::st_transform(target_crs) |>
      sf::st_make_valid() |>
      sf::st_set_precision(10) |>
      sf::st_buffer(0)
  }

  x_clean <- clean_geometry(x, crs_planar)
  y_clean <- clean_geometry(y, crs_planar)

  # Intersect against a dissolved target to avoid repeated overlaps.
  y_union <- y_clean |>
    sf::st_union() |>
    sf::st_make_valid() |>
    sf::st_buffer(0)

  intersection_result <- try(sf::st_intersection(x_clean, y_union), silent = TRUE)

  if (!inherits(intersection_result, "try-error")) {
    return(
      intersection_result |>
        sf::st_collection_extract("POLYGON") |>
        sf::st_make_valid()
    )
  }

  message("Falling back to polygonize repair")

  boundary_lines <- sf::st_cast(sf::st_geometry(x_clean), "MULTILINESTRING")
  polygonized <- sf::st_polygonize(boundary_lines)
  polygonized_sf <- sf::st_sf(geometry = polygonized, crs = crs_planar)

  polygonized_sf <- polygonized_sf[sf::st_intersects(polygonized_sf, y_union, sparse = FALSE), ]
  polygonized_sf <- polygonized_sf[sf::st_area(polygonized_sf) > units::set_units(area_min, "m^2"), ]

  polygonized_sf
}