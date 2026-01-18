test_that("block_ids() works with valid inputs", {
  data(xy_sf)

  # Test 2x2 grid
  y <- block_ids(
    df = xy_sf,
    blocks = c(2, 2)
  )

  expect_equal(length(y), nrow(xy_sf))
  expect_true(is.integer(y))
  expect_equal(length(unique(y)), 4)
  expect_equal(max(y), 3)  # 0-based: 0, 1, 2, 3
  expect_equal(min(y), 0)  # Verify 0-based indexing

  # Test 10x10 grid
  y <- block_ids(
    df = xy_sf,
    blocks = c(10, 10)
  )

  expect_equal(length(y), nrow(xy_sf))
  expect_true(is.integer(y))
  expect_true(length(unique(y)) < 100)
  expect_true(max(y) < 100)
  expect_equal(max(table(y)), 1524)
})

test_that("block_ids() validates blocks parameter", {
  data(xy_sf)

  # Not numeric (character)
  expect_error(
    block_ids(df = xy_sf, blocks = "10"),
    "must be NULL, numeric"
  )

  # Wrong length (3 elements)
  expect_error(
    block_ids(df = xy_sf, blocks = c(2, 3, 4)),
    "must be NULL, an integer, or a length-2 vector"
  )

  # Single integer works (minimum enforced to 4)
  y <- block_ids(df = xy_sf, blocks = 10, quiet = TRUE)
  expect_true(is.integer(y))

  # Vector c(rows, cols) works (minimum 2 each)
  y <- block_ids(df = xy_sf, blocks = c(3, 4), quiet = TRUE)
  expect_true(is.integer(y))

  # NULL blocks (auto-computed) works
  y <- block_ids(df = xy_sf, blocks = NULL, quiet = TRUE)
  expect_true(is.integer(y))
})

test_that("block_ids() warns when grid has more cells than points", {
  data(xy_sf)
  n_points <- nrow(xy_sf)

  # Create grid with more cells than points
  rows <- ceiling(sqrt(n_points)) + 10
  cols <- ceiling(sqrt(n_points)) + 10

  expect_warning(
    block_ids(df = xy_sf, blocks = c(rows, cols)),
    "Grid has more cells .* than data points"
  )
})

test_that("block_ids() handles edge case with identical x coordinates", {
  # Create sf with all same x coordinate
  xy_identical_x <- data.frame(
    x = rep(0, 100),
    y = runif(100, 0, 10)
  )
  sf_identical_x <- cast_df_to_sf(xy_identical_x)

  # With new signature, identical x coordinates produce NaN in aspect ratio
  # which causes issues - expect an error
  expect_error(
    block_ids(df = sf_identical_x, blocks = c(2, 2))
  )
})

test_that("block_ids() handles edge case with identical y coordinates", {
  # Create sf with all same y coordinate
  xy_identical_y <- data.frame(
    x = runif(100, 0, 10),
    y = rep(0, 100)
  )
  sf_identical_y <- cast_df_to_sf(xy_identical_y)

  # With new signature, identical y coordinates produce Inf in aspect ratio
  # which causes issues - expect an error
  expect_error(
    block_ids(df = sf_identical_y, blocks = c(2, 2))
  )
})

test_that("block_ids() uses row-major ordering", {
  # Create simple 2x2 grid with 4 points at corners
  xy_corners <- data.frame(
    x = c(0, 1, 0, 1),  # left-left, right-right
    y = c(0, 0, 1, 1)   # top-top, bottom-bottom
  )
  sf_corners <- cast_df_to_sf(xy_corners)

  blocks <- block_ids(df = sf_corners, blocks = c(2, 2))

  # Row-major order: top-left=0, top-right=1, bottom-left=2, bottom-right=3
  # Points: (0,0)=top-left, (1,0)=top-right, (0,1)=bottom-left, (1,1)=bottom-right
  expect_equal(blocks[1], 0)  # (0,0) -> cell 0
  expect_equal(blocks[2], 1)  # (1,0) -> cell 1
  expect_equal(blocks[3], 2)  # (0,1) -> cell 2
  expect_equal(blocks[4], 3)  # (1,1) -> cell 3
})

test_that("block_ids() handles points on boundaries correctly", {
  # Create points exactly on grid boundaries
  xy_boundary <- data.frame(
    x = c(0, 0.5, 1.0, 0, 0.5, 1.0),
    y = c(0, 0, 0, 1.0, 1.0, 1.0)
  )
  sf_boundary <- cast_df_to_sf(xy_boundary)

  blocks <- block_ids(df = sf_boundary, blocks = c(2, 2))

  # All blocks should be valid (0-3)
  expect_true(all(blocks >= 0))
  expect_true(all(blocks <= 3))

  # Points on max boundaries should be assigned to last cells
  # Point at (1.0, 1.0) should be in cell 3 (bottom-right)
  expect_equal(blocks[6], 3)
})

test_that("block_ids() accepts numeric values that can be coerced to integer", {
  data(xy_sf)

  # Float values should be coerced to integer
  y <- block_ids(df = xy_sf, blocks = c(3.0, 3.0))

  expect_equal(length(y), nrow(xy_sf))
  expect_true(is.integer(y))
})

test_that("block_ids() returns all block IDs in valid range", {
  data(xy_sf)

  y <- block_ids(df = xy_sf, blocks = c(5, 5))

  # All IDs should be in range [0, 24]
  expect_true(all(y >= 0))
  expect_true(all(y < 25))
})
