test_that("cast_sf_to_xy() works with point geometry", {
  data(xy_sf)

  result <- cast_sf_to_xy(xy_sf)

  expect_true(is.matrix(result))
  expect_equal(ncol(result), 2)
  expect_equal(nrow(result), nrow(xy_sf))
  expect_equal(colnames(result), c("x", "y"))
  expect_true(is.numeric(result))
})

test_that("cast_sf_to_xy() handles data.frame input via validate_arg_sf", {
  # Data.frame input is now converted to sf via validate_arg_sf
  df <- data.frame(x = 1:10, y = 1:10)

  result <- cast_sf_to_xy(df)

  expect_true(is.matrix(result))
  expect_equal(ncol(result), 2)
  expect_equal(nrow(result), 10)
})

test_that("cast_sf_to_xy() validates unsupported input types", {
  # Matrix input - errors via cast_df_to_sf
  mat <- matrix(1:20, ncol = 2)

  expect_error(
    cast_sf_to_xy(mat),
    "must be a data.frame"
  )

  # NULL input
  expect_error(
    cast_sf_to_xy(NULL),
    "cannot be NULL"
  )
})

test_that("cast_sf_to_xy() validates df has rows", {
  data(xy_sf)

  empty_sf <- xy_sf[0, ]

  expect_error(
    cast_sf_to_xy(empty_sf),
    "has no rows"
  )
})

test_that("cast_sf_to_xy() handles POLYGON geometry via centroid", {
  # Create polygon sf
  polygon <- sf::st_polygon(list(matrix(
    c(0, 0, 1, 0, 1, 1, 0, 1, 0, 0),
    ncol = 2,
    byrow = TRUE
  )))
  polygon_sf <- sf::st_sf(
    id = 1,
    geometry = sf::st_sfc(polygon, crs = 4326)
  )

  suppressWarnings({
    result <- cast_sf_to_xy(polygon_sf)
  })

  expect_true(is.matrix(result))
  expect_equal(ncol(result), 2)
  expect_equal(nrow(result), 1)
  # Centroid of unit square should be approximately (0.5, 0.5)
  # Allow tolerance for s2 spherical geometry
  expect_equal(as.numeric(result[1, "x"]), 0.5, tolerance = 0.01)
  expect_equal(as.numeric(result[1, "y"]), 0.5, tolerance = 0.01)
})

test_that("cast_sf_to_xy() handles MULTIPOLYGON geometry via centroid", {
  # Create multipolygon sf
  poly1 <- sf::st_polygon(list(matrix(
    c(0, 0, 1, 0, 1, 1, 0, 1, 0, 0),
    ncol = 2,
    byrow = TRUE
  )))
  poly2 <- sf::st_polygon(list(matrix(
    c(2, 0, 3, 0, 3, 1, 2, 1, 2, 0),
    ncol = 2,
    byrow = TRUE
  )))

  multipoly <- sf::st_multipolygon(list(poly1, poly2))
  multipoly_sf <- sf::st_sf(
    id = 1,
    geometry = sf::st_sfc(multipoly, crs = 4326)
  )

  suppressWarnings({
    result <- cast_sf_to_xy(multipoly_sf)
  })

  expect_true(is.matrix(result))
  expect_equal(ncol(result), 2)
  expect_equal(nrow(result), 1)
})

test_that("cast_sf_to_xy() rejects unsupported geometry types", {
  # Create LINESTRING geometry
  line <- sf::st_linestring(matrix(c(0, 0, 1, 1), ncol = 2, byrow = TRUE))
  line_sf <- sf::st_sf(
    id = 1,
    geometry = sf::st_sfc(line, crs = 4326)
  )

  expect_error(
    cast_sf_to_xy(line_sf),
    "Unsupported geometry type"
  )
})

test_that("cast_sf_to_xy() returns correct coordinate values", {
  # Create sf with known coordinates
  df <- data.frame(x = c(1.5, 2.5, 3.5), y = c(10.1, 20.2, 30.3))
  df_sf <- cast_df_to_sf(df)

  result <- cast_sf_to_xy(df_sf)

  expect_equal(result[, "x"], c(1.5, 2.5, 3.5))
  expect_equal(result[, "y"], c(10.1, 20.2, 30.3))
})

test_that("cast_sf_to_xy() preserves coordinate precision", {
  data(xy_sf)

  # Get original coordinates
  original_coords <- sf::st_coordinates(xy_sf)

  result <- cast_sf_to_xy(xy_sf)

  # Check coordinates match
  expect_equal(result[, "x"], original_coords[, "X"])
  expect_equal(result[, "y"], original_coords[, "Y"])
})

test_that("cast_sf_to_xy() handles MULTIPOINT geometry", {
  # Create multipoint sf with known coordinates
  multipoint <- sf::st_multipoint(matrix(c(1, 2, 3, 4), ncol = 2, byrow = TRUE))
  multipoint_sf <- sf::st_sf(
    id = 1,
    geometry = sf::st_sfc(multipoint, crs = 4326)
  )

  result <- cast_sf_to_xy(multipoint_sf)

  expect_true(is.matrix(result))
  expect_equal(ncol(result), 2)
  # MULTIPOINT extracts all constituent points
  expect_true(nrow(result) >= 1)
})
