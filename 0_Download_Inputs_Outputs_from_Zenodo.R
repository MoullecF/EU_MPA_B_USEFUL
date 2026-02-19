### ------------------------------------------------------------------------
### Script: Download Inputs and Outputs from Zenodo
### ------------------------------------------------------------------------

# ---- Package setup ----
required_package <- "zenodor"
if (!requireNamespace(required_package, quietly = TRUE)) {
  # Install from GitHub when zenodor is not already available locally
  if (!requireNamespace("remotes", quietly = TRUE)) {
    install.packages("remotes")
  }
  remotes::install_github("FRBCesab/zenodor", force = TRUE)
}

library(zenodor)

# ---- Configuration ----
record_id <- "18701898"
zip_files <- c("Inputs.zip", "Outputs.zip")
project_root <- "."
download_dir <- project_root

# Set to TRUE to replace existing local Inputs/Outputs folders.
overwrite_existing <- FALSE

# ---- Helpers ----

# Extract only files that are not already present locally.
extract_missing_from_zip <- function(zip_path, exdir) {
  zip_index <- utils::unzip(zipfile = zip_path, list = TRUE)
  archived_entries <- zip_index$Name
  archived_files <- archived_entries[!grepl("/$", archived_entries)]

  missing_files <- archived_files[
    !file.exists(file.path(exdir, archived_files))
  ]

  if (length(missing_files) == 0) {
    message("All files already present for archive: ", basename(zip_path))
    return(invisible(NULL))
  }

  message("Extracting ", length(missing_files), " missing file(s) from ", basename(zip_path), " ...")
  utils::unzip(zipfile = zip_path, files = missing_files, exdir = exdir)
}

# ---- Download and extract ----
if (!"zen_download_files" %in% getNamespaceExports("zenodor")) {
  stop("zenodor::zen_download_files is not available. Please update zenodor.")
}

for (zip_file in zip_files) {
  zip_path <- file.path(download_dir, zip_file)
  target_dir <- file.path(project_root, tools::file_path_sans_ext(zip_file))

  if (file.exists(zip_path)) {
    message("Archive already present: ", zip_path)
  } else {
    message("Downloading ", zip_file, " from Zenodo record ", record_id, " ...")
    zenodor::zen_download_files(
      record_id = record_id,
      files = zip_file,
      path = download_dir,
      progress = TRUE
    )
  }

  if (!file.exists(zip_path)) {
    warning("Download attempted but archive is missing: ", zip_path)
    next
  }

  if (dir.exists(target_dir) && overwrite_existing) {
    unlink(target_dir, recursive = TRUE, force = TRUE)
  }

  if (overwrite_existing) {
    message("Extracting full archive ", zip_file, " to ", project_root, " ...")
    utils::unzip(zipfile = zip_path, exdir = project_root)
  } else {
    # Zenodo provides two archive files for this record; this avoids re-extracting
    # files that already exist locally.
    extract_missing_from_zip(zip_path = zip_path, exdir = project_root)
  }

  if (dir.exists(target_dir)) {
    message("Ready: ", target_dir)
  } else {
    warning("Extraction completed but target folder was not found: ", target_dir)
  }
}
