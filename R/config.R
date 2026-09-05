# Constants and Dataset Metadata for PISCOp v3.0

.pisco_figshare_article_id <- 32411886L
.pisco_doi <- "10.6084/m9.figshare.32411886.v1"
.pisco_handle <- "https://hdl.handle.net/20.500.12542/4183"
.pisco_crs <- "EPSG:4326"

# Official geographic coverage for Peru and transboundary basins
.pisco_extent <- c(xmin = -82.0, ymin = -19.0, xmax = -64.0, ymax = 2.0)

.pisco_files <- list(
  monthly = list(
    variable = "pr",
    product = "PISCOp_m",
    filename = "PISCOp_m.nc",
    figshare_file_id = 64968111L,
    download_url = "https://ndownloader.figshare.com/files/64968111",
    md5 = "fbf4f19b5d537183a75d08615c404010",
    size_bytes = 56601000L,
    size_mb = 56.6,
    resolution = "0.10 deg (~10 km)",
    timestep = "monthly",
    period = "1981-01 to 2025-12",
    layers = 540L,
    unit = "mm/month",
    description = "Monthly gridded rainfall for Peru and transboundary basins (1981-2025)"
  ),
  daily = list(
    variable = "pr",
    product = "PISCOp_d",
    filename = "PISCOp_d.nc",
    figshare_file_id = 64968183L,
    download_url = "https://ndownloader.figshare.com/files/64968183",
    md5 = "01a7259f4a4fa38158496e3670bb1794",
    size_bytes = 1527191910L,
    size_mb = 1527.2,
    resolution = "0.10 deg (~10 km)",
    timestep = "daily",
    period = "1981-01-01 to 2025-12-31",
    layers = 16436L,
    unit = "mm/day",
    description = "Daily gridded rainfall for Peru and transboundary basins (1981-2025)"
  ),
  climatology = list(
    variable = "pr",
    product = "PISCOp_clim2",
    filename = "PISCOp_clim2.nc",
    figshare_file_id = 64968156L,
    download_url = "https://ndownloader.figshare.com/files/64968156",
    md5 = "655b42e841505182548f57de70fdd57b",
    size_bytes = 1827367L,
    size_mb = 1.83,
    resolution = "0.10 deg (~10 km)",
    timestep = "climatology (12 months)",
    period = "1991-2015 normal",
    layers = 12L,
    unit = "mm/month",
    description = "Monthly normal rainfall climatology 1991-2015 at 0.10 deg"
  )
)

#' Resolve Dataset Aliases
#'
#' @param dataset Character. Name or alias of dataset.
#' @return Canonical dataset key: `"monthly"`, `"daily"`, or `"climatology"`.
#' @noRd
.pisco_resolve_dataset <- function(dataset) {
  if (missing(dataset) || is.null(dataset) || length(dataset) == 0) {
    return("monthly")
  }
  
  key <- tolower(trimws(dataset[1]))
  
  # Strip .nc extension if passed
  key <- sub("\\.nc$", "", key)
  
  if (key %in% c("monthly", "piscop_m", "m", "month", "mensual")) {
    return("monthly")
  }
  if (key %in% c("daily", "piscop_d", "d", "day", "diario")) {
    return("daily")
  }
  if (key %in% c("climatology", "piscop_clim2", "piscop_clim", "clim", "clim2", "climatologia", "normal")) {
    return("climatology")
  }
  
  cli::cli_abort(c(
    "x" = "Unknown PISCO dataset: {.val {dataset}}.",
    "i" = "Valid options are: {.val {'monthly'}} ({.file {'PISCOp_m.nc'}}), {.val {'daily'}} ({.file {'PISCOp_d.nc'}}), or {.val {'climatology'}} ({.file {'PISCOp_clim2.nc'}})."
  ))
}

#' Spatial Coverage Extent of PISCO
#'
#' @description
#' Returns the official geographic bounding coordinates for the PISCOp v3.0 domain,
#' covering Peru and its transboundary hydrologic basins (2 deg N to 19 deg S, 64 deg W to 82 deg W).
#'
#' @param format Character. Output format: `"vector"` (named numeric vector `c(xmin, ymin, xmax, ymax)`),
#'   `"bbox"` (`sf::st_bbox` object), or `"ext"` (`terra::ext` object). Default is `"vector"`.
#'
#' @return A named numeric vector, `sf::st_bbox`, or `terra::ext` representing the domain boundaries.
#' @export
#' @examples
#' pisco_extent()
#' pisco_extent("bbox")
#' pisco_extent("ext")
pisco_extent <- function(format = c("vector", "bbox", "ext")) {
  format <- match.arg(format)
  ext_vec <- .pisco_extent
  
  switch(
    format,
    vector = ext_vec,
    bbox = sf::st_bbox(
      c(xmin = ext_vec[["xmin"]], ymin = ext_vec[["ymin"]],
        xmax = ext_vec[["xmax"]], ymax = ext_vec[["ymax"]]),
      crs = sf::st_crs(.pisco_crs)
    ),
    ext = terra::ext(ext_vec[["xmin"]], ext_vec[["xmax"]], ext_vec[["ymin"]], ext_vec[["ymax"]])
  )
}

#' @rdname pisco_extent
#' @export
pisco_bbox <- function() {
  pisco_extent(format = "bbox")
}
