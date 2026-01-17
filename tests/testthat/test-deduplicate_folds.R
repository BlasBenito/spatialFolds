test_that("deduplicate_folds() removes correlated folds", {
  data(xy_sf)

  xy_sf_subset <- xy_sf[1:500, ]

  # Generate folds with random method
  folds <- spatial_folds(
    df = xy_sf_subset,
    methods = "random",
    training_fraction = 0.75,
    repetitions = 20,
    seed = 123
  )

  # Deduplicate
  folds_reduced <- deduplicate_folds(folds, max_cor = 0.9)

  # Should have fewer or equal columns
  expect_lte(ncol(folds_reduced), ncol(folds))

  # Should have at least 1 column
  expect_gte(ncol(folds_reduced), 1)

  # All columns should be logical
  expect_true(all(sapply(folds_reduced, is.logical)))

  # Row count should be preserved
  expect_equal(nrow(folds_reduced), nrow(folds))
})

test_that("deduplicate_folds() preserves column names", {
  data(xy_sf)

  xy_sf_subset <- xy_sf[1:500, ]

  folds <- spatial_folds(
    df = xy_sf_subset,
    methods = "random",
    training_fraction = 0.75,
    repetitions = 10,
    seed = 123
  )

  folds_reduced <- deduplicate_folds(folds, max_cor = 0.9)

  # All column names in result should be from original
  expect_true(all(colnames(folds_reduced) %in% colnames(folds)))
})

test_that("deduplicate_folds() works with multiple method-fraction groups", {
  data(xy_sf)

  xy_sf_subset <- xy_sf[1:500, ]

  folds <- spatial_folds(
    df = xy_sf_subset,
    methods = c("random", "blocks"),
    training_fraction = c(0.75, 0.5),
    repetitions = 10,
    seed = 123
  )

  # Should have 2 methods x 2 fractions x 10 repetitions = 40 columns
  expect_equal(ncol(folds), 40)

  folds_reduced <- deduplicate_folds(folds, max_cor = 0.9)

  # Should preserve column names pattern
  expect_true(any(grepl("blocks_0.75", colnames(folds_reduced))))
  expect_true(any(grepl("random_0.75", colnames(folds_reduced))))
})

test_that("deduplicate_folds() validates folds parameter", {
  # NULL folds
  expect_error(
    deduplicate_folds(folds = NULL),
    "cannot be NULL"
  )

  # Non-data.frame folds
  expect_error(
    deduplicate_folds(folds = c(TRUE, FALSE, TRUE)),
    "must be a data.frame"
  )

  # Empty folds
  expect_error(
    deduplicate_folds(folds = data.frame()),
    "has no columns"
  )

  # Non-logical columns
  expect_error(
    deduplicate_folds(folds = data.frame(a = 1:10, b = 1:10)),
    "must be logical vectors"
  )
})

test_that("deduplicate_folds() validates max_cor parameter", {
  folds <- data.frame(
    fold_1 = c(TRUE, FALSE, TRUE, FALSE, TRUE),
    fold_2 = c(TRUE, TRUE, FALSE, FALSE, TRUE)
  )

  # Non-numeric max_cor
  expect_error(
    deduplicate_folds(folds, max_cor = "0.9"),
    "must be a single numeric value"
  )

  # max_cor out of range
  expect_error(
    deduplicate_folds(folds, max_cor = 0),
    "must be between 0 and 1"
  )

  expect_error(
    deduplicate_folds(folds, max_cor = 1),
    "must be between 0 and 1"
  )

  expect_error(
    deduplicate_folds(folds, max_cor = 1.5),
    "must be between 0 and 1"
  )
})

test_that("deduplicate_folds() handles single column input", {
  folds <- data.frame(
    fold_1 = c(TRUE, FALSE, TRUE, FALSE, TRUE)
  )

  # Should return unchanged with message
  expect_message(
    result <- deduplicate_folds(folds),
    "Only 1 fold provided"
  )

  expect_equal(result, folds)
})

test_that("deduplicate_folds() with stricter threshold removes more folds", {
  data(xy_sf)

  xy_sf_subset <- xy_sf[1:500, ]

  folds <- spatial_folds(
    df = xy_sf_subset,
    methods = "random",
    training_fraction = 0.75,
    repetitions = 30,
    seed = 123
  )

  folds_relaxed <- deduplicate_folds(folds, max_cor = 0.95)
  folds_strict <- deduplicate_folds(folds, max_cor = 0.8)

  # Stricter threshold should keep fewer or equal columns
  expect_lte(ncol(folds_strict), ncol(folds_relaxed))
})

test_that("deduplicate_folds() returns data.frame", {
  data(xy_sf)

  xy_sf_subset <- xy_sf[1:500, ]

  folds <- spatial_folds(
    df = xy_sf_subset,
    methods = "random",
    training_fraction = 0.75,
    repetitions = 10,
    seed = 123
  )

  folds_reduced <- deduplicate_folds(folds)

  expect_s3_class(folds_reduced, "data.frame")
})

test_that("deduplicate_folds() preserves original column order", {
  data(xy_sf)

  xy_sf_subset <- xy_sf[1:500, ]

  folds <- spatial_folds(
    df = xy_sf_subset,
    methods = c("random", "blocks"),
    training_fraction = 0.75,
    repetitions = 5,
    seed = 123
  )

  folds_reduced <- deduplicate_folds(folds, max_cor = 0.9)

  # Get indices of result columns in original
  original_names <- colnames(folds)
  result_names <- colnames(folds_reduced)
  indices <- match(result_names, original_names)

  # Indices should be increasing (preserves order)
  expect_true(all(diff(indices) > 0))
})
