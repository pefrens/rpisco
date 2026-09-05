# Download PISCO Datasets

Downloads a PISCO dataset from the official Figshare repository to the
local cache directory. If the file is already cached and complete,
download is skipped unless `overwrite = TRUE`.

## Usage

``` r
pisco_download(
  dataset = c("monthly", "daily", "climatology"),
  destdir = pisco_cache_dir(),
  overwrite = FALSE,
  verify_md5 = TRUE,
  timeout = 3600,
  quiet = FALSE
)
```

## Arguments

- dataset:

  Character. The dataset to download: `"monthly"` (`"PISCOp_m"`),
  `"daily"` (`"PISCOp_d"`), or `"climatology"` (`"PISCOp_clim2"`).
  Default is `"monthly"`.

- destdir:

  Character. Destination directory. Default is
  [`pisco_cache_dir()`](https://pefrens.github.io/rpisco/reference/pisco_cache_dir.md).

- overwrite:

  Logical. If `TRUE`, re-downloads the file even if present in cache.

- verify_md5:

  Logical. If `TRUE`, validates the MD5 checksum after download. Default
  is `TRUE`.

- timeout:

  Numeric. Maximum seconds to allow for download. Default is 3600 (1
  hour), accommodating large files like `PISCOp_d.nc` (~1.52 GB).

- quiet:

  Logical. If `TRUE`, suppresses progress messages. Default is `FALSE`.

## Value

Character. The absolute path to the downloaded (or cached) file.

## Examples

``` r
if (FALSE) { # \dontrun{
# Download monthly precipitation (56.6 MB)
fpath <- pisco_download("monthly")

# Download normal climatology 1991-2015 (1.83 MB)
fpath_clim <- pisco_download("climatology")
} # }
```
