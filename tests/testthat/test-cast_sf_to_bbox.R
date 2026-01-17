test_that("cast_sf_to_bbox returns correct format", {
  df <- data.frame(x = c(0, 10), y = c(0, 5))
  df_sf <- cast_df_to_sf(df)

  result <- cast_sf_to_bbox(df_sf)

  expect_s3_class(result, "sf")
  expect_equal(nrow(result), 1)
  expect_true(inherits(sf::st_geometry(result)[[1]], "POLYGON"))
})

test_that("cast_sf_to_bbox calculates area (spherical or planar)", {
  # Create rectangle: 0-10 in x, 0-5 in y
  df <- data.frame(
    x = c(0, 10, 0, 10),
    y = c(0, 0, 5, 5)
  )
  df_sf <- cast_df_to_sf(df)

  bbox_sf <- cast_sf_to_bbox(df_sf)
  area <- as.numeric(sf::st_area(bbox_sf))

  # Area should be positive
  expect_true(area > 0)

  # If s2 is off, should be ~50 (degree squared)
  # If s2 is on, should be huge (square meters on sphere)
  # Just check it's reasonable for either case
  expect_true(area == 50 || area > 1e10)
})

test_that("cast_sf_to_bbox preserves CRS", {
  df <- data.frame(x = runif(10), y = runif(10))
  df_sf <- cast_df_to_sf(df)

  # cast_df_to_sf uses CRS 4326
  expect_equal(sf::st_crs(df_sf)$epsg, 4326)

  bbox_sf <- cast_sf_to_bbox(df_sf)

  # Bounding box should have same CRS
  expect_equal(sf::st_crs(bbox_sf)$epsg, 4326)
})

test_that("cast_sf_to_bbox handles single point", {
  # lwgeom required when s2 is disabled for st_area calculations
  skip_if_not_installed("lwgeom")

  # Temporarily disable s2 for degenerate geometry handling
  s2_was_enabled <- sf::sf_use_s2()
  sf::sf_use_s2(FALSE)
  on.exit(sf::sf_use_s2(s2_was_enabled), add = TRUE)

  df <- data.frame(x = 5, y = 10)
  df_sf <- cast_df_to_sf(df)

  bbox_sf <- cast_sf_to_bbox(df_sf)
  area <- as.numeric(sf::st_area(bbox_sf))

  # Single point should have zero area
  expect_equal(area, 0)
})

test_that("cast_sf_to_bbox validates inputs", {
  # NULL input
  expect_error(
    cast_sf_to_bbox(NULL),
    "cannot be NULL"
  )

  # Non-sf input
  df <- data.frame(x = 1:10, y = 1:10)
  expect_error(
    cast_sf_to_bbox(df),
    "must be an sf object"
  )

  # Empty sf - create valid sf then subset to empty
  df <- data.frame(x = 1:10, y = 1:10)
  df_sf <- cast_df_to_sf(df)
  expect_error(
    cast_sf_to_bbox(df_sf[0, ]),
    "has no rows"
  )
})
