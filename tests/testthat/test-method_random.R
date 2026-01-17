# Placeholder test file
test_that("method_random() works", {
  data(xy_matrix)

  y <- method_random(
    xy = xy_matrix,
    seed = 1,
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

  z <- method_random(
    xy = xy_matrix,
    seed = 1000,
    target = 15000
  )

  testthat::expect_false(
    all(y == z)
  )
})
