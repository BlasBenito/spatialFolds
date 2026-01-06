# ============================================================================ #
# Comprehensive Test Suite for training_fold_cpp() Function
# ============================================================================ #
#
# This test suite ensures the C++ implementation produces identical results
# to the R version and handles all edge cases correctly.
#
# ============================================================================ #

# Load data
data(xy_matrix, package = "spatialFolds")

# ============================================================================ #
# SECTION 1: CORRECTNESS - R vs C++ EQUIVALENCE
# ============================================================================ #

test_that("training_fold_cpp produces identical results to training_fold", {
  # Setup: Run both versions with same inputs
  params <- list(
    xy = xy_matrix,
    center = 1,
    step_x = 0.4,
    step_y = 0.1,
    training_fraction = 0.5
  )

  result_r <- do.call(training_fold, params)
  result_cpp <- do.call(training_fold_cpp, params)

  # Expectations: Identical results
  expect_identical(result_r, result_cpp)
  expect_identical(class(result_r), class(result_cpp))
  expect_identical(length(result_r), length(result_cpp))
  expect_identical(sum(result_r), sum(result_cpp))
})


test_that("training_fold_cpp matches R version across multiple centers", {
  # Test with different center points
  centers <- c(1, 100, 1000, 15000, 29999)

  for (center in centers) {
    result_r <- training_fold(
      xy = xy_matrix,
      center = center,
      step_x = 0.5,
      step_y = 0.2,
      training_fraction = 0.7
    )

    result_cpp <- training_fold_cpp(
      xy = xy_matrix,
      center = center,
      step_x = 0.5,
      step_y = 0.2,
      training_fraction = 0.7
    )

    expect_identical(result_r, result_cpp)
  }
})


test_that("training_fold_cpp matches R version with different training fractions", {
  # Test various training fractions
  fractions <- c(0.1, 0.25, 0.5, 0.75, 0.9)

  for (frac in fractions) {
    result_r <- training_fold(
      xy = xy_matrix,
      center = 1,
      step_x = 0.4,
      step_y = 0.1,
      training_fraction = frac
    )

    result_cpp <- training_fold_cpp(
      xy = xy_matrix,
      center = 1,
      step_x = 0.4,
      step_y = 0.1,
      training_fraction = frac
    )

    expect_identical(result_r, result_cpp)
  }
})


test_that("training_fold_cpp matches R version with different step sizes", {
  # Test various step size combinations
  step_combinations <- list(
    list(step_x = 0.1, step_y = 0.1),
    list(step_x = 1.0, step_y = 1.0),
    list(step_x = 0.01, step_y = 0.5),
    list(step_x = 2.0, step_y = 0.1)
  )

  for (steps in step_combinations) {
    result_r <- training_fold(
      xy = xy_matrix,
      center = 500,
      step_x = steps$step_x,
      step_y = steps$step_y,
      training_fraction = 0.6
    )

    result_cpp <- training_fold_cpp(
      xy = xy_matrix,
      center = 500,
      step_x = steps$step_x,
      step_y = steps$step_y,
      training_fraction = 0.6
    )

    expect_identical(result_r, result_cpp)
  }
})


# ============================================================================ #
# SECTION 2: SUCCESS CASES - Valid Inputs
# ============================================================================ #

test_that("training_fold_cpp works with default training_fraction", {
  # Test default parameter
  result <- training_fold_cpp(
    xy = xy_matrix,
    center = 1,
    step_x = 0.4,
    step_y = 0.1
  )

  expect_type(result, "logical")
  expect_length(result, nrow(xy_matrix))
  expect_true(sum(result) > 0)
  expect_true(sum(result) < nrow(xy_matrix))

  # Should be close to 0.8 (default)
  training_prop <- sum(result) / length(result)
  expect_true(training_prop >= 0.75 && training_prop <= 0.85)
})


test_that("training_fold_cpp handles small matrices", {
  # Edge case: small number of points
  small_xy <- matrix(c(1, 2, 3, 4, 5, 6), ncol = 2)

  result <- training_fold_cpp(
    xy = small_xy,
    center = 1,
    step_x = 1,
    step_y = 1,
    training_fraction = 0.5
  )

  expect_type(result, "logical")
  expect_length(result, 3)
  expect_true(sum(result) >= 1)  # At least one training point
})


test_that("training_fold_cpp handles different step sizes", {
  # Very small steps
  result1 <- training_fold_cpp(
    xy = xy_matrix,
    center = 1000,
    step_x = 0.01,
    step_y = 0.01,
    training_fraction = 0.5
  )

  # Very large steps
  result2 <- training_fold_cpp(
    xy = xy_matrix,
    center = 1000,
    step_x = 10,
    step_y = 10,
    training_fraction = 0.5
  )

  expect_type(result1, "logical")
  expect_type(result2, "logical")

  # Both should achieve target training fraction
  expect_true(abs(sum(result1) / length(result1) - 0.5) < 0.05)
  expect_true(abs(sum(result2) / length(result2) - 0.5) < 0.05)
})


