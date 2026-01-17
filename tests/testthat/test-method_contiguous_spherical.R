# Tests for method_contiguous_spherical()

test_that("method_contiguous_spherical() works with basic input", {
  # Create test data near north pole
  set.seed(123)
  polar_xy <- cbind(
    x = runif(500, -180, 180),
    y = runif(500, 70, 90)
  )

  xyz <- cast_xy_to_xyz(polar_xy)

  result <- method_contiguous_spherical(
    xyz = xyz,
    center = 1,
    angular_step = 0.01,
    target = 250
  )

  testthat::expect_true(is.logical(result))
  testthat::expect_equal(length(result), 500)
  testthat::expect_true(sum(result) >= 250)
  testthat::expect_true(result[1])  # center should be in fold
})

test_that("method_contiguous_spherical() includes center point", {
  set.seed(456)
  xy <- cbind(
    x = runif(100, -180, 180),
    y = runif(100, -90, 90)
  )

  xyz <- cast_xy_to_xyz(xy)

  # Test with different center points
  for (center in c(1, 50, 100)) {
    result <- method_contiguous_spherical(
      xyz = xyz,
      center = center,
      angular_step = 0.01,
      target = 50
    )

    testthat::expect_true(result[center])
  }
})

test_that("method_contiguous_spherical() handles dateline correctly", {
  # Create data spanning dateline
  set.seed(789)
  dateline_xy <- cbind(
    x = c(runif(50, 170, 180), runif(50, -180, -170)),
    y = runif(100, -10, 10)
  )

  xyz <- cast_xy_to_xyz(dateline_xy)

  # Center at point near lon=175 (should include points on both sides)
  center_idx <- which.min(abs(dateline_xy[, 1] - 175))

  result <- method_contiguous_spherical(
    xyz = xyz,
    center = center_idx,
    angular_step = 0.01,
    target = 80
  )

  testthat::expect_true(is.logical(result))
  testthat::expect_true(sum(result) >= 80)

  # Check that points from both sides of dateline are included
  east_side <- which(dateline_xy[, 1] > 0)
  west_side <- which(dateline_xy[, 1] < 0)

  # If the fold is large enough, it should include points from both sides
  if (sum(result) > 60) {
    testthat::expect_true(any(result[east_side]))
    testthat::expect_true(any(result[west_side]))
  }
})

test_that("method_contiguous_spherical() creates spherical cap at pole", {
  # Create data at north pole
  set.seed(101)
  n <- 200
  polar_xy <- cbind(
    x = runif(n, -180, 180),
    y = runif(n, 85, 90)  # Very near pole
  )

  xyz <- cast_xy_to_xyz(polar_xy)

  # Find point closest to pole
  center_idx <- which.max(polar_xy[, 2])

  result <- method_contiguous_spherical(
    xyz = xyz,
    center = center_idx,
    angular_step = 0.005,
    target = 100
  )

  testthat::expect_true(sum(result) >= 100)

  # At the pole, selected points should come from all longitudes
  # (unlike planar method which would form a rectangle)
  selected_lons <- polar_xy[result, 1]

  # Check that selected points span a wide range of longitudes
  lon_range <- diff(range(selected_lons))
  testthat::expect_gt(lon_range, 90)  # Should span at least 90 degrees
})

test_that("method_contiguous_spherical() different centers produce different folds", {
  set.seed(202)
  xy <- cbind(
    x = runif(200, -180, 180),
    y = runif(200, -60, 60)
  )

  xyz <- cast_xy_to_xyz(xy)

  result1 <- method_contiguous_spherical(
    xyz = xyz,
    center = 1,
    angular_step = 0.01,
    target = 100
  )

  result2 <- method_contiguous_spherical(
    xyz = xyz,
    center = 100,
    angular_step = 0.01,
    target = 100
  )

  # Different centers should produce different folds
  testthat::expect_false(all(result1 == result2))
})
