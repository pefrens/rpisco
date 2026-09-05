test_that("pisco_catalog returns expected structure and products", {
  cat_df <- pisco_catalog()
  
  expect_s3_class(cat_df, "tbl_df")
  expect_equal(nrow(cat_df), 3)
  
  expected_cols <- c("dataset", "variable", "product", "filename",
                     "timestep", "period", "layers", "resolution",
                     "unit", "size_mb", "cached", "download_url")
  expect_true(all(expected_cols %in% colnames(cat_df)))
  
  expect_setequal(cat_df$dataset, c("monthly", "daily", "climatology"))
  expect_setequal(cat_df$product, c("PISCOp_m", "PISCOp_d", "PISCOp_clim2"))
  expect_setequal(cat_df$filename, c("PISCOp_m.nc", "PISCOp_d.nc", "PISCOp_clim2.nc"))
  expect_equal(cat_df$layers[cat_df$dataset == "monthly"], 540L)
  expect_equal(cat_df$layers[cat_df$dataset == "daily"], 16436L)
  expect_equal(cat_df$layers[cat_df$dataset == "climatology"], 12L)
})

test_that("dataset alias resolver works accurately", {
  expect_equal(.pisco_resolve_dataset("monthly"), "monthly")
  expect_equal(.pisco_resolve_dataset("PISCOp_m"), "monthly")
  expect_equal(.pisco_resolve_dataset("PISCOp_m.nc"), "monthly")
  expect_equal(.pisco_resolve_dataset("m"), "monthly")
  expect_equal(.pisco_resolve_dataset("mensual"), "monthly")
  
  expect_equal(.pisco_resolve_dataset("daily"), "daily")
  expect_equal(.pisco_resolve_dataset("PISCOp_d"), "daily")
  expect_equal(.pisco_resolve_dataset("d"), "daily")
  expect_equal(.pisco_resolve_dataset("diario"), "daily")
  
  expect_equal(.pisco_resolve_dataset("climatology"), "climatology")
  expect_equal(.pisco_resolve_dataset("PISCOp_clim2"), "climatology")
  expect_equal(.pisco_resolve_dataset("clim"), "climatology")
  expect_equal(.pisco_resolve_dataset("normal"), "climatology")
  
  expect_error(.pisco_resolve_dataset("invalid_name"))
})

test_that("pisco_extent and pisco_bbox return correct boundaries", {
  ext_vec <- pisco_extent("vector")
  expect_type(ext_vec, "double")
  expect_equal(ext_vec[["xmin"]], -82)
  expect_equal(ext_vec[["ymin"]], -19)
  expect_equal(ext_vec[["xmax"]], -64)
  expect_equal(ext_vec[["ymax"]], 2)
  
  bbox_obj <- pisco_bbox()
  expect_s3_class(bbox_obj, "bbox")
  expect_equal(as.numeric(bbox_obj["xmin"]), -82)
  
  ext_obj <- pisco_extent("ext")
  expect_s4_class(ext_obj, "SpatExtent")
})

test_that("pisco_citation produces text and bibtex formats", {
  txt <- pisco_citation("text")
  expect_match(txt, "Gutierrez, L. y Lavado-Casimiro, W.")
  expect_match(txt, "SENAMHI")
  expect_match(txt, "10.6084/m9.figshare.32411886")
  
  bib <- pisco_cite("bibtex")
  expect_match(bib, "@techreport")
  expect_match(bib, "@misc")
  expect_match(bib, "PISCOp")
})
