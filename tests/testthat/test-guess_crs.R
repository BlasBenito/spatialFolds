test_that("guess_crs() returns 4326 for canonical lat/lon value ranges", {
  x <- c(-180, -90, 0, 90, 180)
  y <- c(-90, -45, 0, 45, 90)

  expect_message(result <- guess_crs(x, y), "EPSG:4326")
  expect_equal(result, 4326L)
  expect_type(result, "integer")
})

test_that("guess_crs() returns 4326 for typical geographic coordinates", {
  # Spain bounding box
  x <- c(-9.3, 4.3)
  y <- c(35.9, 43.8)

  expect_message(result <- guess_crs(x, y), "EPSG:4326")
  expect_equal(result, 4326L)
})

test_that("guess_crs() returns 4326 when column names are lat/lon regardless of small values", {
  x <- c(1, 2, 3)
  y <- c(4, 5, 6)

  expect_message(
    result <- guess_crs(x, y, x_name = "lon", y_name = "lat"),
    "column names"
  )
  expect_equal(result, 4326L)
})

test_that("guess_crs() column name confirmation works for all lat/lon name variants", {
  x <- c(1, 2)
  y <- c(3, 4)
  lat_lon_variants <- list(
    list(x_name = "longitude", y_name = "latitude"),
    list(x_name = "longitud",  y_name = "latitud"),
    list(x_name = "long",      y_name = "lat"),
    list(x_name = "lon",       y_name = "lat"),
    list(x_name = "LON",       y_name = "LAT"),
    list(x_name = "Longitude", y_name = "Latitude")
  )
  for (names in lat_lon_variants) {
    result <- suppressMessages(
      guess_crs(x, y, x_name = names$x_name, y_name = names$y_name)
    )
    expect_equal(result, 4326L, info = paste("x_name =", names$x_name))
  }
})

test_that("guess_crs() returns 3857 for Web Mercator scale values", {
  x <- c(-12000000, 0, 12000000)
  y <- c(-8000000, 0, 8000000)

  expect_message(result <- guess_crs(x, y), "EPSG:3857")
  expect_equal(result, 3857L)
  expect_type(result, "integer")
})

test_that("guess_crs() returns 3857 for values near Web Mercator extent boundaries", {
  x <- c(1100000, 20000000)
  y <- c(1100000, 15000000)

  result <- suppressMessages(guess_crs(x, y))
  expect_equal(result, 3857L)
})

test_that("guess_crs() returns NA_integer_ for typical UTM values", {
  x <- c(500000, 510000, 520000)
  y <- c(4500000, 4510000, 4520000)

  expect_message(result <- guess_crs(x, y), "could not be detected")
  expect_equal(result, NA_integer_)
})

test_that("guess_crs() returns NA_integer_ for values beyond the 3857 x range", {
  x <- c(25000000, 26000000)
  y <- c(10000000, 11000000)

  expect_message(result <- guess_crs(x, y), "could not be detected")
  expect_equal(result, NA_integer_)
})

test_that("guess_crs() returns NA_integer_ for values beyond the 3857 y range", {
  x <- c(5000000, 6000000)
  y <- c(21000000, 22000000)

  expect_message(result <- guess_crs(x, y), "could not be detected")
  expect_equal(result, NA_integer_)
})

test_that("guess_crs() always returns integer type", {
  result_4326 <- suppressMessages(guess_crs(c(1, 2), c(3, 4)))
  expect_type(result_4326, "integer")

  result_3857 <- suppressMessages(guess_crs(c(1e7, 2e7), c(5e6, 6e6)))
  expect_type(result_3857, "integer")

  result_na <- suppressMessages(guess_crs(c(500000, 510000), c(4500000, 4510000)))
  expect_equal(result_na, NA_integer_)
  expect_type(result_na, "integer")
})

test_that("guess_crs() works with single-point inputs", {
  expect_message(result <- guess_crs(x = 5, y = 45), "EPSG:4326")
  expect_equal(result, 4326L)
})
