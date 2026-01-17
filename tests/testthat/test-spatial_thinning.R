test_that("thinning_to_distance works", {
  data(xy_matrix)

  xy_matrix <- xy_matrix[1:1000, ]

  #wrong input arguments
  testthat::expect_error(
    thinning_to_distance(xy = NULL),
    regexp = "is missing"
  )

  testthat::expect_error(
    thinning_to_distance(xy = xy_matrix),
    regexp = "is missing"
  )

  testthat::expect_error(
    thinning_to_distance(xy = xy_matrix, distance = NULL),
    regexp = "Expecting a single value"
  )

  #valid result
  result <- thinning_to_distance(xy = xy_matrix, distance = 1.5)

  expect_type(result, "integer")
  expect_true(all(result >= 1 & result <= nrow(xy_matrix)))
  expect_true(length(result) <= nrow(xy_matrix))
  expect_true(length(result) >= 1)

  #result complies with distance
  result_coords <- xy_matrix[result, ]

  # Check a sample of pairwise distances (30 random pairs)
  if (nrow(result_coords) > 1) {
    n_pairs <- 30
    set.seed(42)
    for (k in seq_len(n_pairs)) {
      i <- sample(nrow(result_coords), 1)
      j <- sample(setdiff(seq_len(nrow(result_coords)), i), 1)
      dx <- abs(result_coords[i, 1] - result_coords[j, 1])
      dy <- abs(result_coords[i, 2] - result_coords[j, 2])

      # At least one dimension must exceed distance
      # (Manhattan distance constraint)
      expect_true(dx > 1.5 || dy > 1.5)
    }
  }

  #edge cases
  # Single point
  xy_single <- matrix(c(0, 0), ncol = 2)
  result <- thinning_to_distance(xy_single, distance = 1)
  expect_equal(result, 1L)

  # Two very close points
  xy_close <- matrix(c(0, 0, 0.001, 0.001), ncol = 2, byrow = TRUE)
  result <- thinning_to_distance(xy_close, distance = 0.01)
  expect_equal(length(result), 1L)

  # Zero distance (no thinning)
  xy <- matrix(runif(20), ncol = 2)
  result <- thinning_to_distance(xy, distance = 0)
  expect_equal(length(result), nrow(xy))

  # Very large distance
  xy <- matrix(c(0, 0, 1, 1, 2, 2), ncol = 2, byrow = TRUE)
  result <- thinning_to_distance(xy, distance = 100)
  expect_equal(length(result), 1L)

  # Empty input
  xy_empty <- matrix(numeric(0), ncol = 2)
  result <- thinning_to_distance(xy_empty, distance = 1)
  expect_equal(length(result), 0L)
})


test_that("thinning_to_target respects target count", {
  data(xy_matrix)
  target <- 1000

  result <- thinning_to_target(xy = xy_matrix, target = target)

  expect_type(result, "integer")
  expect_true(length(result) <= target)
  expect_true(length(result) >= 1)

  #edge cases
  xy <- matrix(runif(20), ncol = 2)

  # Target equals n - returns all indices
  result <- thinning_to_target(xy, target = 10)
  expect_equal(length(result), 10)

  # Target = 1
  result <- thinning_to_target(xy, target = 1)
  expect_equal(length(result), 1L)

  # Target > n - should return all
  expect_warning(
    result <- thinning_to_target(xy, target = 100)
  )
  expect_equal(length(result), 10)

  # Empty input
  xy_empty <- matrix(numeric(0), ncol = 2)
  result <- thinning_to_target(xy_empty, target = 5)
  expect_equal(length(result), 0L)
})


test_that("spatial_thinning validates method-specific parameters", {
  data(xy_sf)

  # Missing target for "target" method
  expect_error(
    spatial_thinning(df = xy_sf, method = "target", target = NULL),
    "target"
  )

  # Negative distance
  expect_error(
    spatial_thinning(df = xy_sf, method = "distance", distance = -1),
    "must be >= 0"
  )

  # Invalid target
  expect_error(
    spatial_thinning(df = xy_sf, method = "target", target = 0),
    "must be >= 1"
  )

  # Non-numeric distance
  expect_error(
    spatial_thinning(df = xy_sf, method = "distance", distance = "10"),
    "must be numeric"
  )

  # Non-numeric target
  expect_error(
    spatial_thinning(df = xy_sf, method = "target", target = "100"),
    "must be numeric"
  )
})

test_that("spatial_thinning handles sf input", {
  data(xy_sf)

  # Method: distance
  expect_message(
    result <- spatial_thinning(
      df = xy_sf,
      method = "distance",
      distance = 1
    ),
    "Thinned from"
  )

  expect_s3_class(result, "sf")
  expect_true(nrow(result) < nrow(xy_sf))
  expect_true(nrow(result) >= 1)

  # Method: to_target
  expect_message(
    result <- spatial_thinning(
      df = xy_sf,
      method = "target",
      target = 500
    ),
    "Thinned from"
  )

  expect_s3_class(result, "sf")
  expect_true(nrow(result) <= 500)
})

