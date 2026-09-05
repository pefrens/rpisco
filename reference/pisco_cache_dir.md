# PISCO Cache Management

Functions to inspect, set, and clear the local cache directory used by
`rpisco` to store downloaded NetCDF files.

## Usage

``` r
pisco_cache_dir(path = NULL)

pisco_cache_status()

pisco_cache_clear(dataset = "all")
```

## Arguments

- path:

  Character. Custom path to set as cache. If `NULL`, returns current
  cache.

- dataset:

  Character. Dataset name (`"monthly"`, `"daily"`, `"climatology"`), or
  `"all"` to remove all cached files.

## Value

A character path to the cache directory, or logical status invisibly.

## Examples

``` r
pisco_cache_dir()
#> [1] "/home/runner/.cache/R/rpisco"
pisco_cache_status()
#> # A tibble: 3 × 6
#>   dataset     filename        cached expected_mb cached_mb path 
#>   <chr>       <chr>           <lgl>        <dbl>     <dbl> <chr>
#> 1 monthly     PISCOp_m.nc     FALSE        56.6          0 NA   
#> 2 daily       PISCOp_d.nc     FALSE      1527.           0 NA   
#> 3 climatology PISCOp_clim2.nc FALSE         1.83         0 NA   
```
