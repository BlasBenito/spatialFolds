test_that("spatial_folds() generates folds with default parameters", {
  data(xy_sf)

  # Use subset for faster testing
  xy_sf_subset <- xy_sf[1:1000, ]

  folds <- spatial_folds(
    df = xy_sf_subset,
    methods = "random",
    training_fraction = 0.75,
    repetitions = 5,
    seed = 123
  )

  # Check output structure
  expect_s3_class(folds, "data.frame")
  expect_equal(nrow(folds), nrow(xy_sf_subset))
  expect_equal(ncol(folds), 5)

  # Check column names follow pattern
  expect_true(all(grepl("random_0.75_", colnames(folds))))

  # Check all columns are logical
  expect_true(all(sapply(folds, is.logical)))

  # Check training counts are approximately correct
  training_counts <- colSums(folds)
  expect_true(all(training_counts >= 700 & training_counts <= 800))
})

test_that("spatial_folds() works with all methods", {
  data(xy_sf)

  xy_sf_subset <- xy_sf[1:500, ]

  folds <- spatial_folds(
    df = xy_sf_subset,
    methods = c("contiguous", "random", "blocks"),
    training_fraction = 0.75,
    repetitions = 3,
    seed = 42
  )

  # Should have 3 methods x 1 fraction x 3 repetitions = 9 folds
  expect_equal(ncol(folds), 9)

  # Check column names contain all methods
  expect_true(any(grepl("contiguous", colnames(folds))))
  expect_true(any(grepl("random", colnames(folds))))
  expect_true(any(grepl("blocks", colnames(folds))))
})

test_that("spatial_folds() works with multiple training fractions", {
  data(xy_sf)

  xy_sf_subset <- xy_sf[1:500, ]

  folds <- spatial_folds(
    df = xy_sf_subset,
    methods = "random",
    training_fraction = c(0.75, 0.5),
    repetitions = 3,
    seed = 42
  )

  # Should have 1 method x 2 fractions x 3 repetitions = 6 folds
  expect_equal(ncol(folds), 6)

  # Check column names contain both fractions
  expect_true(any(grepl("0.75", colnames(folds))))
  expect_true(any(grepl("0.50", colnames(folds))))
})

test_that("spatial_folds() validates methods parameter", {
  data(xy_sf)

  xy_sf_subset <- xy_sf[1:100, ]

  # Empty methods
  expect_error(
    spatial_folds(df = xy_sf_subset, methods = NULL),
    "cannot be empty"
  )

  expect_error(
    spatial_folds(df = xy_sf_subset, methods = character(0)),
    "cannot be empty"
  )

  # Invalid method
  expect_error(
    spatial_folds(df = xy_sf_subset, methods = "invalid_method"),
    "'arg' should be one of"
  )
})

test_that("spatial_folds() validates training_fraction parameter", {
  data(xy_sf)

  xy_sf_subset <- xy_sf[1:100, ]

  # Empty training_fraction - resets to 0.75 with message
  expect_message(
    result <- spatial_folds(df = xy_sf_subset, training_fraction = NULL, repetitions = 1),
    "Argument 'training_fraction' is invalid"
  )

  # Non-numeric training_fraction - resets to 0.75 with message
  expect_message(
    result <- spatial_folds(df = xy_sf_subset, training_fraction = "0.5", repetitions = 1),
    "Argument 'training_fraction' is invalid"
  )

  # Out of range training_fraction (must be between 0.1 and 0.9, exclusive)
  expect_error(
    spatial_folds(df = xy_sf_subset, training_fraction = 0),
    "must be between 0.1 and 0.9"
  )

  expect_error(
    spatial_folds(df = xy_sf_subset, training_fraction = 0.1),
    "must be between 0.1 and 0.9"
  )

  expect_error(
    spatial_folds(df = xy_sf_subset, training_fraction = 0.9),
    "must be between 0.1 and 0.9"
  )

  expect_error(
    spatial_folds(df = xy_sf_subset, training_fraction = 1),
    "must be between 0.1 and 0.9"
  )

  expect_error(
    spatial_folds(df = xy_sf_subset, training_fraction = 1.5),
    "must be between 0.1 and 0.9"
  )

  expect_error(
    spatial_folds(df = xy_sf_subset, training_fraction = -0.5),
    "must be between 0.1 and 0.9"
  )
})

test_that("spatial_folds() validates repetitions parameter", {
  data(xy_sf)

  xy_sf_subset <- xy_sf[1:100, ]

  # Non-single repetitions
  expect_error(
    spatial_folds(df = xy_sf_subset, repetitions = c(1, 2)),
    "must be a single integer"
  )

  # Non-numeric repetitions
  expect_error(
    spatial_folds(df = xy_sf_subset, repetitions = "5"),
    "must be numeric"
  )

  # repetitions < 1
  expect_error(
    spatial_folds(df = xy_sf_subset, repetitions = 0),
    "must be at least 1"
  )
})