# ============================================================================ #
# SECTION 3: ERROR CASES - Invalid Inputs
# ============================================================================ #

test_that("training_fold_cpp errors with wrong number of columns", {
  # Matrix with 3 columns instead of 2
  bad_xy <- matrix(1:30, ncol = 3)

  expect_error(
    training_fold_cpp(
      xy = bad_xy,
      center = 1,
      step_x = 0.4,
      step_y = 0.1
    ),
    "must have exactly 2 columns"
  )
})


test_that("training_fold_cpp errors with wrong number of columns (1 column)", {
  # Matrix with only 1 column
  bad_xy <- matrix(1:10, ncol = 1)

  expect_error(
    training_fold_cpp(
      xy = bad_xy,
      center = 1,
      step_x = 0.4,
      step_y = 0.1
    ),
    "must have exactly 2 columns"
  )
})


test_that("training_fold_cpp errors with invalid center index (too small)", {
  # Center = 0 (invalid)
  expect_error(
    training_fold_cpp(
      xy = xy_matrix,
      center = 0,
      step_x = 0.4,
      step_y = 0.1
    ),
    "must be between 1 and"
  )
})


test_that("training_fold_cpp errors with invalid center index (too large)", {
  # Center beyond matrix size
  expect_error(
    training_fold_cpp(
      xy = xy_matrix,
      center = nrow(xy_matrix) + 1,
      step_x = 0.4,
      step_y = 0.1
    ),
    "must be between 1 and"
  )
})


test_that("training_fold_cpp errors with invalid training_fraction (zero)", {
  # Fraction = 0
  expect_error(
    training_fold_cpp(
      xy = xy_matrix,
      center = 1,
      step_x = 0.4,
      step_y = 0.1,
      training_fraction = 0
    ),
    "must be between 0 and 1"
  )
})


test_that("training_fold_cpp errors with invalid training_fraction (one)", {
  # Fraction = 1
  expect_error(
    training_fold_cpp(
      xy = xy_matrix,
      center = 1,
      step_x = 0.4,
      step_y = 0.1,
      training_fraction = 1
    ),
    "must be between 0 and 1"
  )
})


test_that("training_fold_cpp errors with invalid training_fraction (negative)", {
  # Negative fraction
  expect_error(
    training_fold_cpp(
      xy = xy_matrix,
      center = 1,
      step_x = 0.4,
      step_y = 0.1,
      training_fraction = -0.5
    ),
    "must be between 0 and 1"
  )
})


test_that("training_fold_cpp errors with invalid training_fraction (>1)", {
  # Fraction > 1
  expect_error(
    training_fold_cpp(
      xy = xy_matrix,
      center = 1,
      step_x = 0.4,
      step_y = 0.1,
      training_fraction = 1.5
    ),
    "must be between 0 and 1"
  )
})


test_that("training_fold_cpp errors with invalid step_x (zero)", {
  # step_x = 0
  expect_error(
    training_fold_cpp(
      xy = xy_matrix,
      center = 1,
      step_x = 0,
      step_y = 0.1,
      training_fraction = 0.5
    ),
    "must be positive"
  )
})


test_that("training_fold_cpp errors with invalid step_x (negative)", {
  # Negative step_x
  expect_error(
    training_fold_cpp(
      xy = xy_matrix,
      center = 1,
      step_x = -0.4,
      step_y = 0.1,
      training_fraction = 0.5
    ),
    "must be positive"
  )
})


test_that("training_fold_cpp errors with invalid step_y (zero)", {
  # step_y = 0
  expect_error(
    training_fold_cpp(
      xy = xy_matrix,
      center = 1,
      step_x = 0.4,
      step_y = 0,
      training_fraction = 0.5
    ),
    "must be positive"
  )
})


test_that("training_fold_cpp errors with invalid step_y (negative)", {
  # Negative step_y
  expect_error(
    training_fold_cpp(
      xy = xy_matrix,
      center = 1,
      step_x = 0.4,
      step_y = -0.1,
      training_fraction = 0.5
    ),
    "must be positive"
  )
})


# ============================================================================ #
# SECTION 4: EDGE CASES - Boundary Conditions
# ============================================================================ #

test_that("training_fold_cpp handles center at edge of data (min x)", {
  # Find a point at the spatial edge (minimum x)
  edge_idx <- which.min(xy_matrix[, "x"])

  result <- training_fold_cpp(
    xy = xy_matrix,
    center = edge_idx,
    step_x = 0.4,
    step_y = 0.1,
    training_fraction = 0.5
  )

  expect_type(result, "logical")
  expect_length(result, nrow(xy_matrix))
  expect_true(sum(result) > 0)
})


test_that("training_fold_cpp handles center at edge of data (max x)", {
  # Find a point at the spatial edge (maximum x)
  edge_idx <- which.max(xy_matrix[, "x"])

  result <- training_fold_cpp(
    xy = xy_matrix,
    center = edge_idx,
    step_x = 0.4,
    step_y = 0.1,
    training_fraction = 0.5
  )

  expect_type(result, "logical")
  expect_length(result, nrow(xy_matrix))
  expect_true(sum(result) > 0)
})


