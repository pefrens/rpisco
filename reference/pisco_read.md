# Read PISCO NetCDF as SpatRaster

Reads a PISCO NetCDF file into a
[terra::SpatRaster](https://rspatial.github.io/terra/reference/SpatRaster-class.html)
object. If the file is not present locally, it can be downloaded
automatically if `download = TRUE`.

## Usage

``` r
pisco_read(
  dataset = c("monthly", "daily", "climatology"),
  file = NULL,
  dates = NULL,
  aoi = NULL,
  mask = NULL,
  download = TRUE
)
```

## Arguments

- dataset:

  Character. The dataset to load: `"monthly"` (`"PISCOp_m"`), `"daily"`
  (`"PISCOp_d"`), or `"climatology"` (`"PISCOp_clim2"`). Default is
  `"monthly"`.

- file:

  Character. Optional custom path to a PISCO NetCDF file. If `NULL`,
  looks in the local cache or downloads automatically.

- dates:

  Vector of dates, years, year-months, or indices to filter layers.

  - For daily/monthly: can be Date objects, character dates
    (`"1998-01-01"`), character year-months (`c("1997-01", "1998-12")`),
    or numeric years (`1998` or `c(1997, 1998)`).

  - For climatology (12 months): can be integer month numbers (`1:12`)
    or month names.

- aoi:

  Optional spatial object (`sf`, `SpatVector`, or bounding box vector)
  to crop/mask the raster upon reading. Alias for `mask`.

- mask:

  Optional spatial mask. Same as `aoi`.

- download:

  Logical. If `TRUE` and file is not cached, downloads it automatically.
  Default is `TRUE`.

## Value

A
[terra::SpatRaster](https://rspatial.github.io/terra/reference/SpatRaster-class.html)
object with assigned CRS and time attributes.

## Examples

``` r
if (FALSE) { # \dontrun{
# Read monthly precipitation (1981-2025)
r <- pisco_read("monthly")

# Read specific time period (e.g. El Nino 1997-1998)
r_nino <- pisco_read("monthly", dates = c("1997-01-01", "1998-12-31"))

# Read with direct spatial clipping to a bounding box
r_sub <- pisco_read("monthly", dates = 1998, aoi = c(-77.5, -12.5, -76.0, -11.5))

# Read climatological normals 1991-2015
r_clim <- pisco_read("climatology")
} # }
```
