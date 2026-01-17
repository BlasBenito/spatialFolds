test_that("training_mask() works with contiguous method", {
  data(xy_matrix)

  result <- training_mask(
    xy = xy_matrix,
    method = "contiguous",
    center = 1,
    step_x = 0.4,
    step_y = 0.1,
    target = 15000
  )

  expect_true(is.logical(result))
  expect_equal(length(result), nrow(xy_matrix))
  expect_true(sum(result) >= 15000)
})

test_that("training_mask() works with random method", {
  data(xy_matrix)

  result <- training_mask(
    xy = xy_matrix,
    method = "random",
    seed = 123,
    target = 15000
  )

  expect_true(is.logical(result))
  expect_equal(length(result), nrow(xy_matrix))
  expect_equal(sum(result), 15000)
})

test_that("training_mask() works with blocks method", {
  data(xy_sf)

  xy <- cast_sf_to_xy(xy_sf)
  block_id <- block_ids(xy_sf, rows = 10, cols = 10)

  result <- training_mask(
    xy = xy,
    method = "blocks",
    block_id = block_id,
    seed = 123,
    target = 15000
  )

  expect_true(is.logical(result))
  expect_equal(length(result), nrow(xy))
  expect_true(sum(result) >= 15000)
})

test_that("training_mask() matches method argument correctly", {
  data(xy_matrix)

  xy_subset <- xy_matrix[1:100, ]

  # Test partial matching works
  result <- training_mask(
    xy = xy_subset,
    method = "rand",
    seed = 1,
    target = 50
  )

  expect_true(is.logical(result))
  expect_equal(length(result), 100)
})

test_that("training_mask() produces different results for different methods", {
  data(xy_matrix)

  xy_subset <- xy_matrix[1:500, ]

  contiguous_result <- training_mask(
    xy = xy_subset,
    method = "contiguous",
    center = 1,
    step_x = 0.1,
    step_y = 0.1,
    target = 250
  )

  random_result <- training_mask(
    xy = xy_subset,
    method = "random",
    seed = 1,
    target = 250
  )

  # Results should be different
  expect_false(identical(contiguous_result, random_result))
})

test_that("training_mask() random method is reproducible with same seed", {
  data(xy_matrix)

  xy_subset <- xy_matrix[1:500, ]

  result1 <- training_mask(
    xy = xy_subset,
    method = "random",
    seed = 42,
    target = 250
  )

  result2 <- training_mask(
    xy = xy_subset,
    method = "random",
    seed = 42,
    target = 250
  )

  expect_identical(result1, result2)
})

test_that("training_mask() random method differs with different seeds", {
  data(xy_matrix)

  xy_subset <- xy_matrix[1:500, ]

  result1 <- training_mask(
    xy = xy_subset,
    method = "random",
    seed = 42,
    target = 250
  )

  result2 <- training_mask(
    xy = xy_subset,
    method = "random",
    seed = 123,
    target = 250
  )

  expect_false(identical(result1, result2))
})
