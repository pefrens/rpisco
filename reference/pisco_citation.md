# Citation Information for PISCOp v3.0

Prints and returns official citation metadata for the PISCOp v3.0
dataset and the associated technical publication by SENAMHI (Gutierrez &
Lavado-Casimiro, 2025).

## Usage

``` r
pisco_citation(format = c("text", "bibtex"))

pisco_cite(format = c("text", "bibtex"))
```

## Arguments

- format:

  Character. Citation format: `"text"` (formatted string for
  papers/reports) or `"bibtex"` (BibTeX entry). Default is `"text"`.

## Value

A character string containing the requested citation (invisibly if
printed).

## Examples

``` r
pisco_citation()
#> Technical Publication:
#>   Gutierrez, L. y Lavado-Casimiro, W. (2025). PISCOp (v3.0): Actualizacion de datos
#>   grillados de precipitacion. Servicio Nacional de Meteorologia e Hidrologia del Peru - SENAMHI.
#>   Libro disponible en: https://hdl.handle.net/20.500.12542/4183 (Deposito Legal N 2025-07014)
#> 
#> Dataset Repository (Figshare):
#>   Gutierrez, L., & Lavado-Casimiro, W. (2025). PISCOp v3.0 [Data set]. Figshare.
#>   https://doi.org/10.6084/m9.figshare.32411886 
pisco_citation("bibtex")
#> @techreport{gutierrez2025piscop,
#>   author      = {Gutierrez, Leonardo and Lavado-Casimiro, Waldo},
#>   title       = {{PISCOp (v3.0): Actualizaci{\'o}n de datos grillados de precipitaci{\'o}n}},
#>   institution = {Servicio Nacional de Meteorolog{\'i}a e Hidrolog{\'i}a del Per{\'u} (SENAMHI)},
#>   year        = {2025},
#>   address     = {Lima, Per{\'u}},
#>   url         = {https://hdl.handle.net/20.500.12542/4183}
#> }
#> 
#> @misc{gutierrez2025piscop_data,
#>   author    = {Gutierrez, Leonardo and Lavado-Casimiro, Waldo},
#>   title     = {{PISCOp v3.0: High-resolution daily and monthly gridded rainfall dataset over Peru}},
#>   year      = {2025},
#>   publisher = {Figshare},
#>   doi       = {10.6084/m9.figshare.32411886}
#> } 
```
