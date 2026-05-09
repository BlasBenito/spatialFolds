test_that("validate_arg_distance auto-calculates when NULL", {
  data(xy_sf)

  expect_message(
    result <- validate_arg_distance(df = xy_sf, distance = NULL),
    "Auto-calculated distance"
  )

  # Should return a positive numeric value
  expect_type(result, "double")
  expect_true(result > 0)

  # Formula: 0.5 * sqrt(bbox_area / nrow(df))
  df_bbox <- sf::st_bbox(xy_sf)
  x_range <- diff(df_bbox[c("xmin", "xmax")])
  y_range <- diff(df_bbox[c("ymin", "ymax")])
  bbox_area <- x_range * y_range
  expected <- 0.5 * sqrt(bbox_area / nrow(xy_sf))

  expect_equal(result, expected, tolerance = 1e-10)
})

test_that("validate_arg_distance returns user-provided distance", {
  data(xy_sf)

  # Valid positive distance
  result <- validate_arg_distance(df = xy_sf, distance = 5.5)
  expect_equal(result, 5.5)

  # Zero distance
  result <- validate_arg_distance(df = xy_sf, distance = 0)
  expect_equal(result, 0)

  # Integer distance
  result <- validate_arg_distance(df = xy_sf, distance = 10L)
  expect_equal(result, 10)
})

test_that("validate_arg_distance errors on negative distance", {
  data(xy_sf)

  expect_error(
    validate_arg_distance(df = xy_sf, distance = -1),
    "must be >= 0"
  )

  expect_error(
    validate_arg_distance(df = xy_sf, distance = -0.001),
    "must be >= 0"
  )
})

test_that("validate_arg_distance errors on non-numeric distance", {
  data(xy_sf)

  expect_error(
    validate_arg_distance(df = xy_sf, distance = "10"),
    "must be numeric"
  )

  expect_error(
    validate_arg_distance(df = xy_sf, distance = TRUE),
    "must be numeric"
  )
})

test_that("validate_arg_distance takes first value when length > 1", {
  data(xy_sf)

  # Should take first value
  result <- validate_arg_distance(df = xy_sf, distance = c(1.5, 2.5, 3.5))
  expect_equal(result, 1.5)
})

test_that("validate_arg_distance works with data.frame input", {
  data(xy_matrix)
  df <- as.data.frame(xy_matrix)

  # Need to convert to sf first (as the actual function expects sf)
  df_sf <- cast_df_to_sf(df)

  result <- validate_arg_distance(df = df_sf, distance = 2.0)
  expect_equal(result, 2.0)
})

test_that("validate_arg_distance uses custom function_name in errors", {
  data(xy_sf)

  expect_error(
    validate_arg_distance(
      df = xy_sf,
      distance = "bad",
      function_name = "my_custom_function()"
    ),
    "my_custom_function\\(\\)"
  )
})

test_that("validate_arg_distance uses custom function_name in messages", {
  data(xy_sf)

  expect_message(
    result <- validate_arg_distance(
      df = xy_sf,
      distance = NULL,
      function_name = "my_custom_function()"
    ),
    "my_custom_function\\(\\)"
  )
})

test_that("validate_arg_distance handles controlled grid dataset", {
  # Create 10x10 grid (100 points, bbox area = 81)
  df <- expand.grid(x = 0:9, y = 0:9)
  df_sf <- cast_df_to_sf(df)

  expect_message(
    result <- validate_arg_distance(df = df_sf, distance = NULL),
    "Auto-calculated distance"
  )

  # bbox_area = 9 * 9 = 81, n = 100
  # distance = 0.5 * sqrt(81 / 100) = 0.5 * 0.9 = 0.45
  expect_equal(as.numeric(result), 0.45, tolerance = 1e-10)
})
