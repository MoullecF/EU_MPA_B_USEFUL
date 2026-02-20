# Marine Protected Area Shapefiles - EU and non-EU MPAs
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.18701898.svg)](https://doi.org/10.5281/zenodo.18701898) [![Data: CC BY 4.0](https://img.shields.io/badge/Data%20License-CC%20BY%204.0-brightgreen.svg)](https://creativecommons.org/licenses/by/4.0/)

R workflow to harmonize and merge multiple MPA datasets, resolve overlapping protection polygons by priority, and generate regional marine-only shapefiles for EU and non-EU waters.

The project combines source data from EU, UK, Iceland, and WDPA-derived layers, then outputs cleaned, de-overlapped MPA polygons for key regions (Mediterranean, Baltic, Black Sea, and NE Atlantic including UK).

Outputs will be used in WP4 of the [B-USEFUL project](https://b-useful.eu/) to assess the spatial match or mismatch between biodiversity hotspots and current marine protection in Europe, and its implications for biodiversity management.

## Purpose ![target](https://img.shields.io/badge/-purpose-37474f?style=flat-square)
- Harmonize heterogeneous MPA attributes into a single schema.
- Merge and validate polygon geometries across source datasets.
- Resolve overlaps by retaining the highest protection level.
- Export marine-only regional shapefiles ready for downstream analyses.

## Methods and Workflow ![workflow](https://img.shields.io/badge/-workflow-00695c?style=flat-square)
1. **Download published data bundle** from Zenodo ([0_Download_Inputs_Outputs_from_Zenodo.R](0_Download_Inputs_Outputs_from_Zenodo.R)).
2. **Merge and standardize source MPAs** (EU, UK, Iceland, Albania, Greenland) into one layer ([1_Merge_MPA_shapefiles.R](1_Merge_MPA_shapefiles.R)).
3. **Intersect, de-overlap, and marine-clip by protection priority** using robust geometry rebuild, masking, and the safe intersection helper sourced within [2_Intersect_MPA_polygons.r](2_Intersect_MPA_polygons.r) (helper: [safe_intersection.r](safe_intersection.r)).
4. **Export shapefile + zip archive** for the selected region (configured in `export_name` inside script 2).
5. **Generate figure outputs** (map + circular proportion panel) with [3_Multipanel_map_Protection_level_surface.R](3_Multipanel_map_Protection_level_surface.R).

**Note:** If you download `Outputs.zip` from Zenodo, you can run script 3 directly to generate figures. In that case, scripts 1 and 2 do not need to be run.

## Inputs and Data ![data](https://img.shields.io/badge/-data-283593?style=flat-square)
- **Zenodo record**: [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.18701898.svg)](https://doi.org/10.5281/zenodo.18701898)
- **Published archives**:
  - `Inputs.zip`
  - `Outputs.zip`
- **Main input folder**: [Inputs/](Inputs/)
  - EU source data (Aminian-Biquet et al. 2024), DOI: [10.1016/j.dib.2024.111177](https://doi.org/10.1016/j.dib.2024.111177)
  - UK source data (Figshare package), DOI: [10.6084/m9.figshare.29901479](https://doi.org/10.6084/m9.figshare.29901479)
  - Iceland revised protection layer
  - WDPA-based Albania and Greenland layers. UNEP-WCMC and IUCN (2025), *Protected Planet: The World Database on Protected Areas (WDPA) [On-line]*, December 2025, Cambridge, UK: UNEP-WCMC and IUCN. Available at: [www.protectedplanet.net](https://www.protectedplanet.net)
  - IHO world seas polygons used for marine clipping. Flanders Marine Institute (2018). *IHO Sea Areas, version 3*. Available online at [marineregions.org](https://www.marineregions.org/). DOI: [10.14284/323](https://doi.org/10.14284/323)

## Outputs ![outputs](https://img.shields.io/badge/-outputs-5d4037?style=flat-square)
- Intermediate merged object: `Outputs/shp_mpa_europe_all.rda`
- Regional final outputs (shapefile directories and optional `.zip` exports), e.g.:
  - `Outputs/shp_mpa_med_sea`
  - `Outputs/shp_mpa_black_sea`
  - `Outputs/shp_mpa_baltic_sea`
  - `Outputs/shp_mpa_NE_Atlantic_incl_UK`

## Figures ![figures](https://img.shields.io/badge/-figures-8e24aa?style=flat-square)
- Figure outputs are saved in a separate `Figures/` folder, including:
  - `Figures/Map_multipanel_Protection_level_all_with_circular_proportion.png`

## Installation and Environment ![setup](https://img.shields.io/badge/-setup-546e7a?style=flat-square)
- **R version**: 4.2.2
- **Core packages**: `sf`, `dplyr`, `lwgeom`, `readxl`, `zenodor`, `ggplot2`, `patchwork`, `rnaturalearth`
- **Zenodo helper package**: [0_Download_Inputs_Outputs_from_Zenodo.R](0_Download_Inputs_Outputs_from_Zenodo.R) auto-installs `zenodor` from GitHub (`FRBCesab/zenodor`) if missing.

## Basic Usage ![run](https://img.shields.io/badge/-run-1b5e20?style=flat-square)
1. Download or refresh `Inputs/` and `Outputs/` from Zenodo:
   ```r
   source("0_Download_Inputs_Outputs_from_Zenodo.R")
   ```
2. Build harmonized all-Europe MPA object:
   ```r
   source("1_Merge_MPA_shapefiles.R")
   ```
3. Generate one regional de-overlapped output (configure region + `export_name` in script):
   ```r
   source("2_Intersect_MPA_polygons.r")
   ```
4. Generate the combined map + circular proportion figure:
   ```r
  source("3_Multipanel_map_Protection_level_surface.R")
  ```

If `Outputs/` comes from the Zenodo archive and already contains the required regional shapefiles, you can skip steps 2 and 3 and run only step 4 for figure generation.

## Repository Structure ![folders](https://img.shields.io/badge/-folders-3949ab?style=flat-square)
- [0_Download_Inputs_Outputs_from_Zenodo.R](0_Download_Inputs_Outputs_from_Zenodo.R): Download/unzip `Inputs.zip` and `Outputs.zip` from Zenodo.
- [1_Merge_MPA_shapefiles.R](1_Merge_MPA_shapefiles.R): Standardize and merge source MPA datasets.
- [2_Intersect_MPA_polygons.r](2_Intersect_MPA_polygons.r): Priority-based de-overlap, marine clipping, and export.
- [3_Multipanel_map_Protection_level_surface.R](3_Multipanel_map_Protection_level_surface.R): Generates the Europe map and combined map + circular protection-surface proportion figure.
- [safe_intersection.r](safe_intersection.r): Safe geometry intersection utility with repair fallback, called from script 2.
- [Inputs/](Inputs/): Source spatial data (typically git-ignored in local workflows).
- [Outputs/](Outputs/): Generated products and exported shapefiles.
- [Figures/](Figures/): Saved plot outputs (maps and summary figures from script 3).

## Citation ![cite](https://img.shields.io/badge/-cite-4e342e?style=flat-square)
If you use this code or dataset, please cite:
- **Dataset**: Moullec, F. (2026). *Marine Protected Area Shapefiles - EU and non-EU MPAs* (Version V1.0.0) [Data set]. Zenodo. [https://doi.org/10.5281/zenodo.18701898](https://doi.org/10.5281/zenodo.18701898)
- **Code**: This GitHub repository (MoullecF/EU_MPA_B_USEFUL).
- **B-USEFUL Deliverable 4.3**: ADD WEB LINK of the report.

## License ![license](https://img.shields.io/badge/-license-263238?style=flat-square)
- **Data license**: Creative Commons Attribution 4.0 International (CC BY 4.0), as provided on Zenodo.
