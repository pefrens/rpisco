#' Statistical Validation Metrics for PISCO
#'
#' @description
#' Implements the statistical evaluation metrics used in the official PISCOp v3.0
#' validation report (Gutierrez & Lavado-Casimiro, 2025; Willmott et al., 2012):
#' - Pearson correlation coefficient (COR)
#' - Refined Index of Agreement (\eqn{d_r}) (Willmott et al., 2012)
#' - Normalized Mean Bias (NMB, \%)
#' - Normalized Mean Gross Error (NMGE)
#' - Root Mean Squared Error (RMSE)
#' - Mean Absolute Error (MAE)
#'
#' @param sim Numeric vector of simulated or gridded values (e.g. PISCO).
#' @param obs Numeric vector of observed values (e.g. rain gauge stations).
#' @param na.rm Logical. If `TRUE`, pairs with missing values (`NA`) are removed. Default is `TRUE`.
#'
#' @name pisco_metrics
#' @examples
#' obs <- c(12.5, 34.2, 0.0, 5.4, 60.1, 105.3)
#' sim <- c(10.1, 31.0, 0.2, 7.8, 55.0, 98.4)
#'
#' pisco_metrics(sim, obs)
#' pisco_metric_dr(sim, obs)
#' pisco_metric_nmb(sim, obs)
#' pisco_metric_nmge(sim, obs)
NULL

#' @rdname pisco_metrics
#' @export
pisco_metric_cor <- function(sim, obs, na.rm = TRUE) {
  idx <- if (na.rm) !is.na(sim) & !is.na(obs) else seq_along(sim)
  s <- sim[idx]
  o <- obs[idx]
  if (length(s) < 3 || stats::sd(s) == 0 || stats::sd(o) == 0) return(NA_real_)
  stats::cor(s, o, method = "pearson")
}

#' @rdname pisco_metrics
#' @export
pisco_metric_dr <- function(sim, obs, na.rm = TRUE) {
  idx <- if (na.rm) !is.na(sim) & !is.na(obs) else seq_along(sim)
  s <- sim[idx]
  o <- obs[idx]
  n <- length(s)
  if (n < 2) return(NA_real_)
  
  # Refined Index of Agreement (Willmott et al., 2012)
  # dr ranges between -1 and 1, where > 0.5 indicates strong agreement
  o_bar <- mean(o)
  mae_err <- sum(abs(s - o))
  c_val <- 2 * sum(abs(o - o_bar))
  
  if (c_val == 0) return(NA_real_)
  
  if (mae_err <= c_val) {
    1 - (mae_err / c_val)
  } else {
    (c_val / mae_err) - 1
  }
}

#' @rdname pisco_metrics
#' @export
pisco_metric_nmb <- function(sim, obs, na.rm = TRUE) {
  idx <- if (na.rm) !is.na(sim) & !is.na(obs) else seq_along(sim)
  s <- sim[idx]
  o <- obs[idx]
  sum_o <- sum(o)
  if (length(s) == 0 || sum_o == 0) return(NA_real_)
  100 * (sum(s - o) / sum_o)
}

#' @rdname pisco_metrics
#' @export
pisco_metric_nmge <- function(sim, obs, na.rm = TRUE) {
  idx <- if (na.rm) !is.na(sim) & !is.na(obs) else seq_along(sim)
  s <- sim[idx]
  o <- obs[idx]
  sum_o <- sum(o)
  if (length(s) == 0 || sum_o == 0) return(NA_real_)
  sum(abs(s - o)) / sum_o
}

#' @rdname pisco_metrics
#' @return `pisco_metrics()` returns a [tibble::tibble] containing all validation metrics.
#' @export
pisco_metrics <- function(sim, obs, na.rm = TRUE) {
  idx <- if (na.rm) !is.na(sim) & !is.na(obs) else seq_along(sim)
  s <- sim[idx]
  o <- obs[idx]
  n <- length(s)
  
  if (n == 0) {
    return(tibble::tibble(
      n = 0L,
      cor = NA_real_,
      dr = NA_real_,
      nmb = NA_real_,
      nmge = NA_real_,
      rmse = NA_real_,
      mae = NA_real_,
      bias = NA_real_
    ))
  }
  
  rmse_val <- sqrt(mean((s - o)^2))
  mae_val <- mean(abs(s - o))
  bias_val <- mean(s - o)
  
  tibble::tibble(
    n = n,
    cor = pisco_metric_cor(s, o, na.rm = FALSE),
    dr = pisco_metric_dr(s, o, na.rm = FALSE),
    nmb = pisco_metric_nmb(s, o, na.rm = FALSE),
    nmge = pisco_metric_nmge(s, o, na.rm = FALSE),
    rmse = rmse_val,
    mae = mae_val,
    bias = bias_val
  )
}