test_that("spatial_folds() validates seed parameter", {
  data(xy_sf)

  xy_sf_subset <- xy_sf[1:100, ]

  # Non-single seed
  expect_error(
    spatial_folds(df = xy_sf_subset, seed = c(1, 2)),
    "must be a single integer"
  )

  # Non-numeric seed
  expect_error(
    spatial_folds(df = xy_sf_subset, seed = "123"),
    "must be numeric"
  )
})

test_that("spatial_folds() validates blocks parameter", {
  data(xy_sf)

  xy_sf_subset <- xy_sf[1:100, ]

  # Invalid blocks type (character)
  expect_error(
    spatial_folds(df = xy_sf_subset, methods = "blocks", blocks = "10"),
    "must be NULL, numeric"
  )

  # Invalid blocks length
  expect_error(
    spatial_folds(df = xy_sf_subset, methods = "blocks", blocks = c(1, 2, 3)),
    "must be NULL, an integer, or a length-2 vector"
  )

  # Single integer blocks works
  result <- spatial_folds(
    df = xy_sf_subset,
    methods = "blocks",
    blocks = 10,
    repetitions = 1
  )
  expect_true(ncol(result) > 0)

  # Vector blocks c(rows, cols) works
  result <- spatial_folds(
    df = xy_sf_subset,
    methods = "blocks",
    blocks = c(3, 4),
    repetitions = 1
  )
  expect_true(ncol(result) > 0)

  # NULL blocks (auto-computed) works
  result <- spatial_folds(
    df = xy_sf_subset,
    methods = "blocks",
    blocks = NULL,
    repetitions = 1
  )
  expect_true(ncol(result) > 0)
})

test_that("spatial_folds() produces reproducible results", {
  data(xy_sf)

  xy_sf_subset <- xy_sf[1:200, ]

  folds1 <- spatial_folds(
    df = xy_sf_subset,
    methods = "random",
    training_fraction = 0.75,
    repetitions = 3,
    seed = 42
  )

  folds2 <- spatial_folds(
    df = xy_sf_subset,
    methods = "random",
    training_fraction = 0.75,
    repetitions = 3,
    seed = 42
  )

  # Same seed should produce same results
  expect_equal(folds1, folds2)
})

test_that("spatial_folds() produces different results with different seeds", {
  data(xy_sf)

  xy_sf_subset <- xy_sf[1:200, ]

  folds1 <- spatial_folds(
    df = xy_sf_subset,
    methods = "random",
    training_fraction = 0.75,
    repetitions = 3,
    seed = 42
  )

  folds2 <- spatial_folds(
    df = xy_sf_subset,
    methods = "random",
    training_fraction = 0.75,
    repetitions = 3,
    seed = 123
  )

  # Different seeds should produce different results
  expect_false(identical(folds1, folds2))
})

test_that("spatial_folds() removes duplicate training fractions", {
  data(xy_sf)

  xy_sf_subset <- xy_sf[1:200, ]

  folds <- spatial_folds(
    df = xy_sf_subset,
    methods = "random",
    training_fraction = c(0.75, 0.75, 0.5),
    repetitions = 2,
    seed = 42
  )

  # Should deduplicate: 1 method x 2 unique fractions x 2 repetitions = 4 folds
  expect_equal(ncol(folds), 4)
})

test_that("spatial_folds() with contiguous method produces spatially coherent folds", {
  data(xy_sf)

  xy_sf_subset <- xy_sf[1:500, ]

  folds <- spatial_folds(
    df = xy_sf_subset,
    methods = "contiguous",
    training_fraction = 0.75,
    repetitions = 3,
    seed = 42
  )

  # Check structure
  expect_equal(ncol(folds), 3)

  # Each fold should have approximately correct training count
  training_counts <- colSums(folds)
  expect_true(all(training_counts >= 300))
})

test_that("spatial_folds() with blocks method produces valid folds", {
  data(xy_sf)

  xy_sf_subset <- xy_sf[1:500, ]

  folds <- spatial_folds(
    df = xy_sf_subset,
    methods = "blocks",
    training_fraction = 0.75,
    repetitions = 3,
    blocks = c(5, 5),
    seed = 42
  )

  # Check structure
  expect_equal(ncol(folds), 3)

  # Each fold should have at least some training samples
  training_counts <- colSums(folds)
  expect_true(all(training_counts > 0))
})