test_that("spatial_thinning handles data.frame input", {
  data(xy_matrix)

  # Convert matrix to data.frame for this test
  df <- as.data.frame(xy_matrix)

  # Should convert to sf internally
  expect_message(
    result <- spatial_thinning(
      df = df,
      method = "distance",
      distance = 1
    ),
    "Thinned from"
  )

  expect_s3_class(result, "sf")
  expect_true(nrow(result) < nrow(df))
})

test_that("spatial_thinning with method='distance' produces valid output", {
  data(xy_sf)

  expect_message(
    result <- spatial_thinning(
      df = xy_sf,
      method = "distance",
      distance = 1
    )
  )

  # Result should be smaller than input
  expect_true(nrow(result) < nrow(xy_sf))

  # Result should maintain sf structure
  expect_s3_class(result, "sf")

  # Coordinates should be subset of original
  result_coords <- cast_sf_to_xy(result)
  original_coords <- cast_sf_to_xy(xy_sf)

  # Check a sample of 30 result coordinates match original
  n_check <- min(30, nrow(result_coords))
  set.seed(42)
  sample_idx <- sample(nrow(result_coords), n_check)
  for (i in sample_idx) {
    found <- any(
      original_coords[, "x"] == result_coords[i, "x"] &
        original_coords[, "y"] == result_coords[i, "y"]
    )
    expect_true(found)
  }
})

test_that("spatial_thinning with method='to_target' produces valid output", {
  data(xy_sf)

  target <- 500

  expect_message(
    result <- spatial_thinning(
      df = xy_sf,
      method = "target",
      target = target
    )
  )

  # Result should have <= target rows
  expect_true(nrow(result) <= target)

  # Result should maintain sf structure
  expect_s3_class(result, "sf")
})

test_that("spatial_thinning handles warnings correctly", {
  data(xy_sf)

  # Target exceeds nrow - should warn and return all
  expect_warning(
    result <- spatial_thinning(
      df = xy_sf,
      method = "target",
      target = 40000
    ),
    "exceeds nrow"
  )
  expect_equal(nrow(result), nrow(xy_sf))

  # Multiple values for distance
  expect_warning(
    result <- spatial_thinning(
      df = xy_sf,
      method = "distance",
      distance = c(0.1, 0.2, 0.3)
    ),
    "length > 1"
  )
})

test_that("thinning_to_target returns valid indices for use in spatial_folds", {
  data(xy_matrix)

  # Get center indices using thinning_to_target (as spatial_folds does)
  n_centers_needed <- 100
  center_indices <- thinning_to_target(
    xy = xy_matrix,
    target = n_centers_needed
  )

  # Verify output format
  expect_type(center_indices, "integer")
  expect_true(length(center_indices) <= n_centers_needed)
  expect_true(all(center_indices >= 1 & center_indices <= nrow(xy_matrix)))

  # Verify indices can be used to subset the data
  centers <- xy_matrix[center_indices, ]
  expect_equal(nrow(centers), length(center_indices))
  expect_true(all(c("x", "y") %in% colnames(centers)))
})

test_that("spatial_thinning uses default distance when NULL", {
  data(xy_sf)

  # Should work without explicit distance parameter
  expect_message(
    result <- spatial_thinning(
      df = xy_sf,
      method = "distance"
      # distance = NULL implicitly
    ),
    "Auto-calculated distance"
  )

  expect_s3_class(result, "sf")
  expect_true(nrow(result) < nrow(xy_sf))
  expect_true(nrow(result) >= 1)
})

test_that("spatial_thinning auto-calculated distance works", {
  # Create controlled dataset: 10×10 grid (100 points)
  df <- expand.grid(x = 0:9, y = 0:9)
  df_sf <- cast_df_to_sf(df)

  expect_message(
    result <- spatial_thinning(
      df = df_sf,
      method = "distance"
    ),
    "Auto-calculated distance"
  )

  # Should thin to some extent (not return all points)
  expect_s3_class(result, "sf")
  expect_true(nrow(result) >= 1)
  expect_true(nrow(result) < nrow(df_sf))
})

test_that("spatial_thinning handles zero bbox_area edge case", {
  # lwgeom required when s2 is disabled for st_area calculations
  skip_if_not_installed("lwgeom")

  # Temporarily disable s2 for degenerate geometry handling
  s2_was_enabled <- sf::sf_use_s2()
  sf::sf_use_s2(FALSE)
  on.exit(sf::sf_use_s2(s2_was_enabled), add = TRUE)

  # All points at same location
  df <- data.frame(x = rep(5, 100), y = rep(5, 100))
  df_sf <- cast_df_to_sf(df)

  expect_message(
    result <- spatial_thinning(
      df = df_sf,
      method = "distance"
    ),
    "All points at same location"
  )

  # With distance = 0, should return all points
  expect_equal(nrow(result), nrow(df_sf))
})
