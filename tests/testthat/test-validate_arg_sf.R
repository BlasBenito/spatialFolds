test_that("validate_arg_sf() errors on NULL input", {
  expect_error(
    validate_arg_sf(df = NULL, function_name = "test_fn"),
    "argument 'df' cannot be NULL"
  )
})

test_that("validate_arg_sf() errors on empty data frame", {
  data(xy_sf)

  expect_error(
    validate_arg_sf(df = xy_sf[0, ], function_name = "test_fn"),
    "has no rows"
  )
})

test_that("validate_arg_sf() validates minimum rows", {
  data(xy_sf)

  # Should error when fewer than min_rows
  expect_error(
    validate_arg_sf(
      df = xy_sf[1:5, ],
      function_name = "test_fn",
      min_rows = 10L
    ),
    "must have at least 10 rows"
  )

  # Should pass when at or above min_rows
  result <- validate_arg_sf(
    df = xy_sf[1:10, ],
    function_name = "test_fn",
    min_rows = 10L
  )
  expect_s3_class(result, "sf")
  expect_equal(nrow(result), 10)
})

test_that("validate_arg_sf() returns sf object for sf input", {
  data(xy_sf)

  result <- validate_arg_sf(
    df = xy_sf[1:100, ],
    function_name = "test_fn"
  )

  # Check return type is sf
  expect_s3_class(result, "sf")
  expect_equal(nrow(result), 100)
})

test_that("validate_arg_sf() converts data.frame to sf", {
  df <- data.frame(x = runif(100), y = runif(100))

  result <- validate_arg_sf(df = df, function_name = "test_fn")

  # Check df is converted to sf
  expect_s3_class(result, "sf")
  expect_equal(nrow(result), 100)
})

test_that("validate_arg_sf() validates coordinate ranges when enabled", {
  # Create data with identical x coordinates
  df_identical_x <- data.frame(x = rep(0, 100), y = runif(100))
  sf_identical_x <- cast_df_to_sf(df_identical_x)

  expect_error(
    validate_arg_sf(
      df = sf_identical_x,
      function_name = "test_fn",
      check_coord_range = TRUE
    ),
    "All x coordinates are identical"
  )

  # Create data with identical y coordinates
  df_identical_y <- data.frame(x = runif(100), y = rep(0, 100))
  sf_identical_y <- cast_df_to_sf(df_identical_y)

  expect_error(
    validate_arg_sf(
      df = sf_identical_y,
      function_name = "test_fn",
      check_coord_range = TRUE
    ),
    "All y coordinates are identical"
  )
})

test_that("validate_arg_sf() skips coordinate range check when disabled", {
  # Create data with identical x coordinates
  df_identical_x <- data.frame(x = rep(0, 100), y = runif(100))
  sf_identical_x <- cast_df_to_sf(df_identical_x)

  # Should NOT error when check_coord_range = FALSE (default)
  result <- validate_arg_sf(
    df = sf_identical_x,
    function_name = "test_fn",
    check_coord_range = FALSE
  )

  expect_s3_class(result, "sf")
})

test_that("validate_arg_sf() includes function name in error messages", {
  # Test with different function names - check for hierarchical format
  expect_error(
    validate_arg_sf(df = NULL, function_name = "my_function"),
    "my_function"
  )

  expect_error(
    validate_arg_sf(df = NULL, function_name = "another_function"),
    "another_function"
  )

  expect_error(
    validate_arg_sf(df = NULL, function_name = "spatial_folds"),
    "spatial_folds"
  )
})

test_that("validate_arg_sf() errors on invalid input types", {
  # Matrix (not data.frame or sf)
  expect_error(
    validate_arg_sf(
      df = matrix(1:20, ncol = 2),
      function_name = "test_fn"
    ),
    "must be a data.frame"
  )

  # List (has no nrow, so fails with "has no rows" error)
  expect_error(
    validate_arg_sf(
      df = list(x = 1:10, y = 1:10),
      function_name = "test_fn"
    ),
    "has no rows"
  )
})

test_that("validate_arg_sf() errors when data.frame missing coordinate columns", {
  # Missing both x and y
  expect_error(
    validate_arg_sf(
      df = data.frame(a = 1:10, b = 1:10),
      function_name = "test_fn"
    ),
    "does not have recognizable coordinate columns"
  )

  # Missing y only
  expect_error(
    validate_arg_sf(
      df = data.frame(x = 1:10, z = 1:10),
      function_name = "test_fn"
    ),
    "does not have recognizable coordinate columns"
  )
})

test_that("validate_arg_sf() handles missing function_name with defaults", {
  data(xy_sf)

  # NULL function_name uses default - should still work
  result <- validate_arg_sf(df = xy_sf[1:10, ], function_name = NULL)
  expect_s3_class(result, "sf")

  # Non-character function_name uses default - should still work
  result <- validate_arg_sf(df = xy_sf[1:10, ], function_name = 123)
  expect_s3_class(result, "sf")
})

test_that("validate_arg_sf() handles alternate coordinate column names", {
  # longitude/latitude
  df_lonlat <- data.frame(longitude = runif(50), latitude = runif(50))
  result <- validate_arg_sf(df = df_lonlat, function_name = "test_fn")
  expect_s3_class(result, "sf")

  # lon/lat
  df_ll <- data.frame(lon = runif(50), lat = runif(50))
  result <- validate_arg_sf(df = df_ll, function_name = "test_fn")
  expect_s3_class(result, "sf")
})

test_that("validate_arg_sf() preserves sf geometry types", {
  data(xy_sf)

  # POINT geometry
  result <- validate_arg_sf(
    df = xy_sf[1:50, ],
    function_name = "test_fn"
  )

  expect_s3_class(result, "sf")
  expect_true(all(sf::st_geometry_type(result) == "POINT"))
})
