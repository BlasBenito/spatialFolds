test_that("cast_df_to_sf() works with standard x/y columns", {
  df <- data.frame(x = c(1, 2, 3), y = c(4, 5, 6))

  result <- suppressMessages(cast_df_to_sf(df))

  expect_s3_class(result, "sf")
  expect_equal(nrow(result), 3)
  expect_equal(sf::st_crs(result)$epsg, 4326)
})

test_that("cast_df_to_sf() works with lon/lat columns", {
  df <- data.frame(lon = c(1, 2, 3), lat = c(4, 5, 6))

  result <- suppressMessages(cast_df_to_sf(df))

  expect_s3_class(result, "sf")
  expect_equal(nrow(result), 3)
})

test_that("cast_df_to_sf() works with longitude/latitude columns", {
  df <- data.frame(longitude = c(1, 2, 3), latitude = c(4, 5, 6))

  result <- suppressMessages(cast_df_to_sf(df))

  expect_s3_class(result, "sf")
  expect_equal(nrow(result), 3)
})

test_that("cast_df_to_sf() works with long/lat columns", {
  df <- data.frame(long = c(1, 2, 3), lat = c(4, 5, 6))

  result <- suppressMessages(cast_df_to_sf(df))

  expect_s3_class(result, "sf")
  expect_equal(nrow(result), 3)
})

test_that("cast_df_to_sf() works with Spanish column names", {
  df <- data.frame(longitud = c(1, 2, 3), latitud = c(4, 5, 6))

  result <- suppressMessages(cast_df_to_sf(df))

  expect_s3_class(result, "sf")
  expect_equal(nrow(result), 3)
})

test_that("cast_df_to_sf() handles case-insensitive column names", {
  df <- data.frame(X = c(1, 2, 3), Y = c(4, 5, 6))

  result <- suppressMessages(cast_df_to_sf(df))

  expect_s3_class(result, "sf")
  expect_equal(nrow(result), 3)

  # Mixed case
  df2 <- data.frame(LoNgItUdE = c(1, 2, 3), LaTiTuDe = c(4, 5, 6))

  result2 <- suppressMessages(cast_df_to_sf(df2))

  expect_s3_class(result2, "sf")
})

test_that("cast_df_to_sf() returns sf input unchanged", {
  data(xy_sf)

  result <- cast_df_to_sf(xy_sf)

  expect_identical(result, xy_sf)
})

test_that("cast_df_to_sf() accepts explicit crs = 4326", {
  df <- data.frame(x = c(1, 2, 3), y = c(4, 5, 6))

  result <- cast_df_to_sf(df, crs = 4326)

  expect_s3_class(result, "sf")
  expect_equal(sf::st_crs(result)$epsg, 4326)
})

test_that("cast_df_to_sf() accepts custom CRS", {
  df <- data.frame(x = c(1, 2, 3), y = c(4, 5, 6))

  result <- cast_df_to_sf(df, crs = 3857)

  expect_s3_class(result, "sf")
  expect_equal(sf::st_crs(result)$epsg, 3857)
})

test_that("cast_df_to_sf() auto-detects EPSG:3857 for Web Mercator values", {
  df <- data.frame(
    x = c(-12000000, 0, 12000000),
    y = c(-8000000,  0,  8000000)
  )

  expect_message(result <- cast_df_to_sf(df), "EPSG:3857")
  expect_s3_class(result, "sf")
  expect_equal(sf::st_crs(result)$epsg, 3857)
})

test_that("cast_df_to_sf() returns NA CRS and emits message for UTM-range values", {
  df <- data.frame(
    x = c(500000, 510000, 520000),
    y = c(4500000, 4510000, 4520000)
  )

  expect_message(result <- cast_df_to_sf(df), "could not be detected")
  expect_s3_class(result, "sf")
  expect_true(is.na(sf::st_crs(result)))
})

test_that("cast_df_to_sf() explicit crs bypasses auto-detection entirely", {
  df <- data.frame(
    x = c(500000, 510000),
    y = c(4500000, 4510000)
  )
  # No message emitted when crs is supplied explicitly
  expect_no_message(result <- cast_df_to_sf(df, crs = 32630))
  expect_equal(sf::st_crs(result)$epsg, 32630)
})

test_that("cast_df_to_sf() validates df is data.frame", {
  # Matrix input
  mat <- matrix(1:6, ncol = 2)

  expect_error(
    cast_df_to_sf(mat),
    "must be a data.frame"
  )

  # List input
  lst <- list(x = 1:3, y = 4:6)

  expect_error(
    cast_df_to_sf(lst),
    "must be a data.frame"
  )
})

test_that("cast_df_to_sf() validates df has rows", {
  df_empty <- data.frame(x = numeric(0), y = numeric(0))

  expect_error(
    cast_df_to_sf(df_empty),
    "has no rows"
  )
})

