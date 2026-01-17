# Tests for method_contiguous_planar()
test_that("method_contiguous_planar() works", {
  data(xy_matrix)

  y <- method_contiguous_planar(
    xy = xy_matrix,
    center = 1,
    step_x = 0.4,
    step_y = 0.1,
    target = 15000
  )

  testthat::expect_true(
    is.logical(y)
  )

  testthat::expect_true(
    length(y) == nrow(xy_matrix)
  )

  testthat::expect_true(
    sum(y) >= 15000
  )

  testthat::expect_true(
    y[1]
  )

  z <- method_contiguous_planar(
    xy = xy_matrix,
    center = 15000,
    step_x = 0.4,
    step_y = 0.1,
    target = 15000
  )

  testthat::expect_false(
    all(y == z)
  )
})
