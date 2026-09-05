# Catalog of PISCO Products

Lists the available PISCO datasets, metadata, temporal ranges,
resolution, official file names, and current local cache status.

## Usage

``` r
pisco_catalog()
```

## Value

A [tibble::tibble](https://tibble.tidyverse.org/reference/tibble.html)
containing metadata for all available datasets.

## Examples

``` r
pisco_catalog()
#> # A tibble: 3 × 12
#>   dataset     variable product  filename timestep period layers resolution unit 
#>   <chr>       <chr>    <chr>    <chr>    <chr>    <chr>   <int> <chr>      <chr>
#> 1 monthly     pr       PISCOp_m PISCOp_… monthly  1981-…    540 0.10 deg … mm/m…
#> 2 daily       pr       PISCOp_d PISCOp_… daily    1981-…  16436 0.10 deg … mm/d…
#> 3 climatology pr       PISCOp_… PISCOp_… climato… 1991-…     12 0.10 deg … mm/m…
#> # ℹ 3 more variables: size_mb <dbl>, cached <lgl>, download_url <chr>
```
