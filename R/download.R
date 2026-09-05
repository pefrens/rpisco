#' Download PISCO Datasets
#'
#' @description
#' Downloads a PISCO dataset from the official Figshare repository to the local
#' cache directory. If the file is already cached and complete, download is skipped
#' unless `overwrite = TRUE`.
#'
#' @param dataset Character. The dataset to download: `"monthly"` (`"PISCOp_m"`),
#'   `"daily"` (`"PISCOp_d"`), or `"climatology"` (`"PISCOp_clim2"`). Default is `"monthly"`.
#' @param destdir Character. Destination directory. Default is [pisco_cache_dir()].
#' @param overwrite Logical. If `TRUE`, re-downloads the file even if present in cache.
#' @param verify_md5 Logical. If `TRUE`, validates the MD5 checksum after download. Default is `TRUE`.
#' @param timeout Numeric. Maximum seconds to allow for download. Default is 3600 (1 hour),
#'   accommodating large files like `PISCOp_d.nc` (~1.52 GB).
#' @param quiet Logical. If `TRUE`, suppresses progress messages. Default is `FALSE`.
#'
#' @return Character. The absolute path to the downloaded (or cached) file.
#' @export
#' @examples
#' \dontrun{
#' # Download monthly precipitation (56.6 MB)
#' fpath <- pisco_download("monthly")
#'
#' # Download normal climatology 1991-2015 (1.83 MB)
#' fpath_clim <- pisco_download("climatology")
#' }
pisco_download <- function(dataset = c("monthly", "daily", "climatology"),
                           destdir = pisco_cache_dir(),
                           overwrite = FALSE,
                           verify_md5 = TRUE,
                           timeout = 3600,
                           quiet = FALSE) {
  dataset <- .pisco_resolve_dataset(dataset)
  info <- .pisco_files[[dataset]]
  
  if (!dir.exists(destdir)) {
    dir.create(destdir, recursive = TRUE, showWarnings = FALSE)
  }
  
  target_file <- file.path(destdir, info$filename)
  
  if (file.exists(target_file) && !overwrite) {
    if (!quiet) {
      cli::cli_alert_info("Found cached file: {.file {target_file}} ({round(file.size(target_file)/(1024^2), 2)} MB). Skipping download.")
    }
    return(normalizePath(target_file, winslash = "/"))
  }
  
  if (!quiet) {
    cli::cli_h2("Downloading PISCO dataset: {dataset} ({info$product})")
    cli::cli_alert_info("File: {.val {info$filename}} | Size: ~{info$size_mb} MB")
    cli::cli_alert_info("Period: {.val {info$period}} | Resolution: {.val {info$resolution}}")
    cli::cli_alert_info("Source: Figshare repository (DOI: {.val {.pisco_doi}})")
  }
  
  # Configure request with timeout and automatic retry
  req <- httr2::request(info$download_url)
  req <- httr2::req_timeout(req, timeout)
  req <- httr2::req_retry(req, max_tries = 3, backoff = ~ 2)
  if (!quiet) {
    req <- httr2::req_progress(req)
  }
  
  temp_download <- tempfile(pattern = "pisco_dl_", fileext = ".tmp")
  on.exit(if (file.exists(temp_download)) unlink(temp_download), add = TRUE)
  
  resp <- tryCatch(
    httr2::req_perform(req, path = temp_download),
    error = function(e) {
      cli::cli_abort(c(
        "x" = "Failed to download {.val {info$filename}} from Figshare.",
        "i" = "URL: {.url {info$download_url}}",
        "i" = "Details: {e$message}"
      ))
    }
  )
  
  # Verify MD5 checksum if requested
  if (isTRUE(verify_md5)) {
    computed_hash <- tools::md5sum(temp_download)[[1]]
    if (!is.na(info$md5) && computed_hash != info$md5) {
      cli::cli_abort(c(
        "x" = "MD5 checksum verification failed for {info$filename}.",
        "i" = "Expected: {info$md5}",
        "i" = "Received: {computed_hash}"
      ))
    }
    if (!quiet) {
      cli::cli_alert_success("MD5 checksum verified successfully: {.val {computed_hash}}")
    }
  }
  
  # Move to destination
  file.copy(temp_download, target_file, overwrite = TRUE)
  
  if (!quiet) {
    cli::cli_alert_success("Dataset saved successfully to: {.file {target_file}}")
  }
  
  normalizePath(target_file, winslash = "/")
}
