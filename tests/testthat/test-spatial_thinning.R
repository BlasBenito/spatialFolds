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

  # Negative distance
  expect_error(
    spatial_thinning(df = xy_sf, distance = -1),
    "must be >= 0"
  )

  # Invalid target (too small)
  expect_error(
    spatial_thinning(df = xy_sf, target = 0),
    "must be between 1 and nrow"
  )

  # Invalid target (too large - equals nrow)
  expect_error(
    spatial_thinning(df = xy_sf, target = nrow(xy_sf)),
    "must be between 1 and nrow"
  )

  # Non-numeric distance
  expect_error(
    spatial_thinning(df = xy_sf, distance = "10"),
    "must be numeric"
  )

  # Non-numeric target
  expect_error(
    spatial_thinning(df = xy_sf, target = "100"),
    "must be numeric"
  )
})

test_that("spatial_thinning handles sf input with distance method", {
  data(xy_sf)

  # Method: distance (inferred from providing distance argument)
  result <- spatial_thinning(
    df = xy_sf,
    distance = 1
  )

  expect_s3_class(result, "sf")
  expect_true(nrow(result) < nrow(xy_sf))
  expect_true(nrow(result) >= 1)
})

test_that("spatial_thinning handles sf input with target method", {
  data(xy_sf)

  # Method: target (inferred from providing target argument)
  result <- spatial_thinning(
    df = xy_sf,
    target = 500
  )

  expect_s3_class(result, "sf")
  expect_true(nrow(result) <= 500)
})

test_that("spatial_thinning handles data.frame input", {
  data(xy_matrix)

  # Convert matrix to data.frame for this test
  df <- as.data.frame(xy_matrix)

  # Should convert to sf internally
  result <- spatial_thinning(
    df = df,
    distance = 1
  )

  expect_s3_class(result, "sf")
  expect_true(nrow(result) < nrow(df))
})

test_that("spatial_thinning with distance produces valid output", {
  data(xy_sf)

  result <- spatial_thinning(
    df = xy_sf,
    distance = 1
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

test_that("spatial_thinning with target produces valid output", {
  data(xy_sf)

  target <- 500

  result <- spatial_thinning(
    df = xy_sf,
    target = target
  )

  # Result should have <= target rows
  expect_true(nrow(result) <= target)

  # Result should maintain sf structure
  expect_s3_class(result, "sf")
})

test_that("spatial_thinning handles warnings correctly", {
  data(xy_sf)

  # Target exceeds nrow - should error (not warn) since target >= nrow(df)
  expect_error(
    spatial_thinning(
      df = xy_sf,
      target = 40000
    ),
    "must be between 1 and nrow"
  )

  # Target equals nrow(df) - 1 should work
  result <- spatial_thinning(
    df = xy_sf,
    target = nrow(xy_sf) - 1
  )
  expect_s3_class(result, "sf")
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

  # Should work without explicit distance parameter (auto-calculates)
  expect_message(
    result <- spatial_thinning(
      df = xy_sf
      # Both distance and target are NULL - uses auto-calculated distance
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
      df = df_sf
      # Auto-calculate distance when both NULL
    ),
    "Auto-calculated distance"
  )

  # Auto-calculation should produce valid result
  # Note: thinning may not occur if calculated distance < actual point spacing
  expect_s3_class(result, "sf")
  expect_true(nrow(result) >= 1)
  expect_true(nrow(result) <= nrow(df_sf))
})

test_that("spatial_thinning errors on zero bbox_area (all points at same location)", {
  # All points at same location - degenerate geometry
  df <- data.frame(x = rep(5, 100), y = rep(5, 100))
  df_sf <- cast_df_to_sf(df)

  # validate_arg_sf errors on degenerate geometry
  expect_error(
    spatial_thinning(df = df_sf),
    "All points at same location"
  )
})

test_that("spatial_thinning prefers distance when both provided", {
  data(xy_sf)

  # When both distance and target provided, should use distance and message
  expect_message(
    result <- spatial_thinning(
      df = xy_sf,
      distance = 1,
      target = 100
    ),
    "cannot be used together.*Using 'distance"
  )

  expect_s3_class(result, "sf")
})
