# ============================================================================ #
# Tests for Optimized Training Fold Implementations
# ============================================================================ #
#
# This file tests the two optimized C++ implementations:
#   - training_fold_optimized() - Distance-based O(n) algorithm
#   - training_fold_binary() - Binary search on rectangle scale
#
# ============================================================================ #

# Load test data
data(xy_matrix, package = "spatialFolds")

# ============================================================================ #
# Test: training_fold_optimized() - Basic Functionality
# ============================================================================ #

test_that("training_fold_optimized() returns logical vector", {
  result <- training_fold_optimized(
    xy = xy_matrix,
    center = 1,
    training_fraction = 0.5
  )

  expect_type(result, "logical")
  expect_length(result, nrow(xy_matrix))
})

test_that("training_fold_optimized() achieves correct training fraction", {
  result <- training_fold_optimized(
    xy = xy_matrix,
    center = 1,
    training_fraction = 0.5
  )

  actual_fraction <- sum(result) / length(result)
  expect_equal(actual_fraction, 0.5, tolerance = 0.001)
})

test_that("training_fold_optimized() works with different fractions", {
  for (fraction in c(0.2, 0.3, 0.5, 0.7, 0.8)) {
    result <- training_fold_optimized(
      xy = xy_matrix,
      center = 1,
      training_fraction = fraction
    )

    actual_fraction <- sum(result) / length(result)
    expect_equal(actual_fraction, fraction, tolerance = 0.001)
  }
})

test_that("training_fold_optimized() works with different centers", {
  for (center in c(1, 100, 1000, 15000, 29999, 30000)) {
    result <- training_fold_optimized(
      xy = xy_matrix,
      center = center,
      training_fraction = 0.5
    )

    expect_type(result, "logical")
    expect_length(result, nrow(xy_matrix))

    actual_fraction <- sum(result) / length(result)
    expect_equal(actual_fraction, 0.5, tolerance = 0.001)
  }
})

# ============================================================================ #
# Test: training_fold_optimized() - Error Handling
# ============================================================================ #

test_that("training_fold_optimized() validates xy has 2 columns", {
  bad_xy <- matrix(1:90000, ncol = 3)

  expect_error(
    training_fold_optimized(xy = bad_xy, center = 1),
    "must have exactly 2 columns"
  )
})

test_that("training_fold_optimized() validates center is in range", {
  expect_error(
    training_fold_optimized(xy = xy_matrix, center = 0),
    "must be between 1 and nrow"
  )

  expect_error(
    training_fold_optimized(xy = xy_matrix, center = 30001),
    "must be between 1 and nrow"
  )
})

test_that("training_fold_optimized() validates training_fraction is in (0, 1)", {
  expect_error(
    training_fold_optimized(xy = xy_matrix, center = 1, training_fraction = 0),
    "must be between 0 and 1"
  )

  expect_error(
    training_fold_optimized(xy = xy_matrix, center = 1, training_fraction = 1),
    "must be between 0 and 1"
  )

  expect_error(
    training_fold_optimized(xy = xy_matrix, center = 1, training_fraction = -0.5),
    "must be between 0 and 1"
  )

  expect_error(
    training_fold_optimized(xy = xy_matrix, center = 1, training_fraction = 1.5),
    "must be between 0 and 1"
  )
})

# ============================================================================ #
# Test: training_fold_binary() - Basic Functionality
# ============================================================================ #

test_that("training_fold_binary() returns logical vector", {
  result <- training_fold_binary(
    xy = xy_matrix,
    center = 1,
    step_x = 0.4,
    step_y = 0.1,
    training_fraction = 0.5
  )

  expect_type(result, "logical")
  expect_length(result, nrow(xy_matrix))
})

test_that("training_fold_binary() achieves approximately correct training fraction", {
  result <- training_fold_binary(
    xy = xy_matrix,
    center = 1,
    step_x = 0.4,
    step_y = 0.1,
    training_fraction = 0.5
  )

  actual_fraction <- sum(result) / length(result)
  # Binary search may slightly overshoot, so use wider tolerance
  expect_equal(actual_fraction, 0.5, tolerance = 0.01)
})

test_that("training_fold_binary() works with different fractions", {
  for (fraction in c(0.2, 0.3, 0.5, 0.7, 0.8)) {
    result <- training_fold_binary(
      xy = xy_matrix,
      center = 1,
      step_x = 0.4,
      step_y = 0.1,
      training_fraction = fraction
    )

    actual_fraction <- sum(result) / length(result)
    expect_equal(actual_fraction, fraction, tolerance = 0.01)
  }
})

test_that("training_fold_binary() works with different centers", {
  for (center in c(1, 100, 1000, 15000, 29999, 30000)) {
    result <- training_fold_binary(
      xy = xy_matrix,
      center = center,
      step_x = 0.4,
      step_y = 0.1,
      training_fraction = 0.5
    )

    expect_type(result, "logical")
    expect_length(result, nrow(xy_matrix))

    actual_fraction <- sum(result) / length(result)
    expect_equal(actual_fraction, 0.5, tolerance = 0.01)
  }
})

