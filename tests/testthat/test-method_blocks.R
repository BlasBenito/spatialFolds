test_that("method_blocks() works", {
  data(xy_sf)

  ids <- block_ids(
    df = xy_sf,
    rows = 10,
    cols = 10
  )

  xy <- cast_sf_to_xy(
    df = xy_sf
  )

  y <- method_blocks(
    xy = xy,
    block_id = ids,
    seed = 1,
    target = 15000
  )

  testthat::expect_true(
    is.logical(y)
  )

  testthat::expect_true(
    length(y) == nrow(xy)
  )

  testthat::expect_true(
    sum(y) >= 15000
  )
})
