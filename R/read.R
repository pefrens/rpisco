#' Read PISCO NetCDF as SpatRaster
#'
#' @description
#' Reads a PISCO NetCDF file into a [terra::SpatRaster] object. If the file is
#' not present locally, it can be downloaded automatically if `download = TRUE`.
#'
#' @param dataset Character. The dataset to load: `"monthly"` (`"PISCOp_m"`),
#'   `"daily"` (`"PISCOp_d"`), or `"climatology"` (`"PISCOp_clim2"`). Default is `"monthly"`.
#' @param file Character. Optional custom path to a PISCO NetCDF file. If `NULL`,
#'   looks in the local cache or downloads automatically.
#' @param dates Vector of dates, years, year-months, or indices to filter layers.
#'   - For daily/monthly: can be Date objects, character dates (`"1998-01-01"`),
#'     character year-months (`c("1997-01", "1998-12")`), or numeric years (`1998` or `c(1997, 1998)`).
#'   - For climatology (12 months): can be integer month numbers (`1:12`) or month names.
#' @param aoi Optional spatial object (`sf`, `SpatVector`, or bounding box vector)
#'   to crop/mask the raster upon reading. Alias for `mask`.
#' @param mask Optional spatial mask. Same as `aoi`.
#' @param download Logical. If `TRUE` and file is not cached, downloads it automatically.
#'   Default is `TRUE`.
#'
#' @return A [terra::SpatRaster] object with assigned CRS and time attributes.
#' @export
#' @examples
#' \dontrun{
#' # Read monthly precipitation (1981-2025)
#' r <- pisco_read("monthly")
#'
#' # Read specific time period (e.g. El Nino 1997-1998)
#' r_nino <- pisco_read("monthly", dates = c("1997-01-01", "1998-12-31"))
#'
#' # Read with direct spatial clipping to a bounding box
#' r_sub <- pisco_read("monthly", dates = 1998, aoi = c(-77.5, -12.5, -76.0, -11.5))
#'
#' # Read climatological normals 1991-2015
#' r_clim <- pisco_read("climatology")
#' }
pisco_read <- function(dataset = c("monthly", "daily", "climatology"),
                       file = NULL,
                       dates = NULL,
                       aoi = NULL,
                       mask = NULL,
                       download = TRUE) {
  # Consolidate aoi and mask
  if (is.null(mask) && !is.null(aoi)) {
    mask <- aoi
  }
  
  resolved_ds <- if (!is.null(dataset)) .pisco_resolve_dataset(dataset) else "monthly"
  
  if (is.null(file)) {
    info <- .pisco_files[[resolved_ds]]
    cached_path <- file.path(pisco_cache_dir(), info$filename)
    
    if (!file.exists(cached_path)) {
      if (isTRUE(download)) {
        cli::cli_alert_info("Dataset '{resolved_ds}' not found in cache. Starting download...")
        cached_path <- pisco_download(resolved_ds)
      } else {
        cli::cli_abort("File not found in cache: {.file {cached_path}}. Set `download = TRUE` to fetch it.")
      }
    }
    file <- cached_path
  }
  
  if (!file.exists(file)) {
    cli::cli_abort("Specified file does not exist: {.file {file}}")
  }
  
  # Load SpatRaster using terra
  r <- terra::rast(file)
  
  # Ensure CRS is set to EPSG:4326 (WGS84)
  if (is.na(terra::crs(r)) || terra::crs(r) == "") {
    terra::crs(r) <- .pisco_crs
  }
  
  # Assign standard units if available
  info <- .pisco_files[[resolved_ds]]
  if (!is.null(info$unit)) {
    terra::units(r) <- info$unit
  }
  
  # For climatology, if layers lack clear month names, assign 1:12
  if (resolved_ds == "climatology" && terra::nlyr(r) == 12) {
    month_labels <- c("Jan", "Feb", "Mar", "Apr", "May", "Jun", 
                      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
    if (all(grepl("^[0-9]+$", names(r))) || any(is.na(names(r)))) {
      names(r) <- month_labels
    }
  }
  
  # Apply date / layer filtering if requested
  if (!is.null(dates)) {
    r <- .pisco_filter_dates(r, dates, resolved_ds)
  }
  
  # Apply spatial clipping if requested
  if (!is.null(mask)) {
    r <- pisco_clip(r, mask = mask)
  }
  
  r
}

#' Helper to Filter SpatRaster by Dates, Years, or Months
#' @noRd
.pisco_filter_dates <- function(r, dates, dataset_name = "monthly") {
  r_time <- terra::time(r)
  
  # Special case for climatology (12 months without standard calendar dates)
  if (dataset_name == "climatology" || (is.null(r_time) || all(is.na(r_time)))) {
    if (is.numeric(dates)) {
      valid_idx <- dates[dates >= 1 & dates <= terra::nlyr(r)]
      if (length(valid_idx) == 0) {
        cli::cli_abort("Invalid layer/month indices for raster: {.val {dates}}")
      }
      return(r[[valid_idx]])
    }
    if (is.character(dates)) {
      matched <- which(tolower(names(r)) %in% tolower(dates))
      if (length(matched) > 0) {
        return(r[[matched]])
      }
    }
    cli::cli_warn("Raster does not contain valid time attributes. Skipping date filter.")
    return(r)
  }
  
  layer_dates <- as.Date(r_time)
  
  # Numeric years passed, e.g. 1998 or c(1997, 1998)
  if (is.numeric(dates)) {
    if (length(dates) == 1) {
      idx <- which(format(layer_dates, "%Y") == as.character(dates))
    } else {
      min_yr <- min(dates)
      max_yr <- max(dates)
      layer_yrs <- as.integer(format(layer_dates, "%Y"))
      idx <- which(layer_yrs >= min_yr & layer_yrs <= max_yr)
    }
  } else if (inherits(dates, "Date") || inherits(dates, "POSIXt")) {
    dates_d <- as.Date(dates)
    if (length(dates_d) == 1) {
      idx <- which(layer_dates == dates_d)
    } else {
      idx <- which(layer_dates >= min(dates_d) & layer_dates <= max(dates_d))
    }
  } else if (is.character(dates)) {
    # Check if format is "YYYY"
    if (all(grepl("^[0-9]{4}$", dates))) {
      yrs <- as.integer(dates)
      if (length(yrs) == 1) {
        idx <- which(format(layer_dates, "%Y") == dates)
      } else {
        layer_yrs <- as.integer(format(layer_dates, "%Y"))
        idx <- which(layer_yrs >= min(yrs) & layer_yrs <= max(yrs))
      }
    } else if (all(grepl("^[0-9]{4}-[0-9]{2}$", dates))) {
      # Format "YYYY-MM"
      layer_ym <- format(layer_dates, "%Y-%m")
      if (length(dates) == 1) {
        idx <- which(layer_ym == dates)
      } else {
        idx <- which(layer_ym >= min(dates) & layer_ym <= max(dates))
      }
    } else {
      # Try coercing to Date
      parsed <- as.Date(dates)
      if (length(parsed) == 1) {
        idx <- which(layer_dates == parsed)
      } else {
        idx <- which(layer_dates >= min(parsed) & layer_dates <= max(parsed))
      }
    }
  } else {
    cli::cli_abort("Unsupported format for `dates` parameter.")
  }
  
  if (length(idx) == 0) {
    cli::cli_abort("No raster layers found within the requested date/time filter.")
  }
  
  r[[idx]]
}
