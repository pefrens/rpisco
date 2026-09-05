#' Spatial Cropping and Masking for PISCO Rasters
#'
#' @description
#' Crops and masks a PISCO [terra::SpatRaster] using a vector polygon (`sf` or `SpatVector`),
#' an `sf::st_bbox` object, or a spatial bounding box numeric vector.
#'
#' @param x A [terra::SpatRaster] object.
#' @param mask An `sf` object, `terra::SpatVector`, `sf::st_bbox`, `terra::SpatExtent`,
#'   or numeric bounding box (`c(xmin, ymin, xmax, ymax)`).
#' @param crop_only Logical. If `TRUE`, only crops to bounding box without masking values outside polygon.
#'   Default is `FALSE`.
#'
#' @return A cropped (and optionally masked) [terra::SpatRaster].
#' @export
#' @examples
#' \dontrun{
#' r <- pisco_read("monthly")
#' # Crop by bounding box (e.g. Lima / Rimac basin)
#' r_sub <- pisco_clip(r, mask = c(-77.5, -12.5, -76.0, -11.5))
#'
#' # Crop and mask using an sf polygon
#' # r_basin <- pisco_clip(r, mask = basin_sf)
#' }
pisco_clip <- function(x, mask, crop_only = FALSE) {
  if (!inherits(x, "SpatRaster")) {
    cli::cli_abort("Argument `x` must be a `terra::SpatRaster`.")
  }
  
  ext_x <- terra::ext(x)
  
  # Helper to check extent overlap
  .check_overlap <- function(em) {
    if (em$xmax < ext_x$xmin || em$xmin > ext_x$xmax ||
        em$ymax < ext_x$ymin || em$ymin > ext_x$ymax) {
      cli::cli_abort("The clipping mask does not intersect the spatial extent of the raster.")
    }
  }
  
  # 1. Handle SpatExtent directly
  if (inherits(mask, "SpatExtent")) {
    .check_overlap(mask)
    return(terra::crop(x, mask))
  }
  
  # 2. Handle bbox from sf
  if (inherits(mask, "bbox")) {
    ext <- terra::ext(mask[["xmin"]], mask[["xmax"]], mask[["ymin"]], mask[["ymax"]])
    .check_overlap(ext)
    return(terra::crop(x, ext))
  }
  
  # 3. Handle numeric bounding box
  if (is.numeric(mask) && length(mask) == 4) {
    nms <- names(mask)
    if (!is.null(nms) && all(c("xmin", "ymin", "xmax", "ymax") %in% nms)) {
      ext <- terra::ext(mask[["xmin"]], mask[["xmax"]], mask[["ymin"]], mask[["ymax"]])
    } else {
      # Assume c(xmin, ymin, xmax, ymax)
      ext <- terra::ext(mask[1], mask[3], mask[2], mask[4])
    }
    .check_overlap(ext)
    return(terra::crop(x, ext))
  }
  
  # 4. Convert sf to SpatVector if needed
  if (inherits(mask, "sf") || inherits(mask, "sfc")) {
    mask <- terra::vect(mask)
  }
  
  if (!inherits(mask, "SpatVector")) {
    cli::cli_abort("Argument `mask` must be an `sf` object, `SpatVector`, `bbox`, `SpatExtent`, or numeric vector of length 4.")
  }
  
  # Ensure same CRS
  if (!is.na(terra::crs(mask)) && terra::crs(mask) != "" && terra::crs(mask) != terra::crs(x)) {
    mask <- terra::project(mask, terra::crs(x))
  }
  
  ext_m <- terra::ext(mask)
  .check_overlap(ext_m)
  
  x_cropped <- terra::crop(x, mask)
  if (isTRUE(crop_only)) {
    return(x_cropped)
  }
  
  terra::mask(x_cropped, mask)
}
