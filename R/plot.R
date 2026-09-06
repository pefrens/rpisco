#' Plot SpatRaster and SpatVector Objects
#'
#' @description
#' S3 plot methods for [terra::SpatRaster] and [terra::SpatVector] objects,
#' ensuring that `plot(r)` works seamlessly when `rpisco` is loaded, even if
#' `library(terra)` has not been explicitly attached.
#'
#' @param x A `terra::SpatRaster` or `terra::SpatVector` object.
#' @param y Optional second argument for bivariate plotting in terra.
#' @param ... Additional graphical parameters forwarded to [terra::plot()].
#'
#' @return Invisibly returns the plotted object or `NULL`, creating a plot on the active device.
#' @export
plot.SpatRaster <- function(x, y, ...) {
  if (missing(y)) {
    terra::plot(x, ...)
  } else {
    terra::plot(x, y, ...)
  }
}

#' @rdname plot.SpatRaster
#' @export
plot.SpatVector <- function(x, y, ...) {
  if (missing(y)) {
    terra::plot(x, ...)
  } else {
    terra::plot(x, y, ...)
  }
}
