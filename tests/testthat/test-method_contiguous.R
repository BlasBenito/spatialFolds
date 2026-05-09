# Tests for method_contiguous_planar()
# Algorithm: Binary search for rectangle scale, selects all points within rectangle

test_that("center point is always included in result", {
  data(xy_matrix)

  # Test multiple center positions
  for (center in c(1, 100, 1000, nrow(xy_matrix))) {
    result <- method_contiguous_planar(
      xy = xy_matrix,
      center = center,
      step_x = 0.4,
      step_y = 0.1,
      target = 100
    )
    expect_true(
      result[center],
      info = paste("Center", center, "should always be selected")
    )
  }
})

test_that("selected points lie within bounding rectangle", {
  data(xy_matrix)
  center <- 5000
  step_x <- 0.5
  step_y <- 0.2
  target <- 10000

  result <- method_contiguous_planar(
    xy = xy_matrix,
    center = center,
    step_x = step_x,
    step_y = step_y,
    target = target
  )

  # Get center coordinates
  center_x <- xy_matrix[center, "x"]
  center_y <- xy_matrix[center, "y"]

  # Get selected points
  selected_x <- xy_matrix[result, "x"]
  selected_y <- xy_matrix[result, "y"]

  # Verify selection forms a rectangle: non-selected points should be outside
  non_selected_x <- xy_matrix[!result, "x"]
  non_selected_y <- xy_matrix[!result, "y"]

  # Calculate actual bounds of selected region (with small tolerance for floating point)
  tol <- 1e-9
  x_min_selected <- min(selected_x) - tol
  x_max_selected <- max(selected_x) + tol
  y_min_selected <- min(selected_y) - tol
  y_max_selected <- max(selected_y) + tol

  # Vectorized check: each non-selected point must be outside on at least one axis
  outside_x <- non_selected_x < x_min_selected | non_selected_x > x_max_selected
  outside_y <- non_selected_y < y_min_selected | non_selected_y > y_max_selected
  all_outside <- outside_x | outside_y

  expect_true(
    all(all_outside),
    info = paste(
      "Found", sum(!all_outside), "non-selected points inside the selected rectangle"
    )
  )
})

test_that("aspect ratio is respected via step_x/step_y ratio", {
  data(xy_matrix)
  center <- 15000

  # Wide rectangle (step_x >> step_y)
  wide <- method_contiguous_planar(
    xy = xy_matrix,
    center = center,
    step_x = 1.0,
    step_y = 0.1,
    target = 5000
  )

  # Tall rectangle (step_y >> step_x)
  tall <- method_contiguous_planar(
    xy = xy_matrix,
    center = center,
    step_x = 0.1,
    step_y = 1.0,
    target = 5000
  )

  center_x <- xy_matrix[center, "x"]
  center_y <- xy_matrix[center, "y"]

  # Calculate extent of each selection
  wide_dx <- max(abs(xy_matrix[wide, "x"] - center_x))
  wide_dy <- max(abs(xy_matrix[wide, "y"] - center_y))
  tall_dx <- max(abs(xy_matrix[tall, "x"] - center_x))
  tall_dy <- max(abs(xy_matrix[tall, "y"] - center_y))

  # Wide selection should have larger x extent relative to y
  # Tall selection should have larger y extent relative to x
  wide_ratio <- wide_dx / (wide_dy + 1e-10)  # avoid div by zero

tall_ratio <- tall_dx / (tall_dy + 1e-10)

  expect_true(
    wide_ratio > tall_ratio,
    info = "Wide rectangle should have larger x/y ratio than tall rectangle"
  )
})

test_that("function is deterministic (no randomness)", {
  data(xy_matrix)

  result1 <- method_contiguous_planar(
    xy = xy_matrix,
    center = 1000,
    step_x = 0.4,
    step_y = 0.1,
    target = 15000
  )

  result2 <- method_contiguous_planar(
    xy = xy_matrix,
    center = 1000,
    step_x = 0.4,
    step_y = 0.1,
    target = 15000
  )

  expect_identical(result1, result2)
})

test_that("different center produces different selection", {
  data(xy_matrix)

  result1 <- method_contiguous_planar(
    xy = xy_matrix,
    center = 1,
    step_x = 0.4,
    step_y = 0.1,
    target = 10000
  )

  result2 <- method_contiguous_planar(
    xy = xy_matrix,
    center = 15000,
    step_x = 0.4,
    step_y = 0.1,
    target = 10000
  )

  expect_false(identical(result1, result2))
})

test_that("edge case: target = 1 selects only center (or minimal rectangle)", {
  data(xy_matrix)
  center <- 5000

  result <- method_contiguous_planar(
    xy = xy_matrix,
    center = center,
    step_x = 0.4,
    step_y = 0.1,
    target = 1
  )

  # Center must be included
  expect_true(result[center])

  # Should select minimal number of points (at least 1)
  expect_true(sum(result) >= 1)
})

test_that("edge case: target > n selects all points", {
  data(xy_matrix)
  n <- nrow(xy_matrix)

  result <- method_contiguous_planar(
    xy = xy_matrix,
    center = 1,
    step_x = 0.4,
    step_y = 0.1,
    target = n + 1000
  )

  # Should select all points when target exceeds n
  expect_equal(sum(result), n)
})

test_that("edge case: empty input returns empty result", {
  empty_matrix <- matrix(numeric(0), ncol = 2)
  colnames(empty_matrix) <- c("x", "y")

  result <- method_contiguous_planar(
    xy = empty_matrix,
    center = 1,
    step_x = 0.4,
    step_y = 0.1,
    target = 10
  )

  expect_equal(length(result), 0)
})

test_that("error: center out of bounds throws error", {
  data(xy_matrix)
  n <- nrow(xy_matrix)

  # Center = 0 (invalid)
  expect_error(
    method_contiguous_planar(
      xy = xy_matrix,
      center = 0,
      step_x = 0.4,
      step_y = 0.1,
      target = 100
    ),
    "center index.*out of bounds"
  )

  # Center > n (invalid)
  expect_error(
    method_contiguous_planar(
      xy = xy_matrix,
      center = n + 1,
      step_x = 0.4,
      step_y = 0.1,
      target = 100
    ),
    "center index.*out of bounds"
  )
})

test_that("works with projected CRS coordinates (meter scale)", {
  set.seed(42)
  n <- 500
  x_utm <- runif(n, 490000, 510000)
  y_utm <- runif(n, 4490000, 4510000)
  xy_utm <- cbind(x = x_utm, y = y_utm)

  center <- 1
  result <- method_contiguous_planar(
    xy = xy_utm,
    center = center,
    step_x = 2000,
    step_y = 2000,
    target = 100
  )

  expect_true(result[center])
  expect_true(sum(result) >= 100)

  selected_x <- xy_utm[result, "x"]
  selected_y <- xy_utm[result, "y"]
  non_selected_x <- xy_utm[!result, "x"]
  non_selected_y <- xy_utm[!result, "y"]

  tol <- 1e-6
  x_min_s <- min(selected_x) - tol
  x_max_s <- max(selected_x) + tol
  y_min_s <- min(selected_y) - tol
  y_max_s <- max(selected_y) + tol

  outside_x <- non_selected_x < x_min_s | non_selected_x > x_max_s
  outside_y <- non_selected_y < y_min_s | non_selected_y > y_max_s
  expect_true(all(outside_x | outside_y))
})
