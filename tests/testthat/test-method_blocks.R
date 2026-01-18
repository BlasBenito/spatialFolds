# Tests for method_blocks()
# Algorithm: Shuffle blocks, select complete blocks until target reached

test_that("blocks are selected as whole units (all or nothing)", {
  data(xy_sf)

  block_id <- block_ids(
    df = xy_sf,
    rows = 10,
    cols = 10
  )

  xy <- cast_sf_to_xy(df = xy_sf)

  result <- method_blocks(
    xy = xy,
    block_id = block_id,
    seed = 1,
    target = 15000
  )

  # For each unique block, either ALL points are selected or NONE are
  unique_blocks <- unique(block_id)
  for (block in unique_blocks) {
    mask <- block_id == block
    block_selection <- result[mask]
    expect_true(
      all(block_selection) || !any(block_selection),
      info = paste(
        "Block", block, "has mixed selection:",
        sum(block_selection), "of", sum(mask), "points selected"
      )
    )
  }
})

test_that("reproducibility: same seed produces identical results", {
  data(xy_sf)

  block_id <- block_ids(
    df = xy_sf,
    rows = 10,
    cols = 10
  )

  xy <- cast_sf_to_xy(df = xy_sf)

  result1 <- method_blocks(
    xy = xy,
    block_id = block_id,
    seed = 123,
    target = 15000
  )

  result2 <- method_blocks(
    xy = xy,
    block_id = block_id,
    seed = 123,
    target = 15000
  )

  expect_identical(result1, result2)
})

test_that("different seeds produce different results", {
  data(xy_sf)

  block_id <- block_ids(
    df = xy_sf,
    rows = 10,
    cols = 10
  )

  xy <- cast_sf_to_xy(df = xy_sf)

  result1 <- method_blocks(
    xy = xy,
    block_id = block_id,
    seed = 1,
    target = 15000
  )

  result2 <- method_blocks(
    xy = xy,
    block_id = block_id,
    seed = 999,
    target = 15000
  )

  expect_false(identical(result1, result2))
})

test_that("count meets or exceeds target (block granularity)", {
  data(xy_sf)

  block_id <- block_ids(
    df = xy_sf,
    rows = 10,
    cols = 10
  )

  xy <- cast_sf_to_xy(df = xy_sf)
  target <- 15000

  result <- method_blocks(
    xy = xy,
    block_id = block_id,
    seed = 1,
    target = target
  )

  # Sum should be >= target (may exceed due to block boundaries)
  expect_true(
    sum(result) >= target,
    info = paste("Selected", sum(result), "but target was", target)
  )
})

test_that("count matches sum of selected blocks' sizes", {
  data(xy_sf)

  block_id <- block_ids(
    df = xy_sf,
    rows = 10,
    cols = 10
  )

  xy <- cast_sf_to_xy(df = xy_sf)

  result <- method_blocks(
    xy = xy,
    block_id = block_id,
    seed = 42,
    target = 15000
  )

  # Calculate expected count from block sizes
  unique_blocks <- unique(block_id)
  block_sizes <- sapply(unique_blocks, function(b) sum(block_id == b))
  names(block_sizes) <- unique_blocks

  # Find which blocks were selected (all their points are TRUE)
  selected_blocks <- sapply(unique_blocks, function(b) {
    all(result[block_id == b])
  })

  expected_count <- sum(block_sizes[selected_blocks])
  actual_count <- sum(result)

  expect_equal(actual_count, expected_count)
})

test_that("edge case: all points in one block", {
  # Create a small dataset where all points have the same block ID
  n <- 100
  xy_small <- matrix(runif(n * 2), ncol = 2)
  colnames(xy_small) <- c("x", "y")
  block_id <- rep(0L, n)  # All in block 0

  result <- method_blocks(
    xy = xy_small,
    block_id = block_id,
    seed = 1,
    target = 50
  )

  # Either all selected or none (depending on block selection)
  # Since we want 50 out of 100 from a single block of 100,
  # the whole block should be selected
  expect_true(all(result) || !any(result))

  # With target 50 from a block of 100, the block should be selected
  expect_true(all(result))
})

test_that("edge case: target > n selects all points", {
  data(xy_sf)

  block_id <- block_ids(
    df = xy_sf,
    rows = 10,
    cols = 10
  )

  xy <- cast_sf_to_xy(df = xy_sf)
  n <- nrow(xy)

  result <- method_blocks(
    xy = xy,
    block_id = block_id,
    seed = 1,
    target = n + 1000
  )

  # Should select all points
  expect_equal(sum(result), n)
  expect_true(all(result))
})

test_that("output has correct length and type", {
  data(xy_sf)

  block_id <- block_ids(
    df = xy_sf,
    rows = 10,
    cols = 10
  )

  xy <- cast_sf_to_xy(df = xy_sf)
  n <- nrow(xy)

  result <- method_blocks(
    xy = xy,
    block_id = block_id,
    seed = 1,
    target = 15000
  )

  expect_equal(length(result), n)
  expect_true(is.logical(result))
})

test_that("different block configurations affect selection patterns", {
  data(xy_sf)

  xy <- cast_sf_to_xy(df = xy_sf)

  # Coarse grid (few large blocks)
  block_id_coarse <- block_ids(df = xy_sf, rows = 5, cols = 5)

  # Fine grid (many small blocks)
  block_id_fine <- block_ids(df = xy_sf, rows = 20, cols = 20)

  result_coarse <- method_blocks(
    xy = xy,
    block_id = block_id_coarse,
    seed = 1,
    target = 15000
  )

  result_fine <- method_blocks(
    xy = xy,
    block_id = block_id_fine,
    seed = 1,
    target = 15000
  )

  # Fine grid should allow closer approximation to target
  # because blocks are smaller
  coarse_diff <- abs(sum(result_coarse) - 15000)
  fine_diff <- abs(sum(result_fine) - 15000)

  # Fine grid should generally give closer match (not always guaranteed
  # but should be true on average with this data)
  expect_true(
    fine_diff <= coarse_diff + 1000,
    info = paste(
      "Fine grid diff:", fine_diff,
      "Coarse grid diff:", coarse_diff
    )
  )
})