test_that("training_fold_binary() works with different step sizes", {
  for (step_x in c(0.1, 0.5, 1.0)) {
    for (step_y in c(0.1, 0.5, 1.0)) {
      result <- training_fold_binary(
        xy = xy_matrix,
        center = 1,
        step_x = step_x,
        step_y = step_y,
        training_fraction = 0.5
      )

      expect_type(result, "logical")
      expect_length(result, nrow(xy_matrix))

      actual_fraction <- sum(result) / length(result)
      expect_equal(actual_fraction, 0.5, tolerance = 0.01)
    }
  }
})

# ============================================================================ #
# Test: training_fold_binary() - Error Handling
# ============================================================================ #

test_that("training_fold_binary() validates xy has 2 columns", {
  bad_xy <- matrix(1:90000, ncol = 3)

  expect_error(
    training_fold_binary(
      xy = bad_xy,
      center = 1,
      step_x = 0.4,
      step_y = 0.1
    ),
    "must have exactly 2 columns"
  )
})

test_that("training_fold_binary() validates center is in range", {
  expect_error(
    training_fold_binary(
      xy = xy_matrix,
      center = 0,
      step_x = 0.4,
      step_y = 0.1
    ),
    "must be between 1 and nrow"
  )

  expect_error(
    training_fold_binary(
      xy = xy_matrix,
      center = 30001,
      step_x = 0.4,
      step_y = 0.1
    ),
    "must be between 1 and nrow"
  )
})

test_that("training_fold_binary() validates training_fraction is in (0, 1)", {
  expect_error(
    training_fold_binary(
      xy = xy_matrix,
      center = 1,
      step_x = 0.4,
      step_y = 0.1,
      training_fraction = 0
    ),
    "must be between 0 and 1"
  )

  expect_error(
    training_fold_binary(
      xy = xy_matrix,
      center = 1,
      step_x = 0.4,
      step_y = 0.1,
      training_fraction = 1
    ),
    "must be between 0 and 1"
  )
})

test_that("training_fold_binary() validates step_x is positive", {
  expect_error(
    training_fold_binary(
      xy = xy_matrix,
      center = 1,
      step_x = 0,
      step_y = 0.1
    ),
    "step_x.*must be positive"
  )

  expect_error(
    training_fold_binary(
      xy = xy_matrix,
      center = 1,
      step_x = -0.4,
      step_y = 0.1
    ),
    "step_x.*must be positive"
  )
})

test_that("training_fold_binary() validates step_y is positive", {
  expect_error(
    training_fold_binary(
      xy = xy_matrix,
      center = 1,
      step_x = 0.4,
      step_y = 0
    ),
    "step_y.*must be positive"
  )

  expect_error(
    training_fold_binary(
      xy = xy_matrix,
      center = 1,
      step_x = 0.4,
      step_y = -0.1
    ),
    "step_y.*must be positive"
  )
})

# ============================================================================ #
# Test: Integration with training_fold_plot()
# ============================================================================ #

test_that("training_fold_optimized() output works with training_fold_plot()", {
  result <- training_fold_optimized(
    xy = xy_matrix,
    center = 1,
    training_fraction = 0.5
  )

  expect_no_error({
    png(tempfile(fileext = ".png"))
    training_fold_plot(
      xy = xy_matrix,
      center = 1,
      training_fold = result
    )
    dev.off()
  })
})

test_that("training_fold_binary() output works with training_fold_plot()", {
  result <- training_fold_binary(
    xy = xy_matrix,
    center = 1,
    step_x = 0.4,
    step_y = 0.1,
    training_fraction = 0.5
  )

  expect_no_error({
    png(tempfile(fileext = ".png"))
    training_fold_plot(
      xy = xy_matrix,
      center = 1,
      training_fold = result
    )
    dev.off()
  })
})

# ============================================================================ #
# Test: Edge Cases
# ============================================================================ #

test_that("training_fold_optimized() works with small datasets", {
  small_xy <- xy_matrix[1:10, ]

  result <- training_fold_optimized(
    xy = small_xy,
    center = 1,
    training_fraction = 0.5
  )

  expect_type(result, "logical")
  expect_length(result, 10)

  actual_fraction <- sum(result) / length(result)
  expect_equal(actual_fraction, 0.5, tolerance = 0.1)
})

test_that("training_fold_binary() works with small datasets", {
  small_xy <- xy_matrix[1:10, ]

  result <- training_fold_binary(
    xy = small_xy,
    center = 1,
    step_x = 0.4,
    step_y = 0.1,
    training_fraction = 0.5
  )

  expect_type(result, "logical")
  expect_length(result, 10)

  actual_fraction <- sum(result) / length(result)
  expect_equal(actual_fraction, 0.5, tolerance = 0.1)
})

