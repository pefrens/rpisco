test_that("pisco_aggregate performs annual, monthly, and SENAMHI seasonal aggregations", {
  r <- terra::rast(xmin = -82, xmax = -64, ymin = -19, ymax = 2,
                   resolution = 1, crs = "EPSG:4326", nlyrs = 24)
  # 2 years of constant 10 mm/month
  terra::values(r) <- 10
  dts <- seq(as.Date("1998-01-01"), by = "month", length.out = 24)
  terra::time(r) <- dts
  
  # Year sum: 12 months * 10 = 120 mm
  r_yr <- pisco_aggregate(r, by = "year", fun = "sum")
  expect_equal(terra::nlyr(r_yr), 2)
  expect_equal(as.numeric(terra::values(r_yr)[1, 1]), 120)
  
  # Monthly cycle: 12 months, mean = 10
  r_mo <- pisco_aggregate(r, by = "month", fun = "mean")
  expect_equal(terra::nlyr(r_mo), 12)
  expect_equal(as.numeric(terra::values(r_mo)[1, 1]), 10)
  
  # SENAMHI season
  r_seas <- pisco_aggregate(r, by = "season_senamhi", fun = "sum")
  expect_true(any(grepl("wet_Nov_Apr", names(r_seas))))
  expect_true(any(grepl("dry_May_Oct", names(r_seas))))
})

test_that("pisco_anomaly computes difference and percentage anomalies", {
  r <- terra::rast(xmin = -82, xmax = -64, ymin = -19, ymax = 2,
                   resolution = 1, crs = "EPSG:4326", nlyrs = 12)
  # 15 mm everywhere
  terra::values(r) <- 15
  dts <- seq(as.Date("1998-01-01"), by = "month", length.out = 12)
  terra::time(r) <- dts
  
  # Baseline of 10 mm everywhere
  b <- terra::rast(xmin = -82, xmax = -64, ymin = -19, ymax = 2,
                   resolution = 1, crs = "EPSG:4326", nlyrs = 12)
  terra::values(b) <- 10
  
  # Difference anomaly: 15 - 10 = 5 mm
  anom_d <- pisco_anomaly(r, baseline = b, type = "difference")
  expect_equal(as.numeric(terra::values(anom_d)[1, 1]), 5)
  expect_equal(unique(terra::units(anom_d)), "mm")
  
  # Percentage anomaly: (15 - 10)/(10 + 0.1) * 100 ~ 49.5%
  anom_p <- pisco_anomaly(r, baseline = b, type = "percentage")
  expect_equal(unique(terra::units(anom_p)), "%")
  expect_gt(as.numeric(terra::values(anom_p)[1, 1]), 45)
})

test_that("pisco_metrics computes COR, dr, NMB, NMGE accurately", {
  obs <- c(10, 20, 30, 40, 50)
  sim <- c(12, 18, 33, 38, 52)
  
  m <- pisco_metrics(sim, obs)
  expect_s3_class(m, "tbl_df")
  expect_equal(m$n, 5)
  expect_gt(m$cor, 0.98)
  expect_gt(m$dr, 0.85)
  expect_lt(abs(m$nmb), 5) # Small bias
  expect_lt(m$nmge, 0.1)  # Small relative error
  
  # Individual functions
  expect_equal(pisco_metric_cor(sim, obs), stats::cor(sim, obs))
  expect_gt(pisco_metric_dr(sim, obs), 0.85)
  expect_equal(pisco_metric_nmb(sim, obs), 100 * sum(sim - obs) / sum(obs))
  expect_equal(pisco_metric_nmge(sim, obs), sum(abs(sim - obs)) / sum(obs))
})
