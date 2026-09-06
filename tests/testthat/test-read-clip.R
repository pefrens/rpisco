test_that("pisco_clip works with numeric vector, bbox, and terra ext", {
  r <- terra::rast(xmin = -82, xmax = -64, ymin = -19, ymax = 2,
                   resolution = 1, crs = "EPSG:4326")
  terra::values(r) <- seq_len(terra::ncell(r))
  
  # 1. Unnamed numeric vector c(xmin, ymin, xmax, ymax)
  c1 <- pisco_clip(r, mask = c(-78, -12, -76, -10))
  expect_equal(terra::xmin(c1), -78)
  expect_equal(terra::xmax(c1), -76)
  expect_equal(terra::ymin(c1), -12)
  expect_equal(terra::ymax(c1), -10)
  
  # 2. Named numeric vector
  c2 <- pisco_clip(r, mask = c(ymin = -12, xmax = -76, xmin = -78, ymax = -10))
  expect_equal(as.vector(terra::ext(c1)), as.vector(terra::ext(c2)))
  
  # 3. bbox from sf
  bb <- sf::st_bbox(c(xmin = -78, ymin = -12, xmax = -76, ymax = -10), crs = sf::st_crs(4326))
  c3 <- pisco_clip(r, mask = bb)
  expect_equal(as.vector(terra::ext(c1)), as.vector(terra::ext(c3)))
  
  # 4. SpatExtent
  ex <- terra::ext(-78, -76, -12, -10)
  c4 <- pisco_clip(r, mask = ex)
  expect_equal(as.vector(terra::ext(c1)), as.vector(terra::ext(c4)))
  
  # 5. Non-overlapping mask errors gracefully
  expect_error(pisco_clip(r, mask = c(10, 20, 30, 40)), "does not intersect")
})

test_that(".pisco_filter_dates filters years, dates, and year-months correctly", {
  r <- terra::rast(xmin = -82, xmax = -64, ymin = -19, ymax = 2,
                   resolution = 1, crs = "EPSG:4326", nlyrs = 36)
  n_cells <- terra::ncell(r)
  terra::values(r) <- rep(1:36, each = n_cells)
  dts <- seq(as.Date("1997-01-01"), by = "month", length.out = 36)
  terra::time(r) <- dts
  
  # Filter single year
  r97 <- .pisco_filter_dates(r, dates = 1997)
  expect_equal(terra::nlyr(r97), 12)
  
  # Filter year range
  r9798 <- .pisco_filter_dates(r, dates = c(1997, 1998))
  expect_equal(terra::nlyr(r9798), 24)
  
  # Filter year-month
  rym <- .pisco_filter_dates(r, dates = c("1997-06", "1997-08"))
  expect_equal(terra::nlyr(rym), 3)
  
  # Filter Date range
  rdt <- .pisco_filter_dates(r, dates = c(as.Date("1997-01-01"), as.Date("1997-03-01")))
  expect_equal(terra::nlyr(rdt), 3)
  
  # Climatology month filter
  r_clim <- terra::rast(xmin = -82, xmax = -64, ymin = -19, ymax = 2,
                        resolution = 1, crs = "EPSG:4326", nlyrs = 12)
  names(r_clim) <- c("Jan", "Feb", "Mar", "Apr", "May", "Jun", 
                     "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
  r_clim_sub <- .pisco_filter_dates(r_clim, dates = 1:3, dataset_name = "climatology")
  expect_equal(terra::nlyr(r_clim_sub), 3)

  # When time(r) is NULL or NA but names have year strings
  r_notime <- terra::rast(xmin = -82, xmax = -64, ymin = -19, ymax = 2,
                          resolution = 1, crs = "EPSG:4326", nlyrs = 24)
  names(r_notime) <- c(paste0("1997_", 1:12), paste0("1998_", 1:12))
  r_filt <- .pisco_filter_dates(r_notime, dates = c(1997, 1998))
  expect_equal(terra::nlyr(r_filt), 24)
})
