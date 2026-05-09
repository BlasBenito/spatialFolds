test_that("validate_arg_target returns default when NULL", {
  data(xy_sf)

  result <- validate_arg_target(df = xy_sf, target = NULL)

  # Default is ceiling(nrow(df) / 2)
  expected <- ceiling(nrow(xy_sf) / 2)
  expect_equal(result, expected)
  expect_type(result, "integer")
})

test_that("validate_arg_target validates and returns user-provided target", {
  data(xy_sf)

  # Valid target in range
  result <- validate_arg_target(df = xy_sf, target = 100)
  expect_equal(result, 100L)
  expect_type(result, "integer")

  # Target at lower boundary
  result <- validate_arg_target(df = xy_sf, target = 1)
  expect_equal(result, 1L)

  # Target at upper boundary
  result <- validate_arg_target(df = xy_sf, target = nrow(xy_sf) - 1)
  expect_equal(result, as.integer(nrow(xy_sf) - 1))
})

test_that("validate_arg_target coerces numeric to integer", {
  data(xy_sf)

  # Float should be coerced to integer
  result <- validate_arg_target(df = xy_sf, target = 100.7)
  expect_equal(result, 100L)
  expect_type(result, "integer")
})

test_that("validate_arg_target errors on non-numeric target", {
  data(xy_sf)

  expect_error(
    validate_arg_target(df = xy_sf, target = "100"),
    "must be numeric"
  )

  expect_error(
    validate_arg_target(df = xy_sf, target = TRUE),
    "must be numeric"
  )

  expect_error(
    validate_arg_target(df = xy_sf, target = c("a", "b")),
    "must be numeric"
  )
})

test_that("validate_arg_target errors when target < 1", {
  data(xy_sf)

  expect_error(
    validate_arg_target(df = xy_sf, target = 0),
    "must be between 1 and nrow"
  )

  expect_error(
    validate_arg_target(df = xy_sf, target = -5),
    "must be between 1 and nrow"
  )
})

test_that("validate_arg_target errors when target >= nrow(df)", {

  data(xy_sf)

  # Target equals nrow (invalid)
  expect_error(
    validate_arg_target(df = xy_sf, target = nrow(xy_sf)),
    "must be between 1 and nrow"
  )

  # Target exceeds nrow
  expect_error(
    validate_arg_target(df = xy_sf, target = nrow(xy_sf) + 100),
    "must be between 1 and nrow"
  )
})

test_that("validate_arg_target works with data.frame input", {
  data(xy_matrix)
  df <- as.data.frame(xy_matrix)

  result <- validate_arg_target(df = df, target = 500)
  expect_equal(result, 500L)
})

test_that("validate_arg_target uses custom function_name in errors", {
  data(xy_sf)

  expect_error(
    validate_arg_target(
      df = xy_sf,
      target = "bad",
      function_name = "my_custom_function()"
    ),
    "my_custom_function\\(\\)"
  )
})

test_that("validate_arg_target handles small datasets", {
  # Minimum dataset: 2 rows (allows target = 1)
  df <- data.frame(x = c(1, 2), y = c(1, 2))

  result <- validate_arg_target(df = df, target = 1)
  expect_equal(result, 1L)

  # nrow = 2, so max target = 1
  expect_error(
    validate_arg_target(df = df, target = 2),
    "must be between 1 and nrow"
  )
})

test_that("validate_arg_target handles vectors (takes first element after coercion)", {
  data(xy_sf)

  # Vector of values - as.integer takes first
  result <- validate_arg_target(df = xy_sf, target = c(100, 200, 300))
  expect_equal(result, 100L)
})
