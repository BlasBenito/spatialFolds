# Tests for utils_needs_spherical() and cast_xy_to_xyz()

test_that("utils_needs_spherical() returns FALSE for local data", {
  # Local data in Europe - should not need spherical
  local_xy <- cbind(
    x = runif(100, -10, 10),
    y = runif(100, 40, 50)
  )

  testthat::expect_false(utils_needs_spherical(local_xy))
})

test_that("utils_needs_spherical() returns TRUE for dateline data", {
  # Data near dateline - should need spherical
  dateline_xy <- cbind(
    x = runif(100, 160, 180),
    y = runif(100, -20, 20)
  )

  testthat::expect_true(utils_needs_spherical(dateline_xy))

  # Data crossing dateline - should need spherical
  cross_dateline_xy <- cbind(
    x = c(runif(50, 170, 180), runif(50, -180, -170)),
    y = runif(100, -20, 20)
  )

  testthat::expect_true(utils_needs_spherical(cross_dateline_xy))
})

test_that("utils_needs_spherical() returns TRUE for polar data", {
  # Data near north pole - should need spherical
  north_polar_xy <- cbind(
    x = runif(100, -180, 180),
    y = runif(100, 75, 90)
  )

  testthat::expect_true(utils_needs_spherical(north_polar_xy))

  # Data near south pole - should need spherical
  south_polar_xy <- cbind(
    x = runif(100, -180, 180),
    y = runif(100, -90, -75)
  )

  testthat::expect_true(utils_needs_spherical(south_polar_xy))
})

test_that("utils_needs_spherical() validates input", {
  # Should error on non-matrix/data.frame input
  testthat::expect_error(
    utils_needs_spherical(c(1, 2, 3)),
    "must be a matrix or data frame"
  )

  # Should error on single column
  testthat::expect_error(
    utils_needs_spherical(matrix(1:10, ncol = 1)),
    "must have at least 2 columns"
  )
})

test_that("cast_xy_to_xyz() produces correct dimensions", {
  xy <- cbind(x = 1:10, y = 1:10)
  xyz <- cast_xy_to_xyz(xy)

  testthat::expect_equal(ncol(xyz), 3)
  testthat::expect_equal(nrow(xyz), 10)
  testthat::expect_equal(colnames(xyz), c("x", "y", "z"))
})

test_that("cast_xy_to_xyz() produces unit sphere coordinates", {
  # Create test coordinates
  xy <- cbind(
    x = c(0, 90, 180, -90, 0, 0),
    y = c(0, 0, 0, 0, 90, -90)
  )

  xyz <- cast_xy_to_xyz(xy)

  # Check that all points are on unit sphere (x^2 + y^2 + z^2 = 1)
  radii <- sqrt(rowSums(xyz^2))
  testthat::expect_equal(radii, rep(1, 6), tolerance = 1e-10)
})

test_that("cast_xy_to_xyz() handles equator correctly", {
  # Points on equator at 0, 90, 180, -90 degrees longitude
  xy <- cbind(
    x = c(0, 90, 180, -90),
    y = c(0, 0, 0, 0)
  )

  xyz <- cast_xy_to_xyz(xy)

  # lon=0, lat=0 -> (1, 0, 0)
  testthat::expect_equal(xyz[1, ], c(x = 1, y = 0, z = 0), tolerance = 1e-10)

  # lon=90, lat=0 -> (0, 1, 0)
  testthat::expect_equal(xyz[2, ], c(x = 0, y = 1, z = 0), tolerance = 1e-10)

  # lon=180, lat=0 -> (-1, 0, 0)
  testthat::expect_equal(xyz[3, ], c(x = -1, y = 0, z = 0), tolerance = 1e-10)

  # lon=-90, lat=0 -> (0, -1, 0)
  testthat::expect_equal(xyz[4, ], c(x = 0, y = -1, z = 0), tolerance = 1e-10)
})

test_that("cast_xy_to_xyz() handles poles correctly", {
  # North and south poles
  xy <- cbind(
    x = c(0, 45, 90, 180),  # longitude doesn't matter at pole
    y = c(90, 90, 90, 90)   # all at north pole
  )

  xyz <- cast_xy_to_xyz(xy)

  # All points at north pole should be (0, 0, 1)
  for (i in 1:4) {
    testthat::expect_equal(unname(xyz[i, "z"]), 1, tolerance = 1e-10)
    testthat::expect_equal(abs(unname(xyz[i, "x"])), 0, tolerance = 1e-10)
    testthat::expect_equal(abs(unname(xyz[i, "y"])), 0, tolerance = 1e-10)
  }

  # South pole
  xy_south <- cbind(x = c(0, 90), y = c(-90, -90))
  xyz_south <- cast_xy_to_xyz(xy_south)

  for (i in 1:2) {
    testthat::expect_equal(unname(xyz_south[i, "z"]), -1, tolerance = 1e-10)
  }
})

test_that("cast_xy_to_xyz() validates input", {
  # Should error on non-matrix/data.frame input
  testthat::expect_error(
    cast_xy_to_xyz(c(1, 2, 3)),
    "must be a matrix or data frame"
  )

  # Should error on single column
  testthat::expect_error(
    cast_xy_to_xyz(matrix(1:10, ncol = 1)),
    "must have at least 2 columns"
  )
})