test_that("training_fold_cpp handles extreme training fractions (very small)", {
  # Very small fraction (1%)
  result <- training_fold_cpp(
    xy = xy_matrix,
    center = 1,
    step_x = 0.4,
    step_y = 0.1,
    training_fraction = 0.01
  )

  training_prop <- sum(result) / length(result)
  expect_true(training_prop < 0.02)  # Should be close to 1%
  expect_true(sum(result) > 0)  # But at least some points
})


test_that("training_fold_cpp handles extreme training fractions (very large)", {
  # Very large fraction (99%)
  result <- training_fold_cpp(
    xy = xy_matrix,
    center = 1,
    step_x = 0.4,
    step_y = 0.1,
    training_fraction = 0.99
  )

  training_prop <- sum(result) / length(result)
  expect_true(training_prop > 0.98)  # Should be close to 99%
  expect_true(sum(!result) > 0)  # But at least some test points
})


test_that("training_fold_cpp handles asymmetric step sizes (x >> y)", {
  # x step much larger than y step
  result <- training_fold_cpp(
    xy = xy_matrix,
    center = 1000,
    step_x = 10,
    step_y = 0.1,
    training_fraction = 0.5
  )

  expect_type(result, "logical")
  expect_length(result, nrow(xy_matrix))

  # Should still achieve target fraction
  training_prop <- sum(result) / length(result)
  expect_true(abs(training_prop - 0.5) < 0.05)
})


test_that("training_fold_cpp handles asymmetric step sizes (y >> x)", {
  # y step much larger than x step
  result <- training_fold_cpp(
    xy = xy_matrix,
    center = 1000,
    step_x = 0.1,
    step_y = 10,
    training_fraction = 0.5
  )

  expect_type(result, "logical")
  expect_length(result, nrow(xy_matrix))

  # Should still achieve target fraction
  training_prop <- sum(result) / length(result)
  expect_true(abs(training_prop - 0.5) < 0.05)
})


# ============================================================================ #
# SECTION 5: RETURN VALUE VERIFICATION
# ============================================================================ #

test_that("training_fold_cpp returns correct type and structure", {
  # Test return value structure
  result <- training_fold_cpp(
    xy = xy_matrix,
    center = 1,
    step_x = 0.4,
    step_y = 0.1,
    training_fraction = 0.5
  )

  # Type checks
  expect_type(result, "logical")
  expect_true(is.logical(result))
  expect_false(is.numeric(result))

  # Length check
  expect_length(result, nrow(xy_matrix))

  # Content checks
  expect_true(any(result))  # Some TRUE values
  expect_true(any(!result))  # Some FALSE values

  # Proportion check
  training_prop <- sum(result) / length(result)
  expect_true(training_prop >= 0.45 && training_prop <= 0.55)  # Close to 0.5
})


test_that("training_fold_cpp result has correct attributes", {
  # Verify result has no unexpected attributes
  result <- training_fold_cpp(
    xy = xy_matrix,
    center = 1,
    step_x = 0.4,
    step_y = 0.1,
    training_fraction = 0.5
  )

  # Should be a simple logical vector with no special attributes
  expect_null(names(result))
  expect_null(dim(result))
})


# ============================================================================ #
# SECTION 6: INTEGRATION AND PERFORMANCE
# ============================================================================ #

test_that("training_fold_cpp works with training_fold_plot", {
  # Verify it integrates with existing visualization function
  result <- training_fold_cpp(
    xy = xy_matrix,
    center = 1,
    step_x = 0.4,
    step_y = 0.1,
    training_fraction = 0.5
  )

  # Should not error when passed to plot function
  expect_silent({
    training_fold_plot(
      xy = xy_matrix,
      center = 1,
      training_fold = result
    )
  })
})


test_that("training_fold_cpp is faster than training_fold", {
  skip_on_cran()  # Skip on CRAN to avoid timeout

  # Use subset of data for reasonable test time
  test_xy <- xy_matrix[1:5000, ]

  # Time R version
  time_r <- system.time({
    for (i in 1:10) {
      training_fold(
        xy = test_xy,
        center = 1,
        step_x = 0.4,
        step_y = 0.1,
        training_fraction = 0.5
      )
    }
  })

  # Time C++ version
  time_cpp <- system.time({
    for (i in 1:10) {
      training_fold_cpp(
        xy = test_xy,
        center = 1,
        step_x = 0.4,
        step_y = 0.1,
        training_fraction = 0.5
      )
    }
  })

  # C++ should be at least 2x faster
  speedup <- time_r["elapsed"] / time_cpp["elapsed"]
  expect_gt(speedup, 2.0)

  message(sprintf("Speedup: %.2fx", speedup))
})


# ============================================================================ #
# BEST PRACTICES DEMONSTRATED:
# - Comprehensive coverage of correctness (R vs C++)
# - All error conditions tested with descriptive expectations
# - Edge cases for boundary conditions
# - Return value structure verification
# - Integration testing with existing functions
# - Performance verification
# ============================================================================ #