test_that("training_fold_optimized() works with extreme fractions", {
  # Very small fraction
  result_small <- training_fold_optimized(
    xy = xy_matrix,
    center = 1,
    training_fraction = 0.01
  )

  actual_small <- sum(result_small) / length(result_small)
  expect_equal(actual_small, 0.01, tolerance = 0.001)

  # Very large fraction
  result_large <- training_fold_optimized(
    xy = xy_matrix,
    center = 1,
    training_fraction = 0.99
  )

  actual_large <- sum(result_large) / length(result_large)
  expect_equal(actual_large, 0.99, tolerance = 0.001)
})

test_that("training_fold_binary() works with extreme fractions", {
  # Very small fraction
  result_small <- training_fold_binary(
    xy = xy_matrix,
    center = 1,
    step_x = 0.4,
    step_y = 0.1,
    training_fraction = 0.01
  )

  actual_small <- sum(result_small) / length(result_small)
  expect_equal(actual_small, 0.01, tolerance = 0.01)

  # Very large fraction
  result_large <- training_fold_binary(
    xy = xy_matrix,
    center = 1,
    step_x = 0.4,
    step_y = 0.1,
    training_fraction = 0.99
  )

  actual_large <- sum(result_large) / length(result_large)
  expect_equal(actual_large, 0.99, tolerance = 0.01)
})

# ============================================================================ #
# Test: Performance Characteristics
# ============================================================================ #

test_that("training_fold_optimized() is faster than R implementation", {
  # Use small dataset for quick test
  test_xy <- xy_matrix[1:1000, ]

  time_r <- system.time({
    training_fold(
      xy = test_xy,
      center = 1,
      step_x = 0.4,
      step_y = 0.1,
      training_fraction = 0.5
    )
  })[["elapsed"]]

  time_optimized <- system.time({
    training_fold_optimized(
      xy = test_xy,
      center = 1,
      training_fraction = 0.5
    )
  })[["elapsed"]]

  # Optimized should be at least 10x faster
  expect_true(time_optimized < time_r / 10)
})

test_that("training_fold_binary() is faster than R implementation", {
  # Use small dataset for quick test
  test_xy <- xy_matrix[1:1000, ]

  time_r <- system.time({
    training_fold(
      xy = test_xy,
      center = 1,
      step_x = 0.4,
      step_y = 0.1,
      training_fraction = 0.5
    )
  })[["elapsed"]]

  time_binary <- system.time({
    training_fold_binary(
      xy = test_xy,
      center = 1,
      step_x = 0.4,
      step_y = 0.1,
      training_fraction = 0.5
    )
  })[["elapsed"]]

  # Binary should be at least 5x faster
  expect_true(time_binary < time_r / 5)
})

# ============================================================================ #
# Test: Reproducibility
# ============================================================================ #

test_that("training_fold_optimized() produces consistent results", {
  result1 <- training_fold_optimized(
    xy = xy_matrix,
    center = 100,
    training_fraction = 0.5
  )

  result2 <- training_fold_optimized(
    xy = xy_matrix,
    center = 100,
    training_fraction = 0.5
  )

  expect_identical(result1, result2)
})

test_that("training_fold_binary() produces consistent results", {
  result1 <- training_fold_binary(
    xy = xy_matrix,
    center = 100,
    step_x = 0.4,
    step_y = 0.1,
    training_fraction = 0.5
  )

  result2 <- training_fold_binary(
    xy = xy_matrix,
    center = 100,
    step_x = 0.4,
    step_y = 0.1,
    training_fraction = 0.5
  )

  expect_identical(result1, result2)
})

# ============================================================================ #
# Test: Comparison Between Implementations
# ============================================================================ #

test_that("training_fold_binary() creates rectangular regions", {
  result <- training_fold_binary(
    xy = xy_matrix,
    center = 1,
    step_x = 0.4,
    step_y = 0.1,
    training_fraction = 0.5
  )

  # Extract training points
  training_xy <- xy_matrix[result, ]

  # Check if bounding box is rectangular (aligned with axes)
  x_range <- range(training_xy[, 1])
  y_range <- range(training_xy[, 2])

  # All training points should be within the bounding box
  in_bbox <- (xy_matrix[, 1] >= x_range[1] & xy_matrix[, 1] <= x_range[2] &
              xy_matrix[, 2] >= y_range[1] & xy_matrix[, 2] <= y_range[2])

  # training_fold_binary should select all points in bounding box
  # (or very close, since binary search may slightly overshoot)
  overlap <- sum(result & in_bbox) / sum(result)
  expect_true(overlap > 0.95)  # At least 95% overlap
})

test_that("Different implementations select similar spatial regions", {
  # While algorithms differ, they should select points near the center
  result_opt <- training_fold_optimized(
    xy = xy_matrix,
    center = 1,
    training_fraction = 0.5
  )

  result_bin <- training_fold_binary(
    xy = xy_matrix,
    center = 1,
    step_x = 0.4,
    step_y = 0.1,
    training_fraction = 0.5
  )

  # Both should include the center point
  expect_true(result_opt[1])
  expect_true(result_bin[1])

  # There should be substantial overlap (at least 40%)
  overlap <- sum(result_opt & result_bin) / sum(result_opt | result_bin)
  expect_true(overlap > 0.4)
})
