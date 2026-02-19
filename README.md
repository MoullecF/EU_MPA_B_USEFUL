# Marine Protected Area Shapefiles - EU and non-EU MPAs
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.18701898.svg)](https://doi.org/10.5281/zenodo.18701898) [![Data: CC BY 4.0](https://img.shields.io/badge/Data%20License-CC%20BY%204.0-brightgreen.svg)](https://creativecommons.org/licenses/by/4.0/)

R workflow to harmonize and merge multiple MPA datasets, resolve overlapping protection polygons by priority, and generate regional marine-only shapefiles for EU and non-EU waters.

The project combines source data from EU, UK, Iceland, and WDPA-derived layers, then outputs cleaned, de-overlapped MPA polygons for key regions (Mediterranean, Baltic, Black Sea, and NE Atlantic including UK).

## Purpose ![target](https://img.shields.io/badge/-purpose-37474f?style=flat-square)
- Harmonize heterogeneous MPA attributes into a single schema.
- Merge and validate polygon geometries across source datasets.
- Resolve overlaps by retaining the highest protection level.
- Export marine-only regional shapefiles ready for downstream analyses.

## Methods and Workflow ![workflow](https://img.shields.io/badge/-workflow-00695c?style=flat-square)
1. **Download published data bundle** from Zenodo ([0_Download_Inputs_Outputs_from_Zenodo.R](0_Download_Inputs_Outputs_from_Zenodo.R)).
2. **Merge and standardize source MPAs** (EU, UK, Iceland, Albania, Greenland) into one layer ([1_Merge_MPA_shapefiles.R](1_Merge_MPA_shapefiles.R)).
3. **Intersect, de-overlap, and marine-clip by protection priority** using robust geometry rebuild, masking, and the safe intersection helper sourced within [2_Intersect_MPA_polygons.r](2_Intersect_MPA_polygons.r) (helper: [safe_intersection.r](safe_intersection.r)).
5. **Export shapefile + zip archive** for the selected region (configured in `export_name` inside script 2).

## Inputs and Data ![data](https://img.shields.io/badge/-data-283593?style=flat-square)
- **Zenodo record**: [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.18701898.svg)](https://doi.org/10.5281/zenodo.18701898)
- **Published archives**:
  - `Inputs.zip`
  - `Outputs.zip`
- **Main input folder**: [Inputs/](Inputs/)
  - EU source data (Aminian-Biquet et al. 2024)
  - UK source data (Figshare package)
  - Iceland revised protection layer
  - WDPA-based Albania and Greenland layers
  - IHO world seas polygons used for marine clipping

## Outputs ![outputs](https://img.shields.io/badge/-outputs-5d4037?style=flat-square)
- Intermediate merged object: `Outputs/shp_mpa_europe_all.rda`
- Regional final outputs (shapefile directories and optional `.zip` exports), e.g.:
  - `Outputs/shp_mpa_med_sea`
  - `Outputs/shp_mpa_black_sea`
  - `Outputs/shp_mpa_baltic_sea`
  - `Outputs/shp_mpa_NE_Atlantic_incl_UK`

## Installation and Environment ![setup](https://img.shields.io/badge/-setup-546e7a?style=flat-square)
- **R version**: 4.2.2
- **Core packages**: `sf`, `dplyr`, `lwgeom`, `readxl`, `zenodor`
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

## Repository Structure ![folders](https://img.shields.io/badge/-folders-3949ab?style=flat-square)
- [0_Download_Inputs_Outputs_from_Zenodo.R](0_Download_Inputs_Outputs_from_Zenodo.R): Download/unzip `Inputs.zip` and `Outputs.zip` from Zenodo.
- [1_Merge_MPA_shapefiles.R](1_Merge_MPA_shapefiles.R): Standardize and merge source MPA datasets.
- [2_Intersect_MPA_polygons.r](2_Intersect_MPA_polygons.r): Priority-based de-overlap, marine clipping, and export (sources `safe_intersection.r`).
- [safe_intersection.r](safe_intersection.r): Safe geometry intersection utility with repair fallback, called from script 2.
- [Inputs/](Inputs/): Source spatial data (typically git-ignored in local workflows).
- [Outputs/](Outputs/): Generated products and exported shapefiles.

## Citation ![cite](https://img.shields.io/badge/-cite-4e342e?style=flat-square)
If you use this code or dataset, please cite:
- **Dataset**: Moullec, F. (2026). *Marine Protected Area Shapefiles - EU and non-EU MPAs* (Version V1.0.0) [Data set]. Zenodo. [https://doi.org/10.5281/zenodo.18701898](https://doi.org/10.5281/zenodo.18701898)
- **Code**: This GitHub repository (MoullecF/EU_MPA_B_USEFUL).

## License ![license](https://img.shields.io/badge/-license-263238?style=flat-square)
- **Data license**: Creative Commons Attribution 4.0 International (CC BY 4.0), as provided on Zenodo.
- **Code license**: no repository-level code license file is currently present. Add a `LICENSE` file if you want to define explicit code reuse terms.
