#' Catalog of PISCO Products
#'
#' @description
#' Lists the available PISCO datasets, metadata, temporal ranges,
#' resolution, official file names, and current local cache status.
#'
#' @return A [tibble::tibble] containing metadata for all available datasets.
#' @export
#' @examples
#' pisco_catalog()
pisco_catalog <- function() {
  cache <- pisco_cache_dir()
  
  rows <- lapply(names(.pisco_files), function(key) {
    item <- .pisco_files[[key]]
    fpath <- file.path(cache, item$filename)
    cached <- file.exists(fpath)
    
    tibble::tibble(
      dataset = key,
      variable = item$variable,
      product = item$product,
      filename = item$filename,
      timestep = item$timestep,
      period = item$period,
      layers = item$layers,
      resolution = item$resolution,
      unit = item$unit,
      size_mb = item$size_mb,
      cached = cached,
      download_url = item$download_url
    )
  })
  
  do.call(rbind, rows)
}

#' Citation Information for PISCOp v3.0
#'
#' @description
#' Prints and returns official citation metadata for the PISCOp v3.0 dataset
#' and the associated technical publication by SENAMHI (Gutierrez & Lavado-Casimiro, 2025).
#'
#' @param format Character. Citation format: `"text"` (formatted string for papers/reports)
#'   or `"bibtex"` (BibTeX entry). Default is `"text"`.
#'
#' @return A character string containing the requested citation (invisibly if printed).
#' @export
#' @examples
#' pisco_citation()
#' pisco_citation("bibtex")
pisco_citation <- function(format = c("text", "bibtex")) {
  format <- match.arg(format)
  
  if (format == "text") {
    cit_text <- paste(
      "Technical Publication:",
      "  Gutierrez, L. y Lavado-Casimiro, W. (2025). PISCOp (v3.0): Actualizacion de datos",
      "  grillados de precipitacion. Servicio Nacional de Meteorologia e Hidrologia del Peru - SENAMHI.",
      "  Libro disponible en: https://hdl.handle.net/20.500.12542/4183 (Deposito Legal N 2025-07014)",
      "",
      "Dataset Repository (Figshare):",
      "  Gutierrez, L., & Lavado-Casimiro, W. (2025). PISCOp v3.0 [Data set]. Figshare.",
      "  https://doi.org/10.6084/m9.figshare.32411886",
      sep = "\n"
    )
    cat(cit_text, "\n")
    return(invisible(cit_text))
  }
  
  if (format == "bibtex") {
    bib_text <- paste(
      "@techreport{gutierrez2025piscop,",
      "  author      = {Gutierrez, Leonardo and Lavado-Casimiro, Waldo},",
      "  title       = {{PISCOp (v3.0): Actualizaci{\\'o}n de datos grillados de precipitaci{\\'o}n}},",
      "  institution = {Servicio Nacional de Meteorolog{\\'i}a e Hidrolog{\\'i}a del Per{\\'u} (SENAMHI)},",
      "  year        = {2025},",
      "  address     = {Lima, Per{\\'u}},",
      "  url         = {https://hdl.handle.net/20.500.12542/4183}",
      "}",
      "",
      "@misc{gutierrez2025piscop_data,",
      "  author    = {Gutierrez, Leonardo and Lavado-Casimiro, Waldo},",
      "  title     = {{PISCOp v3.0: High-resolution daily and monthly gridded rainfall dataset over Peru}},",
      "  year      = {2025},",
      "  publisher = {Figshare},",
      "  doi       = {10.6084/m9.figshare.32411886}",
      "}",
      sep = "\n"
    )
    cat(bib_text, "\n")
    return(invisible(bib_text))
  }
}

#' @rdname pisco_citation
#' @export
pisco_cite <- function(format = c("text", "bibtex")) {
  pisco_citation(format = format)
}