test_that("cast_df_to_sf() validates crs parameter", {
  df <- data.frame(x = 1:3, y = 4:6)

  # Non-numeric crs
  expect_error(
    cast_df_to_sf(df, crs = "WGS84"),
    "must be NA or a single numeric EPSG code"
  )

  # Multiple crs values
  expect_error(
    cast_df_to_sf(df, crs = c(4326, 3857)),
    "must be NA or a single numeric EPSG code"
  )

  # NA crs is valid (explicit unknown CRS, no auto-detection)
  result <- cast_df_to_sf(df, crs = NA)
  expect_s3_class(result, "sf")
  expect_true(is.na(sf::st_crs(result)))
})

test_that("cast_df_to_sf() errors on missing coordinate columns", {
  df <- data.frame(a = 1:3, b = 4:6)

  expect_error(
    cast_df_to_sf(df),
    "does not have recognizable coordinate columns"
  )

  # Only x column
  df_x_only <- data.frame(x = 1:3, z = 4:6)

  expect_error(
    cast_df_to_sf(df_x_only),
    "does not have recognizable coordinate columns"
  )

  # Only y column
  df_y_only <- data.frame(a = 1:3, y = 4:6)

  expect_error(
    cast_df_to_sf(df_y_only),
    "does not have recognizable coordinate columns"
  )
})

test_that("cast_df_to_sf() warns about multiple coordinate column matches", {
  # Multiple x columns
  df_multi_x <- data.frame(x = 1:3, lon = 1:3, y = 4:6)

  expect_warning(
    suppressMessages(cast_df_to_sf(df_multi_x)),
    "Multiple x-coordinate columns found"
  )

  # Multiple y columns
  df_multi_y <- data.frame(x = 1:3, y = 4:6, lat = 4:6)

  expect_warning(
    suppressMessages(cast_df_to_sf(df_multi_y)),
    "Multiple y-coordinate columns found"
  )
})

test_that("cast_df_to_sf() validates coordinates are numeric", {
  # Character x column
  df_char_x <- data.frame(x = c("a", "b", "c"), y = 1:3)

  expect_error(
    cast_df_to_sf(df_char_x),
    "x-coordinate column .* must be numeric"
  )

  # Character y column
  df_char_y <- data.frame(x = 1:3, y = c("a", "b", "c"))

  expect_error(
    cast_df_to_sf(df_char_y),
    "y-coordinate column .* must be numeric"
  )
})

test_that("cast_df_to_sf() errors on NA coordinates", {
  # NA in x
  df_na_x <- data.frame(x = c(1, NA, 3), y = c(4, 5, 6))

  expect_error(
    cast_df_to_sf(df_na_x),
    "Coordinate columns contain NA values"
  )

  # NA in y
  df_na_y <- data.frame(x = c(1, 2, 3), y = c(4, NA, 6))

  expect_error(
    cast_df_to_sf(df_na_y),
    "Coordinate columns contain NA values"
  )
})

test_that("cast_df_to_sf() errors on NaN coordinates", {
  # Note: In R, is.na(NaN) returns TRUE, so NaN is caught by the NA check
  # This test verifies NaN values trigger an error (via NA check)
  df_nan_x <- data.frame(x = c(1, NaN, 3), y = c(4, 5, 6))

  expect_error(
    cast_df_to_sf(df_nan_x),
    "Coordinate columns contain NA values"
  )

  df_nan_y <- data.frame(x = c(1, 2, 3), y = c(4, NaN, 6))

  expect_error(
    cast_df_to_sf(df_nan_y),
    "Coordinate columns contain NA values"
  )
})

test_that("cast_df_to_sf() errors on Inf coordinates", {
  # Inf in x
  df_inf_x <- data.frame(x = c(1, Inf, 3), y = c(4, 5, 6))

  expect_error(
    cast_df_to_sf(df_inf_x),
    "Coordinate columns contain infinite values"
  )

  # -Inf in y
  df_inf_y <- data.frame(x = c(1, 2, 3), y = c(4, -Inf, 6))

  expect_error(
    cast_df_to_sf(df_inf_y),
    "Coordinate columns contain infinite values"
  )
})

test_that("cast_df_to_sf() preserves other columns", {
  df <- data.frame(
    x = c(1, 2, 3),
    y = c(4, 5, 6),
    name = c("a", "b", "c"),
    value = c(10, 20, 30)
  )

  result <- suppressMessages(cast_df_to_sf(df))

  expect_true("name" %in% colnames(result))
  expect_true("value" %in% colnames(result))
  expect_equal(result$name, c("a", "b", "c"))
  expect_equal(result$value, c(10, 20, 30))
})

test_that("cast_df_to_sf() creates correct point geometry", {
  df <- data.frame(x = c(1.5, 2.5), y = c(10.5, 20.5))

  result <- suppressMessages(cast_df_to_sf(df))

  coords <- sf::st_coordinates(result)

  expect_equal(as.numeric(coords[1, "X"]), 1.5)
  expect_equal(as.numeric(coords[1, "Y"]), 10.5)
  expect_equal(as.numeric(coords[2, "X"]), 2.5)
  expect_equal(as.numeric(coords[2, "Y"]), 20.5)
})
